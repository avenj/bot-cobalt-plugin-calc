package Bot::Cobalt::Plugin::Calc::Session;

use feature 'state';

use Config;

use Carp;
use strictures 2;

use Time::HiRes ();

use POE 'Wheel::Run', 'Filter::Reference';

sub TIMEOUT      () { 0 }
sub SESSID       () { 1 }
sub WHEELS       () { 2 }
sub REQUESTS     () { 3 }
sub TAG_BY_WID   () { 4 }
sub PENDING      () { 5 }
sub MAX_WORKERS  () { 6 }
sub RESULT_EVENT () { 7 }
sub ERROR_EVENT  () { 8 }

sub new {
  my ($class, %params) = @_;

  my $timeout = $params{timeout}     || 1;
  my $maxwrk  = $params{max_workers} || 2;

  my $result_event = $params{result_event} || 'calc_result';
  my $error_event  = $params{error_event}  || 'calc_error';
  
  bless [
    $timeout,       # TIMEOUT
    undef,          # SESSID
    +{},            # WHEELS
    +{},            # REQUESTS
    +{},            # TAG_BY_WID
    [],             # PENDING
    $maxwrk,        # MAX_WORKERS
    $result_event,  # RESULT_EVENT
    $error_event,   # ERROR_EVENT
  ], $class
}

sub start {
  my $self = shift;
  $self = $self->new(@_) unless ref $self;

  POE::Session->create(
    object_states => [
      $self => +{
        _start    => 'px_start',
        shutdown  => 'px_shutdown',
        cleanup   => 'px_cleanup',

        calc      => 'px_calc',
        push      => 'px_push',
        
        wheel_error     => 'px_wheel_error',
        worker_input    => 'px_worker_input',
        worker_stderr   => 'px_worker_stderr',
        worker_sigchld  => 'px_worker_sigchld',
      },
    ],
  );
}


sub px_start {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  $kernel->refcount_increment( $_[SESSION]->ID, 'Waiting for requests' );
}

sub px_shutdown {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  $kernel->call( $_[SESSION], 'px_cleanup' );
  $kernel->refcount_decrement( $_[SESSION]->ID, 'Waiting for requests' );
}

sub px_cleanup {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  for my $pid (keys %{ $self->[WHEELS] }) {
    if (my $wheel = delete $self->[WHEELS]->{$pid}) {
      $wheel->kill('TERM')
    }
  }
  $self->[TAG_BY_WID] = +{};
  $self->[PENDING]    = [];
}

sub px_calc {
  # calc => $expr, $hints
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  my ($expr, $hints)  = @_[ARG0, ARG1];
  my $sender_id = $_[SENDER]->ID;

  unless (defined $expr) {
    warn "'calc' event expected an EXPR and optional hints scalar";
    $kernel->post( $sender_id => $self->[ERROR_EVENT] =>
      "EXPR not defined",
      $hints // +{}
    );
  }

  state $p = [ 'a' .. 'z', 1 .. 9 ];
  my $tag = join '', map {; $p->[rand @$p] } 1 .. 3;
  $tag .= $p->[rand @$p] while exists $self->[REQUESTS]->{$tag};

  my $pending = +{
    expr      => $expr,
    tag       => $tag,
    hints     => ($hints // +{}),
    sender_id => $sender_id,
  };

  $self->[REQUESTS]->{$tag} = $pending;
  push @{ $self->[PENDING] }, $pending;
  $kernel->yield('push');
}

sub px_push {
  my ($kernel, $self) = @_[KERNEL, OBJECT];

  return unless @{ $self->[PENDING] };

  if (keys %{ $self->[WHEELS] } >= $self->[MAX_WORKERS]) {
    $kernel->delay( push => 0.5 );
    return
  }

  my $wheel = $self->_create_wheel;

  my $next  = shift @{ $self->[PENDING] };
  my $tag = $next->{tag};
  $self->[TAG_BY_WID]->{ $wheel->ID } = $tag;

  $wheel->put(
    [ $next->{tag}, $next->{expr}, $next->{timeout} ]
  );
}

sub _create_wheel {
  my ($self) = @_;
  
  my $ppath = $Config{perlpath};
  if ($^O ne 'VMS') {
    $ppath .= $Config{_exe} unless $ppath =~ m/$Config{_exe}$/i;
  }
  
  my $forkable;
  if ($^O eq 'MSWin32') {
    require Bot::Cobalt::Plugin::Calc::Worker;
    $forkable = \&Bot::Cobalt::Plugin::Calc::Worker::worker
  } else {
    $forkable = [
      $ppath,
      (map {; '-I'.$_ } @INC),
      '-MBot::Cobalt::Plugin::Calc::Worker',
      '-e',
      'Bot::Cobalt::Plugin::Calc::Worker->worker'
    ]
  }

  my $wheel = POE::Wheel::Run->new(
    CloseOnCall => 1,
    Program     => $forkable,
    StdioFilter => POE::Filter::Reference->new,
    ErrorEvent  => 'wheel_error',
    StderrEvent => 'worker_stderr',
    StdoutEvent => 'worker_input',
  );

  my $pid = $wheel->PID;
  $poe_kernel->sig_child($pid, 'worker_sigchld');
  $self->[WHEELS]->{$pid} = $wheel;

  $wheel
}

sub px_wheel_error {
  my ($op, $errnum, $errstr, $wid) = @_[ARG0 .. $#_];
  $errstr = 'remote end closed' if $op eq 'read' and not $errnum;
  warn "wheel '$wid' err: '$op': $errstr ($errnum)"
}

sub px_worker_input {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  
  my ($input, $wid) = @_[ARG0, ARG1];
  my ($tag, $result) = @$input;
  
  my $req = delete $self->[REQUESTS]->{$tag};
  unless ($req) {
    warn "BUG? worker input but no request found for tag '$tag'";
    return
  }
  
  $kernel->post( $req->{sender_id} => $self->[RESULT_EVENT] =>
    $result, $req->{hints} 
  )
}

sub px_worker_stderr {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  my ($input, $wid) = @_[ARG0, ARG1];
  my $tag = $self->[TAG_BY_WID]->{$wid};
  unless (defined $tag) {
    warn "BUG? px_worker_stderr but no tag for wheel ID '$wid'";
  }
  my $req = delete $self->[REQUESTS]->{$tag};
  if (defined $req) {
    my $sender_id = $req->{sender_id};
    my $hintshash = $req->{hints};
    $kernel->post( $req->{sender_id} => $self->[ERROR_EVENT] =>
      "worker '$wid' stderr: $input"
    )
  } else {
    warn "stderr from worker but request unavailable: $input"
  }
}

sub px_worker_sigchld {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  my $pid = $_[ARG1];
  my $wheel = delete $self->[WHEELS]->{$pid};
  unless (defined $wheel) {
    warn "px_worker_sigchld but no wheel for pid '$pid' found";
    return
  }
  unless (delete $self->[TAG_BY_WID]->{ $wheel->ID }) {
    warn "BUG? px_worker_sigchld found wheel but no tag for pid '$pid'";
  }
  $kernel->yield('px_push')
}


1;

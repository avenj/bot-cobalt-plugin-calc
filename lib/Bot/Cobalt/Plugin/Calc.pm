package Bot::Cobalt::Plugin::Calc;

use strictures 2;

use Bot::Cobalt;
use Bot::Cobalt::Common;

use Math::Calc::Parser ();

sub new { bless [], shift }

sub Cobalt_register {
  my ($self, $core) = splice @_, 0, 2;
  register( $self, SERVER => 'public_cmd_calc' );
  logger->info("Loaded: calc");
  PLUGIN_EAT_NONE
}

sub Cobalt_unregister {
  my ($self, $core) = splice @_, 0, 2;
  logger->info("Unloaded");  
  PLUGIN_EAT_NONE
}

sub Bot_public_cmd_calc {
  my ($self, $core) = splice @_, 0, 2;
  my $msg     = ${ $_[0] };
  
  my $msgarr  = $msg->message_array;
  my $calcstr = join ' ', @$msgarr;
  my $result  = Math::Calc::Parser->try_evaluate($calcstr);

  my $reply = defined $result ? $result : "err: ".Math::Calc::Parser->error;

  broadcast( message => $msg->context, $msg->channel,
    $msg->src_nick . ": $reply"
  );
  
  PLUGIN_EAT_NONE
}


1;
__END__

=pod

=head1 NAME

Bot::Cobalt::Plugin::Calc - Calculator plugin for Bot::Cobalt

=head1 SYNOPSIS

  # See Math::Calc::Parser ->
  !calc 2 + 2
  !calc 0xff << 2
  !calc int rand 5

=head1 DESCRIPTION

A L<Bot::Cobalt> calculator plugin using L<Math::Calc::Parser>.

See the L<Math::Calc::Parser> documentation for details.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

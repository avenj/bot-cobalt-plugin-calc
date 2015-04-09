package Bot::Cobalt::Plugin::Calc::Worker;

use BSD::Resource;

use strict;
use bytes;

use Storable 'nfreeze', 'thaw';

use Math::Calc::Parser;

use Time::HiRes 'alarm';  # may fail on some systems ...

$SIG{INT} = sub { die "Timed out!\n" };

sub worker {
  binmode *STDOUT; binmode *STDIN;
  select *STDOUT;
  $|++;

  my $limit_bytes = 16 * 1024 * 1024;  # 16mb limit
 
  setrlimit(RLIMIT_DATA, $limit_bytes, $limit_bytes);
  setrlimit(RLIMIT_STACK, $limit_bytes, $limit_bytes);
  setrlimit(RLIMIT_NPROC, 1, 1);
  setrlimit(RLIMIT_NOFILE, 0, 0);
  setrlimit(RLIMIT_OFILE, 0, 0);
  setrlimit(RLIMIT_OPEN_MAX, 0, 0);
  setrlimit(RLIMIT_LOCKS, 0, 0);
  setrlimit(RLIMIT_AS, $limit_bytes, $limit_bytes);
  setrlimit(RLIMIT_VMEM, $limit_bytes, $limit_bytes);
  setrlimit(RLIMIT_MEMLOCK, 100, 100);
  setrlimit(RLIMIT_CPU, 10, 10);

  my ($buf, $read_bytes) = '';
  while (1) {
    if (defined $read_bytes) {
      if (length $buf >= $read_bytes) {
        my $input = thaw( substr($buf, 0, $read_bytes, '') );
        $read_bytes = undef;

        my ($tag, $expr, $timeout) = @$input;

        my $result = Math::Calc::Parser->try_evaluate($expr);

        $result //= "err: ".Math::Calc::Parser->error;

        my $frozen = nfreeze( [ $tag, $result ] );
        my $stream  = length($frozen) . chr(0) . $frozen ;
        my $written = syswrite(STDOUT, $stream);
        die $! unless $written == length $stream;
        exit 0
      }
    } elsif ($buf =~ s/^(\d+)\0//) {
      $read_bytes = $1;
      next
    }

    my $readb = sysread(STDIN, $buf, 4096, length $buf);
    last unless $readb;
  }

  exit 0
}

1;

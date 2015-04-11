package Bot::Cobalt::Plugin::Calc::Worker;

use strict;
use bytes;

use BSD::Resource qw/
  setrlimit

  RLIMIT_DATA
  RLIMIT_STACK
  RLIMIT_AS
  RLIMIT_VMEM
  RLIMIT_CPU
/;

use Storable 'nfreeze', 'thaw';

use Math::Calc::Parser ();

sub MEMLIMIT_BYTES () {  64 * 1024 * 1024 }

$SIG{INT} = sub { die "Timed out!\n" };

sub worker {
  binmode *STDOUT; binmode *STDIN;
  select *STDOUT;
  $|++;
 
  # not error-checked, may fail silently on some platforms ...
  setrlimit(RLIMIT_DATA, MEMLIMIT_BYTES, MEMLIMIT_BYTES);
  setrlimit(RLIMIT_STACK, MEMLIMIT_BYTES, MEMLIMIT_BYTES);
  setrlimit(RLIMIT_AS, MEMLIMIT_BYTES, MEMLIMIT_BYTES);
  setrlimit(RLIMIT_VMEM, MEMLIMIT_BYTES, MEMLIMIT_BYTES);
  setrlimit(RLIMIT_CPU, 10, 10);

  my ($buf, $read_bytes) = '';
  while (1) {
    if (defined $read_bytes) {
      if (length $buf >= $read_bytes) {
        my $input = thaw substr $buf, 0, $read_bytes, '';
        $read_bytes = undef;

        my ($tag, $expr) = @$input;

        my $result = Math::Calc::Parser->try_evaluate($expr);
        $result //= "err: ".Math::Calc::Parser->error;

        my $frozen = nfreeze [ $tag, $result ];
        my $stream  = length($frozen) . chr(0) . $frozen ;
        die $! unless syswrite(*STDOUT, $stream) == length $stream;
        exit 0
      }
    } elsif ($buf =~ s/^(\d+)\0//) {
      $read_bytes = $1;
      next
    }

    my $readb = sysread *STDIN, $buf, 4096, length $buf;
    last unless $readb;
  }

  exit 0
}

1;

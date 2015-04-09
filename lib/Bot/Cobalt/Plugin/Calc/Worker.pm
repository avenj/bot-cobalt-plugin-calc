package Bot::Cobalt::Plugin::Calc::Worker;

use strict;
use bytes;

use Storable 'nfreeze', 'thaw';

use Math::Calc::Parser;

use Time::HiRes 'alarm';  # may fail on some systems ...

sub worker {
  binmode *STDOUT; binmode *STDIN;
  select *STDOUT;
  $|++;

  my ($buf, $read_bytes) = '';
  while (1) {
    if (defined $read_bytes) {
      if (length $buf >= $read_bytes) {
        my $input = thaw( substr($buf, 0, $read_bytes, '') );
        $read_bytes = undef;

        my ($tag, $expr, $timeout) = @$input;

        $SIG{ALRM} = sub { die "Timed out!\n" };
        alarm $timeout;
        my $result = Math::Calc::Parser->try_evaluate($expr);
        alarm 0;

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

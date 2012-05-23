package Bot::Cobalt::Plugin::Calc::Parser;

use strict;
use warnings;

use base 'Parser::MGC';

sub parse {
  my ($self) = @_;
  return $self->parse_low;  
}

sub parse_low {
  my ($self) = @_;
  my $value = $self->parse_high;
  1 while $self->any_of(
    sub {
      $self->expect("+");
      $self->commit;
      $value += $self->parse_high;
      1;
    },
    sub {
      $self->expect("-");
      $self->commit;
      $value -= $self->parse_high;
      1;
    },
    sub { 0 },
  );
  return $value;
}

sub parse_high {
  my ($self) = @_;
  my $value = $self->parse_chunk;
  1 while $self->any_of(
    sub {
      $self->expect("^");
      $self->commit;
      $value = $value ** $self->parse_chunk;
      1;
    },
    sub { 
      $self->expect("*"); 
      $self->commit; 
      $value *= $self->parse_chunk;
      1;
    },
    sub {
      $self->expect("/");
      $self->commit;
      $value /= $self->parse_chunk;
      1;
    },
    sub { 0 },
  );
  
  return $value
}

sub token_oct {
  my $self = shift;
  $self->generic_token( 
    oct => qr/^0\d+/, sub { 
      eval { 
        use warnings FATAL => 'all' ; no warnings 'void' ; 
        oct $_[1] 
      };
      die "Not a valid oct" if $@;
      oct $_[1]
    }
  );
}

sub parse_chunk {
  my ($self) = @_;
  $self->any_of(
    sub { $self->scope_of(
        "(", sub { $self->commit; $self->parse }, ")"
      )
    },
    sub { $self->token_oct },
    sub { $self->token_number },
  );
}
1;

package Cobalt::Plugin::Calc::Parser::MGC;
## essentially same as example included w/ Parser::MGC

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

sub parse_chunk {
  my ($self) = @_;
  $self->any_of(
    sub { $self->scope_of(
        "(", sub { $self->commit; $self->parse }, ")"
      )
    },
    sub { $self->token_number },
  );
}
1;

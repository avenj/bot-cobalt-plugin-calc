package Cobalt::Plugin::Calc::Parser::RPN;

## Stateful parser with a stack
##  my $rpn = Cobalt::Plugin::Calc::Parser::RPN->new;
##  my $current = $rpn->stack_current($stackID);
## push a number or calculation to the stack:
##  my $current = $rpn->calc($stackID, "2");
##  my $current = $rpn->calc($stackID, "2 3 4 * -")
## clear the stack:
##  my $current = $rpn->stack_clear($stackID);

use strict;
use warnings;

use base 'Parser::MGC';

sub calc {
  my ($self, $stackid, $str) = @_;
  
  ## FIXME parse this str
  ##  numbers go on stack (..max stack size?)
  ##   if parser hits an operator, run appropriate operation 
  ##   against respective stack values per rpn rules
  ##  
  ##  use 'p(rint)' to print stack
}

sub is_stack_sized {
  ## find out if we can calc (is there a stack?)
}

sub stack_new {
  my ($self, $stackname) = @_;
}

sub stack_clear {
  my ($self, $stackname) = @_;
}

sub stack_current {
  my ($self, $stackname) = @_;
}

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

package Bot::Cobalt::Plugin::Calc::Parser::RPN;

## FIXME

## Stateful parser with a stack
##  my $rpn = Bot::Cobalt::Plugin::Calc::Parser::RPN->new;
##  my $current = $rpn->stack_current($stackID);
## push a number or calculation to the stack:
##  my $current = $rpn->calc($stackID, "2");
##  my $current = $rpn->calc($stackID, "2 3 4 * -")
## clear the stack:
##  my $current = $rpn->stack_clear($stackID);

use strict;
use warnings;

#use base 'Parser::MGC';

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

1;

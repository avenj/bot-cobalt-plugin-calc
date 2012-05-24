use Test::More tests => 6;

use_ok( 'Bot::Cobalt::Plugin::Calc::Parser' );
my $calc = Bot::Cobalt::Plugin::Calc::Parser->new;
isa_ok( $calc, 'Bot::Cobalt::Plugin::Calc::Parser' );

is( $calc->from_string("2+2"), 4, 'Addition' );
is( $calc->from_string("4-2"), 2, 'Subtraction' );
is( $calc->from_string("4*4"), 16, 'Multiplication' );
is( $calc->from_string("12/3"), 4, 'Division' );

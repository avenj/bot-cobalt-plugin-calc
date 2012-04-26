use Test::More tests => 6;

use_ok( 'Bot::Cobalt::Plugin::Calc::Parser::MGC' );
my $calc = Bot::Cobalt::Plugin::Calc::Parser::MGC->new;
isa_ok( $calc, 'Bot::Cobalt::Plugin::Calc::Parser::MGC' );

ok( $calc->from_string("2.1+2.3") == '4.4', 'Addition' );
ok( $calc->from_string("4.2-2.2") == 2, 'Subtraction' );
ok( $calc->from_string("4.2*4.2") == '17.64', 'Multiplication' );
ok( $calc->from_string("12.5/6.25") == 2, 'Division' );

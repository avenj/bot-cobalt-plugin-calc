use Test::More tests => 3;

use_ok( 'Cobalt::Plugin::Calc::Parser::MGC' );
my $calc = Cobalt::Plugin::Calc::Parser::MGC->new;
isa_ok( $calc, 'Cobalt::Plugin::Calc::Parser::MGC' );

ok( $calc->from_string("((2+2)*(2+2))/4") == 4, 'Groups' );

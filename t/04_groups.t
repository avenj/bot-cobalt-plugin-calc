use Test::More tests => 3;

use_ok( 'Bot::Cobalt::Plugin::Calc::Parser' );
my $calc = Bot::Cobalt::Plugin::Calc::Parser->new;
isa_ok( $calc, 'Bot::Cobalt::Plugin::Calc::Parser' );

ok( $calc->from_string("((2+2)*(2+2))/4") == 4, 'Groups' );

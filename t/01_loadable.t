use Test::More tests => 6;

BEGIN {
  use_ok( 'Bot::Cobalt::Plugin::Calc::Parser' );
  use_ok( 'Bot::Cobalt::Plugin::Calc' );
}

new_ok( 'Bot::Cobalt::Plugin::Calc::Parser' );
can_ok( 'Bot::Cobalt::Plugin::Calc::Parser', 'from_string' );

new_ok( 'Bot::Cobalt::Plugin::Calc' );
can_ok( 'Bot::Cobalt::Plugin::Calc', 'Cobalt_register', 'Cobalt_unregister' );

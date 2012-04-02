use Test::More tests => 6;

BEGIN {
  use_ok( 'Cobalt::Plugin::Calc::Parser::MGC' );
  use_ok( 'Cobalt::Plugin::Calc' );
}

new_ok( 'Cobalt::Plugin::Calc::Parser::MGC' );
can_ok( 'Cobalt::Plugin::Calc::Parser::MGC', 'from_string' );

new_ok( 'Cobalt::Plugin::Calc' );
can_ok( 'Cobalt::Plugin::Calc', 'Cobalt_register', 'Cobalt_unregister' );

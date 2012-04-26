#!/usr/bin/env perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
  module_name => 'Bot::Cobalt::Plugin::Calc',
  dist_abstract => 'Calculator plugin for Cobalt',
  dist_author  => 'Jon Portnoy <avenj@cobaltirc.org>',

  license => 'perl',
  
  create_makefile_pl => 'small',
  
  create_readme => 1,
  
  requires => {
    'perl' => '5.10.1',

    'Bot::Cobalt::Core'       => 0,
    'Bot::Cobalt::Serializer' => 0,
    'Bot::Cobalt::Common'     => 0,

    'Parser::MGC' => '0.10',
  },
  
  recommends => {
  },
);

$build->create_build_script;

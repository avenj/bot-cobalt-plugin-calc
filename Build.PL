#!/usr/bin/env perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
  module_name => 'Cobalt::Plugin::Calc',
  dist_abstract => 'Calculator plugin for Cobalt',
  dist_author  => 'Jon Portnoy <avenj@cobaltirc.org>',

  license => 'perl',
  
  create_makefile_pl => 'small',
  
  create_readme => 1,
  
  requires => {
    'perl' => '5.10.1',

    'Cobalt::Core'       => 0,
    'Cobalt::Serializer' => 0,
    'Cobalt::Common'     => 0,

    'Parser::MGC' => '0.10',
  },
  
  recommends => {
  },
);

$build->create_build_script;

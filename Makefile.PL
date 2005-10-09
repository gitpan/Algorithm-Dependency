#!/usr/bin/perl

use inc::Module::Install;

name           ( 'Algorithm-Dependency'        );
abstract       ( 'Toolkit for implementing dependency systems');
author         ( 'Adam Kennedy <cpan@ali.as>'  );
version_from   ( 'lib/Algorithm/Dependency.pm' );
license        ( 'perl'                        );

requires       ( 'perl'             => '5.005' );
requires       ( 'Params::Util'     => '0.06'  );

# Test deps, including the less common ones
build_requires ( 'Test::More'       => '0.47'  );
build_requires ( 'File::Spec'       => '0.82'  );
build_requires ( 'Test::ClassAPI'   => '0.6'   );
include        ( 'Test::ClassAPI'              );
include        ( 'Class::Inspector'            );
auto_install   ();

&WriteAll;

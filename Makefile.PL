#!/usr/bin/perl
use 5.006;
use inc::Module::Install;

name            'Module-ScanDeps';
all_from        'lib/Module/ScanDeps.pm';

requires        'File::Temp'                => '0';
requires        'File::Spec'                => '0';
requires        'Module::Build::ModuleInfo' => '0';
requires        'version'                   => '0';
build_requires  'Test::More'                => '0';

install_script  'script/scandeps.pl';
#sign;
WriteAll;

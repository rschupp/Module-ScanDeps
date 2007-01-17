#!/usr/bin/perl
use inc::Module::Install;

name            'Module-ScanDeps';
all_from        'lib/Module/ScanDeps.pm';

requires        'File::Temp' => '0';
requires        'File::Spec' => '0';

install_script  'script/scandeps.pl';
sign; WriteAll;

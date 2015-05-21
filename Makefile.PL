#!/usr/bin/perl
use strict;
use inc::Module::Install 1.00;

name            'Module-ScanDeps';
all_from        'lib/Module/ScanDeps.pm';
repository      'https://www.openfoundry.org/svn/par/Module-ScanDeps/trunk';
license         'perl';

perl_version    '5.008001';
requires        'File::Temp'                => '0';
requires        'File::Spec'                => '0';
requires        'Getopt::Long'              => '0';
requires        'Module::Metadata'          => '0';
requires        'Text::ParseWords'          => '0';
requires        'version'                   => '0';
test_requires   'Test::More'                => '0';
test_requires   'Test::Requires'            => '0';

install_script  'script/scandeps.pl';

no_index        package => qw( Module::ScanDeps::Cache 
                               Module::ScanDeps::DataFeed );

WriteAll;

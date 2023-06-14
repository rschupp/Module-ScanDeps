#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
use Test::Requires qw( prefork );

use lib 't';
use Utils;

##############################################################
# Tests compilation of Module::ScanDeps
##############################################################
BEGIN { use_ok( 'Module::ScanDeps' ); }

##############################################################
# Tests static dependency scanning with the prefork module.
# This was broken until Module::ScanDeps 0.85
##############################################################
my $root = $0;

use prefork "less";

my @deps = qw(
    Carp.pm   Config.pm	  Exporter.pm 
    Test/More.pm  strict.pm   vars.pm
    prefork.pm less.pm
);

# Functional i/f
my $rv = scan_deps($root);
check_rv($rv, [$0], \@deps);

__END__

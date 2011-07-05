#!/usr/bin/perl

use strict;
use warnings;

use lib 't';
BEGIN {
  require Test::More;
  if (not eval "require prefork; 1;" or $@) {
    Test::More->import(skip_all => "This test requires prefork.pm which is not installed. Skipping.");
    exit(0);
  }
  else {
    # Mwuahahaha!
    delete $INC{"prefork.pm"};
    %prefork:: = ();
  }
}
use Test::More qw(no_plan); # no_plan because the number of objects in the dependency tree (and hence the number of tests) can change
use Utils;

my $rv;
my $root;

##############################################################
# Tests compilation of Module::ScanDeps
##############################################################
BEGIN { use_ok( 'Module::ScanDeps' ); }

##############################################################
# Tests static dependency scanning with the prefork module.
# This was broken until Module::ScanDeps 0.85
##############################################################
$root = $0;

use prefork "less";

my @deps = qw(
    Carp.pm   Config.pm	  Exporter.pm 
    Test/More.pm  strict.pm   vars.pm
    prefork.pm less.pm
);

# Functional i/f
$rv = scan_deps($root);
generic_scandeps_rv_test($rv, [$0], \@deps);

__END__

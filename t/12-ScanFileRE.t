#!/usr/bin/perl

use strict;
use warnings;
use File::Temp;

use Test::More tests => 5;
use lib 't/data/ScanFileRE';

BEGIN { use_ok( 'Module::ScanDeps' ); }

# Test that ScanFileRE is applied to the input files
my ($fh, $filename) = File::Temp::tempfile( UNLINK => 1, SUFFIX => '.na' );
ok($filename !~ $Module::ScanDeps::ScanFileRE, "ScanFileRE is accessible outside Module::ScanDeps");
die "$filename must not match ScanFileRE for the following test to make sense" if $filename =~ $Module::ScanDeps::ScanFileRE;
my $rv = scan_deps(files => [$filename]);
ok(
    !(scalar grep { /\Q$filename\E/ } keys %$rv),
    "ScanFileRE removed matching input files"
);

# The next two tests rely on t/data/ScanFileRE/auto/example/example.h using t/data/ScanFileRE/example_too.pm

# Test that the default ScanFileRE is applied to the used files
$rv = scan_deps(files => ['t/data/ScanFileRE/example.pm'], recurse => 1);
ok(
    !(scalar grep { /example_too\.pm/ } keys %$rv),
    "ScanFileRE only scanned matching files in the dependency tree"
);

# Test that ScanFileRE can be changed to now pick up all files in the dependency tree
$Module::ScanDeps::ScanFileRE = qr/.*/;
$rv = scan_deps(files => ['t/data/ScanFileRE/example.pm'], recurse => 1);
ok(
    (scalar grep { /example_too\.pm/ } keys %$rv),
    "M::SD recognised the new ScanFileRE and scanned all files in the dependency tree"
);

__END__

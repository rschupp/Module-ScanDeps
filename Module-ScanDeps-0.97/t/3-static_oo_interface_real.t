#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 12;

my $rv;
my $root;

##############################################################
# Tests compilation of Module::ScanDeps
##############################################################
BEGIN { use_ok( 'Module::ScanDeps' ); }


##############################################################
# Tests static dependency scanning on a real set of modules.
# This exercises the scanning functionality but because the
# majority of files scanned aren't fixed, the checks are
# necessarily loose.
##############################################################
$root = $0;
my @deps = qw(
    Carp.pm Config.pm	Exporter.pm Test/More.pm
    base.pm constant.pm	strict.pm   vars.pm
    Module/ScanDeps.pm
);

my $obj = Module::ScanDeps->new;
$obj->set_file($0);
$obj->calculate_info;
ok($rv = $obj->get_files);

foreach my $mod (@deps) {
    ok(grep {$_->{store_as} eq $mod } @{$rv->{modules}});
};

use File::Basename qw/basename/;
my $basename = basename($0);
ok(not(grep {$_->{store_as} =~ /\Q$basename\E/} @{$rv->{modules}})); 
__END__

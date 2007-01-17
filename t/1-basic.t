#!/usr/bin/perl

use Test;
BEGIN { plan tests => 20 }

my @deps = qw(
    Carp.pm Config.pm	Exporter.pm Test.pm
    base.pm constant.pm	strict.pm   vars.pm
    Module/ScanDeps.pm
);

use Module::ScanDeps;
ok(1);

my $rv = scan_deps($0);
ok(exists $rv->{$_}) foreach @deps;

my $obj = Module::ScanDeps->new;
$obj->set_file($0);
$obj->calculate_info;
ok($rv = $obj->get_files);

foreach my $mod (@deps) {
    ok(grep {$_->{store_as} eq $mod } @{$rv->{modules}});
};

__END__

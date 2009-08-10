#!/usr/bin/perl

use strict;
use warnings;

use lib 't';
use vars qw/%INC/;
use File::Temp;
use Test::More;
use Cwd;
use Data::Dumper;
use Config qw/%Config/;

BEGIN {
  plan('skip_all', 'Cwd is builtin on OS/2') if $^O eq 'os2';
  plan(tests => 3);
}

# Tests that scan_deps finds the shared library associated
# with an XS module (example: Cwd) both when scanned as a
# dependency and directly as the specified user code/file.

BEGIN { use_ok( 'Module::ScanDeps' ); }

my $cwd_file = $INC{"Cwd.pm"};
my $code = "use Cwd;\n";
my $dl_ext = $Config{dlext};

my ($fh, $filename) = File::Temp::tempfile( UNLINK => 1, SUFFIX => '.pl' );
print $fh $code, "\n" or die $!;
close $fh;

my $rv = scan_deps(files => [$filename]);
#print Dumper $rv;

ok(
    (grep { /\bCwd\.$dl_ext$/ } keys %$rv),
    "Found shared library when module is scanned as dependency."
);

$rv = scan_deps(files => [$cwd_file]);
#print Dumper $rv;

if (not -f $cwd_file) {
    fail("Could not determine the location of the Cwd.pm file. Can't run all tests.");
}
else {
    ok(
        (grep { /\bCwd\.$dl_ext$/ } keys %$rv),
        "Found shared library when module is scanned as user code / script."
    );
}

__END__

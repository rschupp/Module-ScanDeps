#!perl

use strict;
use Test::More;
use Config ();

use Module::ScanDeps;
use Cwd;
use File::Glob;

my $extra = '';	
my $cwd_bundle_path = $INC{ 'Cwd.pm' } || $INC{ 'File/Glob.pm' };

if ($^O eq 'os2' or  # Cwd is builtin in perl*.dll; DLLs have checksum appended
    Cwd->VERSION<2.08 #2.08 has dll, 2.04 does not
) {
    $extra = '\w\w|Glob\w\w' ;  # So use a different dyna module
    $cwd_bundle_path = $INC{ 'File/Glob.pm' };
}

unless( $Config::Config{usedl} ){
    plan('skip_all', 'Sorry, no dynamic loading');
}

plan(tests => 1 + 2*2);

ok($cwd_bundle_path, 'Path for Cwd.pm or File/Glob.pm found');


sub check_bundle_path {
    my $rv = scan_deps_runtime(@_);
    my ( $entry ) =  grep { /^auto\b.*\b(Cwd$extra)\.$Config::Config{dlext}/ } keys %$rv;
    ok( $entry, 'we have some key that looks like it pulled in the Cwd or Glob shared lib' );


    # Build a path the the Cwd library based on the entry in %INC and 
    # our Module::ScanDeps path: if the module Foo::Bar was found as 
    # /some/path/Foo/Bar.pm, assume its shared library is in 
    # /some/path/auto/Foo/Bar/Bar.$dlext
    my $expected_path = $cwd_bundle_path;
    $expected_path =~ s,(Cwd|File/Glob)\.pm$,$entry,;

    # NOTE: This behaviour is not really guaranteed by the way DynaLoader 
    # works, but it is a reasonable assumption for any module installed 
    # by ExtUtils::MakeMaker. But it fails when the module wasn't installed, 
    # but located via blib (where the pm file is below blib/lib, but the
    # corresponding shared library is below blib/arch). CPAN Testers does this.
    $expected_path =~ s,\bblib\b(.)\blib\b,blib$1arch,;

    is( $rv->{$entry}->{file}, $expected_path, 'the full bundle path we got looks legit' );
}

check_bundle_path(
        files   => [ 't/data/check-dynaloader/Bar.pm' ],
        recurse => 0,
        compile => 1
    );
check_bundle_path(
        files   => [ 't/data/check-dynaloader/quux.pl' ],
        recurse => 0,
        execute => 1
    );

__END__


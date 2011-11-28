#!perl

use strict;
use Test::More;
use Config ();

use Module::ScanDeps;
use DynaLoader;
use File::Temp;

plan skip_all => "No dynamic loading available in your version of perl"
    unless $Config::Config{usedl};

my @try_mods = qw( Cwd File::Glob Data::Dumper List::Util Compress::Raw::Zlib );
my @dyna_mods = grep { my $mod = $_; 
                       eval("use $mod; 1") 
                       && grep { $_ eq $mod } @DynaLoader::dl_modules
                     } @try_mods;
plan skip_all => "No dynamic module found (tried @try_mods)"
    unless @dyna_mods;
diag "dynamic modules used for test: @dyna_mods";

plan tests => 3 * 2 * @dyna_mods;

my $dl_dlext = ".$Config::Config{dlext}";
foreach my $module (@dyna_mods)
{
    # cf. XSLoader.pm
    my @modparts = split(/::/,$module);
    my $modfname = $modparts[-1];
    my $dyna_path = join('[/\\\\]', map { quotemeta $_ } 'auto', @modparts, $modfname.$dl_dlext);

    check_bundle_path($module, $dyna_path, ".pl", <<"...",
use $module;
1;
...
        sub { scan_deps(
                files   => [ $_[0] ],
                recurse => 0);
        }
    );
    check_bundle_path($module, $dyna_path, ".pm", <<"...",
package Bar;
use $module;
1;
...
        sub { scan_deps_runtime(
                files   => [ $_[0] ],
                recurse => 0,
                compile => 1);
        }
    );
    check_bundle_path($module, $dyna_path, ".pl", <<"...",
# no way in hell can this detected by static analysis :)
my \$req = join("", qw( r e q u i r e ));
eval "\$req $module";
exit(0);
...
        sub { scan_deps_runtime(
                files   => [ $_[0] ],
                recurse => 0,
                execute => 1);
        }
    );
}

exit(0);

sub check_bundle_path {
    my ($module, $dyna_path, $suffix, $code, $scan) = @_;

    my ($fh, $filename) = File::Temp::tempfile( UNLINK => 1, SUFFIX => $suffix );
    print $fh $code, "\n" or die $!;
    close $fh;

    my $rv = $scan->($filename);
    my ( $entry ) =  grep { /^$dyna_path$/ } keys %$rv;
    ok( $entry, "$module: we have some key that looks like it pulled in its shared lib" );


    # Build a path the the Cwd library based on the entry in %INC and 
    # our Module::ScanDeps path: if the module Foo::Bar was found as 
    # /some/path/Foo/Bar.pm, assume its shared library is in 
    # /some/path/auto/Foo/Bar/Bar.$dlext
    (my $pm = $module.".pm") =~ s,::,/,g;
    my $expected_path = $INC{$pm};
    $expected_path =~ s,\Q$pm\E$,$entry,;

    # NOTE: This behaviour is not really guaranteed by the way DynaLoader 
    # works, but it is a reasonable assumption for any module installed 
    # by ExtUtils::MakeMaker. But it fails when the module wasn't installed, 
    # but located via blib (where the pm file is below blib/lib, but the
    # corresponding shared library is below blib/arch). CPAN Testers does this.
    $expected_path =~ s,\bblib\b(.)\blib\b,blib$1arch,;

    is( $rv->{$entry}->{file}, $expected_path, 'the full bundle path we got looks legit' );
}



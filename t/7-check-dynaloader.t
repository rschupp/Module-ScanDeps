#!perl

use strict;
use Test::More;
use Config ();

use Module::ScanDeps;
use DynaLoader;
use File::Temp;

plan skip_all => "No dynamic loading available in your version of perl"
    unless $Config::Config{usedl};

my @try_mods = qw( Cwd File::Glob Data::Dumper List::Util Time::HiRes Compress::Raw::Zlib );
my @dyna_mods = grep { my $mod = $_; 
                       eval("require $mod; 1") 
                       && grep { $_ eq $mod } @DynaLoader::dl_modules
                     } @try_mods;
plan skip_all => "No dynamic module found (tried @try_mods)"
    unless @dyna_mods;
diag "dynamic modules used for test: @dyna_mods";

plan tests => 3 * 2 * @dyna_mods;

foreach my $module (@dyna_mods)
{
    # cf. XSLoader.pm
    my @modparts = split(/::/,$module);
    my $modfname = $modparts[-1];
    my $auto_path = join('/', 'auto', @modparts, "$modfname.$Config::Config{dlext}");

    check_bundle_path($module, $auto_path, ".pl", <<"...",
use $module;
1;
...
        sub { scan_deps(
                files   => [ $_[0] ],
                recurse => 0);
        }
    );
    check_bundle_path($module, $auto_path, ".pm", <<"...",
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
    check_bundle_path($module, $auto_path, ".pl", <<"...",
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
    my ($module, $auto_path, $suffix, $code, $scan) = @_;

    my ($fh, $filename) = File::Temp::tempfile( UNLINK => 1, SUFFIX => $suffix );
    print $fh $code, "\n" or die $!;
    close $fh;

    my $rv = $scan->($filename);
    my ( $entry ) =  grep { /^\Q$auto_path\E$/ } keys %$rv;
    ok( $entry, "$module: we have some key that looks like it pulled in its shared lib" );


    # Look up what %INC knows about Foo::Bar after require'ing it,
    # then make an educated guess about the location of its shared library.
    # If the module Foo::Bar was found as /some/path/Foo/Bar.pm, 
    # assume its shared library is in  /some/path/auto/Foo/Bar/Bar.$dlext
    # or /some/path/ARCH/auto/Foo/Bar/Bar.$dlext
    (my $pm = $module.".pm") =~ s,::,/,g;
    (my $expected_prefix = $INC{$pm}) =~ s,/\Q$pm\E$,,;

    # NOTE: This behaviour is not really guaranteed by the way DynaLoader 
    # works, but it is a reasonable assumption for any module installed 
    # by ExtUtils::MakeMaker. But it fails when the module wasn't installed, 
    # but located via blib (where the pm file is below blib/lib, but the
    # corresponding shared library is below blib/arch). CPAN Testers does this.
    $expected_prefix =~ s,blib/lib,blib/arch,;

    # Actually we accept anything that starts with $expected_prefix
    # and ends with $auto_path.
    ok(    $rv->{$entry}->{file} =~ m{^\Q$expected_prefix\E/}
        && $rv->{$entry}->{file} =~ m{/\Q$auto_path\E$}, 
        'the full bundle path we got looks legit' );
}



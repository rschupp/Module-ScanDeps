package Module::ScanDeps::DataFeed;


# NOTE: All require's must be done here and 
# "require Module::ScanDeps::DataFeed" must be called while %INC, @INC etc
# are local'ized in order not to pollute these global variables.

use strict; 

require Cwd;
require DynaLoader;
require Data::Dumper;
require B; 
require Config;

# Write %INC, @INC and @DynaLoader::dl_shared_objects to $filename
sub _dump_info {
    my ($filename) = @_;

    my %inchash;
    foreach (keys %INC) {
        # an unsuccessful require may store undefined values into %INC
        next unless defined $INC{$_};
        $inchash{$_} = Cwd::abs_path($INC{$_});
    }

    my @incarray;
    # drop (code) refs from @INC
    @incarray = grep { !ref $_ } @INC;

    my @dl_so = grep { defined $_ && -e $_ } _dl_shared_objects();
    my $dl_ext = $Config::Config{dlext};
    my @dl_bs = @dl_so;
    my @dl_shared_objects = ( @dl_so, grep { s/\Q.$dl_ext\E$/\.bs/ && -e $_ } @dl_bs );

    open my $fh, ">", $filename 
        or die "Couldn't open $filename: $!\n";
    print $fh Data::Dumper->Dump(
                  [\%inchash, \@incarray, \@dl_shared_objects], 
                  [qw(*inchash *incarray *dl_shared_objects)]);
    print $fh "1;\n";
    close $fh;
}

sub _dl_shared_objects {
    if (@DynaLoader::dl_shared_objects) {
        return @DynaLoader::dl_shared_objects;
    }
    elsif (@DynaLoader::dl_modules) {
        return map { _dl_mod2filename($_) } @DynaLoader::dl_modules;
    }

    return;
}

sub _dl_mod2filename {
    my $mod = shift;

    return if $mod eq 'B';
    return unless defined &{"$mod\::bootstrap"};

    my $dl_ext = $Config::Config{dlext};

    # Copied from XSLoader
    my @modparts = split(/::/, $mod);
    my $modfname = $modparts[-1];
    my $modpname = join('/', @modparts);

    foreach my $dir (@INC) {
        my $file = "$dir/auto/$modpname/$modfname.$dl_ext";
        return $file if -r $file;
    }

    return;
}

1;

__END__

# AUTHORS
# 
# Edward S. Peschko <esp5@pge.comE>,
# Audrey Tang <cpan@audreyt.org>,
# to a lesser degree Steffen Mueller <smueller@cpan.org>
# 
# COPYRIGHT
# 
# Copyright 2004-2009 by Edward S. Peschko <esp5@pge.com>,
# Audrey Tang <cpan@audreyt.org>,
# Steffen Mueller <smueller@cpan.org>
# 
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
# 
# See <http://www.perl.com/perl/misc/Artistic.html


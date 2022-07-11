#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Module::ScanDeps qw/scan_chunk/;

my @tests = (
    {
        chunk    => 'use strict;',
        expected => 'strict.pm',
    },
    {
        chunk    => 'use base qw(strict);',
        expected => 'base.pm strict.pm',
    },
    {
        chunk    => 'use parent qw(strict);',
        expected => 'parent.pm strict.pm',
    },
    {
        chunk    => 'use parent::doesnotexists qw(strict);',
        expected => 'parent/doesnotexists.pm',
    },
    {
        chunk    => 'use Mojo::Base "strict";',
        expected => 'Mojo/Base.pm strict.pm',
        comment  => 'Mojo::Base',
    },
    {
        chunk    => 'use Catalyst qw/-Debug ConfigLoader Session::State::Cookie/',
        expected => 'Catalyst.pm Catalyst/Plugin/ConfigLoader.pm 
                     Catalyst/Plugin/Session/State/Cookie.pm',
        comment  => '-Debug should be skipped',
    },
    {
        chunk    => 'use I18N::LangTags 0.30 ();',
        expected => 'I18N/LangTags.pm',
    },
);

plan tests => 0+@tests;

foreach my $t (@tests)
{
    my @got = scan_chunk($t->{chunk});
    my @exp = split(' ', $t->{expected});
    is_deeply([sort @got], [sort @exp], $t->{comment});
}

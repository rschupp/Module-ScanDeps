#!/usr/bin/perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile1(

    NAME            => 'Module::ScanDeps',
    VERSION_FROM    => 'lib/Module/ScanDeps.pm',
    ABSTRACT_FROM   => 'lib/Module/ScanDeps.pm',
    LICENSE         => 'perl_5',
    AUTHOR          => [ 'Audrey Tang <cpan@audreyt.org>' ],

    MIN_PERL_VERSION => '5.008009',
    PREREQ_PM       => {
      'File::Temp'       => 0,
      'File::Spec'       => 0,
      'Getopt::Long'     => 0,
      'List::Util'       => '1.33',
      'Module::Metadata' => 0,
      'Text::ParseWords' => 0,
      'version'          => 0,
    },
    TEST_REQUIRES   => {
      'Test::More'       => 0,
      'Test::Requires'   => 0,
      'IPC::Run3'        => '0.048',
    },

    EXE_FILES       => [ 'script/scandeps.pl' ],

    META_MERGE      => {
      "meta-spec" => { version => 2 },
      resources => {
        repository  => {
          type => 'git',
          url  => 'git://github.com/rschupp/Module-ScanDeps.git',
          web  => 'https://github.com/rschupp/Module-ScanDeps',
        },
        MailingList => 'mailto:par@perl.org',
        bugtracker => { web => 'https://github.com/rschupp/Module-ScanDeps/issues' },
      },
      no_index => {
        package => [qw( Module::ScanDeps::Cache Module::ScanDeps::DataFeed )],
      },
    },
);


sub WriteMakefile1 {  #Compatibility code for old versions of EU::MM. Written by Alexandr Ciornii, version 0.23. Added by eumm-upgrade.
    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{AUTHOR} and ref($params{AUTHOR}) eq 'ARRAY' and $eumm_version < 6.5705) {
        $params{META_ADD}->{author}=$params{AUTHOR};
        $params{AUTHOR}=join(', ',@{$params{AUTHOR}});
    }
    if ($params{TEST_REQUIRES} and $eumm_version < 6.64) {
        $params{BUILD_REQUIRES}={ %{$params{BUILD_REQUIRES} || {}} , %{$params{TEST_REQUIRES}} };
        delete $params{TEST_REQUIRES};
    }
    if ($params{BUILD_REQUIRES} and $eumm_version < 6.5503) {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;

    WriteMakefile(%params);
}


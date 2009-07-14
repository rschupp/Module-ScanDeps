#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
use Module::ScanDeps qw/scan_chunk/;

{
my $chunk=<<'EOT';
use strict;
EOT
my @array=sort (scan_chunk($chunk));
is_deeply(\@array,[sort qw{strict.pm}]);
}

{
my $chunk=<<'EOT';
use base qw(strict);
EOT
my @array=sort (scan_chunk($chunk));
is_deeply(\@array,[sort qw{base.pm strict.pm}]);
}


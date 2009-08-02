#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
use Module::ScanDeps qw/scan_line/;

{
my $chunk=<<'EOT';
use strict;
EOT
my @array=sort (scan_line($chunk));
is_deeply(\@array,[sort qw{strict.pm}]);
}

{
my $chunk=<<'EOT';
require 5.10;
EOT
my @array=sort (scan_line($chunk));
is_deeply(\@array,[sort qw{feature.pm}]);
}

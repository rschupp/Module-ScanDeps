#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Module::ScanDeps qw/scan_line/;

{
my $chunk=<<'EOT';
use strict;
EOT
my @array=scan_line($chunk);@array=sort @array;
is_deeply(\@array,[sort qw{strict.pm}]);
}

{
my $chunk=<<'EOT';
require 5.10;
EOT
my @array=scan_line($chunk);@array=sort @array;
is_deeply(\@array,[sort qw{feature.pm}]);
}

{# RT#48151
my $chunk=<<'EOT';
require __PACKAGE__ . "SomeExt.pm";
EOT
eval {
  scan_line($chunk);
};
is($@,'');
}

{  #  use 5.010 on one line was missing later use calls
  my $chunk = 'use 5.010; use MyModule::PlaceHolder1;';
  my @got = scan_line($chunk);
  diag @got;
  my @expected = sort ('feature.pm', 'MyModule/PlaceHolder1.pm');
  is_deeply (\@expected, [sort @got], 'got more than just feature.pm when use 5.xx on line');
}

{  #  use 5.010 on one line was missing later use calls
  my $chunk = 'use 5.009; use MyModule::PlaceHolder1;';
  my @got = scan_line($chunk);
  diag @got;
  my @expected = sort ('MyModule/PlaceHolder1.pm');
  is_deeply (\@expected, [sort @got], 'did not get feature.pm when use 5.009 on line');
}

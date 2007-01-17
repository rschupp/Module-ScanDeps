#!/usr/bin/perl

use Test;
BEGIN { plan tests => 3 }

use Module::ScanDeps;

use lib qw(t/data);

if (eval {require Module::Pluggable}) {
   my $map = scan_deps(
      files   => ['t/data/Foo.pm'],
      recurse => 1,
   );
   
   ok(exists $map->{'Module/Pluggable.pm'});
   ok(exists $map->{'Foo/Plugin/Bar.pm'});
   ok(exists $map->{'Foo/Plugin/Baz.pm'});

} else {
   print "# Module::Pluggable not installed, skipping all tests\n";
   # Skip tests
   for (1..3) {
      ok(1);
   }
}

__END__

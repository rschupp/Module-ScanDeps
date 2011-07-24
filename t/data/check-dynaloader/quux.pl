# no way in hell can this detected by static analysis :)
my $req = join("", qw( r e q u i r e ));
eval "$req Cwd";
eval "$req File::Glob";

exit(0);

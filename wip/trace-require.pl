#!/usr/bin/perl

# trace the Perl interpreter searching for a module
# (caused by "require", "use", sometimes "do" ...)

BEGIN
{
    unshift @INC, sub {
        my ($self, $name) = @_;
        my (undef, $file, $line) = caller();
        my $msg = "require $name \@ $file:$line";
        if ($file =~ /^\(eval /) 
        {
            my (undef, $file, $line, undef, undef, undef, $evaltext) = caller(1);
            $msg .= " \@ $file:$line \"$evaltext\"";
        }
        print STDERR $msg, "\n";
        return;
    };
}

@ARGV >= 1 or die "Usage: $0 script.pl [arg...]\n";
my $script = shift @ARGV;
$script = "./$script" unless $script =~ /^\//;  # prevent search in $PATH
do $script;

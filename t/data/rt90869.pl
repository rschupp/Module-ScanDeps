# some forms of "use autouse ..."
use autouse TestA => qw(foo bar);
use autouse "TestB", "frobnicate";

# "use if ..."  - note the undefined function in condition
use if frobnicate(), TestC => qw(quux);

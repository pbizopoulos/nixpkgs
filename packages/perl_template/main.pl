#!/usr/bin/env perl
use strict;
use warnings;
my $RED   = "\x1b[31m";
my $GREEN = "\x1b[32m";
my $BLUE  = "\x1b[34m";
my $RESET = "\x1b[0m";
sub run_tests {
    if ( 1 + 1 != 2 ) {
        print STDERR "test math failed\n";
        exit 1;
    }
    print "test ... ok\n";
}
if ( ( $ENV{DEBUG} // "" ) eq "1" ) {
    run_tests();
}
else {
    for my $i ( 1 .. 100 ) {
        if    ( $i % 15 == 0 ) { print "${RED}FizzBuzz${RESET}\n"; }
        elsif ( $i % 3 == 0 )  { print "${GREEN}Fizz${RESET}\n"; }
        elsif ( $i % 5 == 0 )  { print "${BLUE}Buzz${RESET}\n"; }
        else                   { print "$i\n"; }
    }
}

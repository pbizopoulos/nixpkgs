#!/usr/bin/env perl
use strict;
use warnings;
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
    print "Hello World\n";
}

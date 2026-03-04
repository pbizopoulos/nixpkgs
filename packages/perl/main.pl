#!/usr/bin/env perl
use strict;
use warnings;
sub run_tests {
    if ( 1 + 1 != 2 ) {
        print STDERR "test math failed
";
        exit 1;
    }
    print "test math ... ok
";
}
if ( ( $ENV{DEBUG} // "" ) eq "1" ) {
    run_tests();
}
else {
    print "Hello Perl!
";
}

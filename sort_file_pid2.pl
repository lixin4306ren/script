#!/usr/bin/perl
use strict;
use warnings;

#open IN,$ARGV[0]||die;
my $pid=$ARGV[1];
my $cmd="LC_ALL=C sort -k1,1 -k2,2n -k3,3n -k6,6r $ARGV[0] > $ARGV[0].$pid.sort";
print "$cmd\n";
`$cmd`;



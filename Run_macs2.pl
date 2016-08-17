#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
my $type=$ARGV[1]||die;

while (<IN>) {
	chomp;
	my @infor=split;
	my $name=(split/\./,$infor[0])[0];
	print "macs2 callpeak -t $infor[0] -c $infor[1] -g hs -f $type -n $name.macs2\n";
}

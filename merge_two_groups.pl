#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
open IN2,$ARGV[1]||die;
my %hash;
while (<IN>) {
	chomp;
	my @infor=split;
	 $hash{$infor[0]}=$_;
}

while (<IN2>) {
	chomp;
	my @infor=split;
	if (exists $hash{$infor[0]}) {
		print "$_\t$hash{$infor[0]}\n";
	}
}

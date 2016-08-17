#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
while (<IN>) {
	chomp;
	my @infor=split;
	print "$infor[0]\t$infor[0]\t0\t0\t0\t0\t";
	for (my $i=1;$i<@infor ;$i++) {
		if ($infor[$i] eq 'NA') {
			print "0\t0\t";
		}
		elsif($infor[$i]==0){
			print "1\t1\t";
		}
		elsif($infor[$i]==1){
			print "1\t2\t";
		}
		elsif($infor[$i]==2){
			print "2\t2\t";
		}
		#print "\n";

	}
	print "\n";
}


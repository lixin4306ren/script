#!/usr/bin/perl
use strict;
use warnings;

#chrY    59362591        1       0       0
#to
#chr1 3001345 3001346 CpG:9 0.777777777778 +

open IN,$ARGV[0]||die;
while (my $line1=<IN>) {
	chomp $line1;
	my @infor=split/\s+/,$line1;
	my $line2=<IN>;
	my @infor2=split/\s+/,$line2;
	if ($infor2[1]-$infor[1]==1 and $infor[2]==1 and $infor2[2]==4) {
		print "$infor[0]\t$infor[1]\t$infor2[1]\t";
		if ($infor[-1]+$infor2[-1]==0) {
			print "CpG:0\tnan\t+\n";
		}
		else{
			print "CpG:",$infor[-1]+$infor2[-1],"\t",($infor[-2]+$infor2[-2])/($infor[-1]+$infor2[-1]),"\t+\n";
		}
	}
	else{
		print "$line1\n$line2\n";
		die "wrong\n";
	}
}


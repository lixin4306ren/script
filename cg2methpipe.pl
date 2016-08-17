#!/usr/bin/perl
use strict;
use warnings;

open IN, $ARGV[0]||die;


while (<IN>) {
	chomp;
	my @infor=split;
	my $strand;
	if ($infor[2]==1){$strand="+";}
	elsif($infor[2]==4){$strand="-";}
	if($infor[4]==0){
		print "$infor[0]\t$infor[1]\t",$infor[1]+1,"\tCpG:$infor[4]\t0\t$strand\n";
	}
	else{
		print "$infor[0]\t$infor[1]\t",$infor[1]+1,"\tCpG:$infor[4]\t",$infor[3]/$infor[4],"\t$strand\n";
	}
}

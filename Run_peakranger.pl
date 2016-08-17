#!/usr/bin/perl
use strict;
use warnings;

open L,$ARGV[0]||die;#chip list
open O,">peakranger.sh"||die;
while (<L>) {
	chomp;
	my @infor=split;
	my $tmp1=(split /\./,$infor[0])[0];
	my $tmp2=(split /\./,$infor[1])[0];
	#print "$tmp1\t$tmp2\n";
	my $cmd="~/soft/PeakRanger/peakranger ccat -d $infor[0].single.bed -c $infor[1].single.bed --format bed --output $tmp1.$tmp2.ccat --win_size $infor[2] --win_step $infor[3]\n";
	print O $cmd;
}
close L;

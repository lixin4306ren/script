#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die; # chip control list
while (<IN>) {
	chomp;
	my @infor=split;
	print "perl /home/jhmi/xinli/scripts/Calculate_enrich_ratio2.pl $infor[0].sort.bam.rmdup.pair.bed $infor[1].sort.bam.rmdup.pair.bed $infor[0] $infor[1] hg19.len 1000 1000 hg19\n";
}


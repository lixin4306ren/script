#!/usr/bin/perl
use strict;
use warnings;
open IN,$ARGV[0]||die;
while (<IN>) {
	chomp;
	my @infor=split;
	my $name=$infor[0];
	open TMP,$name."/accepted_hits.unique.bam.count"||die;

	close TMP;
	last;
}

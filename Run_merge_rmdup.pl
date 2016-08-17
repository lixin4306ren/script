#!/usr/bin/perl
use strict;
use warnings;
open IN,$ARGV[0]||die; #sample list
while (<IN>) {
	chomp;
	my @infor=split;
	my $sample_name=$infor[0];
	if ($sample_name=/\//) {
		$sample_name=(split /\//,$infor[0])[-1];
	}

	#print "$_\n$sample_name\n";next;
	print "samtools merge - ";
	opendir DB, $sample_name||die;
	while (my $filename=readdir(DB)) {
		#print "$filename\n";
		if ($filename=~/.*crick\.bam\.sort\.bam/) {
			print "$sample_name/$filename ";
		}
	}
	closedir DB;
	print "|samtools rmdup - $sample_name/$sample_name.crick.sort.rmdup.bam\n";

	print "samtools merge - ";
	opendir DB, $sample_name||die;
	while (my $filename=readdir(DB)) {
		if ($filename=~/.*watson.bam\.sort\.bam/) {
			print "$sample_name/$filename ";
		}
	}
	closedir DB;
	print "|samtools rmdup - $sample_name/$sample_name.watson.sort.rmdup.bam\n";

}

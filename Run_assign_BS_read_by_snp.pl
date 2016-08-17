#!/usr/bin/perl
use strict;
use warnings;
open IN,$ARGV[0]||die; #sample list
open Chr,$ARGV[1]||die; #chr
my $dir=$ARGV[2];

while (my $line=<IN>) {
	chomp $line;
	my $sample=(split /\//,$line)[-1];

	open Chr,$ARGV[1]||die; #chr
	while (my $chr=<Chr>) {
		chomp $chr;
		#my $dir_tmp="$sample/high";
		if (!(-d "$sample\/high")) {mkdir("$sample\/high");}
		if (!(-d "$sample\/low")) {mkdir("$sample\/low");}
		print "perl ~/scripts/assign_BS_read_by_snp2.pl $sample/all/$chr.ev.tsv.gz $dir/$sample/all.high.list $dir/$sample/all.low.list $sample/high/$chr.ev.tsv $sample/low/$chr.ev.tsv\n";
	}
	close Chr;

}

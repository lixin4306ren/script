#!/usr/bin/perl
use strict;
use warnings;

#Pair    41_1_ACAGTG_L003_001
#Observation1    41_1_ACAGTG_L003_R1_001.fastq
#Observation2    41_1_ACAGTG_L003_R2_001.fastq
#MeanInsertSize  202.7030
#Total nucleotide#       800000000
#AverageReadLengthBeforeTrimming 100
#Trimming%       0.0000
#Total read#     8000000
#Uniquely paired read#   7259532
#Non-uniquely paired read#       0
#Uniquely mapped read1#  88464
#Non-uniquely mapped read1#      0
#Uniquely mapped read2#  82079
my %hash;
open L,$ARGV[0]||die;#sample.list
while (my $sample=<L>) {
chomp $sample;
opendir DIR,"./"||die;
while (my $file=readdir(DIR)) {
	print "$file\n";
	if ($file=~/^$sample/ and (-d $file)) {
		#print "$file\n";
			open TMP,"$file/$file.AlignmentSummary.txt"||die;
			while (my $line=<TMP>) {
				chomp $line;
				my @infor=split /\s+/,$line;
				if ($line=~/^Uniquely paired read\#/ or $line=~/^Uniquely mapped read1\#/ or $line=~/^Uniquely mapped read2\#/) {
					$hash{$sample}+=$infor[3];
					#print $hash{$sample},"\n";
				}
			}
			close TMP;
			#exit;
	}
}
closedir DIR;

}
close L;

foreach my $key (keys %hash) {
	print "$key\t$hash{$key}\n";
}

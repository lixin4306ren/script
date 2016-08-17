#!/usr/bin/perl
use strict;
use warnings;

open L,$ARGV[0]||die;  ##chr

my $outfile=$ARGV[2]; #high.filter.vcf

while (my $chr=<L>) {
	chomp $chr;
	print "java -Xmx15g -Djava.io.tmpdir=/home/jhmi/xinli/amber3/Chicken/SNP -jar ~/bin/GenomeAnalysisTK.jar -nt 4 -T CombineVariants -o $chr.$outfile -genotypeMergeOptions UNIQUIFY -R all.with.lambda.fa ";
open L2,$ARGV[1]||die;  ##chr list
while (my $sample=<L2>) {
	chomp $sample;
	print "--variant $sample.$chr.filtered.vcf ";

}
close L2;
print "\n";
}

#!/usr/bin/perl
use strict;
use warnings;

#chr1    11239   1       0       0
#chr1    11240   4       0       0

open IN,$ARGV[0]||die;
my $min_cov=$ARGV[1];

print "chrBase\tchr\tbase\tstrand\tcoverage\tfreqC\tfreqT\n";
while (my $line1=<IN>) {
	chomp $line1;
	my @infor=split /\s/,$line1;
	my $line2=<IN>;
	chomp $line2;
	my @infor2=split /\s/,$line2;
	if (!($infor2[1]-$infor[1]==1) or !($infor[2]==1 and $infor2[2]==4)) {die "wrong\n";}
	my $name=$infor[0].".$infor[1]";
	my $chr=$infor[0];
	my $base=$infor[1];
	my $coverage=$infor[4]+$infor2[4];
	if ($coverage<$min_cov) {next;}
	my $freqC=(($infor[3]+$infor2[3])/$coverage)*100;
	my $freqT=100-$freqC;
	print "$name\t$chr\t$base\tF\t$coverage\t$freqC\t$freqT\n";

}

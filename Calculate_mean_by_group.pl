#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
my $mean_col=$ARGV[1];
my $tag_col=$ARGV[2];
my $start=$ARGV[3];
my $end=$ARGV[4];
my $step=$ARGV[5];

my %mean;
my %total;

while (<IN>) {
	chomp;
	my @infor=split;
	if (/^L1/) {next;}
	my $tag=$infor[$tag_col-1];
	if ($tag % $step ==0 ) {
		$mean{int($tag/$step)}+=$infor[$mean_col-1];
	}
	else{
		$mean{int($tag/$step)+1}+=$infor[$mean_col-1];
		$total{int($tag/$step)+1}++;
	}

}

foreach my $key (sort{$a<=>$b}keys %mean) {
	print "$key\t",$mean{$key}/$total{$key},"\n";
}

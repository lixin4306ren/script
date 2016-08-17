#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die; ##SNP list
open S,$ARGV[1]||die; ##fasta file

my %seq;
my $name;
while (<S>) {
	chomp;
	if (/^>/) {
		$name=$_;$name=~s/>//;
	}
	else{
		$seq{$name}.=uc($_);
	}
}
close S;

#chr10   1602    .       T       C       C       C       51.60   PASS            1       1       1       0       1       0       AC=20;

while (<IN>) {
	chomp;
	my @infor=split;
	my $chr=$infor[0];
	my $pos=$infor[1];
	if ($infor[5] ne $infor[6]) {die "wrong 1\n";}
	if ($infor[5] eq $infor[3]) {die "wrong 2\n";}
	if (substr($seq{$chr},$pos-1,1) ne $infor[3]) {die "wrong 3\n";}
	substr($seq{$chr},$pos-1,1)=uc($infor[5]);
}
close IN;

foreach my $key (keys %seq) {
	print ">$key\n$seq{$key}\n";
}

#!/usr/bin/perl
use strict;
use warnings;

#@HISEQ:128:C1R0UACXX:3:1208:2022:90244 2:N:0:ACAGTG
#CACCGTCAAAGGAAGAACTCCTTAAACTAACTGAAACTGTTGTGACTGAATATCTAAATAGTGGAAATGCAAATGAGGCTGTCAATGGTGTAAGAGAAAT
#+
#CCCFFFFFHHHHHJJJJJJJJJJJJJJJIJJJJJJJJJJJJJIJJJJJIJIJIJJIIJJIJHHIHIIIIJJJJJJJHHHHFDFFFFEE@CACDDCDCDDD
open IN,"samtools view $ARGV[0]|"||die;
my %hash;
while (<IN>) {
	my @infor=split;
	my $name=(split /_/,$infor[0])[0];
	$hash{$name}++;
}
close IN;

print "starting output\n";
open IN,"samtools view $ARGV[0]|"||die;
open O1,">$ARGV[1]"||die;
open O2,">$ARGV[2]"||die;
while (<IN>) {
	my @infor=split;
	my $name=(split /_/,$infor[0])[0];
	if ($hash{$name}<2) {next;}
	if ($infor[0]=~/_1\:/) {
	print O1 "@",$infor[0],"\n";
	print O1 $infor[9],"\n";
	print O1 "+\n";
	print O1 "$infor[10]\n";

	}else{
	print O2 "@",$infor[0],"\n";
	print O2 $infor[9],"\n";
	print O2 "+\n";
	print O2 "$infor[10]\n";
	}
}
close IN;



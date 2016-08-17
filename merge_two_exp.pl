#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
open IN2,$ARGV[1]||die;


#no_feature      15020035
#ambiguous       2518978
#too_low_aQual   0
#not_aligned     0
#alignment_not_unique    0

my %gene;
my %hash;
while (<IN>) {
	chomp;
	if (/^no_feature/ or /^ambiguous/ or /^too_low/ or /^not_aligned/ or /^alignment_not_unique/){next;}	
my @infor=split;
	$hash{$infor[0]}=$infor[1];
	$gene{$infor[0]}=1;
}
close IN;

my %hash2;
while (<IN2>) {
	chomp;
	if (/^no_feature/ or /^ambiguous/ or /^too_low/ or /^not_aligned/ or /^alignment_not_unique/){next;}
	my @infor=split;
	$hash2{$infor[0]}=$infor[1];
	$gene{$infor[0]}=1
}
close IN2;

foreach my $key (keys %gene) {
	if (!exists $hash{$key}) {$hash{$key}=0;}
	if (!exists $hash2{$key}) {$hash2{$key}=0;}
	if ($hash{$key}==0 and $hash2{$key}==0) {next;}
	print "$key\t$hash{$key}\t$hash2{$key}\n";
}



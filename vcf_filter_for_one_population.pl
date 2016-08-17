#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
my $allele_count1=$ARGV[1]||die;
open O,">$ARGV[2]"||die;


my $test;
my $all;
my $fix1;

my %group;

while (<IN>) {
	chomp;
	if (/^\#\#/) {print O $_,"\n";next;}
	my @infor=split;
	if (/^\#CHROM/) {
		print O "$_\n";next;
	}

my $f1;my $q1;
my $total_allel;
if (/AN=(\d+)/) {$total_allel=$1;}

my $covered_sample;

	my %hash;
	for (my $i=9;$i<@infor ;$i++) {
		if ($infor[$i] eq './.') {next;}
		my $genotype=(split /\:/,$infor[$i])[0];
		my $allel_1=(split /\//,$genotype)[0];
		my $allel_2=(split /\//,$genotype)[1];
		$hash{$allel_1}++;
		$hash{$allel_2}++;
		$covered_sample++;
	}
	#if ((keys %hash)>2 or (keys %hash)==1) {next;} ### only keep biallele snps
	if ((keys %hash)>2) {next;}
	$test++;
	my $tag=0;
	my $debug=0;
	foreach my $key (keys %hash) {
		if ($key==0) {$tag=1;}
	}
	###tag==1,has at least one ref allele; tag==0, no ref allele
	foreach my $key (keys %hash) {
			if (!defined $hash{$key}) {$hash{$key}=0;}
		
		if($tag==1){
			if ($key==0) {
				$f1=$hash{$key};
			}
			else{
				$q1=$hash{$key};
			}

		}
		elsif($tag==0){
			if ($key==1) {
				$f1=$hash{$key};
				$debug=1;
			}
			else{
				$q1=$hash{$key};
			}
		}
	}
	if ($tag==0 and $debug==0) {
		die "Wrong\n";
	}

if (!defined $f1) {$f1=0}
if (!defined $q1) {$q1=0}

if (($f1+$q1) != $total_allel) {die "Wrong\n";}

if (!defined $covered_sample) {$covered_sample=0;}

if ($covered_sample<$allele_count1) {next;}
$all++;


if (($tag==1 and $q1/($f1+$q1)==1) || ($tag==0 and abs($q1/($f1+$q1)-$f1/($f1+$q1))==1)) {
	$fix1++;
	#print "$_\n";
	print O "$_\n";
}

}

print "test:$test\tall:$all\tfix1:$fix1\n";



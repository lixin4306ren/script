#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
open L1,$ARGV[1]||die;
open L2,$ARGV[2]||die;
my $allele_count1=$ARGV[3]||die;
my $allele_count2=$ARGV[4]||die;
my $allele_freq_diff=$ARGV[5]||die;
open O,">$ARGV[6]"||die; #diff snps between line1 and line2
open C,">$ARGV[7]"||die; #common fixed snps
open O1,">$ARGV[8]"||die; #line1 fixed snps
open O2,">$ARGV[9]"||die; #line2 fixed snps
open O3,">$ARGV[10]"||die; #line1 uniquely fixed snps
open O4,">$ARGV[11]"||die; #line2 uniquely fixed snps

my %p1;
my %p2;

#my $test;
my $all;
my $common;
my $diff;
my $diff2;
my $fix1;
my $fix2;
my $all_fix;
my $unique1;
my $unique2;
while (<L1>) {
	chomp;
	$p1{$_}=$_;
}
close L1;
while (<L2>) {
	chomp;
	$p2{$_}=$_;
}
close L2;

my %group;

my $process=0;
while (<IN>) {
	chomp;
	if (/^\#\#/) {print O $_,"\n";next;}
	my @infor=split;
	if (/^\#CHROM/) {
		print O "$_\n";
		for (my $i=9;$i<@infor ;$i++) {
			my $tmp_name=(split /\./,$infor[$i])[0];
			if (exists $p1{$tmp_name}) {
				$group{$i}=1;
			}
			elsif(exists $p2{$tmp_name}){
				$group{$i}=2;
			}
		}
		next;
	}
	$process++;



my $f1;my $f2;my $q1;my $q2;
my $total_allel;
if (/AN=(\d+)/) {$total_allel=$1;}

#if ($total_allel<$allele_count) {next;}
my @covered_sample;

	my %hash;
	for (my $i=9;$i<@infor ;$i++) {
		if ($infor[$i] eq './.') {next;}
		my $genotype=(split /\:/,$infor[$i])[0];
		my $allel_1=(split /\//,$genotype)[0];
		my $allel_2=(split /\//,$genotype)[1];
		$hash{$allel_1}->[$group{$i}]++;
		$hash{$allel_2}->[$group{$i}]++;
		$covered_sample[$group{$i}]++;
	}
	#if ((keys %hash)>2 or (keys %hash)==1) {next;} ### only keep biallele snps
	if ((keys %hash)>2) {next;}
	#$test++;
	my $tag=0;
	my $debug=0;
	foreach my $key (keys %hash) {
		if ($key==0) {$tag=1;}
	}
	###tag==1,has at least one ref allele; tag==0, no ref allele
	foreach my $key (keys %hash) {
			if (!defined $hash{$key}->[1]) {$hash{$key}->[1]=0;}
			if (!defined $hash{$key}->[2]) {$hash{$key}->[2]=0;}
			
		if($tag==1){
			if ($key==0) {
				$f1=$hash{$key}->[1];
				$f2=$hash{$key}->[2];
			}
			else{
				$q1=$hash{$key}->[1];
				$q2=$hash{$key}->[2];
			}

		}
		elsif($tag==0){
			if ($key==1) {
				$f1=$hash{$key}->[1];
				$f2=$hash{$key}->[2];
				$debug=1;
			}
			else{
				$q1=$hash{$key}->[1];
				$q2=$hash{$key}->[2];
			}
		}
	}


	if ($tag==0 and $debug==0) {
		die "Wrong\n";
	}
			

if (!defined $f1) {$f1=0}
if (!defined $q1) {$q1=0}
if (!defined $f2) {$f2=0}
if (!defined $q2) {$q2=0}

if (($f1+$f2+$q1+$q2) != $total_allel) {die "Wrong\n";}

if (!defined $covered_sample[1]) {$covered_sample[1]=0;}
if (!defined $covered_sample[2]) {$covered_sample[2]=0;}

if ($covered_sample[1]<$allele_count1 or $covered_sample[2]<$allele_count1) {next;}

$all++;
#print abs($q1/($f1+$q1)-$q2/($f2+$q2)),"\n";
my $fix1_tag=0;
my $fix2_tag=0;

if (($tag==1 and $q1/($f1+$q1)==1) or ($tag==0 and abs($q1/($f1+$q1)-$f1/($f1+$q1))==1)) {
	$fix1++;
	$fix1_tag=1;
	print O1 "$_\n";
}

if (($tag==1 and $q2/($f2+$q2)==1) or ($tag==0 and abs($q2/($f2+$q2)-$f2/($f2+$q2))==1)) {
	$fix2++;
	$fix2_tag=1;
	print O2 "$_\n";
}




if ($fix1_tag==1 and $fix2_tag==1 ) {
	$all_fix++;
	if ($q1/($f1+$q1)==$q2/($f2+$q2)) {
		$common++;
		print C "$_\n";
	}
	else{
		$diff++;
		#print "$_\n";
	}
}

if ($fix1_tag==1 and $fix2_tag==0) {$unique1++;print O3 "$_\n";}
if ($fix1_tag==0 and $fix2_tag==1) {$unique2++;print O4 "$_\n";}




if (abs($f1/($f1+$q1)-$f2/($f2+$q2))>=$allele_freq_diff) {print O "$_\n";}


}

print STDERR "all:$all\tall_fix:$all_fix\tcommon:$common\tdiff:$diff\tfix1:$fix1\tfix2:$fix2\tunique1:$unique1\tunique2:$unique2\n";



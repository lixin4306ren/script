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
open C,">$ARGV[7]"||die; 
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
my $other;
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
	if (/^\#\#/) {next;}
	my @infor=split;
	if (/^\#CHROM/) {
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
my @homo;
my @hetero;
my $f_genotype;my $q_genotype;
my @alt_allele;
$alt_allele[0]=$infor[3];
if ($infor[4]=~/,/) {
	my @tmp=split /,/,$infor[4];
	for (my $i=0;$i<@tmp ;$i++) {
		$alt_allele[$i+1]=$tmp[$i];
		#print $i+1,"\t$alt_allele[$i]\n";
	}
}
else{
	$alt_allele[1]=$infor[4];
}
	my %hash;
	for (my $i=9;$i<@infor ;$i++) {
		if ($infor[$i] eq './.') {next;}
		my $genotype=(split /\:/,$infor[$i])[0];
		my $allel_1=(split /\//,$genotype)[0];
		my $allel_2=(split /\//,$genotype)[1];
		$hash{$allel_1}->[$group{$i}]++;
		$hash{$allel_2}->[$group{$i}]++;
		$covered_sample[$group{$i}]++;
		if ($allel_1 eq $allel_2) {
			$homo[$group{$i}]++;
		}
		else{
			$hetero[$group{$i}]++;
		}
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
				$f_genotype=$alt_allele[$key];
			}
			else{
				$q1=$hash{$key}->[1];
				$q2=$hash{$key}->[2];
				$q_genotype=$alt_allele[$key];
			}

		}
		elsif($tag==0){
			if ($key==1) {
				$f1=$hash{$key}->[1];
				$f2=$hash{$key}->[2];
				$f_genotype=$alt_allele[$key];
				$debug=1;
			}
			else{
				$q1=$hash{$key}->[1];
				$q2=$hash{$key}->[2];
				$q_genotype=$alt_allele[$key];
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
if (!defined $homo[1]) {$homo[1]=0;}
if (!defined $homo[2]) {$homo[2]=0;}
if (!defined $hetero[1]) {$hetero[1]=0;}
if (!defined $hetero[2]) {$hetero[2]=0;}

if ($covered_sample[1]<$allele_count1 or $covered_sample[2]<$allele_count1) {next;}

$all++;

my $fix1_tag=0;
my $fix2_tag=0;

my $high_allele;my $low_allele;
if ($f1/($f1+$q1)>$q1/($f1+$q1)) {
	$high_allele=$f_genotype;
}
else{$high_allele=$q_genotype;}

if ($f2/($f2+$q2)>$q2/($f2+$q2)) {
	$low_allele=$f_genotype;
}
else{$low_allele=$q_genotype;}

if (($tag==1 and $q1/($f1+$q1)==1) or ($tag==0 and abs($q1/($f1+$q1)-$f1/($f1+$q1))==1)) {
	$fix1++;
	$fix1_tag=1;
	print O1 "$infor[0]\t$infor[1]\t$infor[2]\t$infor[3]\t$infor[4]\t$high_allele\t$low_allele\t$infor[5]\t$infor[6]\t","\t",$homo[1]/($homo[1]+$hetero[1]),"\t",$homo[2]/($homo[2]+$hetero[2]),"\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t$infor[7]\n";
}

if (($tag==1 and $q2/($f2+$q2)==1) or ($tag==0 and abs($q2/($f2+$q2)-$f2/($f2+$q2))==1)) {
	$fix2++;
	$fix2_tag=1;
	print O2 "$infor[0]\t$infor[1]\t$infor[2]\t$infor[3]\t$infor[4]\t$high_allele\t$low_allele\t$infor[5]\t$infor[6]\t","\t",$homo[1]/($homo[1]+$hetero[1]),"\t",$homo[2]/($homo[2]+$hetero[2]),"\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t$infor[7]\n";
}


if ($fix1_tag==1 and $fix2_tag==1 ) {
	$all_fix++;
	if ($q1/($f1+$q1)==$q2/($f2+$q2)) {
		$common++;
		print C "$infor[0]\t$infor[1]\t$infor[2]\t$infor[3]\t$infor[4]\t$high_allele\t$low_allele\t$infor[5]\t$infor[6]\t","\t",$homo[1]/($homo[1]+$hetero[1]),"\t",$homo[2]/($homo[2]+$hetero[2]),"\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t$infor[7]\n";
	}
	else{
		$diff++;
	}
}

if ($fix1_tag==1 and $fix2_tag==0) {$unique1++;print O3 "$infor[0]\t$infor[1]\t$infor[2]\t$infor[3]\t$infor[4]\t$infor[5]\t$infor[6]\t","\t",$homo[1]/($homo[1]+$hetero[1]),"\t",$homo[2]/($homo[2]+$hetero[2]),"\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t$infor[7]\n";}
if ($fix1_tag==0 and $fix2_tag==1) {$unique2++;print O4 "$infor[0]\t$infor[1]\t$infor[2]\t$infor[3]\t$infor[4]\t$infor[5]\t$infor[6]\t","\t",$homo[1]/($homo[1]+$hetero[1]),"\t",$homo[2]/($homo[2]+$hetero[2]),"\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t$infor[7]\n";}

if ($fix1_tag==0 and $fix2_tag==0) {
	$other++;
		#print CON1 "$infor[0]\t$infor[1]\t$infor[2]\t$infor[3]\t$infor[4]\t$infor[5]\t$infor[6]\t","\t",$homo[1]/($homo[1]+$hetero[1]),"\t",$homo[2]/($homo[2]+$hetero[2]),"\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t$infor[7]\n";
}


if (abs($f1/($f1+$q1)-$f2/($f2+$q2))>=$allele_freq_diff) {
	print O "$infor[0]\t$infor[1]\t$infor[2]\t$infor[3]\t$infor[4]\t$high_allele\t$low_allele\t$infor[5]\t$infor[6]\t","\t",$homo[1]/($homo[1]+$hetero[1]),"\t",$homo[2]/($homo[2]+$hetero[2]),"\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t$infor[7]\n";
	}


}

print STDERR "all:$all\tall_fix:$all_fix\tcommon:$common\tdiff:$diff\tfix1:$fix1\tfix2:$fix2\tunique1:$unique1\tunique2:$unique2\tother:$other\n";



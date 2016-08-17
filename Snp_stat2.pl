#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw/ uniq /;
#my @unique = uniq @faculty;

open IN,$ARGV[0]||die;
open L,$ARGV[1]||die; # gene and transcript relationship file
my %hash;
my %gene;
my %hash_type;

while (<L>) {
	chomp;
	my @infor=split;
	$gene{$infor[1]}=$infor[0];
}

#EFF=INTRON(MODIFIER||||363|MAPK14|protein_coding|CODING|ENSGALT00000001203|8)
while (<IN>) {
	chomp;
	if (/^\#/) {next;}
	my @infor=split;

	my $type;
	my $trans_name;
	if (!($_=~/EFF=/)) {next;}
	my $eff_infor=(split /;/,$infor[7])[-1];
	$eff_infor=~s/EFF=//;
	my @eff=split /,/,$eff_infor;
	foreach my $item (@eff) {
	if ($item=~/(\w+)\((\S*)\)/) {
		$type=$1;
		my $tmp=$2;
		$trans_name=(split/\|/,$tmp)[8];
	}
		if ($type eq 'INTERGENIC') {next;}
		#if ($type=~/SPLICE/) {print $_,"\n";exit;}
		$hash_type{$type}++;
		$hash{$gene{$trans_name}}{$type}++;
	}

	#exit;
}

#UPSTREAM
#NON_SYNONYMOUS_CODING
#UTR_5_PRIME
#START_GAINED
#STOP_LOST
#UTR_3_PRIME
#SPLICE_SITE_DONOR
#STOP_GAINED
#SPLICE_SITE_ACCEPTOR
#EXON
#START_LOST

#DOWNSTREAM
#INTRON
#INTERGENIC
#SYNONYMOUS_CODING
print "#gene\t";
foreach my $key (sort{$a cmp $b}keys %hash_type) {
print "$key\t";
}
print "\n";
foreach my $key (keys %hash) {
	print "$key\t";
	my $tag;
	foreach my $key2 (sort{$a cmp $b} keys %hash_type) {
		if (!exists $hash{$key}{$key2}) {
			$hash{$key}{$key2}=0;
		}
	}
#$hash{$key}{'UPSTREAM'}>0 or 
	if ($hash{$key}{'NON_SYNONYMOUS_CODING'}>0 or $hash{$key}{'START_GAINED'}>0 or $hash{$key}{'STOP_LOST'}>0 or $hash{$key}{'SPLICE_SITE_DONOR'}>0 or $hash{$key}{'STOP_GAINED'}>0 or $hash{$key}{'SPLICE_SITE_ACCEPTOR'}>0 or $hash{$key}{'START_LOST'}>0) {
		$tag="major";
	}
	else{
		$tag="minor";
	}
	print "$tag\t";
	foreach my $key2 (sort{$a cmp $b}keys %hash_type) {
			print "$hash{$key}{$key2}\t";
	}

	print "\n";
}

#!/usr/bin/perl
use strict;
use warnings;

open S,$ARGV[0]||die; #snp list
#chr10   907377  .       T       C       C       T       72.17   PASS            1       0.6     0       1       0.8     0.2     AC=12;

my %hash;
while (<S>) {
	chomp;
	my @infor=split;
	my $chr=$infor[0];
	$chr=~s/chr//;$chr=uc($chr);
	#print "$chr\n";exit;
	$hash{$chr}{$infor[1]}->[0]=$infor[5];
	$hash{$chr}{$infor[1]}->[1]=$infor[6];
}
close S;

my %seq1;
my %seq2;
open IN,$ARGV[1]||die;#genome file
my $chr;
while (<IN>) {
	chomp;
	if (/^>/) {
		my @infor=split;
		$chr=$infor[0];$chr=~s/>//;
		#print $chr,"\n";
	}else{
		#print $chr,"\n";exit;
		$seq1{$chr}.=$_;
		$seq2{$chr}.=$_;
	}
}
close IN;

foreach my $chr (keys %seq1) {
	if (!exists $hash{$chr}) {next;}
	#print ">>>$chr\n";
	foreach my $pos (keys %{$hash{$chr}}) {
		substr($seq1{$chr},$pos-1,1)=$hash{$chr}{$pos}->[0];
		substr($seq2{$chr},$pos-1,1)=$hash{$chr}{$pos}->[1];
	}
}

open O1,">$ARGV[2]"||die;
my $species=$ARGV[3]||die;

foreach my $key (keys %seq1) {
	if($seq1{$key} eq $seq2{$key}){print "$key\tyes\n";}else{print "$key\tno\n";}
if ($species eq "high") {
	print O1 ">$key\n$seq1{$key}\n";
}
elsif($species eq "low"){
	print O1 ">$key\n$seq2{$key}\n";
}
	
}
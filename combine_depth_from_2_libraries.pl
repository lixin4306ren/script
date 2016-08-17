#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
open IN2,$ARGV[1]||die;

my %hash;
my %hash2;
while (my $line=<IN>) {
	chomp $line;
	my @infor=split /\s+/,$line;
	$hash{$infor[0]}+=$infor[2];
	$hash2{$infor[0]}+=$infor[3];
	$line=<IN>;
	chomp $line;
	@infor=split/\s+/,$line;
	$hash{$infor[0]-1}+=$infor[2];
	$hash2{$infor[0]-1}+=$infor[3];
}
close IN;

while (my $line=<IN2>) {
	chomp $line;
	my @infor=split/\s+/,$line;
	my $m+=$hash{$infor[0]};
	my $t+=$hash2{$infor[0]};
	$m+=$infor[2];
	$t+=$infor[3];
	$line=<IN2>;
	chomp $line;
	@infor=split/\s+/,$line;
	$m+=$infor[2];
	$t+=$infor[3];
	print $infor[0]-1,"\t1\t","$m\t$t\n"; 
}

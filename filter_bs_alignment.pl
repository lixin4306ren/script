#!/usr/bin/perl
use strict;
use warnings;

open IN,"samtools view $ARGV[0]|"||die;

my %insert_len;
my %num;
while (<IN>) {
	chomp;
	my @infor=split;
	my $read_name=(split/\_/,$infor[0])[0];
	$insert_len{$read_name}=abs($infor[8]);
	$num{$read_name}++;
}

foreach my $key (keys %insert_len) {
	print "$key\t$insert_len{$key}\t$num{$key}\n";
}


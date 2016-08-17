#!/usr/bin/perl -w

#........
#use strict;
use File::Basename qw(basename dirname);

my %hash;
open L,$ARGV[0]||die; #chr list
my $head="";
while (<L>) { 
	chomp;
	my @infor=split;
	$hash{$infor[0]}=$infor[0];
}
close L;

my $tmp=basename($ARGV[1]);
my $sample_name=(split/\./,$tmp)[0];
#print "$tmp\t$sample_name\n";exit;
my $file_handle;

open IN,$ARGV[1]||die; #data file
while (<IN>){
	if (/^\#/) {
		$head.=$_;
	}
	else{last;}
}
close IN;

foreach my $key (keys %hash) {
	my $file_name="$sample_name.$hash{$key}";
	$file_handle=$key;
	print "$file_name.cpg.raw.vcf\n";
	open $file_handle,">$file_name.cpg.raw.vcf"||die;
	print $file_handle $head;
}


print "out\n";

open IN,$ARGV[1]||die; #data file
while (<IN>){
	chomp;
	if (/^\#/) {next;}
	my @infor=split;
	my $chr=$infor[0];
	$file_handle=$chr;
	print $file_handle "$_\n";
}
close IN;

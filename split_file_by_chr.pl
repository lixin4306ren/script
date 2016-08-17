#!/usr/bin/perl -w

#........
#use strict;
use File::Basename qw(basename dirname);

my %hash;
open IN,$ARGV[0]||die;
my $col=$ARGV[1]||=1;
while (<IN>) {
        chomp;
        my @infor=split;
        $hash{$infor[$col-1]}=$infor[$col-1];
		#print "$infor[$col-1]\n";
}
close IN;

my $tmp=basename($ARGV[0]);

my $file_handle;
foreach my $key (keys %hash) {
        my $file_name="$hash{$key}.bis";
        $file_handle=$key;
        open $file_handle,">$file_name"||die;
}

open IN,$ARGV[0]||die;
while (<IN>){
        chomp;
        my @infor=split;
        my $chr=$infor[$col-1];
        $file_handle=$chr;
        my $file_name="$chr.bis";
        print $file_handle "$_\n";
}


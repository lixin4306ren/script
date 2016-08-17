#!/usr/bin/perl
use strict;
use warnings;

#chr10   10868632        HWI-ST1417:155:D29GUACXX:6:1106:11014:80364_1:N:0:GCCAAT        C       1       1       67      J       -1

#HWI-ST1417:155:D29GUACXX:2:1216:8618:9891       0       1       0

open IN,"gzip -dc $ARGV[0]|"||die;
open L1,$ARGV[1]||die;
open L2,$ARGV[2]||die;
open O1, ">$ARGV[3]"||die;
open O2, ">$ARGV[4]"||die;

my %hash;
while (<L1>){
	chomp;
	my @infor=split;
	$hash{$infor[0]}=$infor[1];
}
close L1;

while (<L2>){
	chomp;
	my @infor=split;
	$hash{$infor[0]}=$infor[1];
}
close L2;

print "starting\n";
while (<IN>) {
	chomp;
	my @infor=split;
	my $read_name=(split /_/,$infor[2])[0];
	#print "$read_name\n";
	if (exists $hash{$read_name}) {
		if ($hash{$read_name}==0) {
			print O1 $_,"\n";
		}elsif($hash{$read_name}==1){
			print O2 $_,"\n";
		}
	}
}


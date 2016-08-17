#!/usr/bin/perl
use strict;
use warnings;

#open IN,$ARGV[0]||die;

my %chr;
my %max;
my %min;
while (<>) {
	chomp;
	my @infor=split;
	if (!exists $chr{$infor[2]}) {
		$chr{$infor[2]}=$infor[0];
		$max{$infor[2]}=$infor[1];
		$min{$infor[2]}=$infor[1];
	}
	else{
		if ($infor[0] ne $chr{$infor[2]}) {
			die "wrong\n";
		}
		
		if ($infor[1]<$min{$infor[2]}) {$min{$infor[2]}=$infor[1];}
		if ($infor[1]>$max{$infor[2]}) {$max{$infor[2]}=$infor[1];}
	}
}

foreach my $key (keys %chr) {
	print "$chr{$key}\t$min{$key}\t$max{$key}\t$key\n";
}

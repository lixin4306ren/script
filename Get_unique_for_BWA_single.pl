#!/usr/bin/perl
use strict;
use warnings;

#open IN,$ARGV[0]||die;
while (<>) {
	chomp;
	if (/^@/) {print "$_\n";next;}
	
	my @infor=split;
	my $name1=$infor[0];
	my $tag1=0;
	if ($_=~/XT\:A\:U/) {
		print "$_\n";
	}
}


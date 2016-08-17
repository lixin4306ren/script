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
	if ($_=~/XT\:A\:U/ or $_=~/XT\:A\:M/) {$tag1=1;}
	my $line1=$_;
	$_=<>;chomp;
	my $line2=$_;
	my @infor2=split;
	my $name2=$infor2[0];
	my $tag2=0;
	if ($_=~/XT\:A\:U/ or $_=~/XT\:A\:M/) {$tag2=1;}
	if($name1 ne $name2){die "wrong!";exit;}
	if ($tag1==1 and $tag2==1) {
		print "$line1\n$line2\n";
	}
}


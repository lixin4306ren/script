#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
my $tag=0;
while (my $file=<IN>) {
	chomp $file;
	open TMP,$file||die;
	while (my $line=<TMP>) {
		if ($line=~/^\#/) {
			if ($tag==0) {print "$line";}
		}
		else{
			$tag=1;
			print "$line";
		}
	}
	close TMP;
}

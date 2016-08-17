#!/usr/bin/perl -w

use strict;
use Getopt::Long;
open IN,"$ARGV[0]" || die"!";
my $name=(split /\//,$ARGV[0])[-1];
my $total;
my $num=$ARGV[1];
while (<IN>) {
	$total++;
}
close IN;

my $index=1;
my $count;
open IN,"$ARGV[0]" || die"!";
open TMP, ">>$name.$index";

while (<IN>) {
	print TMP $_;
	$count++;
	if ($count>=$total/$num) {close TMP;$index++;$count=0;open TMP, ">>$name.$index";}
}
close IN;



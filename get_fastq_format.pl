#!/usr/bin/perl
use strict;
use warnings;

open IN,"zcat $ARGV[0]|"||die;
my $num=1;
my %hash;
while (<IN>) {
	chomp;
	if ($num % 4==0) {
		for (my $i=0;$i<length($_) ;$i++) {
			my $ascii=ord(substr($_,$i,1));
			$hash{$ascii}++;
		}
		
	}
	$num++;
if ($num>1000000) {last;}
}
my $total;
foreach my $key (keys %hash) {
        $total+=$hash{$key};
}
foreach my $key (keys %hash) {
	print "$key\t$hash{$key}\t",$hash{$key}/$total,"\n";
}


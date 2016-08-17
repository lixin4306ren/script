#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
my %seq;
my $name;
while (<IN>) {
	chomp;
	if (/^>/) {
		$name=$_;$name=~s/>//;
		print STDERR "$name\n";
	}
	else{
		$seq{$name}.=$_;
	}
}

my $tag=0;
my $start;
my $end;
foreach my $key (keys %seq) {
	my $len=length($seq{$key});
	print STDERR "$key\n";
	for (my $i=0;$i<$len ;$i++) {
		my $char=substr($seq{$key},$i,1);
		if ($char eq 'N' and $tag==0) {
			$tag=1;$start=$i;
		}
		elsif($tag==1 and $char ne 'N'){
			$end=$i;$tag=0;
			print "$key\t$start\t$end\tX\t0\t+\n";
		}
	}
	if (substr($seq{$key},$len-1,1) eq 'N') {
		$end=$len;
		print "$key\t$start\t$end\tX\t0\t+\n";$tag=0;
	}
}


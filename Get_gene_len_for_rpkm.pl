#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
open O,">$ARGV[1]"||die;
my %hash;
my %len;
my $process=0;
while (<IN>) {
	chomp;
	my @infor=split/\t/,$_;
	if ($infor[2] ne 'exon') {next;}
	$process++;
	if ($process % 10000 ==0) {
		print $process,"\n";
	}
	my $gene;
#	print $infor[8]
	if ($infor[8]=~/gene_id \"(\w+)\"; trans/) {
		$gene=$1;
		#print "$gene\n";exit;
	}
	#exit;
	for (my $i=$infor[3];$i<=$infor[4] ;$i++) {
		if (!exists $hash{$gene}{$i}) {
			$hash{$gene}{$i}=1;
			$len{$gene}++;
		}
	}

}

foreach my $key (keys %len) {
	print O "$key\t$len{$key}\n";
}

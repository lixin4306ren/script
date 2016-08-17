#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
my $cov=$ARGV[1]||=10;
my $level=$ARGV[2]||=0.8;
while (<IN>) {
	chomp;
	my $dir;
	my $tmp=(split/\s+/,$_)[0];
	if ($tmp=~s/\///) {
		$dir=(split /\//,$tmp)[-1];
	}
	else{$dir=$tmp;}
	
	if (!$dir=~/_BS$/) {next;}
	my $dir2=$dir;$dir2=~s/_BS/_ox/;
	my %hash;
	my %hash2;
	my $tmp_file="$dir/all/lambda.cg";
	open TMP_OUT,">$dir/all/lambda.hmc.cg";
	open TMP,$tmp_file||die;
	while (my $line=<TMP>) {
		chomp $line;
		my @infor=split /\s+/,$line;
		if($infor[3]>$cov ){
			if ($infor[2]/$infor[3]<$level) {next;}
			$hash{$infor[0]}=1;
		}
	}
	close TMP;
	close TMP_OUT;

	$tmp_file="$dir2/all/lambda.cg";
	open TMP_OUT,">$dir2/all/lambda.hmc.cg";
	open TMP,$tmp_file||die;
	while (my $line=<TMP>) {
		chomp $line;
		my @infor=split /\s+/,$line;
		if (exists $hash{$infor[0]} and $infor[3]>$cov) {
			$hash2{$infor[0]}=1;
			print TMP_OUT $line,"\n";
		}
	}
	close TMP;
	close TMP_OUT;

	$tmp_file="$dir/all/lambda.cg";
	open TMP_OUT,">$dir/all/lambda.hmc.cg";
	open TMP,$tmp_file||die;
	while (my $line=<TMP>) {
		chomp $line;
		my @infor=split /\s+/,$line;
		if(exists $hash2{$infor[0]} ){
			print TMP_OUT $line,"\n";
		}
	}
	close TMP;
	close TMP_OUT;
}
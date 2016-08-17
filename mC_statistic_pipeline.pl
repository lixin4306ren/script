#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die; #sample_list
my $out_file=$ARGV[1]||die;
my $type=$ARGV[2]||="BS";
my $type2=$ARGV[3]||="all";

my $cmd;
while (<IN>) {
	chomp;
	my $dir;
	my $tmp=(split/\s+/,$_)[0];
	if ($tmp=~s/\///) {
		$dir=(split /\//,$tmp)[-1];
	}
	else{$dir=$tmp;}
	#print "$dir\n";next;
	if (!(-d "stat")) {
		$cmd="mkdir stat";
		print "$cmd\n";
		`$cmd`;
	}
	$cmd="cat $dir/$type2/chr*.cg|perl ~/scripts/mC_statistic.pl 1 > stat/$dir.stat ";
	print "$cmd\n";
	`$cmd`;
	if (-e "$dir/$type2/ecoli.cg") {
		$cmd="cat $dir/$type2/ecoli.cg|perl ~/scripts/mC_statistic.pl 1 > stat/$dir.ecoli.stat";
		`$cmd`;
		print "$cmd\n";
	}
	
if ($type eq 'BS') {
	if(-e "$dir/$type2/lambda.cg"){
	$cmd="cat $dir/$type2/lambda.cg|perl ~/scripts/mC_statistic.pl 1 > stat/$dir.labmda.stat";
	}
	else{
	$cmd="cat $dir/$type2/chrMT.cg|perl ~/scripts/mC_statistic.pl 1 > stat/$dir.chrMT.stat";
	}
}
elsif($type eq "OX"){
	$cmd="cat $dir/$type2/lambda.cg|perl ~/scripts/mC_statistic.pl 1 > stat/$dir.labmda.hmc.stat";
}
	print "$cmd\n";
	`$cmd`;
}

$cmd="perl ~/scripts/mC_statistic2.pl stat $type > stat/$out_file";
`$cmd`;
print $cmd,"\n";

#!/usr/bin/perl
use strict;
use warnings;

my $dir=$ARGV[0]||die;
my $file_list=$ARGV[1];
my %dup;
my %remove;
opendir D,$dir||die;
while (my $file=readdir(D)) {
	my $dup_rate;
	my $sample_name;
	my $remove_reads;
	my $total_reads;
	if (!($file=~/\.sh$/)) {next;}
	else{

		#print $dir.$file,"\n";exit;
		open TMP,$dir.$file||die;
		my $cmd=<TMP>;
		my $tmp_name=(split /\s+/,$cmd)[-3];
		my $tmp_name2=(split /\//,$tmp_name)[-1];
		$sample_name=(split /\./,$tmp_name2)[0];
		#print "$tmp_name\t$sample_name\n";exit;
		close TMP;
		$file=~s/sh/e/;
		open TMP,$dir.$file||die;
		while (my $line=<TMP>) {
			if ($line=~/library/) {
				$dup_rate=(split /\s+/,$line)[5];
				$remove_reads=(split /\s+/,$line)[1];
				$total_reads=(split /\s+/,$line)[3];
			}
		}
		close TMP;
	}
	
	$dup{$sample_name}=$dup_rate;
	$remove{$sample_name}=$remove_reads*2;
	print "$sample_name\t$dup_rate\t$total_reads\n";
}
closedir D;

open L,$file_list||die;
my %mapping_rate;
my %read_num;
while (<L>) {
	chomp;
	my $sample_name=(split /\//,$_)[-1];
	my $file_name=$sample_name.".sort.rmdup.bam";
	my $cmd="samtools flagstat $file_name";
	my @data=`$cmd`;
	#print "$/sample_name\n";
	my $read_num;
	my $mapping_rate;
	foreach my $item (@data) {
		#print $item,"\n";
		if ($item=~/in total/) {
			$read_num{$sample_name}=(split /\s+/,$item)[0]+$remove{$sample_name};
		}
		elsif($item=~/0 mapped \((.*)\:.*\)/){
			$mapping_rate{$sample_name}=$1;
		}
	}
	#print "$sample_name\t$mapping_rate{$sample_name}\t$read_num{$sample_name}\n";
}
close L;
print "Sample_name\tTotal_reads\tMapping_rate\tDuplicates_rate\n";
foreach my $key (keys %mapping_rate){
	print "$key\t$read_num{$key}\t$mapping_rate{$key}\t$dup{$key}\n";

}
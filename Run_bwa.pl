#!/usr/bin/perl
use strict;
use warnings;

my $data_dir=$ARGV[0]||die;#/amber3/feinbergLab/core/sequencing/hiseq/HiSeq033/Project_Bisulfite/Sample_HW_BM_L144
my $index_dir=$ARGV[1]||die;
my $setting=$ARGV[2]||="mem";
#my $genome_dir=$ARGV[2]||die;
my $out_dir=(split/\//,$data_dir)[-1];
my $sample_name=$out_dir;
$sample_name=~s/Sample_//g;$out_dir=~s/Sample_//g;
$out_dir=~s/Liv//i;$out_dir=~s/BM//i;$out_dir=~s/_//g;$out_dir=~s/-//g;$out_dir=~s/SNP//g;
print STDERR "samtools merge -fh $out_dir.rg $out_dir.sort.bam $sample_name*.sort.bam\n";

my $file_handle="$out_dir.rg";
open O,">$file_handle"||die;
print O "\@RG\tID:$out_dir\tSM:$out_dir\tPL:illumina\tLB:$out_dir\tPU:$out_dir";
close O;

opendir DB,$data_dir;
my @db=readdir(DB);
closedir DB;
my $fold_name=0;
foreach my $item (@db) {
	if ($item=~/.*R1_.*\.fastq\.gz$/ or $item=~/.*R1_.*\.fq\.bz2$/) {
		my $item2=$item;
		$item2=~s/R1/R2/;
		#HW_BM_L144_GCCAAT_L003_R1_005.fastq.gz
		my $tmp=(split /_/,$item)[-1];
		$fold_name++;

		print STDOUT "/home/jhmi/xinli/soft/bwa-0.7.12/bwa $setting -M $index_dir $data_dir/$item  $data_dir/$item2 |samtools view -bS - |samtools sort - $item.sort\n";
	}
}


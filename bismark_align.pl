#!/usr/bin/perl
use strict;
use warnings;

my $data_dir=$ARGV[0]||die;#/amber3/feinbergLab/core/sequencing/hiseq/HiSeq033/Project_Bisulfite/Sample_HW_BM_L144
my $index_dir=$ARGV[1]||die;
my $setting=$ARGV[2]||="--bowtie2";
#my $genome_dir=$ARGV[2]||die;

my $out_dir=(split/\//,$data_dir)[-1];
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

		print "bismark $setting $index_dir --output_dir $out_dir -1 $data_dir/$item -2 $data_dir/$item2\n";
	}
}


#!/usr/bin/perl
use strict;
use warnings;

my $data_dir=$ARGV[0]||die;#/amber3/feinbergLab/core/sequencing/hiseq/HiSeq033/Project_Bisulfite/Sample_HW_BM_L144
#my $index_dir=$ARGV[1]||die;
my $genome_dir=$ARGV[1]||die;

my $out_dir=(split/\//,$data_dir)[-1];
opendir DB,$data_dir;
my @db=readdir(DB);
closedir DB;
my $fold_name=0;
foreach my $item (@db) {
	if ($item=~/.*R1_.*\.fastq\.gz$/) {
		my $item2=$item;
		$item2=~s/R1/R2/;
		#HW_BM_L144_GCCAAT_L003_R1_005.fastq.gz
		#my $tmp=(split /_/,$item)[-1];

		print "bwa aln $genome_dir $data_dir/$item > $out_dir/$item.sai\n";
		print "bwa aln $genome_dir $data_dir/$item2 > $out_dir/$item2.sai\n";
	}
}


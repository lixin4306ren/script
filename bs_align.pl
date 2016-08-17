#!/usr/bin/perl
use strict;
use warnings;

my $data_dir=$ARGV[0]||die;#/amber3/feinbergLab/core/sequencing/hiseq/HiSeq033/Project_Bisulfite/Sample_HW_BM_L144
my $index_dir=$ARGV[1]||die;
my $genome_dir=$ARGV[2]||die;
my $noncg=$ARGV[3]||="no";
my $bowtie2_prameters=$ARGV[4]||="";
#print $bowtie2_prameters,"\n";exit;
my $out_dir=(split/\//,$data_dir)[-1];
opendir DB,$data_dir;
my @db=readdir(DB);
closedir DB;
my $fold_name=0;
#130427_I277_FCC1UTBACXX_L8_NIGqlpHLODEABPEMI-30_2.fq.gz
foreach my $item (@db) {
	if ($item=~/.*R1_.*\.fastq\.gz$/) {
		my $item2=$item;
		$item2=~s/R1/R3/;
		#print ">>>$item2\n";
		if(-e "$data_dir/$item2"){$item2=$item2;}
		else{
			$item2=~s/R3/R2/;
		}
		#HW_BM_L144_GCCAAT_L003_R1_005.fastq.gz
		my $tmp=(split /_/,$item)[-1];
		$fold_name++;
		if ($noncg eq "yes") {
			print "/home/jhmi/xinli/soft/bsmooth-align-0.7.1/bin/bswc_bowtie2_align.pl --bsc --gzip --bam=$out_dir/$fold_name --temp=$out_dir/ --out=$out_dir/$fold_name/ -- $index_dir -- $genome_dir -- \"$bowtie2_prameters\" -- $data_dir/$item -- $data_dir/$item2\n";
		}
		else
		{
			print "/home/jhmi/xinli/soft/bsmooth-align-0.7.1/bin/bswc_bowtie2_align.pl --bscpg --gzip --bam=$out_dir/$fold_name --temp=$out_dir/ --out=$out_dir/$fold_name/ -- $index_dir -- $genome_dir -- \"$bowtie2_prameters\" -- $data_dir/$item -- $data_dir/$item2\n";
		}
	}
	elsif($item=~/.*_1\.fq\.gz$/){
                my $item2=$item;
                $item2=~s/_1\.fq/_2\.fq/;
                my $tmp=(split /_/,$item)[-1];
                $fold_name++;
		if($noncg eq 'yes'){
			print "/home/jhmi/xinli/soft/bsmooth-align-0.7.1/bin/bswc_bowtie2_align.pl --bsc --gzip --bam=$out_dir/$fold_name --temp=$out_dir/ --out=$out_dir/$fold_name/ -- $index_dir -- $genome_dir -- \"$bowtie2_prameters\" -- $data_dir/$item -- $data_dir/$item2\n";
		}
		else{
			print "/home/jhmi/xinli/soft/bsmooth-align-0.7.1/bin/bswc_bowtie2_align.pl --bscpg --gzip --bam=$out_dir/$fold_name --temp=$out_dir/ --out=$out_dir/$fold_name/ -- $index_dir -- $genome_dir -- \"$bowtie2_prameters\" -- $data_dir/$item -- $data_dir/$item2\n";
		}


	}
}


#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;

my ($tdf_name,$sample_list,$noncg,$bedfile_folder,$chr_list,$step,$reference,$reference_dir,$bowtie_path,$help,$out,$out2,$mapq,$baseq,$trim_5_len,$fdr_level,$rate,$correct,$strand,$only_depth, $bowtie2_prameters,$read_len);

my $Function='align and extract methylation matrix pipline';

GetOptions(
        "sample_list:s"=>\$sample_list,
        "chr_list:s"=>\$chr_list,
	"reference:s"=>\$reference,
	"reference_dir:s"=>\$reference_dir,
	"bowtie2_prameters:s"=>\$bowtie2_prameters,
        "help"=>\$help,
        "CG:s"=>\$out,
        "NCG:s"=>\$noncg,
        "mapq:s"=>\$mapq,
        "base_qual:s"=>\$baseq,
        "trim_5_len:s"=>\$trim_5_len,
	"read_len:s"=>\$read_len,
        "fdr:s"=>\$fdr_level,
        "rate:s"=>\$rate,
        "correct:s"=>\$correct,
        "strand:s"=>\$strand,
	"step:s"=>\$step,
	"bowtie_path:s"=>\$bowtie_path,
	"tdf_name:s"=>\$tdf_name,
	"only_depth:s"=>\$only_depth,
	"bedfile_folder:s"=>\$bedfile_folder,
);
if (!defined $bowtie2_prameters) {$bowtie2_prameters="";}
if (!defined $noncg) {$noncg="no";}
if (!defined $tdf_name) {$tdf_name="hg19";}
if (!defined ($mapq)) {$mapq=20;}
if (!defined ($trim_5_len)) {$trim_5_len=10;}
if (!defined ($baseq)) {$baseq=10;}
if (!defined ($correct)) {$correct=0;}
if (!defined $strand) {$strand ="both";}
if (!defined $bedfile_folder) {$bedfile_folder="all";}
my @fdr=($fdr_level)||=(0.05);
if(!defined $sample_list|| !defined $read_len){Usage();}
#print ">>>>>>>>>>>\n";
if ($correct ==1 && !defined ($rate)) {
        print "need give converation error rate\n";
        Usage();
}

if ($step eq 'align') {
	open TMP,">align.sh"||die;
	print "$sample_list\n$reference\n$bowtie_path\n$step\n";
	if(!defined($sample_list) ||!$reference||defined($help)||!defined($step)||!defined($bowtie_path) ){Usage();}

	open IN,$sample_list||die;

	while (my $line=<IN>) {
		chomp $line;
		my @tmp=split/\s+/,$line;
        my @infor=split /\//,$tmp[0];
		my $sample_name=$infor[-1];
		$bowtie2_prameters=~s/\\//g;
		my $cmd="perl /home/jhmi/xinli/scripts/bs_align.pl $tmp[0] $bowtie_path $reference $noncg \"$bowtie2_prameters\"";
		#print $bowtie2_prameters,"<<<<<<<\n";
		my @data=`$cmd`;
		print TMP @data;
	}
	close IN;
	close TMP;
my $tmp_cmd="perl /home/jhmi/xinli/scripts/qsub_sge.pl --resource cegs,mf=10G,h_vmem=5G --pe 3 align.sh";
#system($tmp_cmd);

}
elsif($step eq 'depth'){
if(!defined($sample_list) ||!defined($chr_list) ||!defined ($reference_dir)||defined($help)||!defined($step) ){

        Usage();

}
if (!defined $only_depth) {

open IN,$sample_list||die;

my $index=0;
my $tmp_cmd="";
while (my $line1=<IN>) {
	#print "$line1\n";
        chomp $line1;
		my @tmp=split/\s+/,$line1;
        my @infor=split /\//,$tmp[0];
		my $sample_name=$infor[-1];
		if (! -d "$infor[-1]/all") {
			$tmp_cmd="mkdir $sample_name/all";
			`$tmp_cmd`;
		}
		
        open IN2,$chr_list||die;
        while (my $line2=<IN2>) {
				$index++;
				my $cmd="";
                #if($line2=~/lambda/){next;}
                chomp $line2;
                my @infor2=split /\./,$line2;
				$line2=~s/\.ev.tsv.gz//;
				#print "$reference_dir\n";
				$cmd.="(cat $sample_name/?/$line2.ev.tsv.gz $sample_name/??/$line2.ev.tsv.gz > $sample_name/all/$line2.ev.tsv.gz) &&";
                if ($noncg eq 'yes') {
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/all/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/all/$infor2[0].cg -NCG $sample_name/all/$infor2[0].ncg -correct $correct -trim_5_len $trim_5_len -mapq $mapq -read_len $read_len)";
				}
				else{
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/all/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/all/$infor2[0].cg -correct $correct -trim_5_len $trim_5_len -mapq $mapq -read_len $read_len)";
				}
				if(!($line2=~/lambda/)){
					if ($noncg eq 'yes') {
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/all) & perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].ncg";
					}else{
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/all)";
					}
				
				}
		if ($index==1) {

			my $file="depth.sh";
			open TMP,">$file"||die;
			print TMP "$cmd\n";
			close TMP;
		}
		else{
			my $file="depth.sh";
			open TMP,">>$file"||die;
			print TMP "$cmd\n";
			close TMP;
			}
		}
        close IN2;
}
close IN;
$tmp_cmd="perl /home/jhmi/xinli/scripts/qsub_sge.pl depth.sh";

}else{

open IN,$sample_list||die;

my $index=0;
my $tmp_cmd="";
while (my $line1=<IN>) {
	#print "$line1\n";
        chomp $line1;
		my @tmp=split/\s+/,$line1;
        my @infor=split /\//,$tmp[0];
		my $sample_name=$infor[-1];

		
        open IN2,$chr_list||die;
        while (my $line2=<IN2>) {
				$index++;
				my $cmd="";
                #if($line2=~/lambda/){next;}
                chomp $line2;
                my @infor2=split /\./,$line2;
				$line2=~s/\.ev.tsv.gz//;
				#print "$reference_dir\n";
                if ($noncg eq 'yes') {
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/$only_depth/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/$only_depth/$infor2[0].cg -NCG $sample_name/$only_depth/$infor2[0].ncg -correct $correct -trim_5_len $trim_5_len -mapq $mapq -read_len $read_len)";
				}
				else{
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/$only_depth/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/$only_depth/$infor2[0].cg -correct $correct -trim_5_len $trim_5_len -mapq $mapq -read_len $read_len)";
				}
				if(!($line2=~/lambda/)){
					if ($noncg eq 'yes') {
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/$only_depth) & perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].ncg";
					}else{
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/$only_depth)";
					}
				
				}
		if ($index==1) {

			my $file="depth.$only_depth.sh";
			open TMP,">$file"||die;
			print TMP "$cmd\n";
			close TMP;
		}
		else{
			my $file="depth.$only_depth.sh";
			open TMP,">>$file"||die;
			print TMP "$cmd\n";
			close TMP;
			}
		}
        close IN2;
}
close IN;
}

}
elsif($step eq 'capture_depth'){
if(!defined($sample_list) ||!defined($chr_list) ||!defined ($reference_dir)||defined($help)||!defined($step) ){

        Usage();

}
if (!defined $only_depth) {

open IN,$sample_list||die;

my $index=0;
my $tmp_cmd="";
while (my $line1=<IN>) {
	#print "$line1\n";
        chomp $line1;
		my @tmp=split/\s+/,$line1;
        my @infor=split /\//,$tmp[0];
		my $sample_name=$infor[-1];
		if (! -d "$infor[-1]/filter_all") {
			$tmp_cmd="mkdir $sample_name/filter_all";
			`$tmp_cmd`;
		}
		
        open IN2,$chr_list||die;
        while (my $line2=<IN2>) {
				$index++;
				my $cmd="";
                #if($line2=~/lambda/){next;}
                chomp $line2;
                my @infor2=split /\./,$line2;
				$line2=~s/\.ev.tsv.gz//;
				#print "$reference_dir\n";
				$cmd.="(cat $sample_name/?/$line2.ev.tsv.gz $sample_name/??/$line2.ev.tsv.gz > $sample_name/all/$line2.ev.tsv.gz) &&";
                if ($noncg eq 'yes') {
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/all/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/filter_all/$infor2[0].cg -NCG $sample_name/filter_all/$infor2[0].ncg -correct $correct -trim_5_len $trim_5_len -insert_len_file $sample_name/all/all.crick.bam.sort.bam.list -insert_len_file2 $sample_name/all/all.watson.bam.sort.bam.list -mapq $mapq -read_len $read_len)";
				}
				else{
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/all/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/filter_all/$infor2[0].cg -correct $correct -trim_5_len $trim_5_len -insert_len_file $sample_name/all/all.crick.bam.sort.bam.list -insert_len_file2 $sample_name/all/all.watson.bam.sort.bam.list -mapq $mapq -read_len $read_len)";
				}
				if(!($line2=~/lambda/)){
					if ($noncg eq 'yes') {
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/filter_all) & perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].ncg";
					}else{
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/filter_all)";
					}
				
				}
		if ($index==1) {

			my $file="capture_depth.sh";
			open TMP,">$file"||die;
			print TMP "$cmd\n";
			close TMP;
		}
		else{
			my $file="capture_depth.sh";
			open TMP,">>$file"||die;
			print TMP "$cmd\n";
			close TMP;
			}
		}
        close IN2;
}
close IN;
$tmp_cmd="perl /home/jhmi/xinli/scripts/qsub_sge.pl capture_depth.sh";

}else{

open IN,$sample_list||die;

my $index=0;
my $tmp_cmd="";
while (my $line1=<IN>) {
	#print "$line1\n";
        chomp $line1;
		my @tmp=split/\s+/,$line1;
        my @infor=split /\//,$tmp[0];
		my $sample_name=$infor[-1];
                if (! -d "$infor[-1]/filter_all") {
                        $tmp_cmd="mkdir $sample_name/filter_all";
                        #print "~$infor[-1]\t$tmp_cmd";
                        `$tmp_cmd`;
                }

		
        open IN2,$chr_list||die;
        while (my $line2=<IN2>) {
				$index++;
				my $cmd="";
                chomp $line2;
                my @infor2=split /\./,$line2;
				$line2=~s/\.ev.tsv.gz//;
                if ($noncg eq 'yes') {
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/all/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/$only_depth/$infor2[0].cg -NCG $sample_name/$only_depth/$infor2[0].ncg -correct $correct -trim_5_len $trim_5_len -insert_len_file $sample_name/all/all.crick.bam.sort.bam.list -insert_len_file2 $sample_name/all/all.watson.bam.sort.bam.list -mapq $mapq -read_len $read_len)";
				}
				else{
					$cmd.="(perl /home/jhmi/xinli/scripts/soap_depth_one_chr_human_new.pl -soap  $sample_name/all/$line2.ev.tsv.gz -ref $reference_dir/$infor2[0].fa -strand $strand -CG $sample_name/$only_depth/$infor2[0].cg -correct $correct -trim_5_len $trim_5_len -insert_len_file $sample_name/all/all.crick.bam.sort.bam.list -insert_len_file2 $sample_name/all/all.watson.bam.sort.bam.list -mapq $mapq -read_len $read_len)";
				}
				if(!($line2=~/lambda/)){
					if ($noncg eq 'yes') {
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/$only_depth) & perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].ncg";
					}else{
						$cmd.="&& (perl /home/jhmi/xinli/scripts/Calculate_meth_sliding.pl $infor2[0].cg $sample_name/$only_depth)";
					}
				
				}
		if ($index==1) {

			my $file="capture_depth.$only_depth.sh";
			open TMP,">$file"||die;
			print TMP "$cmd\n";
			close TMP;
		}
		else{
			my $file="capture_depth.$only_depth.sh";
			open TMP,">>$file"||die;
			print TMP "$cmd\n";
			close TMP;
			}
		}
        close IN2;
}
close IN;
}

}
elsif($step eq 'tdf'){
		if (! -d "tdf") {
			my $tmp_cmd="mkdir tdf";
			`$tmp_cmd`;
		}

	my $cmd="";
	open IN,$sample_list||die;
	while (my $line1=<IN>) {
        chomp $line1;
		my @tmp=split/\s+/,$line1;
        my @infor=split /\//,$tmp[0];
		my $sample_name=$infor[-1];
		$cmd.="perl /home/jhmi/xinli/scripts/combine_depth_file.pl $sample_name/$bedfile_folder/ > $sample_name/$bedfile_folder/all.cg & cat $sample_name/$bedfile_folder/chr*.bed > $sample_name/$bedfile_folder/all.bedgraph & /home/jhmi/xinli/soft/IGVTools/igvtools toTDF $sample_name/$bedfile_folder/all.bedgraph tdf/$sample_name.meth.tdf $tdf_name\n";
	}
	open O, ">tdf.sh"||die;
	print O $cmd;
	close O;
}
elsif($step eq 'only_tdf'){
                if (! -d "tdf") {
                        my $tmp_cmd="mkdir tdf";
                        `$tmp_cmd`;
                }

        my $cmd="";
        open IN,$sample_list||die;
        while (my $line1=<IN>) {
        chomp $line1;
                my @tmp=split/\s+/,$line1;
        my @infor=split /\//,$tmp[0];
                my $sample_name=$infor[-1];
                $cmd.="cat $sample_name/$bedfile_folder/chr*.bed > $sample_name/$bedfile_folder/all.bedgraph & /home/jhmi/xinli/soft/IGVTools/igvtools toTDF $sample_name/$bedfile_folder/all.bedgraph tdf/$sample_name.meth.tdf $tdf_name\n";
        }
        open O, ">only_tdf.sh"||die;
        print O $cmd;
        close O;
}
elsif($step eq 'dmr'){
open TMP,">bsseq.R"||die;
print TMP << "SCRIPT";
source("/home/jhmi/xinli/r_scripts/bsseq.r")
dmr_pipeline(sample.list="$sample_list")

SCRIPT
close TMP;
my $cmd="Rscript --vanilla bsseq.R\n";
open TMP,">bsseq.sh"||die;
print TMP $cmd;
close TMP;
}

sub Usage {
    print << "    Usage";

        $Function

        Usage: $0 <options>

                -sample_list        sample list

		-read_len           read length                

		-chr_list           chr list

                -reference          reference fasta path

                -reference_dir      reference fasta dir by chr 

                -bowtie_path        bowtie index path

                -bowtie2_prameters  bowtie2 parameters

                -step               align or depth or capture_depth or tdf or dmr

                -only_depth         only generate depth matrix

                -tdf_name           genome version, default hg19

                -bedfile_folder     bed files folder

                -strand              + or - or both

                -NCG                 yes or no 

                -mapq                MAPQ cutoff, defalut 20

                -base_qual           base Quality cutoff, defalut 10

                -trim_5_len          length of trim from read 5', defalut 10

                -fdr                 fdr level, defalut 0.05

                -rate                control non-converstion rate

                -correct             perform fdr correction 1 or not 0, defalut 1

                -h or -help          Show Help , have a choice

    Usage
        exit;

}


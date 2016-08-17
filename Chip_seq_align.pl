#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;

my ($sample_list,$ref,$help,$step,$chip_list,$insert_len,$read_len,$keep_multihits,$bin_size_rseg,$type,$window_size,$step_size);

my $Function='Chip-Seq pipeline';

GetOptions(
        "sample_list:s"=>\$sample_list,
        "chip_list:s"=>\$chip_list,
        "ref:s"=>\$ref,
        "help"=>\$help,
        "step:s"=>\$step,
        "insert_len:s"=>\$insert_len,
        "read_len:s"=>\$read_len,
        "keep_multihits:s"=>\$keep_multihits,
        "bin_size_for_rseg:s"=>\$bin_size_rseg,
        "type:s"=>\$type,
		"window_size:s"=>\$window_size,
		"step_size:s"=>\$step_size,

);
#print $opt{bin_size_for_rseg};exit;

if(!defined($sample_list) ||!defined($step)||defined($help) ){

        Usage();

}

if (!defined $ref) {
$ref="/amber3/feinbergLab/personal/xinli/no_back_up/data/genome/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa";
}

if (!defined $keep_multihits) {
	$keep_multihits="No";
}

if (!defined $window_size) {$window_size=1000;}
if (!defined $step_size) {$step_size=1000;}

if ($step eq 'align') {

open IN,$sample_list;
open O,">align.sh"||die;
while (<IN>) {
	chomp;
	opendir DIR,$_;
	my $sample_name=(split /\//,$_)[-1];
	while (my $file=readdir(DIR)) {
		if ($file=~/.*_R1_.*fastq.gz$/) {
			my $pair=$file;
			$pair=~s/R1/R2/;

			#print ">>>$file\n";
			#print "$pair\n";
			my $cmd= "bwa aln $ref  $_/$file  > $file.sai && bwa aln $ref $_/$pair > $pair.sai && ";
			if ($keep_multihits eq 'No') {
				$cmd.="bwa sampe $ref $file.sai $pair.sai $_/$file $_/$pair |perl ~/scripts/Get_unique_for_BWA.pl|samtools view -bS - |samtools sort - $file.sort\n";
			}
			elsif($keep_multihits eq 'Yes'){
				$cmd.="bwa sampe $ref $file.sai $pair.sai $_/$file $_/$pair |samtools sort - $file.sort\n";
			}
			else{die "keep_multihits must be Yes or No\n";}
			#print $cmd;
			print O $cmd;
		}

	}
	closedir DIR;
}
close IN;
close O;

my $tmp_cmd="perl ~/scripts/qsub_sge.pl align.sh";
#system($tmp_cmd);

}
elsif($step eq 'merge_rmdup'){

open IN,$sample_list;
open O,">merge_rmdup.sh"||die;
while (<IN>) {
	chomp;
	opendir DIR,$_;
	my $sample_name=(split /\//,$_)[-1];
	my $cmd= "samtools merge - ";
	while (my $file=readdir(DIR)) {
		if ($file=~/.*_R1_.*fastq.gz$/) {
			$cmd.=" $file.sort.bam";
		}
	}
	closedir DIR;
	$cmd.="|samtools rmdup - $sample_name.sort.rmdup.bam\n";
	print O $cmd;
}
close IN;
close O;
my $tmp_cmd="perl ~/scripts/qsub_sge.pl merge_rmdup.sh";
system($tmp_cmd);

}
elsif($step eq "tobed"){
if(!defined $type){$type="pair";}
open IN,$sample_list;
open O,">tobed.$type.sh"||die;
while (<IN>) {
	chomp;
	my $sample_name=(split /\//,$_)[-1];
	my $cmd;
	if($type eq 'pair'){
		$cmd="perl ~/scripts/pairbam2bed_bwa.pl $sample_name.sort.rmdup.bam pair > $sample_name.sort.rmdup.bam.pair.bed";
	}
	elsif($type eq 'single'){
		$cmd="perl ~/scripts/pairbam2bed_bwa.pl $sample_name.sort.rmdup.bam real_single > $sample_name.sort.rmdup.bam.single.bed";
	}
	print O $cmd,"\n";
}
close IN;
close O;

}
elsif($step eq 'tdf'){
if(!defined($insert_len)||!defined($read_len)){Usage();}
open IN,$sample_list;
open O,">tdf.sh"||die;
while (<IN>) {
	chomp;
	my $sample_name=(split /\//,$_)[-1];
	my $tmp_e=$insert_len-$read_len;
	if (-e "$sample_name.sort.rmdup.bam.tdf") {next;}
	my $cmd="~/soft/IGVTools/igvtools count -z 10 -w 100 -e $tmp_e $sample_name.sort.rmdup.bam $sample_name.sort.rmdup.bam.tdf hg19";
	#print "$cmd\n";
	print O $cmd,"\n";
}
close IN;
close O;
my $tmp_cmd="perl ~/scripts/qsub_sge.pl tdf.sh";
#system($tmp_cmd);




open IN,$chip_list;
open O,">ratio.sh"||die;
if(!defined $type){$type="pair";}
while (<IN>) {
	chomp;
	my @infor=split;
	my $name1=(split /\./,$infor[0])[0];
	my $name2=(split /\./,$infor[1])[0];
	my $cmd;
	if($type eq 'pair'){
	if(-e "$infor[0].pair.bed" and -e "$infor[1].pair.bed" and !(-e "$infor[0].$infor[1].density.ratio.tdf")){
		$cmd="perl /home/jhmi/xinli/scripts/Calculate_enrich_ratio2.pl $infor[0].pair.bed $infor[1].pair.bed $name1 $name2 ~/amber3/Oliver/Chip-Seq/hg19.len $window_size $step_size hg19";
	}
	#elsif(-e "$infor[0].pair.bed" and -e "$infor[1].pair.bed" and -e "$infor[0].$infor[1].density.ratio.tdf"){
	#	
	#}
	else{
		die("no bed files");
	}
	}
	elsif($type eq 'single'){
		if(-e "$infor[0].single.bed" and -e "$infor[1].single.bed" and !(-e "$infor[0].$infor[1].density.ratio.tdf")){
			$cmd="perl /home/jhmi/xinli/scripts/Calculate_enrich_ratio2.pl $infor[0].single.bed $infor[1].single.bed $name1 $name2 ~/amber3/Oliver/Chip-Seq/hg19.len $window_size $step_size hg19";
		}
		#elsif(-e "$infor[0].pair.bed" and -e "$infor[1].pair.bed" and -e "$infor[0].$infor[1].density.ratio.tdf"){
		#	
		#}
		else{
			die("no bed files");
		}
	}
	print O $cmd,"\n";
}
close O;
close IN;
$tmp_cmd="perl ~/scripts/qsub_sge.pl ratio.sh";
#system($tmp_cmd);

}
elsif($step eq 'macs'){

open IN,$chip_list;
open O,">macs2.sh"||die;

while (<IN>) {
	chomp;
	my @infor=split;
	my $name1=(split /\./,$infor[0])[0];
	my $name2=(split /\./,$infor[1])[0];
	my $cmd="macs2 callpeak -t $infor[0] -c $infor[1] -g hs -f BAMPE -B -n $name1.$name2.macs2";
	print O $cmd,"\n";
}
close O;
close IN;
my $tmp_cmd="perl ~/scripts/qsub_sge.pl macs2.sh";
system($tmp_cmd);
}
elsif($step eq 'rseg'){
if(!defined $type){$type="pair";}
open IN,$chip_list;
open O,">rseg.sh"||die;
my $pid=$$;
my $index=0;
while (<IN>) {
	chomp;
	$index++;
	my @infor=split;
	my $name1=(split /\./,$infor[0])[0];
	my $name2=(split /\./,$infor[1])[0];
	

	my $cmd="perl ~/scripts/sort_file_pid2.pl $infor[0].$type.bed $$.$index ";
	$cmd.="&& perl ~/scripts/sort_file_pid2.pl $infor[1].$type.bed $$.$index ";
	#my $cmd="";
if($type eq 'pair'){
	if(defined $bin_size_rseg){
	$cmd.="&& rseg-diff -out $name1.$name2.$bin_size_rseg.domain.bed -c /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len -i 20 -v -d /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort -duplicates -mode 2 -bin-size $bin_size_rseg $infor[0].$type.bed.$$.$index.sort $infor[1].$type.bed.$$.$index.sort";
        #$cmd.="rseg-diff -out $name1.$name2.$bin_size_rseg.domain.bed -c /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len -i 20 -v -d /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort -duplicates -mode 2 -bin-size $bin_size_rseg $infor[0].$type.bed $infor[1].$type.bed";	

	}
	else{
	$cmd.="&& rseg-diff -out $name1.$name2.domain.bed -c /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len -i 20 -v -d /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort -duplicates -mode 2 $infor[0].$type.bed.$$.$index.sort $infor[1].$type.bed.$$.$index.sort";
	#$cmd.="rseg-diff -out $name1.$name2.domain.bed -c /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len -i 20 -v -d /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort -duplicates -mode 2 $infor[0].$type.bed $infor[1].$type.bed";
	}
}elsif($type eq 'single'){
	if(!defined($insert_len)){Usage();}
	if(defined $bin_size_rseg){
	#print "$bin_size_rseg\n";
	$cmd.="&& rseg-diff -fragment_length $insert_len -out $name1.$name2.$bin_size_rseg.domain.bed -c /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len -i 20 -v -d /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort -duplicates -mode 2 -bin-size $bin_size_rseg $infor[0].$type.bed.$$.$index.sort $infor[1].$type.bed.$$.$index.sort";
	}
	else{
	$cmd.="&& rseg-diff -fragment_length $insert_len -out $name1.$name2.domain.bed -c /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len -i 20 -v -d /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort -duplicates -mode 2 $infor[0].$type.bed.$$.$index.sort $infor[1].$type.bed.$$.$index.sort";
	}

}
	print O $cmd,"\n";
}
close O;
close IN;
my $tmp_cmd="perl ~/scripts/qsub_sge.pl rseg.sh";
#system($tmp_cmd);
}
elsif($step eq 'rseg_chr'){
if(!defined $type){$type="pair";}
open IN,$chip_list;
open O,">rseg.sh"||die;
my $pid=$$;
my $index=0;
while (<IN>) {
	chomp;
	$index++;
	my @infor=split;
	my $name1=(split /\./,$infor[0])[0];
	my $name2=(split /\./,$infor[1])[0];
	my $cmd;
	

if($type eq 'pair'){
	if(defined $bin_size_rseg){
	open TMP, "/home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len"||die;
	while (<TMP>) {
		my @tmp_infor=split;
		my $chr_name=$tmp_infor[0];
		#print "$chr_name\n";
		$cmd.="perl /home/jhmi/xinli/scripts/Run_rseg.pl $infor[0].$type.bed $infor[1].$type.bed /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort 2 $chr_name $name1.$name2.$bin_size_rseg \"-bin-size $bin_size_rseg -score $name1.$name2.$bin_size_rseg.$chr_name.score\"\n";
	}
	close TMP;
	}
	else{
	open TMP, "/home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len"||die;
	while (<TMP>) {
		my @tmp_infor=split;
		my $chr_name=$tmp_infor[0];
		$cmd.="perl /home/jhmi/xinli/scripts/Run_rseg.pl $infor[0].$type.bed $infor[1].$type.bed /home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort 2 $chr_name $name1.$name2\n";
	}
	close TMP;
	}
}elsif($type eq 'single'){
	if(!defined($insert_len)){Usage();}
	if(defined $bin_size_rseg){
	open TMP, "/home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len"||die;
	while (<TMP>) {
		my @tmp_infor=split;
		my $chr_name=$tmp_infor[0];
		$cmd.="perl ~/scripts/Run_rseg.pl $infor[0].$type.bed $infor[1].$type.bed ~/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort 2 $chr_name $name1.$name2.$bin_size_rseg \"-bin-size $bin_size_rseg -fragment_length $insert_len -score $name1.$name2.$bin_size_rseg.$chr_name.score\"\n";
	}
	close TMP;
	}
	else{
	open TMP, "/home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len"||die;
	while (<TMP>) {
		my @tmp_infor=split;
		my $chr_name=$tmp_infor[0];
		$cmd.="perl ~/scripts/Run_rseg.pl $infor[0].$type.bed $infor[1].$type.bed ~/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len /home/jhmi/xinli/amber3/Oliver/Chip-Seq-solid/deadzones-hg19-k46.bed.sort 2 $chr_name $name1.$name2 \"-fragment_length $insert_len\"\n";
	}
	close TMP;
	}

}
	print O $cmd;
}
close O;
close IN;
my $tmp_cmd="perl ~/scripts/qsub_sge.pl rseg.sh";
#system($tmp_cmd);
}
elsif($step eq 'rseg_merge'){
open IN,$chip_list;
open O,">rseg.merge.sh"||die;
while (<IN>) {
	chomp;
	my @infor=split;
	my $name1=(split /\./,$infor[0])[0];
	my $name2=(split /\./,$infor[1])[0];
	my $cmd="cat ";
	
#Sample_38-5_K9me2_1_sh.Sample_38-5_INP_1_sh.500.chr9.domain.bed

	open TMP, "/home/jhmi/xinli/amber3/Akiko/Chip-Seq/human_hiseq031/hg19.len"||die;
	while (<TMP>) {
		my @tmp_infor=split;
		my $chr_name=$tmp_infor[0];
		#print "$chr_name\n";
		$cmd.="$name1.$name2.$bin_size_rseg.$chr_name.domain.bed ";
	}
	close TMP;
	$cmd.="> $name1.$name2.$bin_size_rseg.chr.domain.bed \n";
	print O $cmd;
}
close O;
close IN;
my $tmp_cmd="perl ~/scripts/qsub_sge.pl rseg.merge.sh";
#system($tmp_cmd);
}



sub Usage {
    print << "    Usage";

        $Function

        Usage: $0 <options>

                -sample_list        sample list

                -chip_list          chip input relationship list

                -ref                reference fasta path

                -step               align or merge_rmdup or or tobed or tdf or macs or rseg or rseg_chr

                -type               pair or single read

                -insert_len         fragment length

                -read_len           read length

                -window_size        sliding window size

                -step_size          sliding step size

                -bin_size_for_rseg  bin size used for rseg program

                -keep_multihits     Yes or No, default No

                -h or -help         Show Help , have a choice

    Usage
        exit;

}

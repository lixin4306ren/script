#!/usr/bin/perl
use strict;
use warnings;

#./MAnorm.no.shift.sh  ~/amber3/Oliver/Chip-Seq2/Sample_DMSO1_Dik4.Sample_DMSO1_INPUT.macs2_peaks.bed ~/amber3/Oliver/Chip-Seq2/Sample_DMSO2_Dik4.Sample_DMSO2_INPUT.macs2_peaks.bed ~/amber3/Oliver/Chip-Seq2/Sample_DMSO1_Dik4.sort.rmdup.bam.pair.bed  ~/amber3/Oliver/Chip-Seq2/Sample_DMSO2_Dik4.sort.rmdup.bam.pair.bed 0 0
open IN,$ARGV[0]||die;
while (<IN>) {
	chomp;
	my @infor=split;
	my $name1=(split/\./,$infor[0])[0];
	my $name2=(split/\./,$infor[1])[0];
	my $dir_name="$name1"."_vs_".$name2;
	if (!(-d $dir_name)) {
		mkdir ($dir_name);
	}
	#print "$dir_name";
	#exit;
	my $cmd="cp /home/jhmi/xinli/soft/MAnorm_Linux_R_Package/MAnorm.no.shift.sh $dir_name/.";
	`$cmd`;
	$cmd="cp /home/jhmi/xinli/soft/MAnorm_Linux_R_Package/MAnorm.r $dir_name/.";
	`$cmd`;
	$cmd="cp /home/jhmi/xinli/soft/MAnorm_Linux_R_Package/classfy_by_M_value.sh $dir_name/.";
	my $pwd=`pwd`;chomp $pwd;
	chdir("$pwd/$dir_name/");
	$cmd="./MAnorm.no.shift.sh  ../$infor[0] ../$infor[1] ../$name1.sort.rmdup.bam.pair.bed  ../$name2.sort.rmdup.bam.pair.bed 0 0";
	open TMP,">$dir_name.sh"||die;
	print TMP $cmd;
	close TMP;
	$cmd="qsub -cwd -l cegs,mf=5G,h_vmem=7G tmp.sh";
	`$cmd`;
	chdir("../");
	#last;
}
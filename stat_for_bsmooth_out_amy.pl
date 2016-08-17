#!/usr/bin/perl
use strict;
use warnings;

#  Of 4000000 input reads:
#    256252 (3.203%) reads/ends failed to align
#    1106935 (13.837%) reads/ends aligned with bisulfite-strand ambiguity
#    6636813 (82.960%) reads/ends aligned without bisulfite-strand ambiguity

		my %num;
		my %aligned;

opendir (DIR,$ARGV[0])||die;
while (my $file=readdir(DIR)) {
	if ($file=~/work_.*e$/) {
	my $sample;
	open IN,$ARGV[0]."/".$file||die;
	while (my $line=<IN>) {
		chomp $line;
		if($line=~/^Mate \#1 inputs\:/){
			$line=<IN>;
			my @infor=split /\//,$line;
			if ($infor[-2] eq ""){$sample=$infor[-3];}
			else{$sample=$infor[-2];}
	#print "$sample\n";
		}
		if ($line=~/Of (\d+) input reads/) {$num{$sample}+=$1*2;}
	
		if ($line=~/    (.*) \(.*without bisulfite-strand ambiguity$/) {$aligned{$sample}+=$1;}
	}
	close IN;
 	}
}
closedir DIR;

open L,$ARGV[1]||die;###sample.list

my $tag=0;
my %speficity;
while (<L>) {
        chomp;
        my $sample_name;
	if($_=~/\//){
		$sample_name=(split /\//,$_)[-1];
		}
	else{$sample_name=$_;}
		if (!(-e "$sample_name/all/chr1.cov")) {$tag=1;last;}
        my $cmd="cat $sample_name\/all\/chr*.cov\|awk \'{t1+=\$1;t2+=\$2}END{print t2/t1}\'";
        $speficity{$sample_name}=`$cmd`;
		chomp $speficity{$sample_name}
}
close L;


print "Sample\tTotal_pair\tTotal_reads\taligned_reads\taligned_rate\n";
foreach my $key (keys %num) {
	#if(!defined $all{$key}){print "<<<<<<<<<<<<<$key\n";}
	print $key,"\t",$num{$key}/2,"\t",$num{$key},"\t",$aligned{$key},"\t",$aligned{$key}/$num{$key},"\n";
}




 

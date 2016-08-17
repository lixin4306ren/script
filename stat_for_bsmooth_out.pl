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
			$sample=$infor[-2];
		}
		if ($line=~/Of (\d+) input reads/) {$num{$sample}+=$1*2;}
	
		if ($line=~/    (.*) \(.*without bisulfite-strand ambiguity$/) {$aligned{$sample}+=$1;}
	}
	close IN;
 	}
}
closedir DIR;

my %remove;
my %all;
my %dup;
my $dir=$ARGV[1];
opendir D,$ARGV[1]||die;
while (my $file=readdir(D)) {

	#print "$file<<<<<<<<<<<<<\n";
        my $dup_rate;
        my $sample_name;
        my $remove_reads;
		my $all_reads;
        if (!($file=~/\.sh$/)) {next;}
        else{

                #print $dir.$file,"<<<<<<<<<<\n";
                open TMP,$dir.$file||die;
				#print ">>>>>>>>>>>>$dir.$file\n";
                my $cmd=<TMP>;
                my $tmp_name=(split /\s+/,$cmd)[3];
                $sample_name=(split /\//,$tmp_name)[0];
                #$sample_name=(split /\./,$tmp_name2)[0];
                #print "$tmp_name\t$sample_name\n";exit;
                close TMP;
                $file=~s/sh/e/;
                open TMP,$dir.$file||die;
#				print $dir.$file,"<<<<<<<<<\n";
                while (my $line=<TMP>) {
                        if ($line=~/library/) {
                                $dup_rate=(split /\s+/,$line)[5];
                                $remove_reads=(split /\s+/,$line)[1];
								$all_reads=(split /\s+/,$line)[3];
                        }
                }
                close TMP;
        }
        $dup{$sample_name}=$dup_rate;
        $remove{$sample_name}+=$remove_reads;
		$all{$sample_name}+=$all_reads;
        #print "$sample_name\t$dup_rate\t$remove_reads\n";
}
closedir D;



open L,$ARGV[2]||die;###sample.list

my $tag=0;
my %speficity;
while (<L>) {
        chomp;
        my $sample_name=(split /\//,$_)[-1];
	#print "$sample_name\n";
		if (!(-e "$sample_name/all/chr1.ev.tsv.gz.bed.cov")) {$tag=1;print "$sample_name>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";last;}
        my $cmd="cat $sample_name\/all\/chr*.cov\|awk \'{t1+=\$1;t2+=\$2}END{print t2/t1}\'";
        $speficity{$sample_name}=`$cmd`;
		chomp $speficity{$sample_name}
}
close L;

if ($tag==0) {

print "Sample\tTotal_pair\tTotal_reads\taligned_reads\taligned_rate\tremoved_reads_pair\tall_analyzed_read_pair\tdup_rate\tspecificity\n";
foreach my $key (keys %num) {
	#if(!defined $all{$key}){print "<<<<<<<<<<<<<$key\n";}
	print $key,"\t",$num{$key}/2,"\t",$num{$key},"\t",$aligned{$key},"\t",$aligned{$key}/$num{$key},"\t",$remove{$key},"\t",$all{$key},"\t",$remove{$key}/$all{$key},"\t",$speficity{$key},"\n";
}
}
elsif($tag==1){
print "Sample\tTotal_pair\tTotal_reads\taligned_reads\taligned_rate\tremoved_reads_pair\tall_analyzed_read_pair\tdup_rate\n";
foreach my $key (keys %num) {
	#if(!defined $all{$key}){print "<<<<<<<<<<<<<$key\n";}
	print $key,"\t",$num{$key}/2,"\t",$num{$key},"\t",$aligned{$key},"\t",$aligned{$key}/$num{$key},"\t",$remove{$key},"\t",$all{$key},"\t",$remove{$key}/$all{$key},"\n";
}
}



 

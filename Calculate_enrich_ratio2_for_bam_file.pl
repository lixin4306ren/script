#!/usr/bin/perl
use strict;
use warnings;

#cat H3k36me3.sort.bam.rmdup.bed |genomic_scans counts -min 0 -i -v  -w 500 -d 500 -g /amber2/scratch/xinli/reads/coverage/mm
#8.bed |genomic_regions bed > H3k36me3.sort.bam.rmdup.bed.density
#open IN,$ARGV[0]||die;
#open IN2,$ARGV[1]||die;
my $s1=$ARGV[2]; #file 1 sample name
my $s2=$ARGV[3]; #file 2 sample name
my $chr_len=$ARGV[4];
my $window=$ARGV[5];
my $step=$ARGV[6];
my $genome=$ARGV[7]||die;#hg19 or other
my $normalize=$ARGV[8];

my $tmp_file="$ARGV[2]"."\."."$ARGV[3]"."."."density";
my $cmd="/home/jhmi/xinli/bin/genomic_scans counts -min 0 -i -v -op c -w $window -d $step -g $chr_len $ARGV[0]|/home/jhmi/xinli/bin/genomic_regions bed > $tmp_file.tmp1";
print "$cmd\n";
`$cmd`;
$cmd="/home/jhmi/xinli/bin/genomic_scans counts -min 0 -i -v -op c -w $window -d $step -g $chr_len $ARGV[1]|/home/jhmi/xinli/bin/genomic_regions bed > $tmp_file.tmp2";
`$cmd`;
print "$cmd\n";

$cmd="paste $tmp_file.tmp1 $tmp_file.tmp2 > $tmp_file.tmp3";
`$cmd`;
print "$cmd\n";

#print $data1[0],"\n$data1[1]";exit;
my $num1=0;
my $num2=0;

open IN,$ARGV[0]||die;
open IN2,$ARGV[1]||die;
while(<IN>){
        chomp;
        $num1++;
}
close IN;

while(<IN2>){
        chomp;
        $num2++;
}
close IN2;


my $factor;
if (defined $normalize) {
	$factor=1/$normalize;
}
else{$factor=$num2/$num1;}

print "$num1\t$num2\t$factor\n";

print "print caculating ratio\n";

open O,">$tmp_file.$window.ratio.bedgraph"||die;
open O2,">$tmp_file.$window.rpkm.bedgraph"||die;
open IN,"$tmp_file.tmp3"||die;
	while (<IN>) {
        
		my @infor=split;
        my $ratio;
		my $rpkm1;
		my $rpkm2;
		my $count1=$infor[3];
		my $count2=$infor[9];
		if ($count1==0 and $count2==0) {
		$ratio="NA";
        }
        else{
              $ratio=log($factor*($count1+1)/($count2+1))/log(2);
        }
	  $rpkm1=$count1/$num1*1e6;
	  $rpkm2=$count2/$num2*1e6;

        print O "$infor[0]\t$infor[1]\t$infor[2]\t$ratio\n";
		print O2 "$infor[0]\t$infor[1]\t$infor[2]\t$rpkm1\t$rpkm2\n";
	}
close IN;
if (!-e "$tmp_file.$window.ratio.bedgraph.tdf") {
	$cmd="/home/jhmi/xinli/soft/IGVTools/igvtools toTDF $tmp_file.$window.ratio.bedgraph $tmp_file.ratio.tdf $genome";
	`$cmd`;
}
unlink("$tmp_file.tmp1");
unlink("$tmp_file.tmp2");
unlink("$tmp_file.tmp3");


print "work done!\n";

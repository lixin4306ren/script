#!/usr/bin/perl
use strict;
use warnings;

#cat H3k36me3.sort.bam.rmdup.bed |genomic_scans counts -min 0 -i -v  -w 500 -d 500 -g /amber2/scratch/xinli/reads/coverage/mm
#8.bed |genomic_regions bed > H3k36me3.sort.bam.rmdup.bed.density
#open IN,$ARGV[0]||die;
#open IN2,$ARGV[1]||die;
my $s1=$ARGV[1]; #file 1 sample name
my $chr_len=$ARGV[2];
my $window=$ARGV[3];
my $step=$ARGV[4];
my $genome=$ARGV[5]||die;#hg19 or other

my $cmd="cat $ARGV[0]|genomic_scans counts -min 0 -i -v -op c -w $window -d $step -g $chr_len|genomic_regions bed";
my @data1=`$cmd`;
my $num_line=scalar @data1;


my $num1=0;

open IN,$ARGV[0]||die;
while(<IN>){
        chomp;
        $num1++;
}
close IN;

print "print caculating RPKM\n";
my $tmp_file="$ARGV[1]"."\."."rpkm";
open O,">$tmp_file"||die;

for(my $i=0;$i<$num_line ;$i++){
        my @infor=split /\s+/,$data1[$i];
		print O "$infor[0]\t$infor[1]\t$infor[2]\t",$infor[3]/$num1*1000000,"\n";
}

__END__
$cmd="/home/jhmi/xinli/soft/IGVTools/igvtools toTDF $tmp_file $tmp_file.tdf $genome";
`$cmd`;
print "work done!\n";

#!/usr/bin/perl
use strict;
use warnings;

#open $ARGV[0]||die; #ip read
#open $ARGV[1]||die; #input read
#open $ARGV[2]||die; # peak bed


my $cmd="coverageBed -a $ARGV[0] -b $ARGV[2]|sort -k1,1 -k2,2n -k3,3n |cut -f1,2,3,4 > $ARGV[0].$ARGV[2].count";
`$cmd`;
$cmd="coverageBed -a $ARGV[1] -b $ARGV[2]|sort -k1,1 -k2,2n -k3,3n |cut -f4 > $ARGV[1].$ARGV[2].count";
`$cmd`;
$cmd="paste $ARGV[0].$ARGV[2].count $ARGV[1].$ARGV[2].count > $ARGV[0].$ARGV[1].$ARGV[2].count";
`$cmd`;
open TMP,$ARGV[0]||die;
my $number1;
while (<TMP>) {
$number1++;
}
close TMP;

open TMP,$ARGV[1]||die;
my $number2;
while (<TMP>) {
$number2++;
}
close TMP;

my $factor=$number2/$number1;

open IN,"$ARGV[0].$ARGV[1].$ARGV[2].count"||die;
while (<IN>) {
	my @infor=split;
	my $count1=$infor[3];
	my $count2=$infor[4];
	my $ratio;
	if ($count1==0 and $count2==0) {
                $ratio="NA";
        }
        else{
              $ratio=log($factor*($count1+1)/($count2+1))/log(2);
        }
        print "$infor[0]\t$infor[1]\t$infor[2]\t$ratio\n";
}
#coverageBed -a Sample_P952_Dik4.sort.rmdup.bam.pair.bed -b Dik4.common.peak.bed|sort -k1,1 -k2,2n -k3,3n > Dik4.common.peak.P952.count

#coverageBed -a Sample_P952_INP.sort.rmdup.bam.pair.bed -b Dik4.common.peak.bed|sort -k1,1 -k2,2n -k3,3n > Dik4.common.peak.P951.inp.count
#coverageBed -a Sample_P952_INP.sort.rmdup.bam.pair.bed -b Dik4.common.peak.bed|sort -k1,1 -k2,2n -k3,3n > Dik4.common.peak.P952.inp.count


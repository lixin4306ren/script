#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my ($help,$step,$chip_list);

my $Function='Chip-Seq pipeline';

GetOptions(
        "chip_list:s"=>\$chip_list,
        "help"=>\$help,
        "step:s"=>\$step,

);

if(!defined($chip_list) ||!defined($step)||defined($help) ){

        Usage();

}

if ($step eq 'align') {

open IN,$chip_list||die;

while (<IN>) {
	chomp;
	my @infor=split;
	my $ip1=$infor[0];
	my $ip2=$infor[1];
	my $input1=$infor[2];
	my $input2=$infor[3];

$ip1=~s/,/ /;
$ip2=~s/,/ /;
$input1=~s/,/ /;
$input2=~s/,/ /;
	my $window=$infor[4];
	my $step=$infor[5];
	my $nsd=$infor[6];
	my $gap=$infor[7];
	my $name=$infor[8];
print "perl ~/soft/diffReps-1.54/bin/diffReps.pl -tr $ip1 -co $ip2 --btr $input1 --bco $input2 -gn hg19 -re diff.peak.$name.out -me nb --frag 180 --window $window --step $step --nproc 6 --nsd $nsd --gap $gap\n";
}
}
elsif($step eq 'bed'){
open IN,$chip_list||die;

my $cmd;
while (<IN>) {
	chomp;
	my @infor=split;
	my $name="diff.peak.$infor[8].out";
	$cmd.="more diff.peak.$infor[8].out|grep \'chr\'|cut -f1,2,3,11 > diff.peak.$infor[8].bed\n";
}
print $cmd;

}



sub Usage {
    print << "    Usage";

        $Function

        Usage: $0 <options>

                -chip_list          chip list for diffRep

                -step               align or bed

                -h or -help         Show Help , have a choice

    Usage
        exit;

}
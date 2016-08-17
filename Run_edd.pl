#!/usr/bin/perl
use strict;
use warnings;
open IN, $ARGV[0]||die;
while (<IN>){
chomp;
my @infor=split;
my $name=(split/\./,$infor[0])[0];
my $cmd="edd --fdr 0.2 --bin-size 10 -g 3 -n 2000 --config-file ~/soft/edd/eddlib/default_parameters.conf ~/soft/edd/data/hg19.chromsizes ~/soft/edd/data/hg19_unalignable_regions.bed ";
$cmd.="$infor[0] $infor[1] edd_result_0.2/$name";

print "$cmd\n";
}


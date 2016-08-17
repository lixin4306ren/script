#!/usr/bin/perl
use strict;
use warnings;
my $dir=`pwd`;
my $file=$ARGV[0];
my $window=$ARGV[2]||2000;
my $step=$ARGV[3]||2000;
my $out_dir=$ARGV[1]||$dir;

my $cmd="R --slave --vanilla --file=/home/jhmi/xinli/scripts/sliding.meth.r --args $file $window $step $out_dir";
print $cmd,"\n";
system("$cmd");

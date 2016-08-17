#!/usr/bin/perl
use strict;
use warnings;

opendir D,$ARGV[0]||die;
my @data=sort(readdir(D));
#print "@data\n";exit;
foreach my $filename (@data){
#print "$filename\n";
if($filename=~/^ecoli.*\.cg\b/ or $filename=~/^lambda.*\.cg\b/ or $filename=~/^SQ.*\.cg\b/){
#print "$filename\n";
my $chr=(split/\./,$filename)[0];
open TMP,$ARGV[0]."/$filename"||die;
while (<TMP>) {
        print "$chr\t$_";
}
close TMP;
}
}



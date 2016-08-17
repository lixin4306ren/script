#!/usr/bin/perl
use strict;
use warnings;

opendir D,$ARGV[0]||die;
my @data=sort(readdir(D));
#print "@data\n";exit;
foreach my $filename (@data){
if($filename=~/^chr.*\.cg\b/){
#print "$filename\n";next;
my $chr=(split/\./,$filename)[0];
open TMP,$ARGV[0]."/$filename"||die;
while (<TMP>) {
        print "$chr\t$_";
}
close TMP;
}
}



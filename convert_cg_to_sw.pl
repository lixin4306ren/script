#!/usr/bin/perl
use strict;
use warnings;

opendir D,$ARGV[0]||die;
my @data=sort(readdir(D));
#open O,">$ARGV[0]/"
#print "@data\n";exit;
foreach my $filename (@data){
#print "$file"
if($filename=~/^chr.*\.cg\b/){
#print "$filename\n";next;
my $chr=(split/\./,$filename)[0];
my $out=$ARGV[0]."/$filename.for.sw";
open O,">$out"||die;
open TMP,$ARGV[0]."/$filename"||die;
while (<TMP>) {
	chomp;
#	chr10   80      +       CG      10      5

	my @infor=split;
	my $strand;
	if($infor[1]==1){$strand="+";}elsif($infor[1]==4){$strand="-";}
        print O "$chr\t$infor[0]\t$strand\tCG\t$infor[2]\t",$infor[3]-$infor[2],"\n";
}
close TMP;
close O;
}
}



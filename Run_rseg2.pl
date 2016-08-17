#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die; # chip control list
my $chr_len=$ARGV[1]||die;
my $dead=$ARGV[2]||die;
my $mode=$ARGV[3]||die;
my $frag_len=$ARGV[4]||=0;
my $bin_size=$ARGV[5]||=0;
while (<IN>) {
	chomp;
	my @infor=split;
	
if($bin_size==0){
if($frag_len==0){
print "rseg-diff -out $infor[0].domain.bed -c $chr_len -i 20 -v -d $dead -duplicates -mode $mode $infor[0].pair.bed.sort $infor[1].pair.bed.sort\n";
}
else{
print "rseg-diff -out $infor[0].domain.bed -c $chr_len -i 20 -v -d $dead -duplicates -mode $mode -fragment_length $frag_len  $infor[0].bed.sort $infor[1].bed.sort\n";
}

}
else{
if($frag_len==0){
print "rseg-diff -out $infor[0].$bin_size.domain.bed -c $chr_len -i 20 -v -d $dead -duplicates -mode $mode -bin-size $bin_size $infor[0].pair.bed.sort $infor[1].pair.bed.sort\n";
}
else{
print "rseg-diff -out $infor[0].$bin_size.domain.bed -c $chr_len -i 20 -v -d $dead -duplicates -mode $mode -fragment_length $frag_len -bin-size $bin_size $infor[0].bed.sort $infor[1].bed.sort\n";
}
}
}


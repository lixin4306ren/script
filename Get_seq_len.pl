#!/usr/bin/perl -w

use strict;
open IN, "$ARGV[0]"||die "can not open $ARGV[0]\n";
open OUT, ">$ARGV[1]"||die "can not open $ARGV[1]\n";

#>NM
#NNNNNNNNNNNNN
my %len;
my $name;
my %cg;
my %seq;
while (<IN>) {
chomp;
if (/^>/) {
	my @infor=split;
	$name=$infor[0];
	$name=~s/>//;
}
else{$_=~s/\s+//g;$seq{$name}.=uc($_);}
}
my %c;my %g; my %len_N;
foreach my $key(keys %seq){
   $len{$key}=length($seq{$key});
   $cg{$key}=($seq{$key}=~s/CG/CG/ig); if($cg{$key} eq ""){$cg{$key}=0;}
   $c{$key}=($seq{$key}=~s/C/C/ig); if($c{$key} eq ""){$c{$key}=0;}
   $g{$key}=($seq{$key}=~s/G/G/ig); if($g{$key} eq ""){$g{$key}=0;}
   $len_N{$key}=($seq{$key}=~s/N/N/ig); if($len_N{$key} eq ""){$len_N{$key}=0;}

   my $oe;
   if($c{$key}==0 or $g{$key}==0){$oe="NA";}else{$oe=$cg{$key}*$len{$key}/($c{$key}*$g{$key});}
	
	print OUT "$key\t$len{$key}\t$len_N{$key}\t$cg{$key}\t$c{$key}\t$oe\n";
#print OUT "$key\t$len{$key}\t$len_N{$key}\t",$len{$key}-$len_N{$key},"\n";
}






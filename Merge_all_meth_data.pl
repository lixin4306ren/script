#!/usr/bin/perl
use strict;
use warnings;

#chrom   pos     strand  mc_class        methylated_bases        total_bases     methylation_call
#1       31      +       CTG     1       1       0
#1       33      -       CAG     4       5       1
#1       37      +       CCT     1       1       0
#1       38      +       CTT     1       1       0
#1       44      +       CCC     1       1       0

open P,$ARGV[0]||die; # C type information
open O,">$ARGV[3]"||die;
my $chromosome=$ARGV[4]||die;
my %hash;

print "loading C type information\n";
while (<P>) {
	chomp;
	my @infor=split;
	my $chr=$infor[0];$chr=~s/Chr//;
	my $pos=$infor[1];
	my $strand=$infor[2];
	my $base_type=$infor[3];
	$hash{"$chr\t$pos"}->[0]="$chr\t$pos\t$strand\t$base_type";
}
close P;

print "starting analysis\n";

my $index=1;
print O "chr\tpos\tstrand\tbase_type\t";

open L,$ARGV[1]||die; # sample list
my $tissue=$ARGV[2]||die;

while (<L>) {
	chomp;
	my @infor2=split;
	if ($infor2[1] ne $tissue) {next;}
	my $name=$infor2[0];
	$name=~s/-/_/g;
	print O "$name\t";
}
print O "\n";
close L;

open L,$ARGV[1]||die; # sample list
while (<L>) {
	chomp;
	my @infor2=split;
	if ($infor2[1] ne $tissue) {next;}
	my $name=$infor2[0];
	$name=~s/-/_/g;
	my $file="mC_calls_$name.tsv.gz";
	if ($tissue eq 'Infloresence') {
		$file="mC_calls_$name"."_bud.tsv.gz";
	}
	
	print "$file\n";
	open IN,"gzip -dc $file|"||die;
	while (<IN>) {
	chomp;
	if (/^chrom/) {next;}
	my @infor=split;
	if ($infor[0] ne $chromosome) {next;}
	my $strand=$infor[2];
	my $chr=$infor[0];
	my $str=$infor[3];
	my $base_type;


	
	my $tmp1=substr($str,0,1);
	my $tmp2=substr($str,1,1);
	my $tmp3=substr($str,2,1);

	if($tmp1 eq 'C' && $strand eq '+'){
		if($tmp2 eq 'G' ){$base_type='1';}
		if($tmp3 eq 'G'  && !($tmp2 eq 'G' )){$base_type='2';}
		if(!($tmp2 eq 'G' ) && !($tmp3 eq 'G' )){$base_type='3';}
	}
	elsif($tmp1 eq 'C' && $strand eq '-'){
		if($tmp2 eq 'G' ){$base_type='4';}
		if($tmp3 eq 'G'  && !($tmp2 eq 'G' )){$base_type='5';}
		if(!($tmp2 eq 'G' ) && !($tmp3 eq 'G' )){$base_type='6';}
	}
	my $pos=$infor[1]+1;
	if (! exists $hash{"$chr\t$pos"}) {next;}
	if ($hash{"$chr\t$pos"}->[0] ne "$chr\t$pos\t$strand\t$base_type") {next;}
	$hash{"$chr\t$pos"}->[$index]="$infor[4]\t$infor[5]\t$infor[6]";
}
close IN;
$index++;
}

#Chr1    1       +       3
#Chr1    2       +       3
#Chr1    3       +       3

print "printing output\n";
open P,$ARGV[0]||die; # C type information
while (<P>) {
	chomp;
	my @infor=split;
	my $chr=$infor[0];$chr=~s/Chr//;
	my $pos=$infor[1];
	my $strand=$infor[2];
	my $base_type=$infor[3];
	#$hash{"$chr\t$pos"}->[0]="$chr\t$pos\t$strand\t$base_type";

	for (my $i=0;$i<$index ;$i++) {
		if (!defined $hash{"$chr\t$pos"}->[$i]) {
			print O "0\t0\t0\t";
		}
		else{
		print O $hash{"$chr\t$pos"}->[$i],"\t";
		}
	}
	print O  "\n";
}

print "wrok done\n";
sub revdnacomp {
  my $dna = @_;
  my $revcomp = reverse($dna);
  $revcomp =~ tr/ACGTacgt/TGCAtgca/;
  return $revcomp;
}
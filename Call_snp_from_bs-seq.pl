#!/usr/bin/perl
use strict;
use warnings;

open S_Plus,"$ARGV[0]"||die;
open S_Minus,"$ARGV[1]"||die;
my $depth=$ARGV[2]||die;
open O1,">$ARGV[3]"||die;
open O2,">$ARGV[4]"||die;

#chr12   148     .       G       A,C       22.5    .       DP=6;VDB=0.0784;AF1=1;AC1=2;DP4=0,0,0,4;MQ=20;FQ=-39    GT:PL:GQ        1/1:55,12,0:21

my %snp_p;
my %snp_m;
my %real_snp;
while (<S_Plus>) {
	chomp;
	if (/^\#/) {next;}
	my @infor=split;
	if ($infor[7]=~/DP=(\d+)/ and $1<$depth){next;} 
	if ($infor[4] eq '.') {next;}
	#if ($infor[4]=~/,/ or $infor[4] eq '.') {next;} #为严格只考虑纯合SNP
	if ($infor[3] eq 'C' and $infor[4] eq 'T') {next;}
	if ($infor[3] eq 'A' and $infor[4] eq 'T') {next;} #无法正确确定基因型，可能是T，也可能是C
	if ($infor[3] eq 'G' and $infor[4] eq 'T') {next;} #无法正确确定基因型，可能是T，也可能是C
	
	if ($infor[3] eq 'A' and $infor[4] eq 'C') {next;} #会受甲基化影响
	if ($infor[3] eq 'G' and $infor[4] eq 'C') {next;} #会受甲基化影响
	if ($infor[3] eq 'T' and $infor[4] eq 'C') {next;} #会受甲基化影响

	#$real_snp{"$infor[0]\t$infor[1]"}="$_";
	#$snp_p{"$infor[0]\t$infor[1]"}=$_;
	print O1 "$_\n";
}
close S_Plus;

while (<S_Minus>) {
	chomp;
	if (/^\#/) {next;}
	my @infor=split;
	if ($infor[7]=~/DP=(\d+)/ and $1<$depth){next;}
	if ($infor[4] eq '.') {next;}
	#if ($infor[4]=~/,/ or $infor[4] eq '.') {next;} #为严格只考虑纯合SNP
	if ($infor[3] eq 'G' and $infor[4] eq 'A') {next;}
	if ($infor[3] eq 'C' and $infor[4] eq 'A') {next;}#无法判断基因型
	if ($infor[3] eq 'T' and $infor[4] eq 'A') {next;}#无法判断基因型
	
	if ($infor[3] eq 'A' and $infor[4] eq 'G') {next;} #会受甲基化影响
	if ($infor[3] eq 'C' and $infor[4] eq 'G') {next;} #会受甲基化影响
	if ($infor[3] eq 'T' and $infor[4] eq 'G') {next;} #会受甲基化影响

	#$real_snp{"$infor[0]\t$infor[1]"}="$_";
	#$snp_m{"$infor[0]\t$infor[1]"}=$_;
	print O2 "$_\n";
}
close S_Minus;


#open S_Plus,$ARGV[0]||die;
#while (<S_Plus>) {
#	chomp;
#	if (/^\#/) {next;}
#	my @infor=split;
#	if (exists $snp_p{"$infor[0]\t$infor[1]"} and exists $snp_m{"$infor[0]\t$infor[1]"}) {
#		$real_snp{"$infor[0]\t$infor[1]"}="2\t".$snp_p{"$infor[0]\t$infor[1]"}."\t".$snp_m{"$infor[0]\t$infor[1]"};
#	}
#
#}
#close S_Plus;
#
#	
#foreach my $key (keys %real_snp) {
#	print "$real_snp{$key}\n";
#}

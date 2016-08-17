#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw/ uniq /;
#my @unique = uniq @faculty;

open IN,$ARGV[0]||die;
if(defined $ARGV[1]){open R,$ARGV[1];} #genomic region
my $win;
if(defined $ARGV[2]){$win=$ARGV[2];}
my %hash;
my $total;
my @total_gene;
my @total_trans;
my %gene_num;
my %trans_num;

my %tag;
if(defined $ARGV[1]){
while (<R>) {
	chomp;
	if (/start/) {next;}
	my @infor=split;
	my $start=($infor[1]-1)/$win+1;
	my $end=$infor[2]/$win;
	for (my $i=$start;$i<=$end ;$i++) {
		$tag{"$infor[0]\t$i"}=1;
	}
	#print "$infor[0]\t$tmp\n";
}
}
#EFF=INTRON(MODIFIER||||363|MAPK14|protein_coding|CODING|ENSGALT00000001203|8)
while (<IN>) {
	chomp;
	if (/^\#/) {next;}
	my @infor=split;

if (defined $ARGV[1]) {
	my $index=int (($infor[1]-1)/$win)+1;
	
	if (!exists $tag{"$infor[0]\t$index"}) {next;}
	#print "$infor[0]\t$index\n";
}


	my $type;
	my $type2;
	my $gene_name;
	my $trans_name;
	my $pos;
	$total++;

	if (!($infor[7]=~/EFF=/)) {$hash{"OTHER"}++;next;}
	my $eff_infor=(split /;/,$infor[7])[-1];
	$eff_infor=~s/EFF=//;
	my @eff=split /,/,$eff_infor;
foreach my $item (@eff) {
	if ($item=~/(\w+)\((\S*)\)/) {
		$type=$1;
		my $tmp=$2;

		#if ($type eq 'DOWNSTREAM' or $type eq 'UPSTREAM') {
		#	$pos=(split/\|/,$tmp)[4];
		#	#print "$infor[0]\t$infor[1]\t$item\t$pos\n";
		#}
		if(defined $tmp){$gene_name=(split/\|/,$tmp)[5];$trans_name=(split/\|/,$tmp)[8];}
		
	}
		if ($type=~/SPLICE_SITE/) {
			$hash{"SPLICE_SITE"}++;
		}
		$hash{$type}++;
	
	if (defined $gene_name ) {
		if ($type=~/SPLICE_SITE/) {
			push @{$gene_num{"SPLICE_SITE"}},$gene_name;
		}
		push @{$gene_num{$type}},$gene_name;
		push @{$trans_num{$type}},$trans_name;
		push @total_gene,$gene_name;
		push @total_trans,$trans_name;
	}
}

	
#exit;
}

#SYNONYMOUS_CODING
#NON_SYNONYMOUS_CODING

#STOP_GAINED
#START_LOST

#SPLICE_SITE_ACCEPTOR
#SPLICE_SITE_DONOR

my %gene_num2;

foreach my $key (keys %hash) {
	$gene_num2{$key}=scalar uniq(@{$gene_num{$key}});
	my $gene_num=scalar uniq(@{$gene_num{$key}});
	my $trans_num=scalar uniq(@{$trans_num{$key}});
	print "$key\t$hash{$key}\t",$hash{$key}/$total,"\t$gene_num\t",scalar(uniq(@total_gene)),"\t$trans_num\t",scalar(uniq(@total_trans)),"\n";
}

print "###########################\n";
print "STOP_GAINED\t",$hash{"STOP_GAINED"},"\t",$gene_num2{"STOP_GAINED"},"\n";
print "START_LOST\t",$hash{"START_LOST"},"\t",$gene_num2{"START_LOST"},"\n";
print "SPLICE_SITE\t",$hash{"SPLICE_SITE"},"\t",$gene_num2{"SPLICE_SITE"},"\n";
print "NON_SYNONYMOUS_CODING\t",$hash{"NON_SYNONYMOUS_CODING"},"\t",$gene_num2{"NON_SYNONYMOUS_CODING"},"\n";
print "SYNONYMOUS_CODING\t",$hash{"SYNONYMOUS_CODING"},"\t",$gene_num2{"SYNONYMOUS_CODING"},"\n";
print "TOTAL\t",$total,"\n";
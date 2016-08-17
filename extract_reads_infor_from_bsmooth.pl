#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

open IN,"gzip -dc $ARGV[0]|"||die;

#chr10   42599123        HWI-ST1417:146:C1PU6ACXX:6:1101:1377:2206_1:N:0:CTTGTA  C       1       1       73      H       -1      10
#chr10   42599172        HWI-ST1417:146:C1PU6ACXX:6:1101:1377:2206_1:N:0:CTTGTA  C       1       1       73      @       -1      59
#chr10   42599182        HWI-ST1417:146:C1PU6ACXX:6:1101:1377:2206_1:N:0:CTTGTA  C       1       1       73      I       -1      69
#chr10   42599195        HWI-ST1417:146:C1PU6ACXX:6:1101:1377:2206_1:N:0:CTTGTA  C       1       1       73      H       -1      82
#chr10   42599205        HWI-ST1417:146:C1PU6ACXX:6:1101:1377:2206_1:N:0:CTTGTA  C       1       1       73      E       -1      92

my %start;
my %end;
my %chr;
my %count_meth;
my %count_unmeth;
my %count_other;
my $trim_len=$ARGV[1]||=10;
my $min_cpg_num=$ARGV[2]||=5;

my $mapq;my $trim_5_len;my $baseq;my $offset;
if (!defined ($mapq)) {$mapq=20;}
if (!defined ($trim_5_len)) {$trim_5_len=10;}
if (!defined ($baseq)) {$baseq=10;}
if (!defined $offset) {$offset=33;}

while (<IN>) {
	chomp;
	my @infor=split;
	my $name=(split /_/,$infor[2])[0];
	$chr{$name}=$infor[0];
	#print "$name\t$infor[1]\n";exit;
	if (!exists $start{$name}) {
		$start{$name}=$infor[1];
	}else{
		if ($infor[1]<$start{$name}) {$start{$name}=$infor[1];}
	}

	if (!exists $end{$name}) {
		$end{$name}=$infor[1];
	}else{
		if ($infor[1]>$end{$name}) {$end{$name}=$infor[1];}
	}
	my $tmp_mapq=$infor[-1];
	my $tmp_base_cyc_pos=$infor[9];
	my $tmp_baseq=ord($infor[7])-$offset;
	if ($tmp_base_cyc_pos<=$trim_5_len or $tmp_baseq<=$baseq or $tmp_mapq<=$mapq) {next;}

	my $strand=$infor[4];

	if ($strand==1) {
		if ($infor[3] eq "C") {$count_meth{$name}++;}
		elsif($infor[3] eq "T"){$count_unmeth{$name}++;}
		else{$count_other{$name}++;}
	}
	elsif($strand==0){
		if ($infor[3] eq "G") {$count_meth{$name}++;}
		elsif($infor[3] eq "A"){$count_unmeth{$name}++;}
		else{$count_other{$name}++;}
	}
}
close IN;

foreach my $key (keys %start) {
	if (!exists $count_meth{$key}) {$count_meth{$key}=0;}
	if (!exists $count_unmeth{$key}) {$count_unmeth{$key}=0;}
	if (!exists $count_other{$key}) {$count_other{$key}=0;}
	
	if ($count_meth{$key}+$count_unmeth{$key}<$min_cpg_num) {next;}
	if (abs($start{$key}-$end{$key})>1000) {next;}
	print "$chr{$key}\t$start{$key}\t$end{$key}\t$key\t$count_meth{$key}\t$count_unmeth{$key}\t$count_other{$key}\t",$count_meth{$key}/($count_meth{$key}+$count_unmeth{$key}),"\n";

}


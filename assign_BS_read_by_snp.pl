#!/usr/bin/perl
use strict;
use warnings;

open IN,"samtools view $ARGV[0]|"||die;
open SNP,"$ARGV[1]"||die;
open O1,">$ARGV[2]"||die;
open O2,">$ARGV[3]"||die;
my %snp;
my %read_snp;

while (<SNP>) {
	chomp;
	my @infor=split;
	$snp{"$infor[0]\t$infor[1]"}->[0]=$infor[5];
	$snp{"$infor[0]\t$infor[1]"}->[1]=$infor[6];
}

print "starting\n";
my $process=0;
while (<IN>) {
	chomp;
	$process++;
	if ($process % 100000==0) {
		print "$process\n";
	}
	my @infor=split;
	if ($infor[5] ne '100M') {next;}
	my $read_name=(split /_/,$infor[0])[0];
	my $chr=$infor[2];
	my $start=$infor[3];
	my $end=$start+100-1;
	my $seq=$infor[9];
	my $seq_Q=$infor[10];

	for (my $i=0;$i<100 ;$i++) {
		my $pos=$start+$i;
		if (!exists $snp{"$chr\t$pos"}) {next;}
		my $base=substr($seq,$i,1);
		my $base_Q=ord(substr($seq_Q,$i,1))-33;
		if ($base_Q<10) {next;}

		if ($infor[-1] eq 'XG:Z:CT') {
			if ($snp{"$chr\t$pos"}->[0] eq 'A' and $snp{"$chr\t$pos"}->[1] eq 'C') { ####### AC mutation
				if ($base eq 'A' ) {$read_snp{$read_name}->[0]++;}
				elsif($base eq 'C' or $base eq 'T' ){$read_snp{$read_name}->[1]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'C' and $snp{"$chr\t$pos"}->[1] eq 'A'){####### CA mutation
				if ($base eq 'A' ) {$read_snp{$read_name}->[1]++;}
				elsif($base eq 'C' or $base eq 'T' ){$read_snp{$read_name}->[0]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'G' and $snp{"$chr\t$pos"}->[1] eq 'C'){####### GC
				if ($base eq 'G' ) {$read_snp{$read_name}->[0]++;}
				elsif($base eq 'C' or $base eq 'T' ){$read_snp{$read_name}->[1]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'C' and $snp{"$chr\t$pos"}->[1] eq 'G'){####### CG
				if ($base eq 'G' ) {$read_snp{$read_name}->[1]++;}
				elsif($base eq 'C' or $base eq 'T' ){$read_snp{$read_name}->[0]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'T' and $snp{"$chr\t$pos"}->[1] eq 'C'){#######TC
				if ($base eq 'C') {$read_snp{$read_name}->[1]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'C' and $snp{"$chr\t$pos"}->[1] eq 'T'){#######CT
				if ($base eq 'C') {$read_snp{$read_name}->[0]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] ne 'C' and $snp{"$chr\t$pos"}->[1] ne 'C'){
				if ($base eq $snp{"$chr\t$pos"}->[0]){$read_snp{$read_name}->[0]++;}
				elsif($base eq $snp{"$chr\t$pos"}->[1]){$read_snp{$read_name}->[1]++;}
			}
			else{die "Wrong 1\n";}
		}
		elsif($infor[-1] eq 'XG:Z:GA'){

			if ($snp{"$chr\t$pos"}->[0] eq 'A' and $snp{"$chr\t$pos"}->[1] eq 'G') { ####### AG mutation
				if ($base eq 'G' ) {$read_snp{$read_name}->[1]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'G' and $snp{"$chr\t$pos"}->[1] eq 'A'){####### GA mutation
				if ($base eq 'G' ) {$read_snp{$read_name}->[0]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'G' and $snp{"$chr\t$pos"}->[1] eq 'C'){####### GC
				if ($base eq 'G' or $base eq 'A') {$read_snp{$read_name}->[0]++;}
				elsif($base eq 'C'){$read_snp{$read_name}->[1]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'C' and $snp{"$chr\t$pos"}->[1] eq 'G'){####### CG
				if ($base eq 'C' ) {$read_snp{$read_name}->[0]++;}
				elsif($base eq 'G' or $base eq 'A' ){$read_snp{$read_name}->[1]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'T' and $snp{"$chr\t$pos"}->[1] eq 'G'){####### TG
				if ($base eq 'T') {$read_snp{$read_name}->[0]++;}
				elsif($base eq 'G' or $base eq 'A'){$read_snp{$read_name}->[1]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] eq 'G' and $snp{"$chr\t$pos"}->[1] eq 'T'){####### GT
				if ($base eq 'T') {$read_snp{$read_name}->[1]++;}
				elsif($base eq 'G' or $base eq 'A'){$read_snp{$read_name}->[0]++;}
			}
			elsif($snp{"$chr\t$pos"}->[0] ne 'G' and $snp{"$chr\t$pos"}->[1] ne 'G'){
				if ($base eq $snp{"$chr\t$pos"}->[0]){$read_snp{$read_name}->[0]++;}
				elsif($base eq $snp{"$chr\t$pos"}->[1]){$read_snp{$read_name}->[1]++;}
			}
			else{die "Wrong 2\n";}

		}
		else{die "wrong\n";}
	}
}


foreach my $key (keys %read_snp) {
	if (!defined $read_snp{$key}->[0]) {$read_snp{$key}->[0]=0;}
	if (!defined $read_snp{$key}->[1]) {$read_snp{$key}->[1]=0;}
	if ($read_snp{$key}->[0]/($read_snp{$key}->[0]+$read_snp{$key}->[1])>2/3) {
		print O1 "$key\t0\t",$read_snp{$key}->[0],"\t",$read_snp{$key}->[1],"\n";
	}
	elsif($read_snp{$key}->[1]/($read_snp{$key}->[0]+$read_snp{$key}->[1])>2/3){
		print O2 "$key\t1\t",$read_snp{$key}->[0],"\t",$read_snp{$key}->[1],"\n";
	}

}
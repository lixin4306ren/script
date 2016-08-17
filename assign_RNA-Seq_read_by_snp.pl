#!/usr/bin/perl
use strict;
use warnings;

open IN,"samtools view $ARGV[0]|"||die;
#open IN,$ARGV[0]||die;
open SNP,"$ARGV[1]"||die;

#open Seq,"$ARGV[2]"||die;
#my $name;
#my %chr_seq;
#while (<Seq>) {
#	chomp;
#	if (/^>/) {
#		my @infor=split;
#		$name=$infor[0];$name=~s/>//;
#	}
#	else{$chr_seq{$name}.=$_;}
#}
open O1,">$ARGV[2]"||die;
open O2,">$ARGV[3]"||die;
my %snp;
my %read_snp;

while (<SNP>) {
	chomp;
	my @infor=split;
	my $chr=$infor[0];$chr=~s/chr//;$chr=uc($chr);
	#print "$chr\n";exit;
	$snp{"$chr\t$infor[1]"}->[0]=$infor[5];
	$snp{"$chr\t$infor[1]"}->[1]=$infor[6];
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
	if ($infor[5] eq 'D' or $infor[5] eq 'I') {next;}#don't deal with indels
	#94M367N3M3S
	
	my @align_number=split/[a-zA-Z]/,$infor[5];
	my $tmp=$infor[5];$tmp=~s/[0-9]//g;
	my @align_type=split//,$tmp;
	
	my $read_name=(split /_/,$infor[0])[0];
	my $chr=$infor[2];
	my $start=$infor[3];
	my $seq_Q=$infor[10];
	my $seq=$infor[9];

	if ($align_type[0] eq 'S') { #if soft clip at the start of read
		substr($seq,0,$align_number[0])="";
		substr($seq_Q,0,$align_number[0])="";
	}
	elsif($align_type[-1] eq 'S'){
		substr($seq,-1,$align_number[0])="";
		substr($seq_Q,-1,$align_number[0])="";
	}


	#my $align_string;
	#for (my $i=0;$i<@align_type ;$i++) {
	#	print "$align_type[$i]\t$align_number[$i]\n";
	#	$align_string.=$align_type[$i] x $align_number[$i];
	#}
	#print "@align_type\n@align_number\n";
	for (my $i=0;$i<length($seq) ;$i++) {
		my $pos=genomic_pos($start,$i,\@align_type,\@align_number);
		#my $ref_base=uc(substr($chr_seq{$chr},$pos-1,1));
		if (!exists $snp{"$chr\t$pos"}) {next;}
		my $base=substr($seq,$i,1);
		my $base_Q=ord(substr($seq_Q,$i,1))-33;
		if ($base_Q<10) {next;}
		if ($base eq $snp{"$chr\t$pos"}->[0]){$read_snp{$read_name}->[0]++;}
		elsif($base eq $snp{"$chr\t$pos"}->[1]){$read_snp{$read_name}->[1]++;}
	}
}
close IN;

my %read_assign;
foreach my $key (keys %read_snp) {
	if (!defined $read_snp{$key}->[0]) {$read_snp{$key}->[0]=0;}
	if (!defined $read_snp{$key}->[1]) {$read_snp{$key}->[1]=0;}
	if ($read_snp{$key}->[0]/($read_snp{$key}->[0]+$read_snp{$key}->[1])>2/3) {
		$read_assign{$key}=0;
	}
	elsif($read_snp{$key}->[1]/($read_snp{$key}->[0]+$read_snp{$key}->[1])>2/3){
		$read_assign{$key}=1;
	}
}

open IN,"samtools view -h $ARGV[0]|"||die;

while (<IN>) {
	chomp;
	if (/^@/) {
		print O1 $_,"\n";
		print O2 $_,"\n";
	}
	$process++;
	if ($process % 100000==0) {
		print "$process\n";
	}
	my @infor=split;
	my $read_name=(split /_/,$infor[0])[0];
	if (exists $read_assign{$read_name} and $read_assign{$read_name}==0) {
		print O1 $_,"\n";
	}
	elsif(exists $read_assign{$read_name} and $read_assign{$read_name}==1){
		print O2 $_,"\n";
	}
}
close IN;

sub genomic_pos{
	my ($tmp_start,$tmp_pos,$tmp_type_ref,$tmp_number_ref)=@_;
	my @tmp_type=@$tmp_type_ref;
	my @tmp_number=@$tmp_number_ref;
	#print "@tmp_type\n";
	my $tag;
	my $index=0;
	my $total_match=0;
	for (my $i=0;$i<@tmp_type;$i++) {
		if ($tmp_type[$i] eq 'S') {next;}
		elsif($tmp_type[$i] eq 'M'){
			$total_match+=$tmp_number[$i];
			if($tmp_pos-$total_match<0){last;}
		}
		elsif($tmp_type[$i] eq 'N'){
			#print ">>>>>>>>>>>>>>>";
			$tmp_pos+=$tmp_number[$i];
		}
		else{
			die($tmp_type[$i]);
		}
	}
	return $tmp_start+$tmp_pos;

}


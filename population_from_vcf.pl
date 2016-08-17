#!/usr/bin/perl
use strict;
use warnings;

open IN,$ARGV[0]||die;
open L1,$ARGV[1]||die;
open L2,$ARGV[2]||die;
my $win=$ARGV[3]||=10000;
my $cov_cutoff=$ARGV[4]||=0.5;
open O,">$ARGV[5]"||die;

my %p1;
my %p2;
while (<L1>) {
	chomp;
	$p1{$_}=$_;
}
close L1;
while (<L2>) {
	chomp;
	$p2{$_}=$_;
}
close L2;

my %group;
my %pi_1;
my %pi_2;
my %pi_3;
my %site_fst;
my %cov_len;
my %num_snp;
my %num_snp_1;
my %num_snp_2;
my %num_diff_snp;
my $process=0;
while (<IN>) {
	chomp;
	if (/^\#\#/) {next;}
	my @infor=split;
	if (/^\#CHROM/) {
		for (my $i=9;$i<@infor ;$i++) {
			my $tmp_name=(split /\./,$infor[$i])[0];
			if (exists $p1{$tmp_name}) {
				$group{$i}=1;
			}
			elsif(exists $p2{$tmp_name}){
				$group{$i}=2;
			}
		}
		next;
	}
	$process++;
	if ($process % 100000==0) {
		#print STDERR "processed $process lines\n";
	}
my $f1;my $f2;my $q1;my $q2;
my $index=int ($infor[1]/$win)+1;
my $total_allel;


if (/AN=(\d+)/) {$total_allel=$1;}
	my %hash;
	for (my $i=9;$i<@infor ;$i++) {
		#print "$i\t$infor[$i]\n";
		if ($infor[$i]=~/^\.\/\./) { next;}
		my $genotype=(split /\:/,$infor[$i])[0];
		my $allel_1=(split /\//,$genotype)[0];
		my $allel_2=(split /\//,$genotype)[1];
		$hash{$allel_1}->[$group{$i}]++;
		$hash{$allel_2}->[$group{$i}]++;
		#print STDERR $allel_1,"\t",$allel_2,"\n";
	}
	
	if ((keys %hash)>2) {next;}
	my $tag=0;
	foreach my $key (keys %hash) {
		if ($key==0) {$tag=1;}
	}
	foreach my $key (keys %hash) {
			if (!defined $hash{$key}->[1]) {$hash{$key}->[1]=0;}
			if (!defined $hash{$key}->[2]) {$hash{$key}->[2]=0;}
			
		if($tag==1){
			if ($key==0) {
				$f1=$hash{$key}->[1];
				$f2=$hash{$key}->[2];
			}
			else{
				$q1=$hash{$key}->[1];
				$q2=$hash{$key}->[2];
			}
		}
		elsif($tag==0){
			if ($key==1) {
				$f1=$hash{$key}->[1];
				$f2=$hash{$key}->[2];
			}
			else{
				$q1=$hash{$key}->[1];
				$q2=$hash{$key}->[2];
			}
		}
	}

if (!defined $f1) {$f1=0}
if (!defined $q1) {$q1=0}
if (!defined $f2) {$f2=0}
if (!defined $q2) {$q2=0}

if (($f1+$f2+$q1+$q2) != $total_allel) {die "Wrong\n";}
if ($f1+$q1==10 and $f2+$q2==10) {$cov_len{$index}++;}else{next;} ######### only use sites covered by all samples
if ((keys %hash)==2) {$num_snp{$index}++;}

if ($f1*$q1!=0) {$num_snp_1{$index}++;}
if ($f2*$q2!=0) {$num_snp_2{$index}++;}
if (abs($f1/($f1+$q1)-$f2/($f2+$q2))>0.8) {$num_diff_snp{$index}++;}

$pi_1{$index}+=pi($f1/($f1+$q1),$q1/($f1+$q1));
$pi_2{$index}+=pi($f2/($f2+$q2),$q2/($f2+$q2));
$pi_3{$index}+=pi(($f1/($f1+$q1)+$f2/($f2+$q2))/2,($q1/($f1+$q1)+$q2/($f2+$q2))/2);
#print "$infor[0]\t$infor[1]\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",pi($f1/($f1+$q1),$q1/($f1+$q1)),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t",pi($f2/($f2+$q2),$q2/($f2+$q2)),"\t",1-$f1/($f1+$q1)*$f2/($f2+$q2)-$q1/($f1+$q1)*$q2/($f2+$q2),"\n";
#if (/AF=(\d+)/) {my $af=$1;if($af==1/$total_allel or $af==($total_allel-1)/$total_allel){next;}}
if ((keys %hash)==2) {
print O "$infor[0]\t$infor[1]\t$infor[3]\t$infor[4]\t$infor[5]\t$infor[6]\t$f1\t$q1\t$f2\t$q2\t",$f1/($f1+$q1),"\t",$q1/($f1+$q1),"\t",$f2/($f2+$q2),"\t",$q2/($f2+$q2),"\t",site_fst(pi($f1/($f1+$q1),$q1/($f1+$q1)),5,pi($f2/($f2+$q2),$q2/($f2+$q2)),5,pi(($f1/($f1+$q1)+$f2/($f2+$q2))/2,($q1/($f1+$q1)+$q2/($f2+$q2))/2)),"\t$infor[7]\n";
}
$site_fst{$index}+=site_fst(pi($f1/($f1+$q1),$q1/($f1+$q1)),5,pi($f2/($f2+$q2),$q2/($f2+$q2)),5,pi(($f1/($f1+$q1)+$f2/($f2+$q2))/2,($q1/($f1+$q1)+$q2/($f2+$q2))/2));
#if (site_fst(pi($f1/($f1+$q1),$q1/($f1+$q1)),5,pi($f2/($f2+$q2),$q2/($f2+$q2)),5,1-$f1/($f1+$q1)*$f2/($f2+$q2)-$q1/($f1+$q1)*$q2/($f2+$q2))eq "NA") {
#	print "$_\n";exit;
#}
}

foreach my $key (sort{$a<=>$b}(keys %cov_len)) {
	my $fst=fst($pi_1{$key},5,$pi_2{$key},5,$pi_3{$key});
	#if ($cov_len{$key}/$win<$cov_cutoff) {
		#print "$key\tNA\tNA\tNA\n";next;
	#}
	if (!exists $num_snp{$key}) {$num_snp{$key}=0;}
	if (!exists $num_diff_snp{$key}) {$num_diff_snp{$key}=0;}
	if (!exists $num_snp_1{$key}) {$num_snp_1{$key}=0;}
	if (!exists $num_snp_2{$key}) {$num_snp_2{$key}=0;}

	print "$key\t";
	print $cov_len{$key}/$win;
	print "\t$num_snp{$key}\t$num_snp_1{$key}\t$num_snp_2{$key}\t$num_diff_snp{$key}\t";
	printf "%.6f",$pi_1{$key}/$cov_len{$key};
	print "\t";
	printf "%.6f",$pi_2{$key}/$cov_len{$key};
	print "\t";
	printf "%.6f",$pi_3{$key}/$cov_len{$key};
	print "\t";
	printf "%.6f",$site_fst{$key}/$cov_len{$key};
	print "\t";
	printf $fst;
	print "\n";
}

sub fst{
#should input the parwise comparision of each group and parwise comparsion between two groups
#should input the number of each group
#format fst(group1 pi,group1 number,group2 pi,group2 number,difference between two groups)
        my $p1=$_[0];my $n1=$_[1];my $p2=$_[2];my $n2=$_[3];my $di=$_[4]; #hw within population diversity, hb between population diversity
        my $hw=($n1*($n1-1)*$p1+$n2*($n2-1)*$p2)/($n1*($n1-1)+$n2*($n2-1));
        my $hb=$di;
		if ($hb==0 and $hw==0) {return 0;}
        elsif ($hb==0 and $hw!=0) {return "NA";}
		else{
			my $fst=1-($hw)/($hb);
			return $fst;
		}
}

sub site_fst{
#should input the parwise comparision of each group and parwise comparsion between two groups
#should input the number of each group
#format fst(group1 pi,group1 number,group2 pi,group2 number,difference between two groups)
        my $p1=$_[0];my $n1=$_[1];my $p2=$_[2];my $n2=$_[3];my $di=$_[4]; #hw within population diversity, hb between population diversity
        my $hw=($n1*($n1-1)*$p1+$n2*($n2-1)*$p2)/($n1*($n1-1)+$n2*($n2-1));
        my $hb=$di;
        if ($hb==0 ) {return 0;}
        my $fst=1-($hw)/($hb);
        return $fst;
}

sub pi{
 my $p=$_[0];my $q=$_[1];
 return 1-$p*$p-$q*$q;
}

#!/usr/bin/perl
use strict;
use warnings;
use Math::CDF;
use Statistics::useR;
#sample name     coversion rate  covered C       %       average depth   mC number       %       average mC level
#P103    0.00720997776297524     126868411       0.863193757978408       11.3355912055996        40615823        0.32014133920
#P103    0.0120949590808126      23334125        0.837902289424494       11.6103664054255        13107737        0.56174109806
#P103    0.010534157629158       21440917        0.867032433026328       12.1595011071588        8993675 0.419463169415748
#P103    0.00544640992816467     82093369        0.869649350775509      

if ($ARGV[0]=~/.gz$/) {
open IN,"gzip -dc $ARGV[0]|"||die; #depth file
}
else{
open IN,"$ARGV[0]"||die;
}
open L,$ARGV[1]||die; #sample list
open C,$ARGV[2]||die; #conversion rate file
my @fdr=($ARGV[3])||die;
open O,">$ARGV[4]"||die;
my %tag;
my %rate;

while (<C>) {
	chomp;
	if (/^sample/) {next;}
	my @infor=split;
	my $name=$infor[0];
	if (!exists $tag{$name}) {
		$tag{$name}=1;
	}
	else{
		$rate{$name}->[$tag{$name}]=$infor[1];
		$tag{$name}++;
	}
}

my %lib;
my $index=0;
while (<L>) {
	chomp;
	$index++;
	my @infor=split;
	$lib{$index}=$infor[0];
}

print STDERR "loading data\n";
my %pvalue;
while (<IN>) {
	chomp;
	my @infor=split;
	#my $str_res;
	my $c_type=$infor[1];
	my $id=1;
	for (my $i=2;$i<@infor;$i++) {
		my $mc_depth=(split /\:/,$infor[$i])[0];
		my $c_depth=(split /\:/,$infor[$i])[2];

		if ($c_depth==0){next;}
		if ($mc_depth >0) {
			my $p_value=1-&Math::CDF::pbinom($mc_depth-1,$c_depth,$rate{$lib{$i-1}}->[$c_type]);
			push @{$pvalue{$id}->[$c_type]},$p_value;
		}
		$id++;
	}
	#if ($infor[0]>5000) {last;}
}
close IN;

print STDERR "estimating q value cutoff\n";
my %cut_off;
foreach my $key (keys %pvalue) {
	for (my $i=1;$i<=3 ;$i++) {
		$cut_off{$key}->[$i]=get_qvalue_cutoff(\@{$pvalue{$key}->[$i]},\@fdr);
		print STDERR $cut_off{$key}->[$i],"\t$key\t$i\n";
	}
}
#exit;
print STDERR "starting output\n";

if ($ARGV[0]=~/.gz$/) {
open IN,"gzip -dc $ARGV[0]|"||die; #depth file
}
else{
open IN,"$ARGV[0]"||die;
}


while (<IN>) {
	chomp;
	my @infor=split;
	my $c_type=$infor[1];
	my $id=1;
	print O "$infor[0]\t$infor[1]\t";
	for (my $i=2;$i<@infor;$i++) {
		my $mc_depth=(split /\:/,$infor[$i])[0];
		my $t_depth=(split /\:/,$infor[$i])[1];
		my $c_depth=(split /\:/,$infor[$i])[2];
		if ($c_depth==0){print O "$infor[$i]\t";next;}
		if ($mc_depth >0) {
			my $p_value=1-&Math::CDF::pbinom($mc_depth-1,$c_depth,$rate{$lib{$i-1}}->[$c_type]);
			if ($p_value<=$cut_off{$id}->[$c_type]) {
				print O "$infor[$i]\t";
			}
			else{
				print O "0:$t_depth:$c_depth\t";
			}
		}
		else{
			print O "$infor[$i]\t";
		}
		$id++;
	}
	print O "\n";
}
close IN;


sub get_qvalue_cutoff{
my $data_ref=$_[0];
my $fdr=$_[1];
my $data = {'pp',$data_ref,'fdr',$fdr};
my $rvar=Statistics::RData->new('data'=>$data, 'name'=>'test');
my $cmd='p.adjust(test$pp,method="BH")->q;which.max(q[q<test$fdr])->ind;cutoff<-as.numeric(test$pp[q<test$fdr][ind]);';
my $res=eval_R($cmd);
my $cutoff=${${$res->getValue()}{real}}[0];
return $cutoff;
}

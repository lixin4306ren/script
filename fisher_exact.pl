#!/usr/bin/perl
use strict;
use warnings;
use Statistics::FET 'fishers_exact';

open IN,$ARGV[0]||die;
while (<IN>) {
	chomp;
	my @infor=split;
	printf "%.6f",fishers_exact($infor[-4],$infor[-3],$infor[-2],$infor[-1],1);
	print "\n";
}
close IN;















__END__
my $cut_off=get_qvalue_cutoff(\@p,\@fdr);
open IN,$ARGV[0]||die;
while (<IN>) {
	chomp;
	my @infor=split;
	if(fishers_exact($infor[-4],$infor[-3],$infor[2],$infor[-1],1)<=$cut_off){
		print "$_\tTure\n";
	};
}
close IN;


sub get_qvalue_cutoff{
my $data_ref=$_[0];
my $fdr=$_[1];
my $data = {'pp',$data_ref,'fdr',$fdr};
my $rvar=Statistics::RData->new('data'=>$data, 'name'=>'test');
#print Dumper($data);
my $cmd='p.adjust(test$pp,method="BH")->q;which.max(q[q<test$fdr])->ind;cutoff<-as.numeric(test$pp[q<test$fdr][ind]);';
my $res=eval_R($cmd);
#print Dumper($res->getValue());
my $cutoff=${${$res->getValue()}{real}}[0];
return $cutoff;
}

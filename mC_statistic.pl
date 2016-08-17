#!/usr/bin/perl
use strict;
use warnings;
#use Statistics::useR;
my %mc_num;
my %depth;
my %mc_depth;
my %mc_cov_depth;
my %cov_num;
my %total_num;
my $cutoff=$ARGV[0]||die;
#print $cutoff;exit;

my %cov_dis;#coverage distribution
my %meth_dis;#meth level distribution

while (<STDIN>) {
	chomp;
	my @infor=split;


	if ($infor[3]<=10) {
		$cov_dis{$infor[3]}++;
	}
	else{
		$cov_dis{11}++;
	}

	my $type;
	if ($infor[1]==1 || $infor[1]==4) {
		$type="CG";	
	}
	elsif($infor[1]==2 || $infor[1]==5){
		$type="CHG";
	}
	elsif($infor[1]==3 || $infor[1]==6){
		$type="CHH";
	}
	$total_num{$type}++;
	if(!($infor[3]>=$cutoff)){next;}
	
	if ($infor[3]>0) {
		my $meth_level=$infor[2]/$infor[3];
		if ($meth_level==0) {$meth_dis{$type}{0}++;}
		elsif($meth_level>0 && $meth_level <=0.1){$meth_dis{$type}{0.1}++;}
		elsif($meth_level>0.1 && $meth_level <=0.2){$meth_dis{$type}{0.2}++;}
		elsif($meth_level>0.2 && $meth_level <=0.3){$meth_dis{$type}{0.3}++;}
		elsif($meth_level>0.3 && $meth_level <=0.4){$meth_dis{$type}{0.4}++;}
		elsif($meth_level>0.4 && $meth_level <=0.5){$meth_dis{$type}{0.5}++;}
		elsif($meth_level>0.5 && $meth_level <=0.6){$meth_dis{$type}{0.6}++;}
		elsif($meth_level>0.6 && $meth_level <=0.7){$meth_dis{$type}{0.7}++;}
		elsif($meth_level>0.7 && $meth_level <=0.8){$meth_dis{$type}{0.8}++;}
		elsif($meth_level>0.8 && $meth_level <=0.9){$meth_dis{$type}{0.9}++;}
		elsif($meth_level>0.9 && $meth_level <=1){$meth_dis{$type}{1}++;}
	}



	if ($infor[3]>0) {
		$cov_num{$type}++;
		$depth{$type}+=$infor[3];
	}
	if ($infor[2]>0 ) {
		$mc_num{$type}++;
		$mc_depth{$type}+=$infor[2];
		$mc_cov_depth{$type}+=$infor[3];
	}
	
}

my $total_cov_c;
my $total_c;
foreach my $key (keys %mc_num) {
	print "$key\t$total_num{$key}\t$cov_num{$key}\t",$cov_num{$key}/$total_num{$key},"\t",$depth{$key}/$cov_num{$key},"\t$mc_num{$key}\t",$mc_num{$key}/$cov_num{$key},"\t",$mc_depth{$key}/$depth{$key},"\t",$mc_depth{$key}/$mc_cov_depth{$key},"\n";
	$total_cov_c+=$cov_num{$key};
	$total_c+=$total_num{$key};
}

my @data_cov;
foreach my $key (sort{$a<=>$b}(keys %cov_dis)) {
	print "$key\t",$cov_dis{$key}/$total_c,"\n";
	push @data_cov,$cov_dis{$key}/$total_c;
}
my @data_meth_dis;
foreach my $key (sort{$a cmp $b}(keys %meth_dis)) {
	foreach my $key2 (sort{$a<=>$b}(keys %{$meth_dis{$key}})) {
		print "$key\t$key2\t",$meth_dis{$key}{$key2}/$cov_num{$key},"\n";
	}
}
__END__
my $data = {'cov',\@data_cov,'meth',\@data_meth_dis};
my $rvar=Statistics::RData->new('data'=>$data, 'name'=>'test');
my $cmd='';
my $res=eval_R($cmd);

barplot(rbind(count.freq(x$V4,cov.range),count.freq(y$V4,cov.range)),beside=T,names.arg=cov.range,xlab="coverage per base",ylab="count",legend.text=c(file1,file2))

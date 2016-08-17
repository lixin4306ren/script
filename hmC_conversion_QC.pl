#!/usr/bin/perl
use strict;
use warnings;

my %hash;
@{$hash{SQ6hmC}{mc_cg}}=(3,22,23,50);
#print @{$hash{SQ6hmC}{mc_cg}};
#__END__

@{$hash{SQ6hmC}{hmc_cg}}=(4,9,10,18,19,42,43,49);
@{$hash{SQ6hmC}{unc_cg}}=(12,13,35,36);

@{$hash{SQ3hmC}{mc_cg}}=(3,4,9,22,23,50);
@{$hash{SQ3hmC}{hmc_cg}}=(10,18,19,42,43);
@{$hash{SQ3hmC}{unc_cg}}=(12,13,35,36,49);

@{$hash{SQ1hmC}{mc_cg}}=(3,4,9,22,23,43,50);
@{$hash{SQ1hmC}{hmc_cg}}=(19,42);
@{$hash{SQ1hmC}{unc_cg}}=(10,12,13,18,35,36,49);

@{$hash{SQC}{mc_cg}}=(33);
@{$hash{SQC}{hmc_cg}}=();
@{$hash{SQC}{unc_cg}}=(3,4,9,10,12,13,18,19,22,23,34,35,36,42,43,49,50);

@{$hash{SQmC}{mc_cg}}=(3,4,9,10,12,13,18,19,22,23,35,36,42,43,49,50);
@{$hash{SQmC}{hmc_cg}}=();
@{$hash{SQmC}{unc_cg}}=();

@{$hash{SQfC}{mc_cg}}=(28,32,33);
@{$hash{SQfC}{fc_cg}}=(9,50);
@{$hash{SQfC}{unc_cg}}=(3,4,10,12,13,18,19,22,23,27,35,36,42,43,49);


my $con_mc_cov=0;
my $con_mc_m=0;
my $con_hmc_cov=0;
my $con_hmc_m=0;
my $con_unc_cov=0;
my $con_unc_m=0;

open IN,$ARGV[0]||die;
while (<IN>){
	chomp;
	my @infor=split;
	if (grep {$_ eq $infor[1]}@{$hash{$infor[0]}{mc_cg}}){
		$con_mc_cov+=$infor[4];
		$con_mc_m+=$infor[3];
		#print "$_\n";
	}
	elsif(grep {$_ eq $infor[1]}@{$hash{$infor[0]}{hmc_cg}}){
		$con_hmc_cov+=$infor[4];
		$con_hmc_m+=$infor[3];
		print "$_\n";
	}
	elsif(grep {$_ eq $infor[1]}@{$hash{$infor[0]}{unc_cg}}){
		$con_unc_cov+=$infor[4];
		$con_unc_m+=$infor[3];
	}
	elsif(grep {$_ eq $infor[1]}@{$hash{$infor[0]}{fc_cg}}){
	}
	else{
		print "$infor[0]\t$infor[1]\n";
		die "wrong!";

	}

}

print "hmC\t$con_hmc_m\t$con_hmc_cov\t",$con_hmc_m/$con_hmc_cov,"\n";
print "mC\t$con_mc_m\t$con_mc_cov\t",$con_mc_m/$con_mc_cov,"\n";
print "unC\t$con_unc_m\t$con_unc_cov\t",$con_unc_m/$con_unc_cov,"\n";

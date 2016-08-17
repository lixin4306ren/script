#!/usr/bin/perl
use strict;
use warnings;

#BN1JJN1:111:C0WRCACXX:7:2102:9470:61459 163     chr10   3007894 10      92M4S   =       3007986 188     TGTGTCAGGAGGGATTTCTTTTCTTGTCCC
#open IN,$ARGV[0]||die;
my $type=$ARGV[1]||die;#single or pair
my $id=0;
my $total;
print STDERR $type,"\n";
if ($type eq "single" or $type eq "real_single") {
	#print STDERR ">>>>>>>>>>>>>>>>>\n";
	open IN,"samtools view $ARGV[0]|"||die;
}
elsif($type eq 'pair'){
	open IN,"samtools view -f 0x0022 $ARGV[0]|"||die;#only print mate mapped to plus strand
}
elsif($type eq 'pair_single'){
	open IN,"samtools view -f 0x0040 $ARGV[0]|"||die;#only print read1 mate
}
else{
	open IN,"samtools view $ARGV[0]|"||die;
}
#exit;
while (<IN>) {
	chomp;
#	print ">>>\n";
	my @infor=split;
	my $read_len=length($infor[9]);
	if ($type eq "pair") {
		#if ($infor[8]<=0) {next;}
		#if ($infor[8]<10){next;}
		$id=$infor[0];
		$total+=abs($infor[8]);
		if ($infor[3]+$infor[8]-1 <= $infor[3]) {next;}
		print "$infor[2]\t$infor[3]\t",$infor[3]+$infor[8]-1,"\t$id\n";
	}
	elsif($type eq "pair_single"){
                $id=$infor[0];
                $total+=abs($infor[8]);
                #if ($infor[8]<=0) {print STDERR $_,"\n";die "wrong";exit;}
                #print "$infor[2]\t$infor[3]\t",$infor[3]+$infor[8]-1,"\t$id\n";
                if ($infor[8]<0) {
                        print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t-\n";
                }
                elsif($infor[8]>0){
                        print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t+\n";
                }

	}
	elsif($type eq "single"){
		if ($infor[8]==0) {next;}
		$id++;
		$total+=abs($infor[8]);
		if ($infor[8]<0) {
			print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t-\n";
		}
		elsif($infor[8]>0){
			print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t+\n";
		}
	}
	elsif($type eq "real_single"){
		$id++;
		if($infor[1]==0){
			print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t+\n";
		}
		elsif($infor[1]==16){
			 print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t-\n";
		}
	}
	elsif($type eq "perfect_match"){
             if(/XM\:i\:0/){
		#print "$_\n";
		$id++;
                if($infor[1]==0){
                        print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t+\n";
                }
                elsif($infor[1]==16){
                         print "$infor[2]\t$infor[3]\t",$infor[3]+$read_len-1,"\t$id\t","0\t-\n";
                }
	     }					

	}
}
close IN;
#print STDERR $total/$id,"\n";

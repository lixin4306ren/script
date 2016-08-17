#!/usr/bin/perl
use strict;
use warnings;
my $dir=$ARGV[0]||die;
my $type=$ARGV[1]||="BS";
opendir D,$dir||die;
if ($type eq "BS") {
print "Sample\tCG_NO\tCovered_CG\tCoverage\tDepth\tmC_No\tmC_Pro\tMeth_level\tConvertion_rate\n";
}elsif($type eq 'OX'){
print "Sample\tCG_NO\tCovered_CG\tCoverage\tDepth\tmC_No\tmC_Pro\tMeth_level\thmC_level\tmC_Convertion_rate\n";
}
#print $dir,"\n";
while (my $filename=readdir(D)) {
	#print "$filename\n";
	if ($filename=~/\.stat$/ && !($filename=~/labmda/) && !($filename=~/ecoli/)) {
		
		my @tmp=split /\./,$filename;
		my $sample_name=$tmp[0];
		my $tmp_file="$dir"."/$filename";
		#print "$tmp_file<<<\n";
		open TMP,$tmp_file||die;
		my $infor=<TMP>;
		close TMP;
		
		if ($type eq "BS") {
			$tmp_file="$dir"."/$sample_name".".labmda.stat";
		}
		elsif($type eq "OX")
		{
			$tmp_file="$dir"."/$sample_name".".labmda.hmc.stat";
			#print $tmp_file,"<<<<\n";
		}
		
		
		my $tmp_file2="$dir"."/$sample_name".".ecoli.stat";
		if(-e $tmp_file){}else{$tmp_file="$dir"."/$sample_name".".chrMT.stat";}
		open TMP,$tmp_file||die;
		my $infor2=<TMP>;
		close TMP;
		my @tmp2=split /\s+/,$infor2;
		@tmp=split /\s+/,$infor;

		print "$sample_name\t$tmp[1]\t$tmp[2]\t$tmp[3]\t$tmp[4]\t$tmp[5]\t$tmp[6]\t$tmp[7]\t",$tmp2[7],"\t";
		open TMP,$tmp_file2||die;
		$infor2=<TMP>;
		close TMP;
		@tmp2=split /\s+/,$infor2;
		@tmp=split /\s+/,$infor;
		
		print (1-$tmp2[7]);
		print "\n";
	
	}
}


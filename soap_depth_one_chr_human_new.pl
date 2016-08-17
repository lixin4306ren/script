#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
#use Math::CDF;
#use Statistics::useR;

my ($soap_file,$soap_file2,$reference,$cover,$baseq,$rate,$help,$out,$out2,$strand,$mapq,$trim_5_len,$fdr_level,$correct,$insert_len_file,$insert_len_file2,$offset,$read_len);

my $Function='calculate base depth';

GetOptions(
	"soap:s"=>\$soap_file,
	"soap2:s"=>\$soap_file2,
    "coverage:s"=>\$cover, 
	"ref:s"=>\$reference,
	"help"=>\$help,
	"CG:s"=>\$out,
	"NCG:s"=>\$out2,
	"mapq:s"=>\$mapq,
	"base_qual:s"=>\$baseq,
	"trim_5_len:s"=>\$trim_5_len,
	"fdr:s"=>\$fdr_level,
	"rate:s"=>\$rate,
	"correct:s"=>\$correct,
	"strand:s"=>\$strand,
	"insert_len_file:s"=>\$insert_len_file,
	"insert_len_file2:s"=>\$insert_len_file2,
	"read_len:s"=>\$read_len,
	"offset:s"=>\$offset,
);

if(!defined($reference) ||!defined($out)||!defined($read_len)||defined($help) ){
	
	Usage();
	
}
if (!defined ($mapq)) {$mapq=20;}
if (!defined ($trim_5_len)) {$trim_5_len=10;}
if (!defined ($baseq)) {$baseq=10;}
if (!defined ($correct)) {$correct=0;}
if (!defined $offset) {$offset=33;}
if (!defined $strand) {$strand="both"}
my @fdr=($fdr_level)||=(0.05);

if ($correct ==1 && !defined ($rate)) {
	print "need give converation error rate\n";
	Usage();
}
#print "$mapq\t$trim_5_len\t$baseq\t$rate\t@fdr\n";

my $noGapLength;#no gap 长度
my @t="";
my @c="";
my $id;
my $tag=0;

print STDERR "loading insert length file...\n";
my %insert;
if (defined $insert_len_file) {
	open TMP, $insert_len_file||die;
	while (<TMP>) {
		my @infor=split;
		if ($infor[1]>0 and $infor[2]==2) {
		#if ($infor[2]==2){
			$insert{$infor[0]}=$infor[1];
		}
	}
	close TMP;
}

if (defined $insert_len_file2) {
	open TMP, $insert_len_file2||die;
	while (<TMP>) {
		my @infor=split;
		#if ($infor[1]>0 and $infor[2]==2) {
		if ($infor[2]==2){
			if (!exists $insert{$infor[0]}) {
				$insert{$infor[0]}=$infor[1];
			}
			else{
				#print STDERR $_;
				#die "Wrong!\n";
			}
			
		}
	}
	close TMP;
}

print STDERR "analysis meth evidence\n";
my $removed_tsv=0;
my $removed_tsv_baseq=0;
my $total_tsv=0;
#chr10   9817794 BN1JJN1:113:C18HFACXX:7:1101:1171:2075_1:N:0:   T       1       1       73      H       -1      11      101     -1   0
my $error_line=0;
	if($soap_file=~/\.gz$/){
		open IN,"gzip -dc $soap_file|"or die $!;	
		#print ">>>>>>>>>>\n";exit;
	}elsif($soap_file=~/\.bz2$/){
		open IN,"bzip2 -dc $soap_file|"or die $!;
	}
	else{
		open IN,$soap_file or die $!;
	}
	
	while (<IN>){
		chomp;
		$total_tsv++;
		my @infor=split;
		my $col_num=scalar @infor;
		if ($col_num!=13) {$error_line++;next;}
		my $read_name=(split/_/,$infor[2])[0];
		my $tmp=(split/_/,$infor[2])[1];
		my $read_pair=(split /\:/,$tmp)[0];
		my $read_len=$infor[10];
		my $base_pos=$infor[1];
		my $chr=$infor[0];
		my $tmp_mapq=$infor[-1];
		my $tmp_baseq=ord($infor[7])-$offset;
		my $tmp_base_cyc_pos=$infor[9];
		if ($tmp_base_cyc_pos<=$trim_5_len or $tmp_baseq<=$baseq or $tmp_mapq<$mapq) {
			if($tmp_baseq<=$baseq){$removed_tsv_baseq++;}
			$removed_tsv++;next;
			}
		if (defined $insert_len_file) {
			######if (!exists $insert{$read_name}) {next;} ##6/17/2014 modfied 之前的错了，扔掉了single mapped的reads
			if (exists $insert{$read_name}) {
				if ($read_pair==1 and $tmp_base_cyc_pos>$insert{$read_name}-$read_len) { #overlap 的pair只保留一个mate
					#print "$tmp_base_cyc_pos\t$insert{$read_name}\t$_\n";
					next;
				}
			}
		}
		my $tmp_strand=$infor[4];
		if ($tmp_strand == 1 and $infor[3] eq 'C') {
			$c[$base_pos] ++;
		}
		elsif ($tmp_strand == 1 and $infor[3] ne 'C') {
			$t[$base_pos] ++;
		}
		elsif ($tmp_strand ==0 and $infor[3] eq 'G') {
			$c[$base_pos] ++;
		}
		elsif ($tmp_strand ==0 and $infor[3] ne 'G') {
			$t[$base_pos] ++;
		}
	}
	close IN;
print STDERR "total tsv $total_tsv\n";
print STDERR "removed $error_line lines\n";
print STDERR "removed $removed_tsv tsv\n";
print STDERR "removed $removed_tsv_baseq lines due to low base quality\n";
print STDERR "load ref \n";
my $ref;
open (A,$reference) || die $!;
while(<A>){
	chomp;
	if(/^>(\S+)/){
		$id = $1;
	}else{
		$ref .= uc($_);
	}
}
close A; #读ref序列

print STDERR "analysis ref and estimate fdr cutoff\n";
my %p;

open CG,">$out"||die;
if(defined $out2){open NCG,">$out2"||die;}
	my	$ref_len=length ($ref);
	#my $debug=0;
	foreach my $i (0..$ref_len-1){
		#$debug++;if($debug>100000){last;}
		my $base_type||=0;
		if ($strand eq '+') {
				if(substr($ref,$i,1) eq 'C'){
				if($i==($ref_len-1)){$base_type='3';}
				else{
				if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+1,1) eq 'G' )){$base_type='1';}
				if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+2,1) eq 'G' ) && !(substr($ref,$i+1,1) eq 'G' )){$base_type='2';}
				if(substr($ref,$i,1) eq 'C'  && !(substr($ref,$i+1,1) eq 'G' ) && !(substr($ref,$i+2,1) eq 'G' )){$base_type='3';}
				}
				}
			
		}
		elsif($strand eq '-'){
			if(substr($ref,$i,1) eq 'G'){
			$noGapLength++;
			if ($i==0) {$base_type='3';}
			else{
				if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-1,1) eq 'C' ) {$base_type='1';}
				if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-2,1) eq 'C'  && !(substr($ref,$i-1,1) eq 'C' )){$base_type='2';}
				if(substr($ref,$i,1) eq 'G'  && !(substr($ref,$i-1,1) eq 'C' ) && !(substr($ref,$i-2,1) eq 'C' )){$base_type='3';}
			}
			}
		
		}
		elsif ($strand eq 'both') {
				if(substr($ref,$i,1) eq 'C'){
					if($i==($ref_len-1)){$base_type='3';}
					else{
					if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+1,1) eq 'G' )){$base_type='1';}
					if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+2,1) eq 'G' ) && !(substr($ref,$i+1,1) eq 'G' )){$base_type='2';}
					if(substr($ref,$i,1) eq 'C'  && !(substr($ref,$i+1,1) eq 'G' ) && !(substr($ref,$i+2,1) eq 'G' )){$base_type='3';}
					}
				}
				elsif(substr($ref,$i,1) eq 'G'){
					if ($i==0) {$base_type='6';}
					else{
					if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-1,1) eq 'C' ) {$base_type='4';}
					if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-2,1) eq 'C'  && !(substr($ref,$i-1,1) eq 'C' )){$base_type='5';}
					if(substr($ref,$i,1) eq 'G'  && !(substr($ref,$i-1,1) eq 'C' ) && !(substr($ref,$i-2,1) eq 'C' )){$base_type='6';}
					}
				}

		}
		else{print STDERR "wrong! must + or - or both\n";exit;}

		#if ($i==0) {print "$base_type>>>>>>>>>>>\n";}
		if ($base_type == 1 or $base_type == 4) {
			my $t_num;
			my $c_num;
			if (!defined $t[$i+1]) {$t_num=0;}else{$t_num=$t[$i+1];}
			if (!defined $c[$i+1]) {$c_num=0;}else{$c_num=$c[$i+1];}


			if($c_num>0 and $correct > 0){
				my $p_value=1-&Math::CDF::pbinom($c_num-1,$c_num+$t_num,$rate);
				push @{$p{$base_type}}, $p_value;
			}

			if ($correct == 0) {print CG $i+1,"\t","$base_type\t$c_num\t",$c_num+$t_num,"\n";}
			
		}
		elsif($base_type > 0 and $base_type!=1 and $base_type!=4){
			my $t_num;
			my $c_num;
			if (!defined $t[$i+1]) {$t_num=0;}else{$t_num=$t[$i+1];}
			if (!defined $c[$i+1]) {$c_num=0;}else{$c_num=$c[$i+1];}
			if($c_num>0 and $correct > 0){
				my $p_value=1-&Math::CDF::pbinom($c_num-1,$c_num+$t_num,$rate);
				push @{$p{$base_type}}, $p_value;
				
			}
			if ($correct == 0){if(defined $out2){print NCG $i+1,"\t","$base_type\t$c_num\t",$c_num+$t_num,"\n";}}
		}

	}

if ($correct ==0) {exit;}

my %cut_off;
print STDERR "print p value cutoff\n";
foreach my $key (keys %p) {
                $cut_off{$key}=get_qvalue_cutoff(\@{$p{$key}},\@fdr);
				#print STDERR "@{$p{$key}}\n";
                print STDERR $cut_off{$key},"\t$key\n";
}
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

#exit;

print STDERR "print output\n";
	foreach my $i (0..$ref_len-1){
		my $base_type||=0;
		if ($strand eq '+') {
				if(substr($ref,$i,1) eq 'C'){
				if($i>=($ref_len-2)){$base_type='1';}
				if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+1,1) eq 'G' )){$base_type='1';}
				if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+2,1) eq 'G' ) && !(substr($ref,$i+1,1) eq 'G' )){$base_type='2';}
				if(substr($ref,$i,1) eq 'C'  && !(substr($ref,$i+1,1) eq 'G' ) && !(substr($ref,$i+2,1) eq 'G' )){$base_type='3';}
				}
			
		}
		elsif($strand eq '-'){
			if(substr($ref,$i,1) eq 'G'){
			$noGapLength++;
			if ($i<1) {$base_type='1';}
			if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-1,1) eq 'C' ) {$base_type='1';}
			if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-2,1) eq 'C'  && !(substr($ref,$i-1,1) eq 'C' )){$base_type='2';}
			if(substr($ref,$i,1) eq 'G'  && !(substr($ref,$i-1,1) eq 'C' ) && !(substr($ref,$i-2,1) eq 'C' )){$base_type='3';}
			}
		
		}
		elsif ($strand eq 'both') {
				if(substr($ref,$i,1) eq 'C'){
					if($i>=($ref_len-2)){$base_type='1';}
					if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+1,1) eq 'G' )){$base_type='1';}
					if(substr($ref,$i,1) eq 'C'  && (substr($ref,$i+2,1) eq 'G' ) && !(substr($ref,$i+1,1) eq 'G' )){$base_type='2';}
					if(substr($ref,$i,1) eq 'C'  && !(substr($ref,$i+1,1) eq 'G' ) && !(substr($ref,$i+2,1) eq 'G' )){$base_type='3';}
				}
				elsif(substr($ref,$i,1) eq 'G'){
					if ($i<1) {$base_type='4';}
					if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-1,1) eq 'C' ) {$base_type='4';}
					if(substr($ref,$i,1) eq 'G'  && substr($ref,$i-2,1) eq 'C'  && !(substr($ref,$i-1,1) eq 'C' )){$base_type='5';}
					if(substr($ref,$i,1) eq 'G'  && !(substr($ref,$i-1,1) eq 'C' ) && !(substr($ref,$i-2,1) eq 'C' )){$base_type='6';}
				}

		}
		else{print STDERR "wrong! must + or - or both\n";exit;}

		if ($base_type == 1 or $base_type == 4) {
			my $t_num;
			my $c_num;
			if (!defined $t[$i+1]) {$t_num=0;}else{$t_num=$t[$i+1];}
			if (!defined $c[$i+1]) {$c_num=0;}else{$c_num=$c[$i+1];}
			
			if ($c_num>0 and (1-&Math::CDF::pbinom($c_num-1,$c_num+$t_num,$rate))<=$cut_off{$base_type}) {
				print CG $i+1,"\t","$base_type\t$c_num\t",$c_num+$t_num,"\n";
			}
			else{
				print CG $i+1,"\t","$base_type\t0\t",$c_num+$t_num,"\n";
			}
			
		}
		elsif($base_type > 0 and $base_type!=1 and $base_type!=4){
			my $t_num;
			my $c_num;
			if (!defined $t[$i+1]) {$t_num=0;}else{$t_num=$t[$i+1];}
			if (!defined $c[$i+1]) {$c_num=0;}else{$c_num=$c[$i+1];}
			#print "$c_num\t$t_num\n";
			if ($c_num>0 and (1-&Math::CDF::pbinom($c_num-1,$c_num+$t_num,$rate))<=$cut_off{$base_type}) {
				if(defined $out2){print NCG $i+1,"\t","$base_type\t$c_num\t",$c_num+$t_num,"\n";}
			}
			else{
				if(defined $out2){print NCG $i+1,"\t","$base_type\t0\t",$c_num+$t_num,"\n";}
			}
		}

	}

sub Usage {
    print << "    Usage";
    
	$Function

	Usage: $0 <options>

		-soap                input soap file

		-ref                 ref sequences

		-insert_len_file     insert length file for pair-end reads

		-insert_len_file2    insert length file 2 for pair-end reads

		-strand              + or - or both, deault both

		-CG                  CG depth results

		-NCG                 non-CG depth results, optional

		-mapq                MAPQ cutoff, defalut 20

		-base_qual           base Quality cutoff, defalut 10

		-trim_5_len          length of trim from read 5', defalut 10
  
                -read_len            read length, no default

		-fdr                 fdr level, defalut 0.05
		
		-rate                control non-converstion rate

		-correct             perform fdr correction 1 or not 0, defalut 0

		-offset              base quality ascii offset, 33 or 64, defalut 33

		-h or -help          Show Help , have a choice

    Usage
	exit;

}


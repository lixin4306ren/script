#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
#use Math::CDF;
#use Statistics::useR;

my ($reference,$help,$out,$out2,$strand);

my $Function='calculate base depth';

GetOptions(
	"ref:s"=>\$reference,
	"help"=>\$help,
	"CG:s"=>\$out,
	"NCG:s"=>\$out2,
	"strand:s"=>\$strand,
);

if(!defined($reference) ||!defined($out)||defined($help) ){
	
	Usage();
	
}

if (!defined $strand) {$strand="both";}


my $noGapLength;#no gap ³¤¶È
my $id;


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
close A; #¶ÁrefÐòÁÐ


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

			print CG "$id\t",$i+1,"\t","$base_type\n";
			
		}
		elsif($base_type > 0 and $base_type!=1 and $base_type!=4){

			if(defined $out2){print NCG $i+1,"\t","$base_type\n";}
		}

	}

sub Usage {
    print << "    Usage";
    
	$Function

	Usage: $0 <options>

		-ref                 ref sequences

		-strand              + or - or both, deault both

		-CG                  CG depth results

		-NCG                 non-CG depth results, optional

		-h or -help          Show Help , have a choice

    Usage
	exit;

}


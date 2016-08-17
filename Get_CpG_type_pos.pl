#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my ($reference,$help,$out);

my $Function='output C type and pos information';

GetOptions(
	"ref:s"=>\$reference,
	"help"=>\$help,
	"O:s"=>\$out,
);

if(!defined($reference) ||!defined($out)||defined($help) ){
	
	Usage();
	
}

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

print STDERR "analysis ref\n";

open O,">$out"||die;
	my	$ref_len=length ($ref);

	foreach my $i (0..$ref_len-1){

		my $base_type||=0;

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
	
	if ($base_type>=1 && $base_type<=3) {
		print O $id,"\t",$i+1,"\t+\t$base_type\n";
	}
	elsif($base_type>=4 && $base_type<=6){
	
		print O $id,"\t",$i+1,"\t-\t$base_type\n";
	}



	}




sub Usage {
    print << "    Usage";
    
	$Function

	Usage: $0 <options>


		-ref         ref sequences

		-O          CG depth results

		-h or -help  Show Help , have a choice

    Usage
	exit;

}


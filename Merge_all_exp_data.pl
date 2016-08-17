#!/usr/bin/perl
use strict;
use warnings;

#Bla_1   chr1    200     T       A       40      27      1       1
#Bla_1   chr1    253     T       C       40      42      1       1
#Bla_1   chr1    291     T       A       40      43      1       1
#Bla_1   chr1    336     C       A       40      41      1       1

open O,">$ARGV[2]"||die;

open L,$ARGV[0]||die; # sample list
my $tissue=$ARGV[1]||die;
my %hash;
my %unseq;
my $index=0;
my $tag=0;
my $tag2=0;
while (<L>) {
	chomp;
	my @infor2=split;
	if ($infor2[1] ne $tissue) {next;}
	my $name=$infor2[0];
	$name=~s/-/_/g;

$index++;


#GSM1086911_Rhen_1_expression.tsv
my $filename="$name"."_expression.tsv";


#if ($name eq 'Ler_1') {$tag2=$index;next;}
if (-e $filename) {
	print "loading $filename\n";
}
else{
	next;
}

open S,$filename||die; # exp information
while (<S>) {
	chomp;
	if (/^tracking_id/) {next;}
	my @infor=split;
	my $gene=$infor[0];
	$hash{$gene}->[$index]=$infor[2];
}
close S;



}
close L;
#print "$index\n";
foreach my $key(sort{$a cmp $b}(keys %hash)) {
		
		print O "$key\t";
		for (my $i=1;$i<=$index ;$i++) {
					if (!defined $hash{$key}->[$i]) {
						$hash{$key}->[$i]="NA";
					}
				
				print O $hash{$key}->[$i],"\t";
			
		}
		print O "\n";
}
print "wrok done\n";

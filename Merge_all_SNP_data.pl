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

my $filename="quality_variant_filtered_$name.txt";

if ($name eq 'Col_0') {$tag=$index;next;}

if ($name eq 'Ler_1') {$tag2=$index;next;}
print "loading SNP information $name\n";


open S,$filename||die; # SNP information
while (<S>) {
	chomp;
	if (/^name/) {next;}
	my @infor=split;
	if ($infor[4] eq '-') {next;}
	if ($infor[1] eq 'chrM' or $infor[1] eq 'chrC') {next;}
	my $chr=$infor[1];$chr=~s/Chr//;$chr=~s/chr//;
	my $pos=$infor[2];
	if(!exists $hash{$chr}{$pos}->[0]){$hash{$chr}{$pos}->[0]=$infor[3];}else{
		if ($hash{$chr}{$pos}->[0] ne $infor[3]) {
		print $_,"\n";
		die "wrong\n";
		}
	
	}
	#print "$index\t";
	$hash{$chr}{$pos}->[$index]=$infor[4];
}
close S;


#unsequenced_HR_5.txt
$filename="unsequenced_$name.txt";

print "loading Unsequnced information $name\n";

open S,$filename||die; # unsequenced information
#Old_1   chr1    1       271     271     0       24      40      0       15.4775

while (<S>) {
	chomp;
	if (/^name/) {next;}
	my @infor=split;
	if ($infor[1] eq 'chrM' or $infor[1] eq 'chrC') {next;}
	my $chr=$infor[1];$chr=~s/Chr//;$chr=~s/chr//;
	my $start=$infor[2];
	my $end=$infor[3];
	for (my $i=$start;$i<=$end ;$i++) {
		$unseq{$chr}{$i}->[$index]=1;
	}
}
close S;




}
close L;

foreach my $key(sort{$a<=>$b}(keys %hash)) {
	foreach my $key2 (sort{$a<=>$b}(keys $hash{$key})) {
		
		print O "$key\t$key2\t";
		for (my $i=1;$i<=$index ;$i++) {
			if ($i == $tag) {
				print O $hash{$key}{$key2}->[0],"\t";
			}elsif($i == $tag2){
				print O "NA\t";
			}
			else{
				if (exists $unseq{$key}{$key2}->[$i]) {
					#print "$key\t$key2\n";
					$hash{$key}{$key2}->[$i]="NA";
				}
				else{
					if (!exists $hash{$key}{$key2}->[$i]) {
						$hash{$key}{$key2}->[$i]=$hash{$key}{$key2}->[0];
					}
				}
				print O $hash{$key}{$key2}->[$i],"\t";
			}
		}
		print O "\n";
	}
}
print "wrok done\n";

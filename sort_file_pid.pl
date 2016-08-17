#!/usr/bin/perl
use strict;
use warnings;

#open IN,$ARGV[0]||die;
open L,$ARGV[1]||die;
my $pid=$ARGV[2];
my %chr;
while (<L>) {
	chomp;
	my @infor=split;
	$chr{$infor[0]}=$infor[0];
}
my $cmd;
foreach my $key (sort{$a cmp $b}(keys %chr)) {
	$cmd="cat $ARGV[0]|awk '\$1==\"$key\"'|sort -k2,2n -k3,3n -k6,6r > $ARGV[0].$key.$pid.sort";
	print "$cmd\n";
	`$cmd`;
}

$cmd="cat ";
foreach my $key (sort{$a cmp $b}(keys %chr)) {
	$cmd.=" $ARGV[0].$key.$pid.sort ";
}
$cmd.="> $ARGV[0].$pid.sort";
print "$cmd\n";
`$cmd`;

foreach my $key (sort{$a cmp $b}(keys %chr)) {
	#$cmd="cat $ARGV[0]|awk '\$1==\"$key\"'|sort -k3,3n -k2,2n -k6,6r > $ARGV[0].$key.sort";
	#print "$cmd\n";
	#`$cmd`;
	unlink("$ARGV[0].$key.$pid.sort");
	#unlink("$ARGV[0].sort")
}

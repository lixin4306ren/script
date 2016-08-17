#!/usr/bin/perl
use strict;
use warnings;

opendir(DIR,$ARGV[0])||die;
print "samtools merge - ";
foreach my $file (readdir(DIR)) {
	if ($file=~/sort\.bam$/) {
		print "$ARGV[0]/$file ";
	}
}
closedir(DIR);

print "|samtools rmdup - $ARGV[0]/$ARGV[0].sort.bam.rmdup\n";

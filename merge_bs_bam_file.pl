#!/usr/bin/perl
use strict;
use warnings;

open L,$ARGV[0]||die; ### sample.list

my $tag1=0;
my $tag2=0;
my $tag3=0;
while (<L>) {
	chomp;
	my $sample=(split /\//,$_)[-1];
	
	if(!(-e "$sample/all")){mkdir("$sample/all");}
	#print "samtools merge - ";
	opendir TMP,$sample||die;
	while (my $file=readdir(TMP)) {
		if ($file=~/watson.bam.sort.bam$/) {
			$tag1=1;
			print "$sample/$file ";
		}
	}
	closedir TMP;
	if($tag1==1){print "|samtools rmdup - $sample/all/all.watson.bam.sort.bam\n";}

	#print "samtools merge - ";
	opendir TMP,$sample||die;
	while (my $file=readdir(TMP)) {
		if ($file=~/crick.bam.sort.bam$/) {
			$tag2=1;
			print "$sample/$file ";
		}
	}
	closedir TMP;
	if($tag2==1){print "|samtools rmdup - $sample/all/all.crick.bam.sort.bam\n";}

        print "samtools merge - ";
        opendir TMP,$sample||die;
        while (my $file=readdir(TMP)) {
                if ($file=~/bismark.*bam$/) {
			$tag3=1;
                        print "$sample/$file ";
                }
        }
        closedir TMP;
        if($tag3==1){print "|samtools rmdup - $sample/all/$sample.sort.bam\n";}

}
close L;


#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $read_len;
my $help;
GetOptions(
        "read_len:s"=>\$read_len,
        "help"=>\$help,
);

if(!defined($read_len)||defined($help) ){

        Usage();
}


#my $read_len=$ARGV[0]||die;
my $tag=0;
while (<>) {
	if (/^@/ and $tag==0) {print "$_";next;}elsif(/^@/ and $tag==1){next;}
	$tag=1;
	my $pair1=$_;
	my $pair2=<>;
	
	if (length((split/\s+/,$pair1)[9])==$read_len and length((split/\s+/,$pair2)[9])==$read_len) {
		if((split/\s+/,$pair1)[3]<(split/\s+/,$pair2)[3])
		{print "$pair1$pair2";}
		else{print "$pair2$pair1";}
	}
}

my $Function='removed trimed paired sam results';
sub Usage {
    print << "text";

        $Function

        Usage: $0 <options>

                -read_len     read length

                -h or -help   Show Help , have a choice

text
        exit;

}


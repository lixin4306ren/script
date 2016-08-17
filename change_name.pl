#!/usr/bin/perl
use strict;
use warnings;

while (<>) {
	if (!/^@/) {
		$_=~s/_F3//;
		$_=~s/_F5-DNA//;
	}
	print $_;
}


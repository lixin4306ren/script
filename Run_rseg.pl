#!/usr/bin/perl
use strict;
use warnings;
my $chr_len_file=$ARGV[2];
my $dead_file=$ARGV[3];
my $mode=$ARGV[4];#1,2,3
my $chr=$ARGV[5]||die;
my $out=$ARGV[6]||die;
my $args=$ARGV[7]||"";
my $pid=$$;
#print "$args\n";exit;

#  -o, -out               domain output file
#      -score             Posterior scores file
#      -readcount         readcounts file
#      -boundary          domain boundary file
#      -boundary-score    boundary transition scores file
#system("export LC_ALL=C");

my $tmp=(split /\//,$ARGV[0])[-1];
$ARGV[0]=$tmp;
$tmp=(split /\//,$ARGV[1])[-1];
$ARGV[1]=$tmp;

my $cmd="cat $ARGV[0]|awk '\$1==\"$chr\"'|sort -k2,2n -k3,3n -k6,6r > $ARGV[0].$ARGV[1].$chr.tmp1";
print "$cmd\n";
`$cmd`;
$cmd="cat $ARGV[1]|awk '\$1==\"$chr\"'|sort -k2,2n -k3,3n -k6,6r > $ARGV[0].$ARGV[1].$chr.tmp2";
print "$cmd\n";

`$cmd`;
$cmd="cat $chr_len_file|awk '\$1==\"$chr\"' > $ARGV[0].$ARGV[1].$chr.tmp.len";
print "$cmd\n";

`$cmd`;
$cmd="cat $dead_file|awk '\$1==\"$chr\"' > $ARGV[0].$ARGV[1].$chr.tmp.dead";
print "$cmd\n";

`$cmd`;
if ($mode>1) {
	$cmd="rseg-diff $ARGV[7] -c $ARGV[0].$ARGV[1].$chr.tmp.len -out $out.$chr.domain.bed -i 20 -v -mode $mode -d $ARGV[0].$ARGV[1].$chr.tmp.dead -duplicates $ARGV[0].$ARGV[1].$chr.tmp1 $ARGV[0].$ARGV[1].$chr.tmp2";
}
elsif($mode==1){
	$cmd="rseg $ARGV[7] -c $ARGV[0].$ARGV[1].$chr.tmp.len -out $out.$chr.domain.bed -i 20 -v -d $ARGV[0].$ARGV[1].$chr.tmp.dead -duplicates $ARGV[0].$ARGV[1].$chr.tmp1";
}
print "$cmd\n";
#exit;
my @log=`$cmd`;
print @log,"\n";
unlink("$ARGV[0].$ARGV[1].$chr.tmp1");
unlink("$ARGV[0].$ARGV[1].$chr.tmp2");
unlink("$ARGV[0].$ARGV[1].$chr.tmp.len");
unlink("$ARGV[0].$ARGV[1].$chr.tmp.dead");

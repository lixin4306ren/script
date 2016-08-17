#!/usr/bin/perl -w
use strict;
use File::Basename qw(basename dirname);
if($ARGV[0]=~/\.gz$/){open IN, "gzip -dc $ARGV[0]|"||die;}else{open IN,$ARGV[0];}
#open IN,$ARGV[0];
my $depth=$ARGV[2];
open O,">$ARGV[3]"||die;
open O2,">$ARGV[4]"||die;
my %total_c;
my %total_cover_c;
my %total_m_c;

#118 2 15:2:17 0:0:0 23:3:32 19:0:19 20:1:23 16:0:17 2:5:8 17:0:17 13:0:14 25:4:31 0:5:6 0:3:3 33:3:37 0:1:4 2:0:3 26:1:28 38:1:41 0:3:
#$tmp_m:$tmp_unmeth:$tmp_depth

my %m_level; 
my %depth;
my %depth_m;
my %depth_mc_site;
my %cover_number;
my $index;
print "start\n";
while (<IN>) {
        my @infor=split;
        my $tmp_number;
        $index++;
        open L,$ARGV[1]||die;

        for (my $i=2;$i<@infor;$i++) {
                my $line=<L>;my $item=(split /\s+/,$line)[0];
                my @tmp=split /\:/,$infor[$i];
                if ($tmp[2]<$depth) {next;} 
                $total_c{$item}->[0]++;$total_c{$item}->[$infor[1]]++;
                if ($tmp[2]>0) { 
                        $tmp_number++;
                        $total_cover_c{$item}->[0]++;$total_cover_c{$item}->[$infor[1]]++;$m_level{$item}->[0]+=$tmp[0]/$tmp[2];$m_level{$item}->[$infor[1]]+=$tmp[0]/$tmp[2];
                        $depth{$item}->[0]+=$tmp[2];$depth{$item}->[$infor[1]]+=$tmp[2];
                }

                if ($tmp[0]>0) { 
                        $total_m_c{$item}->[0]++;$total_m_c{$item}->[$infor[1]]++;
                        $depth_m{$item}->[0]+=$tmp[0];
                        $depth_m{$item}->[$infor[1]]+=$tmp[0];
                        $depth_mc_site{$item}->[0]+=$tmp[2];
                        $depth_mc_site{$item}->[$infor[1]]+=$tmp[2];
                }
        }
        close L;
        if (!defined $tmp_number) {$tmp_number=0;}
        $cover_number{$tmp_number}++;
}
close IN;
print "end\n";
foreach my $key (keys %total_c) {
        for (my $i=0;$i<=3 ;$i++) {
                if (!defined $total_m_c{$key}->[$i]) {$total_m_c{$key}->[$i]=0;}
                if (!defined $depth_m{$key}->[$i]) {$depth_m{$key}->[$i]=0;}
                if (!defined $depth_mc_site{$key}->[$i]) {$depth_mc_site{$key}->[$i]=0;}
                        print O "$key\t$total_c{$key}->[$i]\t$total_cover_c{$key}->[$i]\t",$total_cover_c{$key}->[$i]/$total_c{$key}->[$i],"\t",$depth{$key}->[$i]/$total_cover_c{$key}->[$i],"\t$total_m_c{$key}->[$i]\t",$total_m_c{$key}->[$i]/$total_cover_c{$key}->[$i],"\t";
                if ($total_m_c{$key}->[$i]==0) {
                        print O 0,"\t";
                }else
                {
                        print O $m_level{$key}->[$i]/$total_m_c{$key}->[$i],"\t",$m_level{$key}->[$i]/$total_cover_c{$key}->[$i],"\t";
                        print O "$depth_mc_site{$key}->[$i]\t",$depth_m{$key}->[$i]/$depth_mc_site{$key}->[$i],"\t";
                }
                print O "$depth{$key}->[$i]\t$depth_m{$key}->[$i]\ttrans rate:",$depth_m{$key}->[$i]/$depth{$key}->[$i],"\n";

        }
}

foreach my $key (sort {$a<=>$b} keys %cover_number) {
        print O2 "$key\t$cover_number{$key}\t",$cover_number{$key}/$index,"\n";
}


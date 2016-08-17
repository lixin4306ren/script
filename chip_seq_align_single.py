#!/usr/bin/python

#    
# chip-seq_align.py
#                                                                                                                                                                                                                                    
# Author: Sinan Ramazanoglu
#    Date: 12/05/2014
#Contact: sramaza2@jhmi.edu
#

import argparse
import os
import glob
import sys

#BIN=os.environ['BIN']
#TMP=os.environ['TMP']
HISEQ=os.environ['HISEQ']
#GENOME=os.environ['REF_GENOME']                 
parser = argparse.ArgumentParser()
parser.add_argument("-dir","--directory",help="directory path ex: HiSeq099/Project_C4BN8ACXX/Sample_BN1",type=str)
parser.add_argument("-o","--output",help="output directory full path",type=str)
parser.add_argument("-ref","--refgenome",help="path to ref genome",type=str)
args = parser.parse_args()


output = args.output
dir_path = args.directory
reference = args.refgenome

R1_fastq = []
R2_fastq = []
Sample_Name = dir_path.split("/")

path = HISEQ+dir_path
dirs = os.listdir(path)

os.system("mkdir "+Sample_Name[2])
os.system("cd "+Sample_Name[2])

for file in dirs:
    if "_R1_" in file:
        R1_fastq.append(file)
#    if "_R2_" in file:
#        R2_fastq.append(file)

R1_fastq = sorted(R1_fastq)
#R2_fastq = sorted(R2_fastq)

align = open(Sample_Name[2]+"/"+Sample_Name[2]+'_align.sh','w')


#align.write(HISEQ)
align.write("#$ -cwd \n#$ -pe local 10\n#$ -l mem_free=4G\n#$ -l h_vmem=50G\n")

align.write("echo Step 1 running bwa aln\n")
for i in range(0,len(R1_fastq)):
    align.write("/home/jhmi/xinli/bin/bwa aln "+reference+" "+path+"/"+R1_fastq[i]+" 1> "+output+"/"+Sample_Name[2]+"/"+R1_fastq[i]+".bwa &\n")
    #align.write("/home/jhmi/xinli/bin/bwa aln "+reference+" "+path+"/"+R2_fastq[i]+" 1> "+output+"/"+Sample_Name[2]+"/"+R2_fastq[i]+".bwa &\n")

    if (i+1) % 10 == 0:
        align.write("wait\n")

align.write("wait\n")
align.write("echo Step 2 running bwa sampe\n")

for i in range(0,len(R1_fastq)):
    align.write("/home/jhmi/xinli/bin/bwa samse  "+reference+" "+R1_fastq[i]+".bwa"+" "+path+"/"+R1_fastq[i]+" 1> "+output+"/")
    align.write(Sample_Name[2]+"/"+Sample_Name[2]+"_"+str(i)+".sam &\n")

    if (i+1) % 10 == 0:
        align.write("wait\n")

align.write("wait\necho Step 3 merging sam files and converting to bam\n")
align.write("for i in $(ls *.sam);do samtools view -Shb $i 1> $(basename $i .sam).bam;done\n")
align.write("samtools merge "+Sample_Name[2]+".bam "+Sample_Name[2]+"_*.bam\n")
align.write("rm *.bwa "+Sample_Name[2]+"_*.bam "+Sample_Name[2]+"_*.sam\n")
align.write("samtools sort "+Sample_Name[2]+".bam "+Sample_Name[2]+".sorted\n")
align.write("samtools view -bq 1 "+Sample_Name[2]+".sorted.bam 1> "+Sample_Name[2]+".sorted.uniq.bam\n")
#align.write("samtools rmdup "+Sample_Name[2]+".sorted.uniq.bam "+Sample_Name[2]+".sorted.uniq.rmdup.bam\n")

align.close()
os.system("chmod +x "+Sample_Name[2]+"/"+Sample_Name[2]+"_align.sh")

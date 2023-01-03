#!/bin/bash

#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=2G
#SBATCH --time=02:00:00
#SBATCH --job-name=fastqc
#SBATCH --mail-user=james.groffmizoguchi@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=fastqc_sample_%j.out
#SBATCH --error=fastqc_sample_%j.err
#SBATCH --partition=pall

#First, load or add the required modules
module add UHTS/Quality_control/fastqc/0.11.9
module add UHTS/Analysis/MultiQC/1.8

#Then, copy or link the files from the reads directory
ln -s /data/courses/rnaseq_course/toxoplasma_de/reads/*.fastq.gz .

#Finally, run fastqc to assess quality data
fastqc -t 8 *.fastq.gz

#Run multiqc to get a full report on every fastqc file
multiqc .

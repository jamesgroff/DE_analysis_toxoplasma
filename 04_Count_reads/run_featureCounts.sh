#!/bin/bash

#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1G
#SBATCH --time=02:00:00
#SBATCH --job-name=feature_counts
#SBATCH --mail-user=james.groffmizoguchi@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=feature_counts_%j.out
#SBATCH --error=feature_counts_%j.err
#SBATCH --partition=pall

# Add all the necessary modules for mapping
module add UHTS/Analysis/subread/2.0.1

# Calling the file directories for annotation file and sorted bam files
INDEX_DIR=/data/courses/rnaseq_course/toxoplasma_de/reference
BAM_DIR=/data/users/jgroff/DE_RNA_Seq/03_Map_reads

# Run featureCounts with outuput file "counts.txt"
featureCounts -p -C -s 2 -Q 10 -T 4 -a $INDEX_DIR/Mus_musculus.GRCm39.108.gtf.gz --tmpDir $SCRATCH -o counts.txt $BAM_DIR/*.sorted.bam

# Filter out the first line and the columns Chr, Start, End, Strand and Length from "counts.txt"
tail -n +2 counts.txt | cut -f 1,7- > counts.arranged.txt


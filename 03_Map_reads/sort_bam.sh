#!/bin/bash

#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=25G
#SBATCH --time=01:00:00
#SBATCH --job-name=sort_bam
#SBATCH --mail-user=james.groffmizoguchi@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=sort_bam_%j.out
#SBATCH --error=sort_bam_%j.err
#SBATCH --partition=pall
#SBATCH --array=0-15

# Add all the necessary modules for the sorting
module add UHTS/Analysis/samtools/1.10

# Take all the names of bam files as variables
NAMES=("SRR7821918" "SRR7821919" "SRR7821920" "SRR7821921" "SRR7821922" "SRR7821937" "SRR7821938" "SRR7821939" "SRR7821949" "SRR7821950" "SRR7821951" "SRR7821952" "SRR7821953" "SRR7821968" "SRR7821969" "SRR7821970")

# Sort the bam files with samtools sort
samtools sort -@ 4 -m 24G -o ${NAMES[$SLURM_ARRAY_TASK_ID]}.sorted.bam -T temp ${NAMES[$SLURM_ARRAY_TASK_ID]}.bam 

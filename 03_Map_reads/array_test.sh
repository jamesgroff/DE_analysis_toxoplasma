#!/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=100M
#SBATCH --time=00:01:00
#SBATCH --job-name=array_test
#SBATCH --output=output_alignment_%j.o
#SBATCH --error=error_alignment_%j.e
#SBATCH --mail-user=james.groffmizoguchi@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --partition=pall
#SBATCH --array=0-15
 
READS_DIR=/data/courses/rnaseq_course/toxoplasma_de/reads
NAMES=("SRR7821918" "SRR7821919" "SRR7821920" "SRR7821921" "SRR7821922" "SRR7821937" "SRR7821938" "SRR7821939" "SRR7821949" "SRR7821950" "SRR7821951" "SRR7821952" "SRR7821953" "SRR7821968" "SRR7821969" "SRR7821970")

echo $READS_DIR/${NAMES[$SLURM_ARRAY_TASK_ID]}_1.fastq.gz

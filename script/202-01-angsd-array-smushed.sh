#!/bin/bash
#SBATCH --output=intermediates/202/slurm_out/%A_%a.output.txt
#SBATCH --output=intermediates/202/slurm_err/%A_%a.error.txt
#SBATCH --array=1-2492%500


module load bio/angsd

IDX=$(printf "%04d" $SLURM_ARRAY_TASK_ID)

for run_type in both; do

angsd -out intermediates/202/MAFS/${run_type}.$IDX \
  -doMajorMinor 4 -ref genome/Otsh_V1_genomic.fna \
  -doMaf 1 -GL 1\
  -bam intermediates/202/${run_type}.bamlist \
  -rf intermediates/202/region_files/$IDX.txt \
  -nind 128 \
  -minInd 60 -SNP_pval 1e-6 > intermediates/202/stdout/${run_type}.$IDX.stdout 2> intermediates/202/stderr/${run_type}.$IDX.stderr
  
done
  
  
  
   
  
   
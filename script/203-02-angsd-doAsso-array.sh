#!/bin/bash
#SBATCH --output=intermediates/203/slurm_out/%A_%a.output.txt
#SBATCH --output=intermediates/203/slurm_err/%A_%a.error.txt
#SBATCH --array=1-2492%240


module load bio/angsd



IDX=$(printf "%04d" $SLURM_ARRAY_TASK_ID)


for C0 in 000 003 010 030 060; do 

  COV="-cov intermediates/203/asso-covariates-$C0.txt"
  if [ $C0 = 000 ]; then
    COV="";
  fi

  angsd -yBin intermediates/203/asso-yBin.txt \
    -out intermediates/203/asso/$IDX.$C0 \
    -doAsso 2 -GL 2 -doPost 1 -doMajorMinor 1 \
    -SNP_pval 1e-6 -doMaf 1 \
    -bam intermediates/203/asso-bamlist.txt \
    -nind 114 $COV\
    -minInd 70  -minMapQ 30 \
    -rf intermediates/202/region_files/$IDX.txt \
    -minHigh 10 > intermediates/203/stdout/$IDX.$C0.stdout  2> intermediates/203/stderr/$IDX.$C0.stderr

done

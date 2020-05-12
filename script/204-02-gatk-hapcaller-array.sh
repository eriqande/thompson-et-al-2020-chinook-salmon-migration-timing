#!/bin/bash
#SBATCH --output=intermediates/204-02/slurm_out/%A_%a.output.txt
#SBATCH --output=intermediates/204-02/slurm_err/%A_%a.error.txt
#SBATCH --array=1-259


IDX=$(printf "%04d" $SLURM_ARRAY_TASK_ID)

# this line defines $region:
eval $(./script/line-assign.sh $SLURM_ARRAY_TASK_ID intermediates/204-02/regions-list.txt)


for B in bams-1.5X-depth bams-full-read-depth; do

  outdir=intermediates/204-02/VCFs/$B
  stderrdir=intermediates/204-02/stderr
  stdoutdir=intermediates/204-02/stdout
  
  mkdir -p $outdir $stderrdir $stdoutdir
  
  gatk --java-options "-Xmx4g" HaplotypeCaller  \
     -R genome/Otsh_V1_genomic.fna \
     -I intermediates/204-02/$B.list \
     --assembly-region-padding 1000 \
     -O $outdir/$IDX.vcf \
     -L $region > $stdoutdir/$IDX.stdout 2> $stderrdir/$IDX.stderr
     
done
#!/bin/bash
#SBATCH --output=intermediates/202/slurm_out/%A_%a.output.txt
#SBATCH --output=intermediates/202/slurm_err/%A_%a.error.txt
#SBATCH --array=1-34




eval $(./script/line-assign.sh $SLURM_ARRAY_TASK_ID intermediates/203/vfiles.txt); 
module load bio/bcftools; 
j=$(basename $file); 
bcftools view -m 2 -M 2 --min-af 0.05 --max-af 0.95 \
  -i 'F_MISSING < 0.5' -S intermediates/203/spring_falls.txt \
  -Ob $file > intermediates/203/filtered_${j/vcf.gz/bcf};

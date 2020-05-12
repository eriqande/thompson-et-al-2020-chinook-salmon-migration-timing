#!/bin/bash
#SBATCH --output=intermediates/008/slurm_out/%A_%a.output.txt
#SBATCH --output=intermediates/008/slurm_err/%A_%a.error.txt
#SBATCH --array=1-160


module load bio/samtools

IDX=$SLURM_ARRAY_TASK_ID

IDX0=$(printf "%04d" $IDX)

COMMS=$( ./script/line-assign.sh $IDX intermediates/008/file-list.tsv)
eval $COMMS
base=$(basename $file)

(
cat intermediates/008/keeper_sites.txt;
echo "xxxxxxxxxxxxxxx";
samtools depth -a -r NC_037124.1:9660000-14825000 $file
) | awk  -v base=$base '
BEGIN {OFS="\t"}
/xxxxxxxxxxxx/ {go = 1; next}
go == 0 {keepers[$1]++}
go == 1 {if($2 in keepers) {sum+=$3; n+=1.0}}
END {print base, sum, n, sum/n}
' > intermediates/008/sb_depths/$IDX0.txt

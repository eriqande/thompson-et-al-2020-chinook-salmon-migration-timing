

if [ $# -ne 2 ]; then 
  echo "Usage:

    pops-and-regions-combinations.sh  poplist  num_regions
    
This just creates a three column file.  The first column is a number
which will be the SGE_TASK_INDEX.  The second is the name of the pop
(which is the same as the .bamlist for all the individuals in that pop)
and the third is the name of the region file.
"

exit 1

fi



PL=$1
NReg=$2


awk -v n=$NReg '
  NF>0 {
    for(i=1;i<=n;i++) printf("%d\t%s\tregion_%04d.txt\n", ++idx, $1, i);
  }
' $PL

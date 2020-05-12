# this script takes as input the target sequence name and a quoted string of query
# sequence names.  Then it runs lastz on them and it ultimately spits out a fasta
# that is congruent with the original target sequence.  

if [ $# -ne 3 ]; then
echo"
Syntax:

lastz-seed-and-chain-for-paralogs.sh  WorkDir  TargetSeq  \"Quoted Query Seqs\"

WorkDir is the path to a directory that should be created, within which all of the 
work and outputs will occur.  If you give it an existing directory, it might
overwrite the contents there.

TargetSeq name of the chromosome to use as the target.

\"Quoted Query Seqs\" If multiple query seqs, then quote them.

This assumes that samtools, lastz, single_cov2, and maf2fasta are in your PATH.

"

exit 1;

fi


WorkDir=$1
TargetSeq=$2
QuerySeqs=$3


# load modules on hoffman
# source /u/local/Modules/default/init/modules.sh
# module load samtools


# make these absolute paths...
# faidx indexed fasta for all the chromosomes of the target (reference)
TARGET_FASTA=/Users/eriq/Documents/UnsyncedData/Otsh_v1.0/Otsh_v1.0_genomic.fna
# TARGET_FASTA=/u/home/e/eriq/nobackup-kruegg/chinook-wgs/genome/Otsh_v1.0_genomic.fna

# indexed fasta for the query
QUERY_FASTA=/Users/eriq/Documents/UnsyncedData/Otsh_v1.0/Otsh_v1.0_genomic.fna
#QUERY_FASTA=/u/home/e/eriq/nobackup-kruegg/chinook-wgs/genome/Okis_V1_genomic.fna




mkdir -p $WorkDir
cd $WorkDir


echo "TargetSeq = $TargetSeq
QuerySeqs = $QuerySeqs" > script.info




samtools faidx $TARGET_FASTA $TargetSeq > target.fna
samtools faidx $QUERY_FASTA $QuerySeqs > query.fna


# here we create sets of parameter values for lastz to experiment with
STEP=" --step=1  "
TRAN="  --transition "
INNER=" --inner=1000 "
IDENT=" 50 "

# cycle over the parameter combos
for S in $STEP; do
  for T in $TRAN; do
    for I in $INNER; do
      for D in $IDENT; do
      
        St=${S/--/}
        Tt=${T/--/}
        It=${I/--/}
        Dt="identity=$D"
        
        OUTPRE=${St}_${Tt}_${It}_${Dt}
      
        echo "Starting lastz at $(date)" > $OUTPRE.time
        
        time (lastz target.fna query.fna $T $S $I --identity=$D \
          --gapped --ambiguous=iupac --format=maf --chain \
          --rdotplot=$OUTPRE.rdp  > $OUTPRE.maf 2> $OUTPRE.stderr) 2>> $OUTPRE.time
          
        echo "Start single_cov2 and maf2fasta at $(date)" >> $OUTPRE.time
        
        # now filter it done to single coverage, keeping the highest scoring alignment blocks
        single_cov2 $OUTPRE.maf > $OUTPRE.scov 2> $OUTPRE.scov.stderr
        
        # now maf2fasta it
        maf2fasta target.fna  $OUTPRE.scov fasta > $OUTPRE.fasta 2> $OUTPRE.fasta.stderr
        
        
        echo "Start pruning fasta at $(date)" >> $OUTPRE.time
        
        # now we process that and keep only those sites that are not dashes in the 
        # target, and also we collapse it down to one single sequence. (If multiple
        # chromosomes mapped to the target, they have already been thinned down
        # to single coverage, but now we need to collapse all the mapped variation from
        # the different queries into a single sequence.)
        NUMLINES=$(wc $OUTPRE.fasta | awk '{print $1}' )
        
        cnt=0
        for((i=2;i<=$NUMLINES;i+=2)); do 
          cnt=$((cnt + 1))
          cat $OUTPRE.fasta | awk -v n=$i 'NR == n' | fold -w1 > tmp_$OUTPRE.$(printf %03d $cnt).column
        done
        
        # now we paste those files together and count up the patterns, filter out the ones that are
        # dashes in the target, and take remove any that are dashes anywhere (should not be any of those...)
        paste tmp_$OUTPRE.*.column | awk  -v TS=$TargetSeq  -v OP="$OUTPRE" '
          BEGIN {
                 SUBSEP = "\t";
                checkfile = OP ".target.fna";
                 qfile = OP ".anc.fna.with_dashes";
                 rcfile = OP ".refcounts";
                 printf(">%s\n", TS) > checkfile;
                 printf(">%s\n", TS) > qfile;
          }
          
          {count[$0]++}
          
          $1=="-" {next}
          
          {
            q = "-";
            for(i=2;i<=NF;i++) if($i != "-") q = $i;
            printf("%s", $1) > checkfile
            printf("%s", q) > qfile
            ++L
            if(L % 60 == 0) {  # make fasta lines 60 characters long
              printf("\n") > checkfile
              printf("\n") > qfile
            }
            
            refcnts[$1, q]++;  # for sites in the reference, record the distribution of sites in the "ancestral"
            
          }
          
        END {
        
          if(L % 60 != 0) {  # put final line returns in the file.
            printf("\n") > checkfile
            printf("\n") > qfile
          }
          
          printf("ref\tanc\t\n") > rcfile;  
          for(i in refcnts) printf("%s\t%d\n", i, refcnts[i]) > rcfile;
          
          # this goes to stdout
          for(i in count) printf("%s\t%d\n", i, count[i])
        }  
        ' > $OUTPRE.seqcnts
        
        
        # now, make a version of the anc.fna with N's instead of dashes
        sed 's/-/N/g;' $OUTPRE.anc.fna.with_dashes > $OUTPRE.anc.fna
        
        # check if here is any difference with target.fna
        diff target.fna $OUTPRE.target.fna > $OUTPRE.target.fna.diff
        
        echo "Start cleaning and gzipping at $(date)" >> $OUTPRE.time
        
        # now clean stuff up
        rm -f tmp_* query.fna target.fna $OUTPRE.anc.fna.with_dashes $OUTPRE.fasta $OUTPRE.maf $OUTPRE.scov $OUTPRE.target.fna
          
        gzip -f $OUTPRE.anc.fna $OUTPRE.rdp
        
        
        echo "Done with $OUTPRE at $(date)" >> $OUTPRE.time
        
      done
    done
  done
done  




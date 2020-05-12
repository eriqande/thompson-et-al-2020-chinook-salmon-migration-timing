

if [ $# -ne 4 ]; then
echo "
  
usage: insert-var-for-primers.sh  chrom:start-stop  fasta  vcf target,positions
example: 

insert-var-for-primers.sh NC_037124.1:12299552-12300227 /Users/eriq/Documents/UnsyncedData/Otsh_v1.0/Otsh_v1.0_genomic.fna ./data/greb1l-ish-region.vcf 151,247,526

"
exit 1
fi


#REG="NC_037124.1:12299552-12300227"
#FASTA=/Users/eriq/Documents/UnsyncedData/Otsh_v1.0/Otsh_v1.0_genomic.fna
#VCF=./data/greb1l-ish-region.vcf
TARGETS="151 247 526"


REG=$1
FASTA=$2
VCF=$3
TARGETS="$4"

CHROM=${REG/:*/}
tmp=${REG/*:/}
START=${tmp/-*/}
STOP=${tmp/*-/}

tmp_reg=xxx_tmp_reg.fasta
tmp_exp=xxx_tmp_exp.txt
tmp_indels=xxx_tmp_indels.txt
tmp_snps=xxx_tmp_snps.txt

# Get the raw region
samtools faidx $FASTA $REG > $tmp_reg


# explode that into one line per position
awk -v targ="$TARGETS" '
# first get the starting position
/^>/ {
  n = split($1, a, /:/);
  n2 = split(a[2], b, /-/);
  stpos = b[1];
  next;
  pos = 0;
  }
  
  {for(i=1;i<=length($1);i++) {
    printf("%d\t%s\n", stpos + pos, substr($1, i, 1));
    pos += 1;
  }}
  
  END {
    n3 = split(targ, t, /,/);
    for(i=1;i<=n3;i++) print t[i], "* * *" > "xxx_tmp_targets.txt";
  }
' $tmp_reg > $tmp_exp


# grab SNVs from that region from the VCF
vcftools --vcf $VCF -c --chr $CHROM --from-bp $START --to-bp $STOP --remove-indels --recode | \
  awk '/^#/ {next} {print $2,$4,$5, "N"}' > $tmp_snps

# grab indels from that region of the VCF
vcftools --vcf $VCF -c --chr $CHROM --from-bp $START --to-bp $STOP --keep-only-indels --recode | \
  awk '/^#/ {next} {n1 = length($4); n2 = length($5); numX = n1; if(n2>n1) numX = n2; 
  dummy = ""
  for(i=1;i<=numX;i++) dummy = sprintf("%s%s", dummy, "X");
  print $2,$4,$5, dummy}' > $tmp_indels
  

# now we bung those together and print out a single sequence that has the Xs and Ns and *s in it.
NEWSEQ=$(cat $tmp_snps $tmp_indels xxx_tmp_targets.txt  $tmp_exp  | awk '
  NF == 4 {rep[$1] = $4; next}  # get the position-wise replacements
  {if($1 in rep) printf("%s", rep[$1]); else printf("%s", $2);}
  END {printf("\n");}
')

# then down here, clean up the temp files and then return the result to stdout
# rm $tmp_reg $tmp_exp $tmp_indels $tmp_snps xxx_tmp_targets.txt

(echo ">$REG"; echo $NEWSEQ)


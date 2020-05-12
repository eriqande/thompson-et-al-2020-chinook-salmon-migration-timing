

if [ $# -ne 1 ]; then
echo "Usage: region-files-from-chinook-bam-header  BAM

     BAM is a bam file from which the header will be exracted and used to 
segmentalize the genome.  Note that for this to work you will have to
have samtools on your system.

Basically, every \"chromosome\" that starts with an NC_03 is treated as its
own entity.  Everything else is bunged together until the total length
gets to be over 100 Mb.

This just creates a bunch of files like region_0001.txt, region_0002.txt, and
so forth, that contain the regions. 

Note that for this to work well, all the long, well-assembled stuff (the NC_03's)
should come first in the bam header.



"

exit 1;

fi


BAM=$1

samtools view -H $BAM | awk '/^@SQ/ {print $2, $3}' | \
  sed 's/SN://g; s/LN://g;' | awk '

BEGIN {n=1;}

{lnsum += $2;
  filename = sprintf("region_%04d.txt", n);
}

/^NC_03/ {
  print $1 ":" > filename;
  n++;
  lnsum = 0;
  close(filename)
  next;
} 

# and here is what happens for non-NC_03 things.
{
  print $1 ":" > filename;
  if(lnsum > 1e08) {
    n++;
    lnsum = 0;
    close(filename)
  }
}

'
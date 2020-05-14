
# This is the script used to download and install dependencies to
# the SEDNA cluster.  We use Miniconda to install many of the programs. 
# Then we deal with genomes, geo-spatial data, R packages, Java programs,
# and a few things that need to be compiled.

# You might have to do somethign different on your system.
# See the repo's README for information about dependencies.
# If need be, you can just install all the stuff by hand.

## Make a ~/bin and put it in your path --------------------------------------
mkdir -p ~/bin
echo $PATH:~/bin >> .bashrc

## Install binaries that we can from Miniconda --------------------------------

# Environment solving seems a little wonky.  This got what I needed
conda create -n thompy -c bioconda bcftools samtools angsd bwa vcftools bedtools
conda activate thompy
conda install samtools=1.9

## Get the PHASE binary and put it in ~/bin

# get PHASE:
wget http://stephenslab.uchicago.edu/assets/software/phase/phasecode/phase.2.1.1.linux.tar.gz
tar -xvf phase.2.1.1.linux.tar.gz
cp phase.2.1.1.linux/PHASE ~/bin/  # ~/bin is in my PATH
rm -r phase.2.1.1.linux # clean up



## Genomes, etc. --------------------------------------------------------------

# Download the necessary Chinook and coho
# genomes and put them in a new directory called `genome` in this repository.
# Index them with samtools faidx.

mkdir genome
cd genome

# coho genome
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/021/735/GCF_002021735.1_Okis_V1/GCF_002021735.1_Okis_V1_genomic.fna.gz
mv GCF_002021735.1_Okis_V1_genomic.fna.gz Okis_V1_genomic.fna.gz
gunzip Okis_V1_genomic.fna.gz 
samtools faidx Okis_V1_genomic.fna


# chinook genome
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/872/995/GCF_002872995.1_Otsh_v1.0/GCF_002872995.1_Otsh_v1.0_genomic.fna.gz
mv GCF_002872995.1_Otsh_v1.0_genomic.fna.gz Otsh_V1_genomic.fna.gz
gunzip Otsh_V1_genomic.fna.gz 
samtools faidx Otsh_V1_genomic.fna

# It looks like there was some inconsistency in the naming of these files
# in some scripts. On the cluster it was Otsh_V1_genomic.fna and on the other
# it was Otsh_v1.0_genomic.fna. Ridiculous. For evaluating code on the laptop the
# latter is used.  Rather than change the code throughout in this repo, we will
# just hard link both file names to the same content on disk, like so:
ln  Otsh_V1_genomic.fna Otsh_v1.0_genomic.fna
ln  Otsh_V1_genomic.fna.fai Otsh_v1.0_genomic.fna.fai

# chinook genome GFF
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/872/995/GCF_002872995.1_Otsh_v1.0/GCF_002872995.1_Otsh_v1.0_genomic.gff.gz

# Narum et al. version of Chinook genome from the Johnson Creek fish
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/vertebrate_other/Oncorhynchus_tshawytscha/all_assembly_versions/GCA_002831465.1_CHI06/GCA_002831465.1_CHI06_genomic.fna.gz
gunzip GCA_002831465.1_CHI06_genomic.fna.gz
samtools faidx GCA_002831465.1_CHI06_genomic.fna

cd ../


## Geo-Spatial data -----------------------------------------------------------


# Get the CalWater2.2.1 data set.  This is hosted on google drive so there is some major 
# rigamoral to get this with wget.  Thanks to Arjan: https://medium.com/@acpanjan/download-google-drive-files-using-wget-3c2c025a8b99
# for suggestions on how to do it.
mkdir -p geo-spatial/GISlayers_calw221_shp
cd geo-spatial/GISlayers_calw221_shp
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=13WqsA3jK1C0kW5zaznEwDkg3wBc-cBco' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=13WqsA3jK1C0kW5zaznEwDkg3wBc-cBco" -O GISlayers_calw221_shp.zip && rm -rf /tmp/cookies.txt
unzip GISlayers_calw221_shp.zip
cd ../  # now we are still in geo-spatial


# get the California Streams
mkdir California_Streams
cd California_Streams
wget http://data-cdfw.opendata.arcgis.com/datasets/29c40f65341749b3aa26d3f0e09502b9_4.zip -O California_Streams.zip
unzip California_Streams.zip
# the names of the files are all mangled.  We fix them like this:
for i in *; do j=$(echo $i | sed 's/^.*\.//g;'); mv $i California_Streams.$j; done

# now we have:
# California_Streams.cpg  California_Streams.dbf  California_Streams.prj  California_Streams.shp  California_Streams.shx 
cd ..



# get NaturalEarth data:
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE2_HR_LC_SR_W_DR.zip
unzip NE2_HR_LC_SR_W_DR.zip

wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces_lines.zip
unzip -d ne_10m_admin_1_states_provinces_lines ne_10m_admin_1_states_provinces_lines.zip

wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_coastline.zip
unzip -d ne_10m_coastline ne_10m_coastline.zip

cd ..

## R packages -----------------------------------------------------------------

# you can try to run it like this, but it is better to do it interactively in R
module load R
Rscript --vanilla R/install_packages_etc.R



## Java Programs --------------------------------------------------------------



wget https://faculty.washington.edu/browning/beagle/beagle.27Jan18.7e1.jar
git clone https://github.com/SajadMirzaei/RentPlus


echo "
BEAGLE=$PWD/beagle.27Jan18.7e1.jar
RentPlus=$PWD/RentPlus/RentPlus.jar
" > script/java-jar-paths.sh


# get snpEff

wget https://sourceforge.net/projects/snpeff/files/snpEff_v4_3t_core.zip/download -O snpEff_download.zip
unzip -d snpEff_v4_3t_core snpEff_download.zip


## Finally, compile some programs ---------------------------------------------

wget http://www.bx.psu.edu/~rsharris/lastz/lastz-1.04.03.tar.gz # slightly older version that originally used on my Mac
gunzip lastz-1.04.03.tar.gz
tar -xvf lastz-1.04.03.tar
cd lastz-distrib-1.04.03/
make
make install

cd ..

wget http://www.bx.psu.edu/miller_lab/dist/multiz-tba.012109.tar.gz
gunzip multiz-tba.012109.tar.gz
tar -xvf multiz-tba.012109.tar
cd multiz-tba.012109/
make CFLAGS='-Wall -Wextra -O0'  # have to override -Werror which causes it to flail

cd ..

# now put those into my PATH.  I do this by putting them in ~/bin which is in my PATH
cp lastz-distrib-1.04.03/bin/lastz ~/bin/
cp multiz-tba.012109/maf2fasta multiz-tba.012109/single_cov2 ~/bin



## Notes on running this on the SEDNA cluster ---------------------------------

# Before doing `source("render-numbered-Rmds.R")` within R on the
# SEDNA cluster we have to prepare it:

# get a good handful of cores.  This will make the BEAGLE stuff
# faster and will also provide snpEff sufficient memory:

# Then activate the thompy conda environment
# Then load the R module (specific to SEDNA)
# Then launch R:

srun -c 8 --pty /bin/bash

conda activate thompy
module load R 
R



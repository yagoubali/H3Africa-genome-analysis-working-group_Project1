>
> 1. URL: https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009914755.1/
> 2. Data resources (T2T-CHM13v2.0)
>   1. GCA_009914755.4	GenBank
>   2. GCF_009914755.1	RefSeq


## 2. Index Reference genome

```bash
# index locally then copy it to ilifu
# Here I use T2T GenBank because it includes Mitochondria genome
## ---> -a bwtsw	Algorithm implemented in BWT-SW. This method works with the whole human genome.
## ---> -a is	IS linear-time algorithm for constructing suffix array. It requires 5.37N memory where N is the size of the database. IS is moderately fast, but does not #work with database larger than 2GB.

#bwa index -a bwtsw  GCA_009914755.4_T2T-CHM13v2.0_genomic.fna

# ---> local download
#conda create -n ncbi_datasets
#conda activate ncbi_datasets
#conda install -c conda-forge ncbi-datasets-cli

# ----> ilifu download
sinteractive
module load  anaconda3/2023.07
conda create --prefix /cbio/projects/022/adam/conda/ncbi-datasets python=3.6
conda activate  /cbio/projects/022/adam/conda/ncbi-datasets
conda install -c conda-forge ncbi-datasets-cli
mkdir -p datasets/dbs/references/T2T
cd datasets/dbs/references/T2T
datasets download genome accession GCF_009914755.1 --include gff3,rna,cds,protein,genome,seq-report
unzip ncbi_dataset.zip 
rm ncbi_dataset.zip

# Download   GCA_009914755.4
mkdir GCA_009914755.4
cd GCA_009914755.4

# ---> https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/


#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_assembly_regions.txt 
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_assembly_report.txt
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_assembly_stats.txt
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_feature_count.txt.gz
wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.gbff.gz
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/annotation_hashes.txt
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/assembly_status.txt
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/assembly_status.txt
#wget -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/md5checksums.txt

gzip -dv GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
./chr_rename_GCA_009914755.4.sh GCA_009914755.4_T2T-CHM13v2.0_genomic.fna



module load bwa/github
## ---> -a bwtsw	Algorithm implemented in BWT-SW. This method works with the whole human genome.
## ---> -a is	IS linear-time algorithm for constructing suffix array. It requires 5.37N memory where N is the size of the database. IS is moderately fast, but does not work with database larger than 2GB.

bwa index -a bwtsw  GCA_009914755.4_T2T-CHM13v2.0_genomic.fna

module load samtools/1.19
samtools faidx  GCA_009914755.4_T2T-CHM13v2.0_genomic.fna
```

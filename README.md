# H3Africa Genome Analysis Working Group

> Project1: Pilot re-analysis of H3A-Baylor samples

## 1. Genome assembly T2T-CHM13v2.0 Reference Genome

```bash
1. URL: https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009914755.1/
2. Data resources (T2T-CHM13v2.0)
   1. GCA_009914755.4	GenBank
   2. GCF_009914755.1	RefSeq
```

## 2. Index Reference genome

```bash
# index locally then copy it to ilifu
# Here I use T2T GenBank because it includes Mitochondria genome
## ---> -a bwtsw	Algorithm implemented in BWT-SW. This method works with the whole human genome.
## ---> -a is	IS linear-time algorithm for constructing suffix array. It requires 5.37N memory where N is the size of the database. IS is moderately fast, but does not work with database larger than 2GB.

bwa index -a bwtsw  GCA_009914755.4_T2T-CHM13v2.0_genomic.fna
```

## [3. bwa mem mapping]('./stage1:convert_carm_T2T_mapping/README.md')


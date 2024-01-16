#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github

userId="yagoubali"
user_dir1="/cbio/users/${userId}/project1_all_wCollate" 
user_dir2="/cbio/users/${userId}/project1_all_woCollate" 
scratch_dir="/scratch3/users/${userId}" 
data_dir="/cbio/datasets/human/baylor/b38/cram"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
REF_GENOME_T2T="/cbio/users/yagoubali/datasets/human/T2T/GenBank/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
SAMPLE=$1

## Copy cram files

cram_file="${data_dir}/${SAMPLE}/${SAMPLE}.md.recal.cram"
cp ${cram_file}* ${scratch_dir}/

## Convert cram files to fastq: 1. with collate 2. without collate
# -t:      Copy RG, BC and QT tags to the FASTQ header line, if they exist.
# output paired reads to separate files, discarding singletons, supplementary and secondary reads.

## ----> 1. with collate 
echo "Convert cram to fastq after sorting cram with collate operation"
samtools collate -u -@ 8 \
    --reference=${REF_GENOME_hg38}  \
    -o ${scratch_dir}/${SAMPLE}_wCollate.bam \
    ${scratch_dir}/${SAMPLE}.md.recal.cram 

#samtools sort -o ${scratch_dir}/${SAMPLE}_intermediate.sorted.bam \
#         ${scratch_dir}/${SAMPLE}_intermediate.bam
samtools fastq -@ 8 --reference=${REF_GENOME_hg38}  \
    -1  ${scratch_dir}/${SAMPLE}_wCollate_1.fq.gz  \
    -2  ${scratch_dir}/${SAMPLE}_wCollate_2.fq.gz  \
    -s ${scratch_dir}/${SAMPLE}_wCollate_single.fq  \
     ${scratch_dir}/${SAMPLE}_wCollate.bam 

samtools fastq -@ 8 --reference=${REF_GENOME_hg38}  \
      ${scratch_dir}/${SAMPLE}_wCollate.bam  \
    >  ${scratch_dir}/${SAMPLE}_wCollate_all.fq.gz 

## ----> 2. without collate 
echo "Convert cram to fastq without sorting cram with collate operation"
samtools fastq -@ 8  -t --reference=${REF_GENOME_hg38}  \
    -1  ${scratch_dir}/${SAMPLE}_woCollate_1.fq.gz  \
    -2  ${scratch_dir}/${SAMPLE}_woCollate_2.fq.gz  \
    -s ${scratch_dir}/${SAMPLE}_woCollate_single.fq  \
     ${scratch_dir}/${SAMPLE}.md.recal.cram

samtools fastq -@ 8 --reference=${REF_GENOME_hg38}  \
     ${scratch_dir}/${SAMPLE}.md.recal.cram \
    >  ${scratch_dir}/${SAMPLE}_woCollate_all.fq.gz 

read_group="@RG\\tID:dummy.0\\tLB:LIBA\\tSM:${SAMPLE}\\tPL:Illumina"

echo "read_group: ${read_group}"

echo "Map fatqc to T2T reference"
echo "step 1.1: T2T -- Map fatqc generated with samtools collate  operation"

# map to T2T # $( echo ${read_group} 
## ---> a 	Output all found alignments for single-end or unpaired paired-end reads. 
      #These alignments will be flagged as secondary alignments.
# ----> -M 	Mark shorter split hits as secondary (for Picard compatibility).
# ----> -Y            use soft clipping for supplementary alignments    
#-aM   
bwa mem -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_T2T} \
     ${scratch_dir}/${SAMPLE}_wCollate_1.fq.gz  ${scratch_dir}/${SAMPLE}_wCollate_2.fq.gz \
    > ${scratch_dir}/${SAMPLE}_wCollate.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_wCollate.sam > ${scratch_dir}/${SAMPLE}_wCollate.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_wCollate.sorted.bam ${scratch_dir}/${SAMPLE}_wCollate.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_wCollate.sorted.bam  > ${scratch_dir}/${SAMPLE}_wCollate.flagstat

cp ${scratch_dir}/${SAMPLE}_wCollate.sorted.bam* ${user_dir1}/
cp ${scratch_dir}/${SAMPLE}_wCollate.flagstat ${user_dir1}/
rm ${scratch_dir}/${SAMPLE}_wCollate.sam 
rm ${scratch_dir}/${SAMPLE}_wCollate.bam
rm ${scratch_dir}/${SAMPLE}_wCollate.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_wCollate.flagstat 

bwa mem -p -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_T2T} \
       ${scratch_dir}/${SAMPLE}_wCollate_all.fq.gz \
    > ${scratch_dir}/${SAMPLE}_wCollate_all.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_wCollate_all.sam > ${scratch_dir}/${SAMPLE}_wCollate_all.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_wCollate_all.sorted.bam ${scratch_dir}/${SAMPLE}_wCollate_all.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_wCollate_all.sorted.bam  > ${scratch_dir}/${SAMPLE}_wCollate_all.flagstat

cp ${scratch_dir}/${SAMPLE}_wCollate_all.sorted.bam* ${user_dir1}/
cp ${scratch_dir}/${SAMPLE}_wCollate_all.flagstat ${user_dir1}/
rm ${scratch_dir}/${SAMPLE}_wCollate_all.sam 
rm ${scratch_dir}/${SAMPLE}_wCollate_all.bam
rm ${scratch_dir}/${SAMPLE}_wCollate_all.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_wCollate_all.flagstat 

echo "step 1.2: T2T -- Map fatqc generated without using samtools collate  operation"

bwa mem -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_T2T} \
     ${scratch_dir}/${SAMPLE}_woCollate_1.fq.gz  ${scratch_dir}/${SAMPLE}_woCollate_2.fq.gz \
    > ${scratch_dir}/${SAMPLE}_woCollate.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_woCollate.sam > ${scratch_dir}/${SAMPLE}_woCollate.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_woCollate.sorted.bam ${scratch_dir}/${SAMPLE}_woCollate.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_woCollate.sorted.bam  > ${scratch_dir}/${SAMPLE}_woCollate.flagstat

cp ${scratch_dir}/${SAMPLE}_woCollate.sorted.bam* ${user_dir2}/
cp ${scratch_dir}/${SAMPLE}_woCollate.flagstat ${user_dir2}/
rm ${scratch_dir}/${SAMPLE}_woCollate.sam 
rm ${scratch_dir}/${SAMPLE}_woCollate.bam
rm ${scratch_dir}/${SAMPLE}_woCollate.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_woCollate.flagstat 

bwa mem -p -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_T2T} \
       ${scratch_dir}/${SAMPLE}_woCollate_all.fq.gz \
    > ${scratch_dir}/${SAMPLE}_woCollate_all.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_woCollate_all.sam > ${scratch_dir}/${SAMPLE}_woCollate_all.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_woCollate_all.sorted.bam ${scratch_dir}/${SAMPLE}_woCollate_all.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_woCollate_all.sorted.bam  > ${scratch_dir}/${SAMPLE}_woCollate_all.flagstat

cp ${scratch_dir}/${SAMPLE}_woCollate_all.sorted.bam* ${user_dir2}/
cp ${scratch_dir}/${SAMPLE}_woCollate_all.flagstat ${user_dir2}/
rm ${scratch_dir}/${SAMPLE}_woCollate_all.sam 
rm ${scratch_dir}/${SAMPLE}_woCollate_all.bam
rm ${scratch_dir}/${SAMPLE}_woCollate_all.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_woCollate_all.flagstat 

echo "Map fatqc to hg38 reference"
echo "step 2.1: hg38 -- Map fatqc generated with samtools collate  operation"

bwa mem -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_hg38} \
     ${scratch_dir}/${SAMPLE}_wCollate_1.fq.gz  ${scratch_dir}/${SAMPLE}_wCollate_2.fq.gz \
    > ${scratch_dir}/${SAMPLE}_wCollate_hg38.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_wCollate_hg38.sam > ${scratch_dir}/${SAMPLE}_wCollate_hg38.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam ${scratch_dir}/${SAMPLE}_wCollate_hg38.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam  > ${scratch_dir}/${SAMPLE}_wCollate_hg38.flagstat

cp ${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam* ${user_dir1}/
cp ${scratch_dir}/${SAMPLE}_wCollate_hg38.flagstat ${user_dir1}/
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38.sam 
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38.bam
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38.flagstat 

bwa mem -p -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_hg38} \
       ${scratch_dir}/${SAMPLE}_wCollate_all.fq.gz \
    > ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.sam > ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.sorted.bam ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.sorted.bam  > ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.flagstat

cp ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.sorted.bam* ${user_dir1}/
cp ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.flagstat ${user_dir1}/
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.sam 
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.bam
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_wCollate_hg38_all.flagstat 

echo "step 2.2: hg38 -- Map fatqc generated without using samtools collate  operation"

bwa mem -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_T2T} \
     ${scratch_dir}/${SAMPLE}_woCollate_1.fq.gz  ${scratch_dir}/${SAMPLE}_woCollate_2.fq.gz \
    > ${scratch_dir}/${SAMPLE}_woCollate_hg38.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_woCollate_hg38.sam > ${scratch_dir}/${SAMPLE}_woCollate_hg38.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_woCollate_hg38.sorted.bam ${scratch_dir}/${SAMPLE}_woCollate_hg38.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_woCollate_hg38.sorted.bam  > ${scratch_dir}/${SAMPLE}_woCollate_hg38.flagstat

cp ${scratch_dir}/${SAMPLE}_woCollate_hg38.sorted.bam* ${user_dir2}/
cp ${scratch_dir}/${SAMPLE}_woCollate_hg38.flagstat ${user_dir2}/
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38.sam 
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38.bam
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38.flagstat 

bwa mem -p -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_hg38} \
       ${scratch_dir}/${SAMPLE}_woCollate_all.fq.gz \
    > ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.sam > ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.sorted.bam ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.sorted.bam  > ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.flagstat

cp ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.sorted.bam* ${user_dir2}/
cp ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.flagstat ${user_dir2}/
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.sam 
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.bam
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.sorted.bam* 
rm ${scratch_dir}/${SAMPLE}_woCollate_hg38_all.flagstat 


#### clean intermediate files
echo "clean intermediate files"
rm  ${scratch_dir}/${SAMPLE}.md.recal.cram*
rm  ${scratch_dir}/${SAMPLE}_*.fq.gz 
rm  ${scratch_dir}/${SAMPLE}_*_single.fq
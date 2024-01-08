#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github

userId="yagoubali"
user_dir="/cbio/users/${userId}" 
scratch_dir="/scratch3/users/${userId}" 
data_dir="/cbio/datasets/human/baylor/b38/cram"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
REF_GENOME_T2T="/cbio/users/yagoubali/datasets/human/T2T/GenBank/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
SAMPLE=$1
RESULT="/scratch3/users/yagoubali/project1_default_values"
#for SAMPLE in ${samples[*]}; do 

    cram_file="${data_dir}/${SAMPLE}/${SAMPLE}.md.recal.cram"
    cp ${cram_file}* ${scratch_dir}/

# convert cram to fastq
# -t:      Copy RG, BC and QT tags to the FASTQ header line, if they exist.
samtools fastq -@ 8  -t --reference=${REF_GENOME_hg38}  \
    -1  ${scratch_dir}/${SAMPLE}_1.fq.gz  \
    -2  ${scratch_dir}/${SAMPLE}_2.fq.gz  \
    -s ${scratch_dir}/${SAMPLE}_single.fq  \
    ${scratch_dir}/${SAMPLE}.md.recal.cram


# map to T2T # $( echo ${read_group} 
## ---> a 	Output all found alignments for single-end or unpaired paired-end reads. 
      #These alignments will be flagged as secondary alignments.
# ----> -M 	Mark shorter split hits as secondary (for Picard compatibility).
#       
read_group="@RG\\tID:bwa\\tLB:LIBA\\tSM:${SAMPLE}\\tPL:Illumina" 
bwa mem -v 3 -aM -R  ${read_group}  \
     -t 31 \
      ${REF_GENOME_T2T} \
     ${scratch_dir}/${SAMPLE}_1.fq.gz  ${scratch_dir}/${SAMPLE}_2.fq.gz \
    > ${scratch_dir}/${SAMPLE}.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}.sam > ${scratch_dir}/${SAMPLE}.bam
samtools sort -o ${scratch_dir}/${SAMPLE}.sorted.bam ${scratch_dir}/${SAMPLE}.bam
samtools flagstat ${scratch_dir}/${SAMPLE}.sorted.bam  > ${scratch_dir}/${SAMPLE}.flagstat


cp ${scratch_dir}/${SAMPLE}.md.recal.cram.flagstat ${RESULT}/
cp ${scratch_dir}/${SAMPLE}.flagstat   ${RESULT}/
cp ${scratch_dir}/${SAMPLE}.sorted.bam*   ${RESULT}/

rm ${scratch_dir}/${SAMPLE}_1.fq.gz
rm ${scratch_dir}/${SAMPLE}_2.fq.gz
rm  ${scratch_dir}/${SAMPLE}.md.recal.cram*
rm ${scratch_dir}/${SAMPLE}.sam*
rm ${scratch_dir}/${SAMPLE}.sorted.bam*
rm ${scratch_dir}/${SAMPLE}.flagstat*
rm ${scratch_dir}/${SAMPLE}_single.fq 



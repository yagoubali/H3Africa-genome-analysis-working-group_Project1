#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github

userId="yagoubali"
user_dir="/cbio/users/${userId}/project1_Y" 
scratch_dir="/scratch3/users/${userId}" 
data_dir="/cbio/datasets/human/baylor/b38/cram"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
REF_GENOME_T2T="/cbio/users/yagoubali/datasets/human/T2T/GenBank/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
SAMPLE=$1

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
# ----> -Y            use soft clipping for supplementary alignments    
#-aM   
read_group="@RG\\tID:dummy.0\\tLB:LIBA\\tSM:${SAMPLE}\\tPL:Illumina" 
bwa mem -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_T2T} \
     ${scratch_dir}/${SAMPLE}_1.fq.gz  ${scratch_dir}/${SAMPLE}_2.fq.gz \
    > ${scratch_dir}/${SAMPLE}.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}.sam > ${scratch_dir}/${SAMPLE}.bam
samtools sort -o ${scratch_dir}/${SAMPLE}.sorted.bam ${scratch_dir}/${SAMPLE}.bam
samtools flagstat ${scratch_dir}/${SAMPLE}.sorted.bam  > ${scratch_dir}/${SAMPLE}.flagstat


## # map to hg38 # 
#-aM 
bwa mem  -R  ${read_group}  \
     -t 31 \
     -K 100000000 -Y \
      ${REF_GENOME_hg38} \
      ${scratch_dir}/${SAMPLE}_1.fq.gz  ${scratch_dir}/${SAMPLE}_2.fq.gz \
    > ${scratch_dir}/${SAMPLE}_hg38.sam

samtools view -S -b ${scratch_dir}/${SAMPLE}_hg38.sam > ${scratch_dir}/${SAMPLE}_hg38.bam
samtools sort -o ${scratch_dir}/${SAMPLE}_hg38.sorted.bam ${scratch_dir}/${SAMPLE}_hg38.bam
samtools flagstat ${scratch_dir}/${SAMPLE}_hg38.sorted.bam  > ${scratch_dir}/${SAMPLE}_hg38.flagstat

cp ${scratch_dir}/${SAMPLE}.md.recal.cram.flagstat ${user_dir}/
cp ${scratch_dir}/${SAMPLE}.flagstat   ${user_dir}/
cp ${scratch_dir}/${SAMPLE}.sorted.bam*   ${user_dir}/
cp ${scratch_dir}/${SAMPLE}_hg38.flagstat   ${user_dir}/
cp ${scratch_dir}/${SAMPLE}_hg38.sorted.bam*   ${user_dir}/


rm ${scratch_dir}/${SAMPLE}_1.fq.gz
rm ${scratch_dir}/${SAMPLE}_2.fq.gz
rm ${scratch_dir}/${SAMPLE}.md.recal.cram*
rm ${scratch_dir}/${SAMPLE}.sam*
rm ${scratch_dir}/${SAMPLE}.sorted.bam*
rm ${scratch_dir}/${SAMPLE}.flagstat*
rm ${scratch_dir}/${SAMPLE}_single.fq*
rm ${scratch_dir}/${SAMPLE}_hg38.sam*
rm ${scratch_dir}/${SAMPLE}_hg38.sorted.bam*
rm ${scratch_dir}/${SAMPLE}_hg38.flagstat 
rm ${scratch_dir}/${SAMPLE}_hg38.bam*
rm ${scratch_dir}/${SAMPLE}.bam
rm ${scratch_dir}/${SAMPLE}_hg38.bam
#mv ${scratch_dir}/${SAMPLE} ${user_dir}/



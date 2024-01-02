#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.18
module load bwa/github

userId="yagoubali"
scratch_dir="/scratch3/users/${userId}" 
data_dir="/cbio/datasets/human/baylor/b38/cram"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
REF_GENOME_T2T="/cbio/users/yagoubali/datasets/human/T2T/GenBank/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
SAMPLE=$1

#for SAMPLE in ${samples[*]}; do 

    cram_file="${data_dir}/${SAMPLE}/${SAMPLE}.md.recal.cram"
    cp ${cram_file}* ${scratch_dir}/

# convert cram to fasqc
samtools fastq -@ 8 --reference=${REF_GENOME_hg38} \
        -1  ${scratch_dir}/${SAMPLE}_1.fq.gz -2  ${scratch_dir}/${SAMPLE}_2.fq.gz \
         ${scratch_dir}/${SAMPLE}.md.recal.cram 

# map to T2T
read_group=\'@RG\\tID:bwa\\tLB:LIBA\\tSM:${SAMPLE}\\tPL:Illumina\'  
bwa mem -R ${read_group} \
     -t 31 \
     -K 100000000 \
      ${REF_GENOME_T2T} \
     ${scratch_dir}/${SAMPLE}_1.fq.gz  ${scratch_dir}/${SAMPLE}_2.fq.gz \
      > ${scratch_dir}/${SAMPLE}.sam

rm ${scratch_dir}/${SAMPLE}_1.fq.gz
rm ${scratch_dir}/${SAMPLE}_2.fq.gz
rm  ${scratch_dir}/${SAMPLE}.md.recal.cram



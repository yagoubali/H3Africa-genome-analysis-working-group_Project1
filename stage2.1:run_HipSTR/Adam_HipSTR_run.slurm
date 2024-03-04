#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github

userId="yagoubali"
bin_HipSTR="/cbio/users/${userId}/HipSTR"
scratch_dir="/scratch3/users/${userId}/HipSTR"
bed_HipSTR="${bin_HipSTR}/GRCh38.hipstr_reference_T2T.bed"
bed_hg38="${bin_HipSTR}/GRCh38.hipstr_reference.bed"

data_dir="/cbio/users/yagoubali/project1_all_samples/mapping"
outdir1="/cbio/users/${userId}/HipSTR_run/T2T" 
outdir2="/cbio/users/${userId}/HipSTR_run/hg38" 



REF_GENOME_T2T="/cbio/users/yagoubali/datasets/human/T2T/GenBank/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
SAMPLE=$1

## Copy cram files ex cp BWR0063_wCollate.sorted.bam

echo "T2T --> step 1.0: copy bam file"
bam_file="${data_dir}/${SAMPLE}_wCollate.sorted.bam"
cp ${bam_file} ${scratch_dir}/

## T2T
echo "T2T -->  step 1.1: index T2T bam file"
samtools index -@32 "${scratch_dir}/${SAMPLE}_wCollate.sorted.bam"

echo "T2T --> step 1.2: call HipSTR"
${bin_HipSTR}/HipSTR --bams          "${scratch_dir}/${SAMPLE}_wCollate.sorted.bam" \
         --fasta         ${REF_GENOME_T2T} \
         --regions       ${bed_HipSTR}  \
         --str-vcf       "${scratch_dir}/strT2T_${SAMPLE}.vcf.gz" 
         
## Call Filtering
# echo "T2T --> step 1.3: filter HipSTR call"

# python ${bin_HipSTR}/scripts/filter_vcf.py  --vcf  ${scratch_dir}/strT2T_${SAMPLE}.vcf.gz \
#                               --min-call-qual         0.9 \
#                               --max-call-flank-indel  0.15 \
#                               --max-call-stutter      0.15 \
#                               --min-call-allele-bias  -2  \
#                               --min-call-strand-bias  -2
    
# python scripts/filter_haploid_vcf.py  --vcf                   haploid_calls.vcf.gz
#                                       --min-call-qual         0.9
#                                       --max-call-flank-indel  0.15
#                                       --max-call-stutter      0.15
#### clean intermediate files
echo "T2T -->  clean intermediate files"
cp ${scratch_dir}/strT2T_${SAMPLE}.vcf.gz ${outdir1}/
rm  ${scratch_dir}/strT2T_${SAMPLE}.vcf.gz 
rm  ${scratch_dir}/${SAMPLE}_wCollate.sorted.bam*




echo "hg38 --> step 1.0: copy bam file"  ## ex  BWR0064_wCollate_hg38.sorted.bam

bam_file="${data_dir}/${SAMPLE}_wCollate_hg38.sorted.bam"
cp ${bam_file} ${scratch_dir}/

## T2T
echo "hg38 -->  step 1.1: index hg38 bam file"
samtools index -@32 "${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam"

echo "hg38 --> step 1.2: call HipSTR"
${bin_HipSTR}/HipSTR --bams          "${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam" \
         --fasta         ${REF_GENOME_hg38} \
         --regions       ${bed_hg38}  \
         --str-vcf       "${scratch_dir}/strhg38_${SAMPLE}.vcf.gz" 

echo "hg38 -->  clean intermediate files"
cp ${scratch_dir}/strhg38_${SAMPLE}.vcf.gz ${outdir2}/
rm  ${scratch_dir}/strT2T_${SAMPLE}* 
rm  ${scratch_dir}/${SAMPLE}_*
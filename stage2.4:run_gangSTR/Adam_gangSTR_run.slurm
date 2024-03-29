#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github
module load  anaconda3/2023.07
conda activate /cbio/projects/022/adam/gangstr
userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
bin_gangSTR="${PROJECT}/adam/gangstr"
scratch_dir="/scratch3/users/${userId}/gangSTR"
bed_gangSTR="${bin_gangSTR}/hg38_ver17.bed"


data_dir="${PROJECT}/${subfolder}/project1_all_samples/mapping"
outdir1="${PROJECT}/${subfolder}/project1_all_samples/gangSTR_run/T2T" 
outdir2="${PROJECT}/${subfolder}/project1_all_samples/gangSTR_run/hg38" 



REF_GENOME_T2T="/cbio/projects/022/adam/datasets/dbs/references/T2T/GCA_009914755.4/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
SAMPLE=$1



echo "T2T --> step 1.0: copy bam file"
bam_file="${data_dir}/T2T/${SAMPLE}_wCollate.sorted.bam"
cp ${bam_file} ${scratch_dir}/

# GangSTR --bam file.bam 
#        --ref ref.fa 
#        --regions regions.bed 
#        --out outprefix
## T2T
echo "T2T -->  step 1.1: index T2T bam file"
samtools index -@32 "${scratch_dir}/${SAMPLE}_wCollate.sorted.bam"

echo "T2T --> step 1.2: call gangSTR"
GangSTR   --bam    "${scratch_dir}/${SAMPLE}_wCollate.sorted.bam" \
          --ref         ${REF_GENOME_T2T} \
          --regions     ${bed_gangSTR}  \
          --out       "${scratch_dir}/strT2T_${SAMPLE}.vcf.gz" 

#### clean intermediate files
echo "T2T -->  clean intermediate files"
cp ${scratch_dir}/strT2T_${SAMPLE}.vcf.gz ${outdir1}/
rm  ${scratch_dir}/strT2T_${SAMPLE}.vcf.gz 
rm  ${scratch_dir}/${SAMPLE}_wCollate.sorted.bam*




echo "hg38 --> step 1.0: copy bam file"  ## ex  BWR0064_wCollate_hg38.sorted.bam

bam_file="${data_dir}/hg38/${SAMPLE}_wCollate_hg38.sorted.bam"
cp ${bam_file} ${scratch_dir}/

## T2T
echo "hg38 -->  step 1.1: index hg38 bam file"
samtools index -@32 "${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam"

echo "hg38 --> step 1.2: call gangSTR"
GangSTR   --bam    "${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam" \
         --ref         ${REF_GENOME_hg38} \
         --regions       ${bed_gangSTR}  \
          --out       "${scratch_dir}/strhg38_${SAMPLE}.vcf.gz" 

echo "hg38 -->  clean intermediate files"
cp ${scratch_dir}/strhg38_${SAMPLE}.vcf.gz ${outdir2}/
rm  ${scratch_dir}/strhg38_${SAMPLE}* 
rm  ${scratch_dir}/${SAMPLE}_*
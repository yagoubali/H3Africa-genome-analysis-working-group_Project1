#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=180:00:00  # 180 hours 
#SBATCH --mem=24G
#SBATCH --export=ALL

module load samtools/1.19
module load bwa/github
module load  anaconda3/2023.07
conda activate /cbio/projects/022/adam/advntr 



userId="yagoubali" ## change this 
subfolder="adam" ## change this 



PROJECT="/cbio/projects/022"
#REF_GENOME_T2T="/cbio/projects/022/adam/datasets/human/T2T/GenBank/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"




scratch_dir="/scratch3/users/${userId}/advntr"
#/cbio/projects/022/adam/project1_all_samples/ExpansionHunter_run"
outdir="${PROJECT}/${subfolder}/project1_all_samples/advntr_run"
outdir_hg38="${outdir}/hg38" 
data="/cbio/projects/022/adam/project1_all_samples_old/mapping"  ## old mapping folder, we will change it from next week 


SAMPLE=$1


## copy bam file 
echo "hg38 --> step 1.0: copy bam file"
bam_file="${data}/hg38/${SAMPLE}_wCollate_hg38.sorted.bam"
cp ${bam_file} ${scratch_dir}/

## index bam file
echo "hg38 -->  step 1.1: index bam file"
samtools index -@32 "${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam"

echo "hg38:  Running adVNTR   "    
#### We can test it without e later
advntr genotype \
     --alignment_file   ${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam \
     --fasta  ${REF_GENOME_hg38}  \
     --working_directory ${scratch_dir} \
     -m  /cbio/projects/022/adam/advntr/vntr_data/hg38_selected_VNTRs_Illumina.db  \
     --outfmt  VCF \
     -t 32 \
     -e \
     -o  ${scratch_dir}/${SAMPLE}_advtr_hg38.vcf

## copy results to output folder 
cp ${scratch_dir}/${SAMPLE}_advtr_hg38.vcf  ${outdir_hg38}/

## clean our intermediate files
rm  ${scratch_dir}/${SAMPLE}_advtr_hg38.vcf*
rm   ${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam* 




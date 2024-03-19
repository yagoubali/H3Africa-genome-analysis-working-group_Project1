#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=180:00:00  # 180 hours 
#SBATCH --mem=24G
#SBATCH --export=ALL

module load samtools/1.19
module load bwa/github

userId="yagoubali" ## change this 



subfolder="adam"
PROJECT="/cbio/projects/022"
#REF_GENOME_T2T="/cbio/projects/022/adam/datasets/human/T2T/GenBank/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"




scratch_dir="/scratch3/users/${userId}/ExpansionHunter"
#/cbio/projects/022/adam/project1_all_samples/ExpansionHunter_run"
outdir="${PROJECT}/${subfolder}/project1_all_samples/ExpansionHunter_run"
outdir_hg38="${outdir}/hg38" 
data="/cbio/projects/022/adam/project1_all_samples_old/mapping"  ## old mapping folder, we will change it from next week 



## ExpansionHunter dir
ExpansionHunter="/cbio/projects/022/adam/ExpansionHunter-v5.0.0-linux_x86_64"



SAMPLE=$1


## copy bam file 
echo "hg38 --> step 1.0: copy bam file"
bam_file="${data}/hg38/${SAMPLE}_wCollate_hg38.sorted.bam"
cp ${bam_file} ${scratch_dir}/

## index bam file
echo "hg38 -->  step 1.1: index bam file"
samtools index -@32 "${scratch_dir}/${SAMPLE}_wCollate_hg38.sorted.bam"

## run ExpansionHunter 
echo "hg38:  Running ExpansionHunter" 
${ExpansionHunter}/bin/ExpansionHunter --reads ${SAMPLE}_wCollate_hg38.sorted.bam \
                   --reference ${REF_GENOME_hg38} \
                   --variant-catalog ${ExpansionHunter_bin}/variant_catalog/grch38/ExpansionHunter_hg38.json \
                   --output-prefix str_expansion_ ${SAMPLE}_hg38

## copy results to output folder 
cp str_expansion_${SAMPLE}_hg38*  ${outdir_hg38}/




## clean our intermediate files
rm str_expansion_${SAMPLE}_hg38*
rm  ${SAMPLE}_wCollate_hg38.sorted.bam* 




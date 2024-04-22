#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=180:00:00  # 180 hours 
#SBATCH --mem=24G
#SBATCH --export=ALL

module load samtools/1.19
module load bwa/github


userId="faithadegoke"
subfolder="faith"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/ExpansionHunterDenovo"
DATA="${PROJECT}/adam/project1_all_samples/mapping"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples/ExpansionHunterDenovo_run"
REF_GENOME_T2T="/cbio/projects/022/adam/datasets/dbs/references/T2T/GCA_009914755.4/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
bed_HipSTR="${bin_HipSTR}/GRCh38.hipstr_reference.bed"



SAMPLE=$1

run_analysis(){
    type_of_ref=$1 {T2T}
    reference=$2
    
    ## copy bam file 
    echo "step 1: Copy bam file"

    bam_file="${DATA}/${type_of_ref}/${SAMPLE}_wCollate.sorted.bam"
    if [[ "${type_of_ref}" == "T2T"  ]]; then
      bam_file="${DATA}/T2T/${SAMPLE}_wCollate_hg38.sorted.bam"
    fi

    cp ${bam_file} ${SCRATCH}/

    bam=$(basename -- "${bam_file}")

    ## index bam file
    echo "step 2: Index bam file"
    samtools index -@32 "${SCRATCH}/${bam}"

    echo "Running ExpansionHunterDenovo" 

    $python straglr.py  ${SCRATCH}/${bam} \
                   ${reference} \
                   "${SCRATCH}/str_${SAMPLE}_${type_of_ref}" \
         --loci    ${bed_HipSTR}
                   --threads 32

    echo "step 3: Copy Straglr results"                
    cp ${SCRATCH}/str_${SAMPLE}_${type_of_ref}*  ${OUTDIR}/${type_of_ref}/

    echo "step 4: Clean scratch3 "                
    rm ${SCRATCH}/str_${SAMPLE}_${type_of_ref}*
    rm ${SCRATCH}/${bam}*

}

## Run T2T

run_analysis "T2T"  ${REF_GENOME_T2T}


hg38_SAMPLE=$1
run_analysis2(){
    type_of_ref=$1 {hg38}
    reference=$2
    
    ## copy bam file 
    echo "step 1: Copy bam file"

    bam_file="${DATA}/${type_of_ref}/${hg38_SAMPLE}_wCollate.sorted.bam"
    if [[ "${type_of_ref}" == "hg38"  ]]; then
      bam_file="${DATA}/hg38/${Shg38_SAMPLE}_wCollate_hg38.sorted.bam"
    fi

    cp ${bam_file} ${SCRATCH}/

    bam=$(basename -- "${bam_file}")

    ## index bam file
    echo "step 2: Index bam file"
    samtools index -@32 "${SCRATCH}/${bam}"

    echo "Running ExpansionHunter" 

    ${ExpansionHunter}/bin/ExpansionHunter --reads ${SCRATCH}/${bam} \
                   --reference ${reference} \
                   --variant-catalog ${ExpansionHunter}/RepeatCatalogs/hg38/variant_catalog.json \
                   --output-prefix "${SCRATCH}/str_${hg38_SAMPLE}_${type_of_ref}" \
                   --threads 32

    echo "step 3: Copy ExpansionHunter results"                
    cp ${SCRATCH}/str_${hg38_SAMPLE}_${type_of_ref}*  ${OUTDIR}/${type_of_ref}/

    echo "step 4: Clean scratch3 "                
    rm ${SCRATCH}/str_${hg38_SAMPLE}_${type_of_ref}*
    rm ${SCRATCH}/${bam}*

}


#Run hg38
run_analysis2 "hg38"  ${REF_GENOME_hg38}

#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github

userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/HipSTR"
DATA="${PROJECT}/${subfolder}/project1_all_samples/mapping"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples/HipSTR_run" 
REF_GENOME_T2T="/cbio/projects/022/adam/datasets/dbs/references/T2T/GCA_009914755.4/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"


bin_HipSTR="${PROJECT}/${subfolder}/HipSTR"






SAMPLE=$1

run_analysis(){
    type_of_ref=$1  # {T2T, hg38}
    reference=$2
    bed_HipSTR="${bin_HipSTR}/T2T.hipstr_reference.bed"

    ## copy bam file 
    echo "step 1: Copy bam file"

    bam_file="${DATA}/${type_of_ref}/${SAMPLE}_wCollate.sorted.bam"
    if [[ "${type_of_ref}" == "hg38"  ]]
     then
      bam_file="${DATA}/hg38/${SAMPLE}_wCollate_hg38.sorted.bam"
      bed_HipSTR="${bin_HipSTR}/GRCh38.hipstr_reference.bed"
    fi

    cp ${bam_file} ${SCRATCH}/${type_of_ref}/
    cp ${bam_file}.bai ${SCRATCH}/${type_of_ref}/

    bam=$(basename -- "${bam_file}")

    ## index bam file
    #echo "step 2: Index bam file"
    #samtools index -@32 "${SCRATCH}/${bam}"

    echo "Running HipSTR" 
    ${bin_HipSTR}/HipSTR --bams    "${SCRATCH}/${type_of_ref}/${bam}" \
         --fasta         ${reference} \
         --regions       ${bed_HipSTR}  \
         --str-vcf       "${SCRATCH}/${type_of_ref}/str_${SAMPLE}_${type_of_ref}.vcf.gz"  \
         --def-stutter-model   \
         --min-reads 10

    echo "step 3: Copy HipSTR resuls"                
    cp ${SCRATCH}/${type_of_ref}/str_${SAMPLE}_${type_of_ref}*  ${OUTDIR}/${type_of_ref}/

    echo "step 4: Clean scratch3 "                
    rm ${SCRATCH}/${type_of_ref}/str_${SAMPLE}_${type_of_ref}*
    rm ${SCRATCH}/${type_of_ref}/${bam}*

}

## Run T2T

run_analysis "T2T"  ${REF_GENOME_T2T}

#Run hg38

run_analysis "hg38"  ${REF_GENOME_hg38}
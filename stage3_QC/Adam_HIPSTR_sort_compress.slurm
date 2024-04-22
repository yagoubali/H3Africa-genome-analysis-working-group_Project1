#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github
module load anaconda3/2023.07 
module load bcftools
conda activate /cbio/projects/022/adam/gangstr
userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/HipSTR_sort"
DATA="${PROJECT}/adam/project1_all_samples/HipSTR_run"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples/HipSTR_sort"
REF_GENOME_T2T="/cbio/projects/022/adam/datasets/dbs/references/T2T/GCA_009914755.4/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"



SAMPLE=$1

## T2T strT2T_813-MALI.vcf.gz
## hg38 strhg38_865-MALI.vcf.gz

run_analysis(){
    type_of_ref=$1  # {T2T, hg38}
    reference=$2
    
    ## copy bam file 
    echo "step 1: Copy vcf file"

    vcf_file="${DATA}/${type_of_ref}/strT2T_${SAMPLE}.vcf"
    if [[ "${type_of_ref}" == "hg38"  ]]; then
      vcf_file="${DATA}/hg38/strhg38_${SAMPLE}.vcf"
    fi

    cp "${vcf_file}.gz" ${SCRATCH}/

    vcf=$(basename -- "${vcf_file}")

    ## exttract gz files, not sure it is bgziped or not
    echo "step 2: unzip  vcf file"
    gzip -d ${SCRATCH}/${vcf}.gz

    echo "step 3: sort vcf file"
  
    bcftools sort ${SCRATCH}/${vcf} -o  ${SCRATCH}/${SAMPLE}.vcf -T ${SCRATCH}
    rm ${SCRATCH}/${vcf} 
     #mv ${SCRATCH}/${vcf}.sorted ${SCRATCH}/${vcf}
    
    echo "step 4: bgzip vcf file"
    
    bgzip -c ${SCRATCH}/${SAMPLE}.vcf  >${SCRATCH}/${SAMPLE}.vcf.gz
    tabix -p vcf ${SCRATCH}/${SAMPLE}.vcf.gz

    echo "step 5: Clean scratch3 " 
    #rm ${SCRATCH}/${vcf}               
    mv ${SCRATCH}/${SAMPLE}.vcf.gz*  ${OUTDIR}/${type_of_ref}/
}

## Run T2T

run_analysis "T2T"  ${REF_GENOME_T2T}

#Run hg38

run_analysis "hg38"  ${REF_GENOME_hg38}

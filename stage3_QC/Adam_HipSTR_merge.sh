#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --output=/scratch3/users/yagoubali/HipSTR_merged/%x.%j.out
#SBATCH --error=/scratch3/users/yagoubali/HipSTR_merged/%x.%j.err
#SBATCH --export=ALL


module load samtools/1.19
module load bwa/github
module load anaconda3/2023.07 
module load bcftools
conda activate /cbio/projects/022/adam/gangstr
conda activate /cbio/projects/022/adam/trtools
userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/HipSTR_merged"
DATA="${PROJECT}/adam/project1_all_samples/HipSTR_sort"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples/HipSTR_merged"
REF_GENOME_T2T="/cbio/projects/022/adam/datasets/dbs/references/T2T/GCA_009914755.4/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"

baylor="/cbio/projects/022/adam/H3A-Baylor_sample_list.txt"	# all samples 346
bam_ids=($(cat ${baylor} | tr \\n " "))


## T2T strT2T_813-MALI.vcf.gz
## hg38 strhg38_865-MALI.vcf.gz
mkdir -p ${OUTDIR}
mkdir -p ${SCRATCH}


run_analysis(){
  
  type_of_ref=$1  # {T2T, hg38}
  reference=$2
  files=''
  separator=',' # e.g. constructing regex, pray it does not contain %s
   if [[ "${type_of_ref}" == "T2T"  ]]; then
      files=($(ls ${DATA}/${type_of_ref}/*.gz ))
    else
      files=($(ls ${DATA}/hg38/*.gz ))
    fi 
    all_files="$( printf "${separator}%s" "${files[@]}" )"
    all_files="${all_files:${#separator}}" # remove leading separator
  

     echo "step 1: merge  vcf file"
      mergeSTR \
	  --vcfs ${all_files} \
	  --out ${SCRATCH}/${type_of_ref}_merged \
	  --vcftype hipstr \
	  --verbose

   bgzip -c ${SCRATCH}/${type_of_ref}_merged.vcf  >${SCRATCH}/${type_of_ref}_merged.vcf.gz
  tabix -p vcf ${SCRATCH}/${type_of_ref}_merged.vcf.gz


    echo "step 5: Clean scratch3 " 
    #rm ${SCRATCH}/${vcf}               
    mv ${SCRATCH}/${type_of_ref}_merged*  ${OUTDIR}/
}

## Run T2T

run_analysis "T2T"  ${REF_GENOME_T2T}

#Run hg38

run_analysis "hg38"  ${REF_GENOME_hg38}

#sbatch --job-name="hipstr_merge" ~/Adam_HipSTR_merge.sh
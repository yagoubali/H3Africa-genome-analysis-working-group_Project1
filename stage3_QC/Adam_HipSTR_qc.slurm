#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --time=180:00:00
#SBATCH --mem=24G
#SBATCH --output=/scratch3/users/yagoubali/HipSTR_qc/%x.%j.out2
#SBATCH --error=/scratch3/users/yagoubali/HipSTR_qc/%x.%j.err
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
SCRATCH="/scratch3/users/${userId}/HipSTR_qc"
DATA="${PROJECT}/adam/project1_all_samples/HipSTR_run_old"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples/HipSTR_qc"
REF_GENOME_T2T="/cbio/projects/022/adam/datasets/dbs/references/T2T/GCA_009914755.4/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna"
REF_GENOME_hg38="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"

SAMPLE=$1



run_analysis(){
  
  type_of_ref=$1  # {T2T, hg38}
  reference=$2
  file="${DATA}/${type_of_ref}/str_${SAMPLE}_${type_of_ref}.vcf.gz"

  cp ${file}  ${SCRATCH}/
  
  vcf=$(basename -- "${file}")
  
  ## exttract gz files, not sure it is bgziped or not
  echo "step 2: unzip  vcf file"
  gzip -d ${SCRATCH}/${vcf}
  rm ${SCRATCH}/${vcf}

  echo "step 3: sort vcf file"
  
  bcftools sort ${SCRATCH}/str_${SAMPLE}_${type_of_ref}.vcf  -o  ${SCRATCH}/${SAMPLE}_${type_of_ref}.vcf -T ${SCRATCH}
  rm ${SCRATCH}/str_${SAMPLE}_${type_of_ref}.vcf
  
  echo "step 4: bgzip vcf file"
  bgzip -c ${SCRATCH}/${SAMPLE}_${type_of_ref}.vcf  > ${SCRATCH}/${SAMPLE}_${type_of_ref}.vcf.gz
  tabix -p vcf ${SCRATCH}/${SAMPLE}_${type_of_ref}.vcf.gz
  rm ${SCRATCH}/${SAMPLE}_${type_of_ref}.vcf




  qcSTR \
    --vcf ${SCRATCH}/${SAMPLE}_${type_of_ref}.vcf.gz \
    --out ${SCRATCH}/${SAMPLE} \
    --vcftype hipstr
   

  echo "step : Clean scratch3 " 
  #rm ${SCRATCH}/${vcf}        
        
  mv ${SCRATCH}/${SAMPLE}*  ${OUTDIR}/${type_of_ref}/
}

## Run T2T

run_analysis "T2T"  ${REF_GENOME_T2T}

#Run hg38

run_analysis "hg38"  ${REF_GENOME_hg38}

#sbatch --job-name="hipstr_merge" ~/Adam_HipSTR_merge.sh

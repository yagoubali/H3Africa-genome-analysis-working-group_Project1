#!/usr/bin/bash

userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/ExpansionHunter"
DATA="${PROJECT}/adam/project1_all_samples/mapping"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples/ExpansionHunter_run"


SUBMISSION_LOG=$(date '+%Y-%m-%d')

baylor="/cbio/projects/022/adam/H3A-Baylor_sample_list2.txt"	# all samples 346

## we store all bam ids in a bash array called bam_ids
bam_ids=($(cat ${baylor} | tr \\n " "))

### 
## we run our analysis on both T2T and hg38 refrence genome
## -------> just in case we missed some information during the conversion process
##  ------> We converted cram files to fastq and there might be some reads have been lost.

mkdir -p ${OUTDIR}/hg38
mkdir -p ${OUTDIR}/T2T
mkdir -p ${SCRATCH}


## for loop will run pararell ananlyis for all 346 samples
for bam_id in ${bam_ids[*]}; do 

      # here we run our slurm code using sbatch
        echo "Submitting Job ${bam_id}" 
        sbatch --job-name=${bam_id}   \
                 --output=${SCRATCH}/${bam_id}_slurm_%j.out  \
                 /users/${userId}/Adam_expansionHunter.slurm  ${bam_id}

    echo "${bam_id} submitted" >> ${SCRATCH}/Jobs_${SUBMISSION_LOG}.txt            
done 

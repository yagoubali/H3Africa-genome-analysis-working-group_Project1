#!/usr/bin/bash

userId="yagoubali" ## change this 


subfolder="adam"   ### No need to change, as we are all working in the same folder
PROJECT="/cbio/projects/022"   ## This is a shared folder 


scratch_dir="/scratch3/users/${userId}/ExpansionHunter"   # This is your scratch3 folder
outdir="/cbio/projects/022/${subfolder}/project1_all_samples/ExpansionHunter_run"


SUBMISSION_LOG=$(date '+%Y-%m-%d')

baylor="/cbio/project/022/adam/H3A-Baylor_sample_list.txt"	# all samples 346

## we store all bam ids in a bash array called bam_ids
bam_ids=($(cat ${baylor} | tr \\n " "))

### 
## we run our analysis on both T2T and hg38 refrence genome
## -------> just in case we missed some information during the conversion process
##  ------> We converted cram files to fastq and there might be some reads have been lost.

mkdir -p ${outdir}/hg38
mkdir -p ${scratch_dir}


## for loop will run pararell ananlyis for all 346 samples
for bam_id in ${bam_ids[*]}; do 

      # here we run our slurm code using sbatch
        echo "Submitting Job ${bam_id}" 
        sbatch --job-name=${bam_id}   \
                 output=${scratch_dir}/${bam_id}_slurm_%j.out  \
                 /users/${userId}/expansionHunter.slurm  ${bam_id}

    echo "${bam_id} submitted" >> ${scratch_dir}/Jobs_${SUBMISSION_LOG}.txt"            
done 

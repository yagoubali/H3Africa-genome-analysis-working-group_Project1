#!/usr/bin/bash

RESULT="/scratch3/users/yagoubali/project1"
#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)
SUBMISSION_LOG=$(date '+%Y-%m-%d')


userId="yagoubali"
baylor="/users/${userId}/H3A-Baylor_sample_list.txt"	
cram_ids=($(cat ${baylor} | tr \\n " "))

mkdir -p ${RESULT}
###
for cram_id in ${cram_ids[*]}; do 
    echo "Submitting Job ${cram_id}"
    mkdir -p /scratch3/users/${userId}/${cram_id}   
	sbatch --job-name=${cram_id} \
	       	       --output=/scratch3/users/${userId}/${cram_id}/${cram_id}_slurm_%j.out \
	      	        /users/${userId}/T2T_run.slurm ${cram_id}
	echo "${cram_id} submitted" >> ${RESULT}/Jobs_${SUBMISSION_LOG}.txt
done 

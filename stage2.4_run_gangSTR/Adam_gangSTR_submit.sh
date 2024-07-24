#!/usr/bin/bash


userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/gangSTR"
DATA="${PROJECT}/adam/project1_all_samples/mapping"
RESULT="${SCRATCH}/out"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples"



#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)
SUBMISSION_LOG=$(date '+%Y-%m-%d')


baylor="/cbio/projects/022/adam/H3A-Baylor_sample_list.txt"
bam_ids=($(cat ${baylor} | tr \\n " "))

mkdir -p ${OUTDIR}/gangSTR_run/T2T
mkdir -p ${OUTDIR}/gangSTR_run/hg38
mkdir -p ${SCRATCH}/T2T
mkdir -p ${SCRATCH}/hg38
mkdir -p ${RESULT}

for bam_id in ${bam_ids[*]}; do 
    echo "Submitting Job ${bam_id}" 
	sbatch --job-name=${bam_id} \
	       	       --output=${RESULT}/${bam_id}_slurm_%j.out \
	      	        /users/${userId}/Adam_gangSTR_run.slurm ${bam_id}
	echo "${bam_id} submitted" >> ${RESULT}/Jobs_${SUBMISSION_LOG}.txt
done 

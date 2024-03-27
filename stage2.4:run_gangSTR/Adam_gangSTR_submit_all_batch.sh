#!/usr/bin/bash


userId="yagoubali"
subfolder="adam"
scratch_dir="/scratch3/users/${userId}/gangSTR"

PROJECT="/cbio/projects/022"
RESULT="${scratch_dir}/out"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples"



#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)
SUBMISSION_LOG=$(date '+%Y-%m-%d')



baylor="/users/${userId}/H3A-Baylor_sample_list.txt"	# all samples
bam_ids=($(cat ${baylor} | tr \\n " "))

mkdir -p ${OUTDIR}/gangSTR_run/T2T
mkdir -p ${OUTDIR}/gangSTR_run/hg38
mkdir -p ${scratch_dir}
mkdir -p ${RESULT}
for bam_id in ${bam_ids[*]}; do 
    echo "Submitting Job ${bam_id}" 
	sbatch --job-name=${bam_id} \
	       	       --output=${RESULT}/${bam_id}_slurm_%j.out \
	      	        /users/${userId}/Adam_gangSTR_run.slurm ${bam_id}
	echo "${bam_id} submitted" >> ${RESULT}/Jobs_${SUBMISSION_LOG}.txt
done 

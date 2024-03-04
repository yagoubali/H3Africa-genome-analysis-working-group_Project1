#!/usr/bin/bash


userId="yagoubali"
scratch_dir="/scratch3/users/${userId}/HipSTR"
outdir="/cbio/users/${userId}/project1_all_samples/HipSTR_run"  
#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)
SUBMISSION_LOG=$(date '+%Y-%m-%d')



baylor="/users/${userId}/H3A-Baylor_sample_list.txt"	# all samples
bam_ids=($(cat ${baylor} | tr \\n " "))

mkdir -p ${outdir}/T2T
mkdir -p ${outdir}/hg38
mkdir -p ${scratch_dir}

for bam_id in ${bam_ids[*]}; do 
    echo "Submitting Job ${bam_id}" 
	sbatch --job-name=${bam_id} \
	       	       --output=${scratch_dir}/${bam_id}_slurm_%j.out \
	      	        /users/${userId}/Adam_HipSTR_run.slurm ${bam_id}
	echo "${bam_id} submitted" >> ${scratch_dir}/Jobs_${SUBMISSION_LOG}.txt
done 

#!/usr/bin/bash


userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/HipSTR_sort"
DATA="${PROJECT}/adam/project1_all_samples/HipSTR_run"
RESULT="${SCRATCH}/out"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples"



#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)
SUBMISSION_LOG=$(date '+%Y-%m-%d')


#baylor="/cbio/projects/022/adam/H3A-Baylor_sample_list.txt"
baylor="/cbio/projects/022/adam/H3A-Baylor_sample_list.txt"	# all samples 346
bam_ids=($(cat ${baylor} | tr \\n " "))


mkdir -p ${OUTDIR}/HipSTR_sort/T2T
mkdir -p ${OUTDIR}/HipSTR_sort/hg38
mkdir -p ${SCRATCH}/T2T
mkdir -p ${SCRATCH}/hg38
mkdir -p ${RESULT}
for bam_id in ${bam_ids[*]}; do 
    echo "Submitting Job ${bam_id}" 
	sbatch --job-name=${bam_id} \
	       	       --output=${RESULT}/${bam_id}_slurm_%j.out \
	      	        /users/${userId}/Adam_HipSTR_sort_compress.slurm ${bam_id}
	echo "${bam_id} submitted" >> ${RESULT}/Jobs_${SUBMISSION_LOG}.txt
done 

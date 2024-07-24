#!/usr/bin/bash


userId="yagoubali"
subfolder="adam"


PROJECT="/cbio/projects/022"
SCRATCH="/scratch3/users/${userId}/HipSTR_qc"
DATA="${PROJECT}/adam/project1_all_samples/HipSTR_run_old"
RESULT="${SCRATCH}/out"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples"



#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)
SUBMISSION_LOG=$(date '+%Y-%m-%d')


#baylor="/cbio/projects/022/adam/H3A-Baylor_sample_list.txt"
#baylor="/cbio/projects/022/adam/H3A-Baylor_sample_list.txt"	# all samples 346
#bam_ids=($(cat ${baylor} | tr \\n " "))

bam_ids=("716-MALI"  "727-MALI"  "733-MALI"  "762-MALI")


mkdir -p ${OUTDIR}/HipSTR_qc/T2T
mkdir -p ${OUTDIR}/HipSTR_qc/hg38
mkdir -p ${SCRATCH}
mkdir -p ${RESULT}
for bam_id in ${bam_ids[*]}; do 
    echo "Submitting Job ${bam_id}" 
	sbatch --job-name=${bam_id}_qc \
	       	       --output=${RESULT}/${bam_id}_slurm_%j.out \
	      	        /users/${userId}/Adam_HipSTR_qc.slurm ${bam_id}
	echo "${bam_id} submitted" >> ${RESULT}/Jobs_${SUBMISSION_LOG}.txt
done 

#!/usr/bin/bash


userId="yagoubali"
subfolder="adam"
scratch_dir="/scratch3/users/${userId}/project1_all_samples"



PROJECT="/cbio/projects/022"
RESULT="/scratch3/users/${userId}/project1_all_samples"
OUTDIR="${PROJECT}/${subfolder}/project1_all_samples" 
SUBMISSION_LOG=$(date '+%Y-%m-%d')
#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)


copy_orginal_flagstat="${PROJECT}/${subfolder}/project1_all_samples/orginal_flagstat"
mkdir -p ${copy_orginal_flagstat}

inputfile=$1;
echo ${inputfile} >> "${RESULT}/anaylzed.txt"
baylor="/users/${userId}/H3A-Baylor_sample_list.txt"	# all samples

#baylor="/users/${userId}/x$inputfile"    # 20 smamples each time
cram_ids=($(cat ${baylor} | tr \\n " "))

mkdir -p ${RESULT}
mkdir -p ${OUTDIR}/mapping/T2T
mkdir -p ${OUTDIR}/mapping/hg38

mkdir -p ${scratch_dir}


for cram_id in ${cram_ids[*]}; do 
    echo "Submitting Job ${cram_id}"
    mkdir -p ${scratch_dir}/${cram_id}   
	sbatch --job-name=${cram_id} \
	       	       --output=${RESULT}/${cram_id}/${cram_id}_slurm_%j.out \
	      	        /users/${userId}/Adam_run_T2T.slurm ${cram_id}
	echo "${cram_id} submitted" >> ${RESULT}/Jobs_${SUBMISSION_LOG}.txt
done 

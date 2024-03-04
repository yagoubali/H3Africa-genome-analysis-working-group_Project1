#!/usr/bin/bash


userId="yagoubali"
RESULT="/scratch3/users/${userId}/project1_all_samples"
scratch_dir="/scratch3/users/${userId}/project1_all_samples"
outdir="/cbio/users/${userId}/project1_all_samples" 
#SUCCEED_RUN=$(cat ${RESULT}/succeed_run.txt)
SUBMISSION_LOG=$(date '+%Y-%m-%d')
copy_orginal_flagstat="/cbio/users/${userId}/project1_all_samples/orginal_flagstat"

mkdir -p ${copy_orginal_flagstat}

inputfile=$1;
echo ${inputfile} >> "${RESULT}/anaylzed.txt"

baylor="/users/${userId}/H3A-Baylor_sample_list.txt"	# all samples

#baylor="/users/${userId}/x$inputfile"    # 20 smamples each time
cram_ids=($(cat ${baylor} | tr \\n " "))

mkdir -p ${RESULT}
mkdir -p ${outdir}/mapping_test
mkdir -p ${scratch_dir}

#rm -r  ${outdir}/withCollate/* 
#rm -r  ${outdir}/withoutCollate/*
#rm -r  ${scratch_dir}/*
###
for cram_id in ${cram_ids[*]}; do 
    echo "Submitting Job ${cram_id}"
    mkdir -p ${scratch_dir}/${cram_id}   
	sbatch --job-name=${cram_id} \
	       	       --output=${RESULT}/${cram_id}/${cram_id}_slurm_%j.out \
	      	        /users/${userId}/DemoAdam_run_T2T_all_wCollate.slurm ${cram_id}
	echo "${cram_id} submitted" >> ${RESULT}/Jobs_${SUBMISSION_LOG}.txt
done 

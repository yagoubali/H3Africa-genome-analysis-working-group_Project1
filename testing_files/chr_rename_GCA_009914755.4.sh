#!/usr/bin/bash

## Adam 
## Rename T2T chromosomes names to match GrCh38
## This script works with GCA_009914755.4 (genbank version of T2T)

#  ------>  How to run
# chmod +x chr_rename_GCA_009914755.4.sh 
# ./chr_rename_GCA_009914755.4.sh  GCA_009914755.4.fna
T2T=$1

sed -i 's/>CP068277.2/>chr1/g'   ${T2T}    
sed -i 's/>CP068276.2/>chr2/g'   ${T2T}  
sed -i 's/>CP068275.2/>chr3/g'   ${T2T}  
sed -i 's/>CP068274.2/>chr4/g'   ${T2T}  
sed -i 's/>CP068273.2/>chr5/g'   ${T2T}  
sed -i 's/>CP068272.2/>chr6/g'   ${T2T}  
sed -i 's/>CP068271.2/>chr7/g'   ${T2T}  
sed -i 's/>CP068270.2/>chr8/g'   ${T2T}  
sed -i 's/>CP068269.2/>chr9/g'   ${T2T}  
sed -i 's/>CP068268.2/>chr10/g'   ${T2T}  
sed -i 's/>CP068267.2/>chr11/g'   ${T2T}  
sed -i 's/>CP068266.2/>chr12/g'   ${T2T}  
sed -i 's/>CP068265.2/>chr13/g'   ${T2T}  
sed -i 's/>CP068264.2/>chr14/g'   ${T2T}  
sed -i 's/>CP068263.2/>chr15/g'   ${T2T}  
sed -i 's/>CP068262.2/>chr16/g'   ${T2T}  
sed -i 's/>CP068261.2/>chr17/g'   ${T2T}  
sed -i 's/>CP068260.2/>chr18/g'   ${T2T}  
sed -i 's/>CP068259.2/>chr19/g'   ${T2T}  
sed -i 's/>CP068258.2/>chr20/g'   ${T2T}  
sed -i 's/>CP068257.2/>chr21/g'   ${T2T}  
sed -i 's/>CP068256.2/>chr22/g'   ${T2T}  
sed -i 's/>CP068255.2/>chrX/g'   ${T2T}  
sed -i 's/>CP086569.2/>chrY/g'   ${T2T} 
sed -i 's/>CP068254.1/>chrM/g'   ${T2T} 





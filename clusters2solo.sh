#!/usr/bin/env bash
bwa=${1}
ltr=${2}
clust=${3}
if [ $# -lt 3 ]; then
	echo "Usage: $0 <bwa_index> <ltr_index> <cluster_fasta>"
	exit 1
fi

out=${clust%%.clust.fa}
log="ltr.log"

# Find alignments
echo "---> aligning clusters to chromosome"
./bowtie2/bowtie2 -a --very-sensitive -f ${bwa} ${clust} -S ${out}.sam >> ${log}

# Filter all inside found LTRs
echo "---> filtering solo LTRs from healthy LTRs"
./filter_solo.py ${ltr} ${out}.sam > solo-ltr.bed 

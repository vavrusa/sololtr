#!/usr/bin/env bash
chromo="${1}"
if [ -z ${chromo} ]; then
	echo "Usage: $0 <chromosome.fa>"
	exit 1
fi

echo "# 1/3 Build indexes and find LTR predictions"
./db2pred.sh ${1} || exit 1

echo "# 2/3 Cluster LTR predictions"
./pred2clusters.sh ltrharvest.fa ltrharvest.index || exit 1

echo "# 3/3 Align clusters to chromosome and filter solo-LTRs"
./clusters2solo.sh ltrharvest_bwa ltrharvest.index ltrharvest.clust.fa || exit 1

#rm -r ltrharvest_bwa*
#rm ${chromo}.*
out="${chromo%%.fa}-solo-ltr.bed"
mv solo-ltr.bed ${out} 
echo "# Done processing ${chromo}"
echo "# BED result file in ${out}"


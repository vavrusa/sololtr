#!/usr/bin/env bash
fsa="${1}"
index="${2}"
log="ltr.log"
out="${fsa%%.fa}.clust.fa"
identity="0.7"

if [ $# -lt 2 ]; then
	echo "Usage: $0 <fasta> <index>"
	exit 1
fi

# Strip line endings
echo "---> stripping line endings from FASTA"
./genometools/bin/gt convertseq -fastawidth 1000000 ${fsa} > ${fsa}.nole
cp ${fsa}.nole ${fsa%%.fa}.nole.fa

# Extract l+r LTRs
echo "---> extracting LTRs from matches"
./extract_ltr.py ${fsa}.nole ${index} > ${fsa}.lr

# Cluster LTRs
echo "---> clustering 1/1 (cd-hit)"
./cd-hit/cd-hit -i ${fsa}.lr -o ltrharvest.fa.clu -c ${identity} -T 0 >> ${log}
echo "---> clustering 2/2 (stripping line endings)"
./genometools/bin/gt convertseq -fastawidth 1000000 ${fsa}.clu > ${fsa}.nole
mv ${fsa}.nole ${out}
rm ${fsa}.lr ${fsa}.clu

echo "---> result in '${out}'"

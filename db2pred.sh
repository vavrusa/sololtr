#!/usr/bin/env bash
input=${1}
log="ltr.log"
echo "$(date) $0" >> ${log}
if [ -z ${input} ]; then
	echo "Usage: ${0} <input fasta>"
	exit 1
fi

# Check for gzip
if [ "${input}" != "${input%%.gz}" ]; then
	echo "error: run 'gzip -d ${input}' first because bowtie can't handle gzipped fasta"
	exit 1
fi

# Check .fa
if [ "${input}" == "${input%%.fa}" ]; then
	echo "error: input file doesn't end with '.fa'"
	exit 1
fi

# Generate suffix arrays 
echo "---> generating suffix arrays"
./genometools/bin/gt suffixerator -db ${input} -indexname ${input%%.gz} -tis -suf -lcp -des -sds -dna >> ${log}
echo "---> generating BWA index"
./bowtie2/bowtie2-build ${input} ltrharvest_bwa >> ${log}
echo "---> finding LTR regions"
./genometools/bin/gt ltrharvest -index ${input%%.gz} -v -out ltrharvest.fa  > ltrharvest.index 
echo "---> done, sequences in 'ltrharvest.fa' index in 'ltrharvest.index'"

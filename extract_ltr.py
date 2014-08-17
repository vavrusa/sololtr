#!/usr/bin/env python
import sys

fasta = sys.argv[1]
index = sys.argv[2]

def index_seek(f):
	line = '#'
	while line.startswith('#'):
		line = f.readline()
		if len(line) is 0:
			return None 
	line = line.strip().split(' ')
	return (int(line[10]), int(line[16]), int(line[6]), int(line[12]))

with open(fasta) as fasta_file:
	with open(index) as index_file:
		while True:
			# Seek index start
			ltr_len = index_seek(index_file)
			if ltr_len is None:
				break
			# Fetch header + data
			header = fasta_file.readline().strip()
			header = header[0:header.rindex(' ')]
			data = fasta_file.readline().strip()
			# Print l + r LTRs
			print '>LTR%d' % (ltr_len[2])
			print data[:ltr_len[0]]
			print '>LTR%d' % (ltr_len[2])
			print data[-ltr_len[1]:]


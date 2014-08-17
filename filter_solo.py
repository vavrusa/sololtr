#!/usr/bin/env python
import sys
import re
from random import randint

if len(sys.argv) != 3:
	print('Usage: filter_solo.py <ltr_index> <sam_alignments>')
	sys.exit(1)

index = sys.argv[1]
sam = sys.argv[2]

# Build non-solo LTR regions
chromo = 'chr1'
healthy = [] 
with open(index) as index_file:
	for line in index_file:
		if line.startswith('#'):
			if 'indexname' in line:
				chromo = re.findall(r'chr[0-9]+', line)[0]
			continue
		line = line.strip().split(' ')
		ltr = (int(line[0]), int(line[2]))
		healthy.append(ltr)

healthy_count = len(healthy) * 2
print '# chromosome %s' % chromo
print('# %d healthy LTR regions (=%d LTR seqs)' % (len(healthy), healthy_count))

def region_find(tree, a, b):
	for r in tree:
		# Begins inside the healthy region
		if a >= r[0] and a <= r[1]:
			return True
		# Terminates inside the healthy region
		if b >= r[0] and b <= r[1]:
			return True
		# Encloses healthy region
		if a < r[0] and b > r[1]:
			return True
	return False

# I use simple metric = ratio of matches against total length
def cigar2score(cigar, seqlen):
	score = 0
	matches = re.findall(r'[0-9]+M', cigar)
	for m in matches:
		score += int(m.rstrip('M'))
	# Normalize against sequence length to range <0, 1000>
	score = (score / float(seqlen)) * 1000
	return score 

colorhash = {}
def name2color(name):
	if name in colorhash:
		return colorhash[name]
	colorhash[name] = '%d,%d,%d' % (randint(0, 255), randint(0, 255), randint(0, 255))
	return colorhash[name]

def bed_begin():
	print 'track name=soloLTRs description="Solo LTR regions found" useScore=1 itemRgb="on"'

def bed_write(name, pos, score, seq):
	color = name2color(name)
	start = pos
	end = pos + len(seq)
	score = cigar2score(cigar, len(seq))
	print '%s %d %d %s %d + %d %d %s' % (chromo, start, end, name, score, start, end, color)

# Print alignments outside healthy LTR regions
recovered_count = 0
solo_count = 0
with open(sam) as sam_file:
	bed_begin()
	for line in sam_file:
		if line.startswith('@'):
			continue
		line = line.strip().split('\t')
		(name, pos, cigar, seq) = (line[0], int(line[3]), line[5], line[9])
		is_healthy = region_find(healthy, pos, pos + len(seq))
		# Print annotation for solo LTRs
		if not is_healthy:
			bed_write(name, pos, cigar, seq)
			solo_count += 1
		else:
			recovered_count += 1

print('# recovered %d/~%d found %d solo LTRs' % (recovered_count, healthy_count, solo_count))

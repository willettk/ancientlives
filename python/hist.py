import unicodedata
import codecs
import sys

from itertools import groupby

# Histogram the user data
userCount = []
with open("fragmentStatistics.csv", "r") as f:
    next(f)
    for line in f:
        l = line.strip()
        v = l.split(",")
        userCount.append(int(v[2]))

uu = sorted(userCount)
hist = [len(list(group)) for key, group in groupby(uu)]
val = sorted(list(set(uu)))

# Write the histogrammed data to text file
with open("hist.csv","w") as ff:

    ff.write('bin,count\n')
    for v,h in zip(val,hist):
        ff.write('%s,%s\n' % (v,h))


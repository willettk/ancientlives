import unicodedata
import codecs
import sys

from itertools import groupby




# histogram data for users
userCount = []
ff = open("fragmentStatistics.txt", "r")
for l in ff:
    l = l.strip()
    v = l.split(", ")
    userCount.append(int(v[2]))

ff.close()


uu = sorted(userCount)
hist = [len(list(group)) for key, group in groupby(uu)]
val = sorted(list(set(uu)))

ff = open("hist.txt","w")

for i in range(len(val)):
    ff.write(str(val[i]) + ", " + str(hist[i])+ "\n")

ff.close()

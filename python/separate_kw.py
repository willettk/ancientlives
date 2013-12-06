import unicodedata
import codecs
import sys


# from the dictionary of the number of users for each fragment

flist = []
with open("../sortedFragments.csv","r") as ff:
    next(ff)
    for line in ff:
        l = line.strip()
        v = l.split(",")
    
        frag = int(v[0])
        flist.append(v)

# form a data structure for groupid
groupLimits = [1,5,7,9,11,13,15,17,20,30,40,100,100000,1000000]
glist = []
for idx,(gmin,gmax) in enumerate(zip(groupLimits[:-1],groupLimits[1:])):
    for j in range(gmin, gmax):
        glist.append(idx)

# open the files for each groupsize
fhandle = []
for gmin,gmax in zip(groupLimits[:-1],groupLimits[1:]):
    fn = '../frag%i_%i.txt' % (gmin,gmax-1)
    fhandle.append(open(fn,'w'))


for ff in flist:
    frag = ff[0]
    users = int(ff[2])
    
    try:
        ii = glist[users-1]
        fhandle[ii].write(frag + "\n")
    except:
        print 'bad ', frag, users


for fh in fhandle:
    fh.close()


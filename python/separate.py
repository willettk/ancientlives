


import unicodedata
import codecs
import sys


# from the dictionary of the number of users for each fragment

flist = []
fragments = {}
ff = open("./sortedFragments.txt","r")
for l in ff:
    l = l.strip()
    v = l.split(",")

    frag = int(v[0])
    users = int(v[2])
    flist.append(v)
ff.close()



# form a data structure for groupid
groupLimits = [1,5,7,9,11,13,15,17,20,30,40,100,100000,1000000]
gmin = groupLimits[0]
gfinal = groupLimits[len(groupLimits)-1]
glist = []
for i in range(len(groupLimits)-1 ):
    gmax = groupLimits[i+1]
    for j in range(gmin, gmax):
        glist.append(i)
    gmin = gmax

for i in range(30):
    print i+1, glist[i]



# open the files for each groupsize
filename = []
fhandle = []
for i in range(len(groupLimits)-1):
    fn = ("frag" + str(int(groupLimits[i]))  + "_" + str(groupLimits[i+1] -1) + ".txt")
    filename.append(fn)
    fhandle.append(open(fn,'w'))


for i in range(len(flist)):
    ff = flist[i]
    frag = ff[0]
    users = int(ff[2])
    
    try:
        ii = glist[users-1]
        fhandle[ii].write(frag + "\n")
    except:
        print 'bad ', frag, users


for i in range(len(groupLimits)-1):
    fhandle[i].close()

        

    

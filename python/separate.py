
# from the dictionary of the number of users for each fragment

flist = []
with open("sortedFragments.txt","r") as ff:
    next(ff)
    for line in ff:
        l = line.strip()
        v = l.split(",")
    
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
    fn = 'frag%i_%i.txt' % (gmin,gmax-1)
    fhandle.append(open(fn,'w'))


for f in flist:
    frag = int(f[0])
    userCount = int(f[2])
    
    try:
        ii = glist[userCount-1]
        fhandle[ii].write('%i\n' % frag)
    except:
        print 'bad ', frag, userCount


for fh in fhandle:
    fh.close()


import os
import glob

# Point of this program: end up with a list of fragment IDs (fraglist.txt) WITHOUT consensus as defined by the KDE algorithm.

thisdir = os.getcwd()
f = thisdir.split("/")
name = "../" +  f[-1] + ".txt"      # eg, ../frag5_6.txt

# Create a unique list of files that need to be run

with open(name,"r") as a:

    olist = []
    for lines in a:
        olist.append(int(lines.strip()))        # olist is a list of the fragment IDs in that user range

cset= sorted(list(set(olist)))      # unique fragment IDs

cdict = {}
for c in cset:
    cdict[c] = 0                    # empty dictionary, with every entry (initially) at 0

# Make a list of the EXISTING output files
path = "./"
flist = glob.glob(os.path.join(path,"fragment*_consensus*.txt"))

clist = []                          # empty array for the EXISTING fragment integers
for f in flist:
    ll = f.split("_")
    clist.append(int(ll[1]))

for d in clist:
    cdict[d] += 1                   # add counter to the dictionary if it has a consensus file

with open("fraglist.txt","w") as f2:    
    for c in cset:
        if cdict[c] != 4:               # If consensus counter is not 4 (?), write fragment ID to file
            f2.write(str(c) + "\n")
    

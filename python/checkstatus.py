
import sys
import os
import glob

path = "./"
flist = glob.glob(os.path.join(path,"frag[1-9]*.txt"))


for f in flist:
    dd = f.split('.')
    targetDir = "." + dd[1]


    ct = 0
    f2 = open(f,"r")
    for l in f2:
        ct = ct + 1
    f2.close()


    flist2 = glob.glob(os.path.join(targetDir,"fragment*_consensus_8.txt"))
    print "--------"
    if len(flist2) == 0:
        s = "NOT STARTED"
    elif len(flist2) < ct:
        s = "NOT COMPLETED"
    elif len(flist2) == ct:
        s = "DONE"
    else:
        s = "ERROR"

    status = targetDir +  "   :" + str(len(flist2)) + " of " + str(ct) +  " fileS proceessed - "   + s
    print status                                   
#    print targetDir, len(flist2), ct
print "--------"

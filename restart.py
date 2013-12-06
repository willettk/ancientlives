
#import packages
#from Tkinter import *
#from numpy import *
#from scipy import *
import math
import urllib
import sys
import time
import os
import glob



thisdir = os.getcwd()
f = thisdir.split("/")
name = "../" +  f[-1] + ".txt"

# create a unique list of files that needed to be run
a = open(name,"r")

olist = []
for lines in a:
    olist.append(int(lines.strip()))
a.close()

cset= sorted(list(set(olist)))

cset1 = {}
for c in cset:
    cset1[c] = 0


# make a list of the output files
path = "./"
flist = glob.glob(os.path.join(path,"fragment*_consensus*.txt"))

clist = []
for f in flist:
    ll = f.split("_")
    clist.append(int(ll[1]))

for d in clist:
    cset1[d] = cset1[d] + 1

f2 = open("fraglist.txt","w")
for c in cset:
    if cset1[c] <> 4:
        f2.write(str(c) + "\n")
f2.close()
    

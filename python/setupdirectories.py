import sys
import os
import glob

path = "./"
flist = glob.glob(os.path.join(path,"frag[1-9]*.txt"))

executable = "process_directory_serial"
current = os.getcwd()
masterdirectory = current

f4 = open("PBS_master","w")

for f in flist:
    cmdlist = []
    nn = f.split("/")
    nn1 = nn[1].split(".")
    dirname = nn1[0]

    exists = os.path.exists(dirname)

    if not os.path.exists(dirname):
        print "creating ", dirname
        os.makedirs(dirname)

        name = "greek_to_latex.mat"
        src = current + "/" + name
        dst = dirname + "/"+ name
        os.link(src, dst)

        name = "markers.mat"
        src = current + "/" + name
        dst = dirname + "/"+ name
        os.link(src, dst)



    s= "#!/bin/bash -l"
    s = "#PBS -l nodes=1:ppn=1,mem=16gb,walltime=24:00:00"
    cmdlist.append(s)

    s = "#PBS -m abe"
    cmdlist.append(s)

    s = "#!/bin/bash"
    cmdlist.append(s)

    s = "cd " + masterdirectory
    cmdlist.append(s)


    s = "cd " + dirname
    cmdlist.append(s)

    s = "python ../restart.py"
    cmdlist.append(s)

    s = "module load matlab"
    cmdlist.append(s)

    s = "matlab -nodesktop -nosplash -r \"addpath('../'); " + executable + "\""
    cmdlist.append(s)

    s = "python ../createLines.py"
    cmdlist.append(s)

    pbsname = dirname + ".pbs"
    f3 = open(pbsname, "w")
    for c in cmdlist:
        f3.write(c + "\n")
    f3.close()
               
    s = "qsub -q lab " + pbsname
    f4.write(s + "\n")

f4.close()



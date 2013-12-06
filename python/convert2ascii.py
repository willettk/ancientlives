import unicodedata
import codecs

fname = "markers.txt"
f = codecs.open(fname, encoding='utf-8', mode='r')


ii = 0
for l in f:
    l = l.strip()
    e = l.split(",")

    if len(e[4]) == 1:
         s = e[0] + "," + e[1] + "," +  e[2] + "," + e[3] + "," + str(ord(e[4]))

    print s
    

f.close()

    

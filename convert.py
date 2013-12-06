import unicodedata
import codecs

f = codecs.open("markers20130708.txt", encoding='utf-8', mode='r')


ii = 0
for l in f:
    l = l.strip()
    e = l.split("\t")
#    print e
#    print l

    if ii == 0:
        s = e[1] + "\t" + e[2] + "\t" + e[4] + "\t" + e[5] + "\t" + e[6]
        print s.encode('utf-8')
        ii = 1
    else:
        s = e[1] + "," + e[2] + "," + e[4] + "," + e[5] + "," + e[6]

        if e[4] != 'NULL' and len(e[6]) == 1 and e[4] != '\N':
            print s.encode('utf-8')

#    print "-----"

f.close()

    

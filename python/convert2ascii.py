import codecs

fname = "markers.csv"
with codecs.open(fname, encoding='utf-8', mode='r') as f:

    next(f)
    for line in f:
        l = line.strip()
        e = l.split(",")
    
        if len(e[4]) == 1:      # Encoding for John's MySQL query
            s = '%s,%s,%s,%s,%s' % (e[0],e[1],e[2],e[3],ord(e[4]))
            print s
        elif len(e[4]) == 3:    # Encoding for Kyle's MySQL query
            s = '%s,%s,%s,%s,%s' % (e[0],e[1],e[2],e[3],ord(e[4][1]))
            print s
    

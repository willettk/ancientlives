import unicodedata
import codecs
import sys



fname = "converted_by_frag.txt"
f = codecs.open(fname, encoding='utf-8', mode='r')


userList = []
fragmentList = []
clickCount = 0
userCount = []
users = []
clicks = []

ii = 0
fragmentCurrent = 0
for l in f:
    l = l.strip()
    e = l.split(",")

    frag  = int(e[1])
    userList.append(e[0])
    if frag != fragmentCurrent and len(userList) > 1:
        fragmentList.append(fragmentCurrent)
        fragmentCurrent = frag
        #print frag

        # find the unique users
        ulist = list(set(userList))
        users.append(ulist)
        userCount.append(len(ulist))
        userList = []
        
        # update the number of clicks
        clicks.append(clickCount)
        clickCount = 0
    
    clickCount = clickCount + 1

f.close()


ff = open("fragmentStatistics.txt", "w")
for i in range(len(fragmentList)):
#    print fragmentList[i], clicks[i], userCount[i], users[i]
    s = str(fragmentList[i]) + ", " + str(clicks[i]) + ", " +  str(userCount[i]) + ", " + str(clicks[i]/userCount[i]) + "\n"
    ff.write(s)
    #sys.stdout.write(s)
ff.close()



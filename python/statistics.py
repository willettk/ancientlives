import unicodedata
import codecs
import sys

fname = "converted_by_frag.csv"
f = codecs.open(fname, encoding='utf-8', mode='r')

# Empty lists
userList = []
userCount = []
fragmentList = []

users = []
clicks = []

# Start fragment, click count at 0
fragmentCurrent = 0
clickCount = 0

for line in f:
    l = line.strip()
    e = l.split(",")

    frag  = int(e[1])
    userList.append(e[0])
    
    # Count transcriptions of each fragment
    if frag != fragmentCurrent and len(userList) > 1:
        fragmentList.append(fragmentCurrent)
        fragmentCurrent = frag

        # find the unique users who classified each fragment
        ulist = list(set(userList))
        users.append(ulist)
        userCount.append(len(ulist))
        userList = []
        
        # update the number of clicks
        clicks.append(clickCount)
        clickCount = 0
    
    clickCount += 1

f.close()
    
# Write the results to a text file in CSV format
with open("fragmentStatistics.csv", "w") as ff:
    ff.write('fragment,clicks,userCount,clicksPerUser\n')
    
    for fragment,click,usercnt in zip(fragmentList,clicks,userCount):
        s = '%s,%s,%s,%s\n' % (fragment,click,usercnt,click/usercnt)
        ff.write(s)
    
    ff.close()


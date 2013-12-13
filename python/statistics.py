import unicodedata
import codecs
import sys

# Empty lists
userList = []
userCount = []
fragmentList = []

users = []
clicks = []

# Assume that the id of the first fragment is 0
fragmentCurrent = 0
clickCount = 0

fname = "converted_by_frag.txt"
with codecs.open(fname, encoding='utf-8', mode='r') as f:

    for line in f:
        l = line.strip()
        e = l.split(",")
    
        frag  = int(e[1])
        userList.append(e[0])
        
        # Update user and click numbers when fragment counting ends
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

# Write the results to a text file in CSV format
with open("fragmentStatistics.txt", "w") as ff:
    ff.write('fragment,clicks,userCount,clicksPerUser\n')
    
    for fragment,click,usercnt in zip(fragmentList,clicks,userCount):
        s = '%i,%i,%i,%i\n' % (fragment,click,usercnt,click/usercnt)
        ff.write(s)
    


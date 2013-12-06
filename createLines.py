
# character placement analysis for the Ancient Lives Project
# written by John Wallin MTSU May 2013

import os
import glob
import unicodedata
import codecs
import sys
import math
import numpy as np

class papyri:

    def __init__(self):
        self.minClicks = 2
        self.readFiles()
        nfile = len(self.flist)

        # loop through files and process them
        self.processCommandLine()

        if self.all == 1:
            for findex in range(0, nfile):
                self.fname = self.flist[findex]
                self.setFileName()
                self.processFile()
        else:
            self.fname = self.targetName
            self.setFileName()
            self.processFile()

    def processFile(self):
        self.readFile()
        self.filterData()
        self.positionStats()

        self.formPairs()
        self.formGroups()
        self.formChains()

        self.findLines()
        self.mergeLines()
        self.formLines()
        self.findSimilarLines()

        # if there are less than 2 lines, this analysis will not work
        if len(self.lines) > 1:
            self.trimLines()
            self.dropUnknownCharacters()
            self.estimateMargins()
            self.removeCharactersLeftOfMargin()
            self.joinLines()
            self.recalculateSpacing()
            self.absoluteCharacterPosition()
            if self.doMachine == 1:
                self.dumpMachineReadable()
            if self.doHuman == 1:
                self.dumpHumanReadable()
            if self.doFormatted == 1:
                self.dumpFormatted()
            if self.doDecoded == 1:
                self.dumpDecoded()
            if self.doStats == 1:
                self.dumpPositionStats()

        else:
            print "There are less than 2 lines in the file - character placement analysis failed."

    def readFiles(self):
        path = "./"
        self.flist = glob.glob(os.path.join(path,"fragment*8.txt"))

    def setFileName(self):
        ff = self.fname.split("fragment")
        self.fileid = ff[len( ff)-1]
        ff = self.fname.split("/")
        self.filename = ff[len(ff)-1]

    def readFile(self):
        ff = codecs.open(self.fname,encoding='utf-8',mode='r')
        self.xx = []
        self.yy = []
        self.xxFiltered = []
        self.yyFiltered = []
        self.cval = []
        self.possible = []
        self.nclicks = []
        self.confidence = []
        self.fullString = []
        self.exclude = []
        self.excludeReason = []
        ct = 0
        for l in ff:
            l = l.strip()
          #  print l
            data = l.split('\t')
            if (ct > 0):
                index = int(data[0])
                x = float(data[1])
                y = float(data[2])
                best = data[3][1]
                others = data[4]
                nclick = int(data[5])
                votes = float(data[6])

                ostring = str(index) + ", " + str(x) + ", " + str(y) + ", " + best + ", " + others + ", " + str(nclick) + ", " + str(votes)
                self.xx.append(x)
                self.yy.append(y)
                self.cval.append(best)
                self.possible.append(others)
                self.nclicks.append(nclick)
                self.confidence.append(votes)
                self.fullString.append(ostring)
                self.exclude.append(0)
                self.excludeReason.append("")

            ct =ct +1

        ff.close()


    def filterData(self):
        for i in range(len(self.cval)):
            cc = self.cval[i]
            clicks = self.nclicks[i]

            # eliminate clicks without character id
#            if cc == "?":
#                self.exclude[i] = self.exclude[i] + 1
#                self.excludeReason[i] = self.excludeReason[i] + "Unknown character -"

            if clicks < self.minClicks:
                self.exclude[i] = self.exclude[i]  + 1
                self.excludeReason[i] = self.excludeReason[i] + "Insufficent clicks -"

            if self.exclude[i] == 0:
                self.xxFiltered.append(self.xx[i])
                self.yyFiltered.append(self.yy[i])



    def positionStats(self):
        self.totalClicks = 0
        self.totalFilteredClicks = 0
        self.maxClicks = 0
        for i in range(len(self.nclicks)):
            self.totalClicks = self.totalClicks + self.nclicks[i]
            if self.exclude[i] == 0:
                self.totalFilteredClicks = self.totalFilteredClicks  + self.nclicks[i]
            if self.maxClicks < self.nclicks[i]:
                self.maxClicks = self.nclicks[i]

        self.xmin = np.amin(self.xxFiltered)
        self.xmax = np.amax(self.xxFiltered)
        self.xmean = np.mean(self.xxFiltered)
        self.xmedian = np.median(self.xxFiltered)
        self.xstd = np.std(self.xxFiltered)

        self.ymin = np.amin(self.yyFiltered)
        self.ymax = np.amax(self.yyFiltered)
        self.ymean = np.mean(self.yyFiltered)
        self.ymedian = np.median(self.yyFiltered)
        self.ystd = np.std(self.yyFiltered)

    def dumpData(self):
        for i in range(len(self.cval)):
            if self.exclude[i] == 0:
                x = self.xx[i]
                y = self.yy[i]
                best = self.cval[i]
                others = self.possible[i]
                nclick = self.nclicks[i]
                votes = self.confidence[i]
                ostring = str(i) + ", " + str(x) + ", " + str(y) + ", " + best + ", " + others + ", " + str(nclick) + ", " + str(votes)
                print ostring

        for i in range(len(self.cval)):
            if self.exclude[i] != 0:
                x = self.xx[i]
                y = self.yy[i]
                best = self.cval[i]
                others = self.possible[i]
                nclick = self.nclicks[i]
                votes = self.confidence[i]
                excluded = self.exclude[i]
                excludedReason =  self.excludeReason[i]
                ostring = str(i) + ", " + str(x) + ", " + str(y) + ", " + best + ", " + others + ", " + str(nclick) + ", " + str(votes) + "|" + excludedReason + "(" + str(excluded) + ")"
                print ostring


    def findNearestCharacterToTheRight(self, ichar):
        dmin = 1000000.0
        ddxbest = -1000000
        ddybest = -1000000
        index = -1
        x = self.xx[ichar]
        y = self.yy[ichar]

        for i in range(0, len(self.xx)):
            xc = self.xx[i]
            yc = self.yy[i]
            ddx = (x - xc)
            ddy = (y - yc)
            dr = ddx*ddx + ddy*ddy
            # find a character that is to the right and not above or below the location by more than the displacement
            if (dr < dmin and ddx < 0 and abs(ddx) > abs(ddy) and dr > 1e-5 and self.exclude[i] == 0 ):
                dmin = dr
                index = i
                ddxbest = ddx
                ddybest = ddy
        return [index, dmin, ddxbest, ddybest]


    def formPairs(self):
                # form pairs of characters based on the current character's location and one to the right
        self.thetaValues = []
        self.spacingValues = []
        self.nearList = []
        groupId = -1
        for ichar in range(0, len(self.xx)):
            [iright, dist, dx, dy] = self.findNearestCharacterToTheRight(ichar)
            theta = math.atan2(dx, dy)
            dist = math.sqrt(dist)
            # exclude pairs where the primary object is excluded
            if iright != -1:
                if self.nclicks[ichar] <= self.minClicks:
                    iright = -1
            self.nearList.append([ichar, iright, dist, dx, dy, theta, groupId])
            self.thetaValues.append(theta)
            self.spacingValues.append(dist)



    def formGroups(self):
        # do statistical analysis of the pairs
        tt = np.array(self.thetaValues)
        dd = np.array(self.spacingValues)
        tave = np.average(tt)
        tstd = np.std(tt)
        dave = np.average(dd)
        dstd = np.std(dd)

        # create a table of group IDs
        self.maxGroupId = 0
        self.groupSize = []
        for i in range(len(self.nearList)):
            self.groupSize.append(0)

        # take the pairs and put them together into groups
        for i in range(len(self.nearList)):
            ff = self.nearList[i]
            ichar = ff[0]
            iright = ff[1]
            dist = ff[2]
            dx = ff[3]
            dy = ff[4]
            theta = ff[5]
            groupId = ff[6]

            # make sure the groups do not have big variations in their direction or their spacings
            # for each character, we are adding a group ID to the nearList varaible
            if (iright != -1):
                if (theta  < tave + tstd  and theta > tave - tstd  and dist < dave + dstd and dist > dave - dstd):
                    if groupId == -1:
                        if self.nearList[iright][6] == -1:
                            self.nearList[ichar][6] = self.maxGroupId
                            self.nearList[iright][6] = self.maxGroupId
                            self.groupSize[self.maxGroupId] = self.groupSize[self.maxGroupId] + 1
                            self.maxGroupId = self.maxGroupId + 1
                        else:
                            gid =  self.nearList[iright][6]
                            self.nearList[ichar][6] =gid
                            self.groupSize[gid] = self.groupSize[gid] + 1
                    else:
                        if (self.nearList[iright][6] == -1):
                            self.nearList[iright][6] = groupId
                            self.groupSize[groupId] = self.groupSize[groupId] + 1
                        else:
                            if (self.nearList[ichar][6] < self.nearList[iright][6]):
                                gid = self.nearList[iright][6]
                                for j in range(len(self.nearList)):
                                    if self.nearList[j][6] == gid:
                                        self.nearList[j][6] = groupId
                                        self.groupSize[gid] = 0
                            else:
                                gid = self.nearList[iright][6]
                                for j in range(len(self.nearList)):
                                    if self.nearList[j][6] == groupId:
                                        self.nearList[j][6] = gid
                                        self.groupSize[groupId] = 0

    def formChains(self):
        # form the groups into chains
        self.gList = []
        for jj in range(len(self.groupSize)):
            self.gList.append(-1)
            self.gListIndex = 0

        # remap the data from the group data into full chains of characters
        for jj in range(len(self.nearList)):
            if self.groupSize[jj] != 0:
                for kk in range(0, len(self.nearList)):
                    ff = self.nearList[kk]
                    ichar = ff[0]
                    iright = ff[1]
                    dist = ff[2]
                    dx = ff[3]
                    dy = ff[4]
                    theta = ff[5]
                    groupID = ff[6]
                    if groupID == jj:
                        self.gList[self.gListIndex] = kk
                        self.gListIndex = self.gListIndex + 1



        # find the start of the chains
        gcurrent = -1
        self.groupStart = []
        for j in range(self.gListIndex):
            ii = self.gList[j]
            ichar = self.nearList[ii][0]
            iright = self.nearList[ii][1]
            igroup = self.nearList[ii][6]
            if igroup !=gcurrent:
                gcurrent = igroup
                self.groupStart.append(j)

        # find the end of the last chain
        self.groupStart.append(-1)
        for j in range(self.gListIndex):
            ii = self.gList[j]
            igroup = self.nearList[ii][6]
            if igroup == gcurrent:
                self.groupStart[len(self.groupStart)-1] = j+1
        self.ngroups = len(self.groupStart)


    def printChains(self):
        # print the data for each joined string
        printJoined = 1
        if printJoined == 1:
            clist = []
            ccount = 0
            for i in range(self.ngroups -1):
                sys.stdout.write(str(i) + "> ")
                for j in range(self.groupStart[i], self.groupStart[i+1]):
                    ii = self.gList[j]
                    ichar = self.nearList[ii][0]
                    iright = self.nearList[ii][1]
                    igroup = self.nearList[ii][6]
                    sys.stdout.write(str(ichar) + " ")
                print ""



    def findLine(self, xval, yval):
        xs = 0
        ys = 0
        xys = 0
        x2s = 0
        nn = 0
        for i in range(len(xval)):
            xs = xs + xval[i]
            x2s = x2s + xval[i]*xval[i]
            ys = ys + yval[i]
            xys = xys + xval[i]*yval[i]
            nn = nn + 1

        a = (nn* xys - xs*ys) / (nn*x2s - xs*xs)
        b = (ys * x2s - xs*xys) / (nn*x2s - xs*xs)

        return(a,b)


    def findIntercept(self, xval, yval, slope):
        bval = 0
        nn = 0
        for i in range(len(xval)):
            bval = bval + (yval[i]- (slope*xval[i]))
            nn = nn + 1
        b = bval / nn

        return b

    def findLines(self):
        # find the equation for a line
        if self.ngroups > 1:
            self.slopeValue = []
            for i in range(self.ngroups-1):
                xval = []
                yval = []
                ct = 0
                for j in range(self.groupStart[i], self.groupStart[i+1]):
                    ii = self.gList[j]
                    ichar = self.nearList[ii][0]
                    xval.append( self.xx[ichar] )
                    yval.append( self.yy[ichar] )
                    ct = ct + 1
                vv = self.findLine(xval, yval)
                self.slopeValue.append(vv[0])

            # find the median slope
            sval = sorted(self.slopeValue)
            self.medianSlope = sval[ len(sval)/2]

            # find the intercepts for a line using the median slope
            self.interceptValue = []
            for i in range(self.ngroups-1):
                xval = []
                yval = []
                ct = 0
                #            sys.stdout.write(str(i) + "> ")
                for j in range(self.groupStart[i], self.groupStart[i+1]):
                    ii = self.gList[j]
                    ichar = self.nearList[ii][0]
                    xval.append( self.xx[ichar] )
                    yval.append( self.yy[ichar] )
                    ct = ct + 1
                bval = self.findIntercept(xval, yval, self.medianSlope)
                x1 = 1
                y1 = self.medianSlope*x1 + bval
                x2 = 700
                y2 = self.medianSlope*x2 + bval
                self.interceptValue.append(bval)

            # find the line spacing
            self.spacing = []
            ival = sorted(self.interceptValue)
            for i in range(len(ival)-1):
                di = ival[i+1] -ival[i]
                self.spacing.append(di)

            self.sortedSpacing = sorted(self.spacing)
            if len(self.sortedSpacing) > 1:
                self.medianSpacing = self.sortedSpacing[ len(self.sortedSpacing) *2 / 3]
            else:
                self.medianSpacing = -1

    def mergeLines(self):
        #Merge the lines
        if self.ngroups > 1:
            self.lineGroups = []
            self.groupUsed = []
            for i in range(self.ngroups-1):
                self.groupUsed.append(0)
            self.lineGroupCT = 0
            for i in range(self.ngroups-1):
                if self.groupUsed[i] == 0:
                    gList2 = []
                    ival = self.interceptValue[i]
                    gList2.append(i)
                    self.groupUsed[i] = 1
                    for j in range(self.ngroups -1):
                        if self.groupUsed[j] == 0 and abs(self.interceptValue[j] - ival) < self.medianSpacing*0.3:
                            gList2.append(j)
                            self.groupUsed[j] = 1
                    self.lineGroups.append(gList2)
                    self.lineGroupCT= self.lineGroupCT + 1

    def formLines(self):
        if self.ngroups > 1:
            # actually merger the characters
            self.lines = []
            for i in range(self.lineGroupCT):
                currentLine = []
                for j in self.lineGroups[i]:
                    for k in range(self.groupStart[j], self.groupStart[j+1]):
                        ii = self.gList[k]
                        ichar = self.nearList[ii][0]
                        currentLine.append(ichar)
                # since the characters are in ascending order left to right, we can do a sort on them
                cline = sorted(currentLine)
                self.lines.append(cline)
        else:
            self.lines = []

    def findSimilarLines(self):
        # redo the analysis for putting the lines in order
        # find the intercepts for a line using the median slope
        visualizeLines2 = 0
        interceptValue2 = []


        for i in range(len(self.lines)):
            xval = []
            yval = []
            ct = 0

            for ichar in self.lines[i]:
                xval.append( self.xx[ichar] )
                yval.append( self.yy[ichar] )
                ct = ct + 1
            bval2 = self.findIntercept(xval, yval, self.medianSlope)
            interceptValue2.append( (i, bval2) )

        self.ilist = sorted(interceptValue2, key=lambda intercept: intercept[1])


    def trimLines(self):
        # eliminate characters that are more than 4 sigma above or below the line
        dvalue = []
        diffSS = 0
        ct = 0
        for i in range(len(self.ilist)):
            iline = self.ilist[i][0]
            for j in range( len(self.lines[iline])):
                ichar = self.lines[iline][j]
                xv = self.xx[ichar]
                yv = self.yy[ichar]
                yp = self.medianSlope * xv + self.ilist[i][1]
                diffSS = diffSS + (yp-yv)*(yp-yv)
                dvalue.append(abs(yp-yv))
                ct = ct + 1
        sd = math.sqrt(diffSS)/ ct
        sm = dvalue[len(dvalue)*3/4]
        if (sm < 3):
            sm = 3

        # actually delete the characters
        dlist = []
        for i in range(len(self.ilist)):
            iline = self.ilist[i][0]
            for j in range( len(self.lines[iline])):
                ichar = self.lines[iline][j]
                xv = self.xx[ichar]
                yv = self.yy[ichar]
                yp = self.medianSlope * xv + self.ilist[i][1]
                diff = abs(yp -yv)

        for ii in range( len(dlist)):
            i = dlist[ii][0]
            j = dlist[ii][1]
            self.lines[i][j] = -1


    def dropUnknownCharacters(self):
        # drop out unknown characters
        for i in range(len(self.ilist)):
            iline = self.ilist[i][0]
            for j in range( len(self.lines[iline])):
                ichar = self.lines[iline][j]
                if (ichar > 0):
                    xv = self.cval[ichar]
                    if xv == unicodedata.lookup("QUESTION MARK"):
                        self.lines[iline][j] = -1


    def estimateMargins(self):
        # find the approxmate left and right margin along with character spacing
        self.lineLeft = []
        self.lineRight = []
        self.characterSpace = []
        for i in range(len(self.ilist)):
            iline = self.ilist[i][0]
            xleft = 1000000
            xright = -100000
            cspace = []
            xc = 0
            for j in range( len(self.lines[iline])):
                ichar = self.lines[iline][j]
                if (ichar > 0):
                    x = self.xx[ichar]
                    y = self.yy[ichar]

                    if (x< xleft):
                        xleft = x
                    if (x> xright):
                        xright = x
                    if (xc != 0):
                        space = abs(x - xc)
                        self.characterSpace.append(space)
                        xc = x
                    else:
                        xc = x
            self.lineLeft.append( xleft)
            self.lineRight.append(xright)


        # we estimate the spacing between characters - the 1/8 number is to ensure we are not looking at large
        # gaps associated with black areas in the document.    we generally expect characters to be within
        # the 7/8 spacing distribution with the rest being bigger gaps.   this probably should be done
        # with a more sophisticated algorithm that looks for gaps in the distribution.   The best estimate seems
        # to ber spaceEstimateSmall since it is more typical of spacing than the bigger gaps.
        self.spaceEstimateBig   =  sorted(self.characterSpace)[ len(self.characterSpace)* 7/ 8]
        self.spaceEstimateSmall =  sorted(self.characterSpace)[ len(self.characterSpace)* 1/ 8]
        self.spaceEstimate      =  sorted(self.characterSpace)[ len(self.characterSpace)* 6/ 8]

        # the margin estimates are taken using the array of left and right extents for each line
        # we sort them, and then take the 3/8 number from the left and the 7/8 from the right to
        # eliminate the extreme cases.   we expect the left margin to be a bit better aligned than the
        # right margin.   we then backup one character to make sure everything is included that is on
        # the line.
        self.leftEstimate = sorted(self.lineLeft)[len(self.lineLeft)* 3/8]  - self.spaceEstimate
        self.rightEstimate = sorted(self.lineRight)[len(self.lineRight)* 7/8]  + self.spaceEstimate



    def removeCharactersLeftOfMargin(self):
        # knock out any characters to the left of the left margin
        for i in range(len(self.ilist)):
            iline = self.ilist[i][0]
            for j in range( len(self.lines[iline])):
                ichar = self.lines[iline][j]
                if (ichar > 0):
                    x = self.xx[ichar]
                    y = self.yy[ichar]
                    if x < self.leftEstimate:
                        self.lines[iline][j] = -1


    def joinLines(self):
        # join the lines that are within a 1/2 line spacing where all the characaters of the sequence
        # are in ascending order from left to right - this only involves merging lines, not deleting them
        self.blanked = []
        for i in range(0, len(self.ilist)):
            self.blanked.append(0)

        for i in range(0, len(self.ilist)-1):
            iline1 = self.ilist[i][0]
            iline2 = self.ilist[i+1][0]
            b1 = self.ilist[i][1]
            b2 = self.ilist[i+1][1]

            left1 = self.lineLeft[i]
            right1 = self.lineRight[i]
            left2 = self.lineLeft[i+1]
            right2 = self.lineRight[i+1]

            if  (b2-b1)/self.medianSpacing < 0.45:
                if (right1 < left2):
                    self.lines[iline2] = self.lines[iline1] + self.lines[iline2]
                    self.lines[iline1] = []
                    self.blanked[i+1] = 1
                if (right2 < left1):
                    self.lines[iline2] = self.lines[iline2] + self.lines[iline1]
                    self.lines[iline1]  = []
                    self.blanked[i] = 1
        self.blanked.append(0)


    def recalculateSpacing(self):
        # recalculate the spacings for each line
        self.finalSpacing = []
        self.allSpacing = []

        for i in range(0, len(self.ilist)):
            iline = self.ilist[i][0]
            ct = 0
            # if the line is not blanked process it
            if self.blanked[i] == 0:
                self.blankedList = []
                # go through the lines and make a list of nonblanked characters
                for j in range(len(self.lines[iline])):
                    ii = self.lines[iline][j]
                    if ii !=-1:
                        self.blankedList.append(ii)

                self.dx = []
                if len(self.blankedList) > 1:
                    i1 = self.blankedList[0]
                    x1 = self.xx[i1]
                    y1 = self.yy[i1]
                    self.dx.append(x1-self.leftEstimate)
                    self.allSpacing.append(x1-self.leftEstimate)
                    for j in range( len(self.blankedList)-1 ):
                        i1 =  self.blankedList[j]
                        i2 = self.blankedList[j+1]
                        x1 = self.xx[i1]
                        y1 = self.yy[i1]
                        x2 = self.xx[i2]
                        y2 = self.yy[i2]
                        self.dx.append( abs(x2-x1))
                        self.allSpacing.append( abs(x2-x1))

                    i1 = self.blankedList[len(self.blankedList)-1]
                    x1 = self.xx[i1]
                    y1 = self.yy[i1]
                    self.dx.append(self.rightEstimate - x1)
                    self.allSpacing.append(self.rightEstimate - x1)
                self.finalSpacing.append(self.dx)

    def dumpMachineReadable(self):
        # dump out the full machine readable datafile
        fname1 = "machine" + self.fileid
        fout1 = codecs.open(fname1,encoding='utf-8',mode='w')
        for i in range(0, len(self.ilist)):
            iline = self.ilist[i][0]
            ct = 0
            if self.blanked[i] == 0:
                for ii in self.lines[iline]:
                    if ii !=-1:
                        cval = self.cval[ii]
                        x1 = self.xx[ii]
                        y1 = self.yy[ii]
                        ct = ct + 1
                        lineString = str(i) + ", " + str(ct) + ", " + str(ii) + ", " + self.fullString[ii]
                        fout1.write(lineString + "\n")
        fout1.close()

    def dumpHumanReadable(self):
        # dump out the datafile
        # mark the characters
        fname2 = "human" + self.fileid
        fout2 = codecs.open(fname2,encoding='utf-8',mode='w')
        for i in range(0, len(self.ilist)):
            iline = self.ilist[i][0]
            ct = 0
            if self.blanked[i+1] == 0:
                lineString = ""
                for ii in self.lines[iline]:
                    if ii !=-1:
                        lineString = lineString + self.cval[ii]
                        ct = ct + 1

                fout2.write(lineString + "\n")
        fout2.close()

    def absoluteCharacterPosition(self):
        fout1 = sys.stdout
        self.indexList = []
        self.characterPositions = []
        self.characterValues = []
        # loop through all the lines in the document
        for i in range(len(self.ilist)):
            iline = self.ilist[i][0]
            ct = 0
            pList = []
            cList = []
            # if it is not blanked, do the analysis
            if self.blanked[i+1] == 0:
                left = self.lineLeft[i]
                right = self.lineRight[i]
                pList = []
                cList = []
                pcount = 0

                # put together the characters across this line
                ploc = 0
                for pos in range(len(self.lines[iline])):
                    ii = self.lines[iline][pos]
                    if ii >=0 :
                        cval1 = self.cval[ii]
                        x1 = self.xx[ii]
                        y1 = self.yy[ii]
                        ct = ct + 1
                        ploc = ploc + 1

                        # calculate the approximate absolute positions
                        dxleft = x1 - self.leftEstimate
                        dnleft = dxleft / self.spaceEstimate
                        dxright = self.rightEstimate - x1
                        dnright = dxright / self.spaceEstimate

                        # treat the first character in a special way
                        if ploc == 1:

                            # if the character is close to the left edge, put it on the left edge
                            if dnleft < 1.4:
                                cstart = 1
                            else:
                                cstart = int(dnleft)
                            ccurrent = cstart
                            clast = x1
                            dx = 0

                        else:

                            # for characters other than the first, we see if it is within 2 spaces
                            # from the last character.   If not, we find its location based on the
                            # absolute position
                            dn = (x1 - clast) / self.spaceEstimateSmall
                            clast = x1
                            if dn < 1.5:
                                ccurrent = ccurrent + 1
                            else:
                                ccurrent = ccurrent + int(dn)

                        # update the list of character locations
                        cList.append(ii)
                        pList.append(ccurrent)
                        clast = x1

            self.characterValues.append(cList)
            self.characterPositions.append(pList)

    def dumpFormatted(self):

        # dump out the full machine readable datafile
        fname1 = "formatted" + self.fileid
        fout1 = codecs.open(fname1,encoding='utf-8',mode='w')

        maxlength = 0
        lcount = 0
        for il in range(len(self.characterPositions)):
            ilength = len(self.characterPositions[il])
            jlength = len(self.characterValues[il])
            for ic in range(jlength):
                ipos = self.characterPositions[il][ic]
                if ipos > maxlength:
                    maxlength = ipos
                    lcount = lcount + 1

        maxlength = maxlength +1
        lcount = lcount + 250
        finalLines = []
        for icount in range(lcount):
            theLine = []
            for ichar in range(maxlength):
                theLine.append(" ")
            finalLines.append(theLine)

        lcount = 0
        for il in range(len(self.characterPositions)):
            ilength = len(self.characterPositions[il])
            jlength = len(self.characterValues[il])
            if ilength > 0:
                for ic in range(jlength):
                    ipos = self.characterPositions[il][ic]
                    ichar = self.characterValues[il][ic]
                    cc = self.cval[ichar]
                    finalLines[lcount][ipos] = cc
                lcount = lcount + 1

        for il in range(lcount):
            s = ""
            for cc in finalLines[il]:
                s = s + cc
            fout1.write( s[1:] + "\n")

        fout1.close()

    def dumpDecoded(self):
        # dump out the full machine readable datafile
        fname1 = "decode" + self.fileid
        fout1 = codecs.open(fname1,encoding='utf-8',mode='w')
        lcount = 0
        ct = 0
        for il in range(len(self.characterPositions)):
            ilength = len(self.characterPositions[il])
            jlength = len(self.characterValues[il])
            lineString = ""
            if ilength > 0:
                for ic in range(jlength):
                    ipos = self.characterPositions[il][ic]
                    ichar = self.characterValues[il][ic]
                    cc = self.cval[ichar]
                    cval = self.cval[ichar]
                    x1 = self.xx[ichar]
                    y1 = self.yy[ichar]
                    ct = ct + 1
                    lineString = str(il) + ", " + str(ic) + ", "  + str(ipos) + ", " + str(ct) + ", " + self.fullString[ichar]
                    fout1.write(lineString + "\n")
                lcount = lcount + 1

        fout1.close()

    def dumpPositionStats(self):

        # dump out the full statistics datafile
        fname1 = "stats" + self.fileid
        statout = codecs.open(fname1,encoding='utf-8',mode='w')

        statout.write( "document_name =" + self.filename + "\n")
        statout.write("\n")
        statout.write( "document_total_character = " + str(len(self.xx)) + "\n")
        statout.write( "document_filtered_characters = " +  str(len(self.xxFiltered)) + "\n")
        statout.write( "document_total_clicks = " + str( self.totalClicks) + "\n")
        statout.write( "document_total_filtered_clicks = " + str(self.totalFilteredClicks) + "\n")
        statout.write( "document_max_clicks_per_character = " + str(self.maxClicks) + "\n")

        statout.write( "document_xmin = " + str(self.xmin) + "\n")
        statout.write( "document_xmax = " +  str(self.xmax) + "\n")
        statout.write( "document_xmean = " + str(self.xmean) + "\n")
        statout.write( "document_xmedian = " + str(self.xmedian) + "\n")
        statout.write( "document_xstd    = "+ str(self.xstd) + "\n")
        statout.write( "\n")

        statout.write( "document_ymin = "+ str(self.ymin) + "\n")
        statout.write( "document_ymax = "+ str(self.ymax) + "\n")
        statout.write( "document_ymean = "+ str(self.ymean) + "\n")
        statout.write( "document_ymedian = " + str(self.ymedian) + "\n")
        statout.write( "document_ystd = "+ str(self.ystd) + "\n")
        statout.write( "\n")

        f = sorted(self.allSpacing)
        lf = len(f)

        statout.write( "document_left_estimate " + str(self.leftEstimate) + "\n")
        statout.write( "document_right_estimate " + str(self.rightEstimate) + "\n")

        statout.write( "character_small_estimate = " + str(self.spaceEstimateSmall) + "\n")
        statout.write( "character_middle_estmate = " + str(self.spaceEstimate) + "\n")
        statout.write( "character_big_estimate = " + str(self.spaceEstimateBig) + "\n")
        a1 = np.average(f)
        s1 = np.std(f)
        self.betterList = []
        for i in self.allSpacing:
            if i < a1 + s1:
                self.betterList.append(i)
        a2 = np.average(self.betterList)
        s2 = np.std(self.betterList)
        self.betterList = []
        for i in self.allSpacing:
            if i < a2 + s2:
                self.betterList.append(i)
        a3 = np.average(self.betterList)
        s3 = np.std(self.betterList)
        statout.write("\n")
        statout.write( "document_a1 = "+ str(a1) + "\n")
        statout.write( "document_a2 = "+ str(a2) + "\n")
        statout.write( "document_a3 = "+ str(a3) + "\n")
        statout.write( "document_s1 = "+ str(s1) + "\n")
        statout.write( "document_s2 = "+ str(s2) + "\n")
        statout.write( "document_s3 = "+ str(s3) + "\n")

        # print out line statistics
        statout.write("\n\nLine analysis\n")
        for i in range(0, len(self.ilist)-1):
            iline = self.ilist[i][0]
            b1 = self.ilist[i][1]
            b2 = self.ilist[i+1][1]
            left = self.lineLeft[i]
            right = self.lineRight[i]
            ct = 0
            for ll in self.lines[iline]:
                if ll != -1:
                    ct = ct + 1

            statout.write( "\n")
            statout.write("line_number = " + str(i) + "\n")
            statout.write("line_vertical_b1 = " + str(b1) + "\n")
            statout.write("line_vertical_b2 = " + str(b2) + "\n")
            statout.write("line_vertical_median_spacing = "  + str(self.medianSpacing) + "\n")
            statout.write("line_vertical_width_characters = " + str((b2-b1)/self.medianSpacing) + "\n")

            statout.write("line_horizontal_left = " + str(left) + "\n")
            statout.write("line_horizontal_right = " + str(right) + "\n")
            statout.write("line_horizontal_space_estimate = " + str(self.spaceEstimate) + "\n")
            statout.write("line_horizontal_width_characters = " + str((right-left)/self.spaceEstimate) + "\n")
            statout.write( "line_characters= "+ str(ct) + "\n")
            statout.write( "line_character_list = "+ str(self.lines[iline]) + "\n")

        statout.close()

    def printDoc(self):
        print "\n"
        print "File documentation"
        print ""
        print "Decode files:"
        print "Column    Description"
        print "1         Line number"
        print "2         Character number on the line"
        print "3         Estimated character position on the line"
        print "4         Absolute character number in the processed document"
        print "5         Character ID in fragment file"
        print "6         Character X position - pixels"
        print "7         Character Y position - pixels"
        print "8         Best character guess"
        print "9         Probability analysis of characters"
        print "10        Number of clicks"
        print "11        Fraction of clicks on consensus character"

        print ""
        print "Formatted file:"
        print "Contains an approximate layout of the characters in a human readable form."
        print "Spaces are for both blanks or unclear identifications."
        print ""
        print "Stat files:"
        print "Contains a number of statistics on the entire document, character spacing"
        print "and for each line."
        print ""

    def processCommandLine(self):
        self.doStats = 1       # statistical analysis of the document
        self.doHuman = 0       # unformatted human output  (depreciated)
        self.doMachine = 0     # original machine output of lines (depreciated)
        self.doDecoded = 1     # new machine output - includes character position
        self.doFormatted = 1   # human readable & formatted strings
        self.all = 1           # do all the files

        if len(sys.argv) == 1:
            print "\nCommand line parameters:"
            print "--help - prints this list"
            print "--all  - processes all the files in the directory"
            print "  filename - processes only the selected file\n\n"
            exit()

        for iparm in range(1,len(sys.argv)):
            parm = sys.argv[iparm]
            if parm == "--help":
                print "\nCommand line parameters:"
                print "--help - prints this list"
                print "--all  - processes all the files in the directory"
                print "--doc  - prints longer documentation about output files"
                print "  filename - processes only the selected file\n\n"
                exit()

            if parm == "--doc":
                self.printDoc()
                exit()

            if parm == "--all":
                self.all = 1

            if parm.find("--") == -1:
                self.targetName = parm
                self.all = 0

if __name__ == '__main__':

    papyri()

from matplotlib import pyplot as plt
from astropy.io import ascii

# Adapt the gnuplot routines to use Python/MPL

# fragmentStatistics 

with open('fragmentStatistics.txt','r') as f:
    fs = ascii.read(f)

fig = plt.figure()
ax = fig.add_subplot(111)

ax.plot(fs['userCount'],fs['clicks'],'+')

ax.set_xlim(1,50)
ax.set_ylim(1,10000)
ax.set_xlabel('number of users per fragment')
ax.set_ylabel('total clicks per fragment')
ax.set_yscale('log')

plt.savefig('fragmentStatistics.ps')

# hist

with open('hist.txt','r') as f:
    h = ascii.read(f)

fig = plt.figure()
ax = fig.add_subplot(111)

ax.plot(h['bin'],h['count'],'+')

ax.set_xlim(1,50)
ax.set_ylim(1,10000)
ax.set_ylabel('number of fragments')
ax.set_xlabel('number of users per fragment')
ax.set_yscale('log')

plt.savefig('hist.ps')


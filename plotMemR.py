#-- coding:UTF-8 --

# Usage:
#      python memory.py file_name

# Tips:
#      1. You shold install some dependency library when first run
#      run commond:python -m pip install matplotlib
#      or install anaconda(just visit https://www.anaconda.com/distribution/)
#      2. Script just support python2.7

#      https://www.python.org/ 
#      安装windows版本的python后，
#      pip install numpy
#      pip install matplot

import sys
import numpy as np
import matplotlib.pyplot as plt
import os

f = sys.argv[1]

memorys = []
fds = []

for line in open(f):
    if 'TOTAL SWAP' in line:
        data = line.replace(" ", "")
        index = data.find("TOTAL", 5)
        memory = data[6+3:index]
        memorys.append(int(memory) / 1000)
    elif 'Process Fd totalCount' in line:
        start = line.find(":") + 1
        fd = line[start:]
        fds.append(int(fd))

# show memory start
x = range(len(memorys))
y = memorys

length = len(y)
maxValue = max(y)
minValue = min(y)

title=os.path.basename(f).split('.')[0]
mmtitle='Memory_'+title+''
fdtitle='FD_'+title+''
#factor = maxValue / 10 * 10
median = np.median(y)
log = '[%s]\nData length:%d, Max:%dM, Min:%dM, Median:%dM' % (mmtitle, length, maxValue, minValue, median)
print(log)

fig=plt.figure(figsize=(8,4))
plt.subplot(121)
plt.plot(x, y, marker='o')
plt.hlines(median, length, 0.5, colors = "r", linestyles = "dashed")
plt.title(log, size=10)
# plt.legend()
# plt.savefig(mmtitle+'.jpg')
# plt.show()
# show memory end

# show fd start
x2 = range(len(fds))
y2 = fds
length2 = len(y)
maxValue2 = max(y)
minValue2 = min(y)
log = '[%s]\nData length:%d, Max:%d, Min:%d' % (fdtitle, length2, maxValue2, minValue2)
print(log)
plt.subplot(122)
plt.plot(x2, y2, marker='o', color='coral')
plt.title(log, size=10)


# plt.legend()
fig.tight_layout()
path = os.path.dirname(f)
plt.savefig(path+'/'+title+'.jpg')
plt.show()
# show fd end



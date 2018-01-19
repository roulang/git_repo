#|----------------------------------------------
#|this program is for read event from web site
#|----------------------------------------------

import urllib3
import xml.etree.cElementTree as et
import datetime
import csv

fmt='%m-%d-%Y %I:%M%p'
fmt2='%Y.%m.%d %H:%M:%S'
cmt_gmt_offset=datetime.timedelta(hours=8)

"""
#for test
tree=et.parse('D:/rou/dl/ff_calendar_thisweek.xml')
"""

#for real
print("Read events from web, please wait...")
http = urllib3.PoolManager()
r = http.request('GET', 'http://cdn-nfs.forexfactory.net/ff_calendar_thisweek.xml')
print("Read OK")

tree=et.fromstring(r.data)
evts=[]
for el in tree.findall('event'):
    #print ('-------------------')
    evt={}
    for ch in el.getchildren():
        if ch.tag in ['title','country','date','time','impact']:
            #print ('{:>15}: {:<30}'.format(ch.tag,ch.text))
            evt[ch.tag]=ch.text
    evts.append(evt)

news={}
wrevts=[]
n=1
for i in range(len(evts)):
    imp=evts[i].get('impact')
    title=evts[i].get('title')
    dtstr=evts[i]['date']+' '+evts[i]['time']
    dt=datetime.datetime.strptime(dtstr,fmt)
    m=dt.minute % 10
    dt+=cmt_gmt_offset
    dtstr2=dt.strftime(fmt2)
    evts[i]['datetime']=dtstr2
    if (imp=='High' or imp=='Medium') and (not 'Oil' in title) and (m!=9):
        print (str(n)+'.-------------------')
        for k in evts[i].keys():
            #print(str(i)+','+k+'->'+evts[i].get(k))
            print ('{:>15}: {:<30}'.format(k,evts[i].get(k)))
        cur=evts[i].get('country')
        dtstr3=evts[i].get('datetime')
        k=cur+' '+dtstr3
        if k not in news.keys():
            news[k]=imp
            wrevts.append([n,cur,dtstr3,0])
            n+=1

fn='lang_news.ex4.csv'
oldnews={}
f=open(fn)
r=csv.reader(f)
for row in r:
    #print(str(row))
    k=row[1]+' '+row[2]
    oldnews[k]=row[3]
f.close()

ls=set(oldnews.keys())
rs=set(news.keys())
dels=ls-rs
adds=rs-ls

if dels:
    print('\ndeleted events:')
    print(str(dels))
if adds:
    print('\nadded events:')
    print(str(adds))

if not dels and not adds:
    print('\nNo event need to update, nothing to do.\n')
else:
    msg=''
    while msg!='y':
        print('\nOverwrite file('+fn+'), continue?(y/N) or press^C\n')
        msg=input()

    """
    n=1
    for k in oldnews.keys():
        #print(str(n)+','+k+'->'+oldnews.get(k))
        n+=1

    n=1
    for k in news.keys():
        #print(str(n)+','+k+'->'+news.get(k))
        n+=1
    """

    print("Overwriting file:"+fn)

    f=open(fn,'w',newline='')
    w=csv.writer(f)
    for i in range(len(wrevts)):
        evt=wrevts[i]
        w.writerow(wrevts[i])
        #for j in range(len(wrevts[i])):
            #print(str(i)+','+str(j)+':'+str(wrevts[i][j]))
            
    f.close()

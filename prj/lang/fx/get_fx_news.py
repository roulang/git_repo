# encoding: UTF-8

import pymongo
import urllib2
import xml.etree.cElementTree as et
import datetime
from time import time

fmt = '%m-%d-%Y %I:%M%p'
fmt2 = '%Y.%m.%d %H:%M:%S'
cmt_gmt_offset = datetime.timedelta(hours=8)

# for test
# tree = et.parse('D:/rou/dl/ff_calendar_thisweek.xml')

# for real
print("Read events from web, please wait...")
# http = urllib2.PoolManager()
# r = http.request('GET', 'http://cdn-nfs.forexfactory.net/ff_calendar_thisweek.xml')
r = urllib2.urlopen('http://cdn-nfs.forexfactory.net/ff_calendar_thisweek.xml')
print("Read OK")
# tree = et.fromstring(r.data)
tree = et.fromstring(r.read())

evts = []

for el in tree.findall('event'):
    # print('-------------------')
    evt = {}
    for ch in el.getchildren():
        if ch.tag in ['title', 'country', 'date', 'time', 'impact', 'forecast', 'previous']:
            # print('{:>15}: {:<30}'.format(ch.tag,ch.text))
            evt[ch.tag] = ch.text
    evts.append(evt)

# con = sqlite3.connect('D:/rou/sync/db/abc.db')
# con = sqlite3.connect(":memory:")

print "writing", len(evts), "records..."

"""数据插入到Mongo数据库中"""
start = time()

# 锁定集合，并创建索引
client = pymongo.MongoClient('localhost', 27017)
collection = client['fx']['news']
collection.ensure_index([('key', pymongo.ASCENDING)], unique=True)

for i in range(len(evts)):
    dt_str = evts[i]['date'] + ' ' + evts[i]['time']
    dt = datetime.datetime.strptime(dt_str, fmt)
    # dt += cmt_gmt_offset
    dt2_str = dt.strftime(fmt2)
    evts[i]['dtm'] = dt2_str
    evts[i]['key'] = evts[i].get('country') + ' ' + dt2_str
    keys = ','.join(evts[i].keys())
    # question_marks = ','.join(list('?' * len(evts[i])))
    # values = tuple(evts[i].values())
    # con.execute('INSERT OR REPLACE INTO evt (' + keys + ') VALUES (' + question_marks + ')', values)
    # evt = {}
    # evt.key = evts[i]['key']
    # evt.title = evts[i]['title']
    # evt.country = evts[i]['country']
    # evt.impact = evts[i]['impact']
    # evt.forecast = evts[i]['forecast']
    # evt.previous = evts[i]['previous']
    # evt.date = evts[i]['date']
    # evt.time = evts[i]['time']
    # evt.datetime = evts[i]['dtm']

    flt = {'key': evts[i]['key']}
    # collection.update_one(flt, {'$set': evt.__dict__}, upsert=True)
    collection.update_one(flt, {'$set': evts[i]}, upsert=True)

print(u'插入完毕，耗时：%s' % (time() - start))


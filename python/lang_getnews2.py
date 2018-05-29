# |----------------------------------------------
# |this program is test for python
# |----------------------------------------------

import urllib3
import xml.etree.cElementTree as et
import datetime
import sqlite3

fmt = '%m-%d-%Y %I:%M%p'
fmt2 = '%Y.%m.%d %H:%M:%S'
cmt_gmt_offset = datetime.timedelta(hours=8)

# for test
# tree = et.parse('D:/rou/dl/ff_calendar_thisweek.xml')

#for real
print("Read events from web, please wait...")
http = urllib3.PoolManager()
r = http.request('GET', 'http://cdn-nfs.forexfactory.net/ff_calendar_thisweek.xml')
print("Read OK")
tree = et.fromstring(r.data)

evts = []

for el in tree.findall('event'):
    # print('-------------------')
    evt = {}
    for ch in el.getchildren():
        if ch.tag in ['title', 'country', 'date', 'time', 'impact']:
            # print('{:>15}: {:<30}'.format(ch.tag,ch.text))
            evt[ch.tag] = ch.text
    evts.append(evt)

con = sqlite3.connect('D:/rou/sync/db/abc.db')
# con = sqlite3.connect(":memory:")

'''
con.execute("""
CREATE TABLE evt
(
    key     TEXT PRIMARY KEY,
    country TEXT,
    date    TEXT,
    time    TEXT,
    impact  TEXT,
    title   TEXT,
    dtm     DATETIME
);
""")
'''

print("writing ",len(evts)," records.")

for i in range(len(evts)):
    dt_str = evts[i]['date'] + ' ' + evts[i]['time']
    dt = datetime.datetime.strptime(dt_str, fmt)
    dt += cmt_gmt_offset
    dt2_str = dt.strftime(fmt2)
    evts[i]['dtm'] = dt2_str
    evts[i]['key'] = evts[i].get('country') + ' ' + dt2_str
    keys = ','.join(evts[i].keys())
    question_marks = ','.join(list('?' * len(evts[i])))
    values = tuple(evts[i].values())
    con.execute('INSERT OR REPLACE INTO evt (' + keys + ') VALUES (' + question_marks + ')', values)

con.commit()

# for row in con.execute("SELECT * FROM evt"):
#     print(row)

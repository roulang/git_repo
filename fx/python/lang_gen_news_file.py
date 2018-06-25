import sqlite3
import datetime
import csv

print("Read events from db, please wait...")
clt_dev = '50CA3DFB510CC5A8F28B48D1BF2A5702'
clt_test = '2010C2441A263399B34F537D91A53AC9'
con = sqlite3.connect('C:/rou/db/abc.db')
cur = con.cursor()
'''
cur.execute("select strftime('%Y.%m.%d %H:%M:%S',dtm),title,country,impact from evt where country='USD' \
and impact in ('High','Medium') and (not title like '%Oil%') and dtm > datetime('now','localtime','-10 days') order by dtm")
'''
cur.execute("select strftime('%Y.%m.%d %H:%M:%S',dtm),title,country,impact from evt \
where impact in ('High','Medium') and dtm > datetime('now','localtime','-10 days') order by dtm")
pt = 'C:/Users/lang/AppData/Roaming/MetaQuotes/Terminal/' + clt_test + '/MQL4/Files/'
fn = pt + 'lang_usd_news.ex4.csv'
f = open(fn, 'w', newline='')
w = csv.writer(f)

for rec in cur.fetchall():
    # print(rec)
    w.writerow(rec)

cur.close()
con.close()
f.close()

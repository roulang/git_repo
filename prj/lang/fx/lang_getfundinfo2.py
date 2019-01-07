# -*- coding: utf-8 -*-
import requests
import sqlite3
from bs4 import BeautifulSoup
import re
from pprint import pprint

m = ['dt', 'price1', 'price2', 'rt', 'bstat', 'sstat', 'dlv']

con = sqlite3.connect('c:/rou/db/abc.db')
cur = con.cursor()
cur.execute("select distinct(code) c from fund_b where c >= '003667' order by c")
codes = []
for rec in cur.fetchall():
    codes.append(rec[0])

n = '10'

for i in range(len(codes)):
# for i in range(2):
    # test
    # print(codes[i])
    print("Read fund (", codes[i], ") info from web, please wait...")
    url = "http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code=" + codes[i] + "&page=1&per=" + n + "&sdate=&edate="
    # print("url=", url)
    f = requests.get(url)
    try:
        f.raise_for_status()
    except Exception as exc:
        print('There was a problem: %s' % exc)
        exit(1)

    print("Read OK")
    soup = BeautifulSoup(f.text, 'lxml')
    tb = soup.find_all('table', class_='w782 comm lsjz')
    if len(tb) == 0:
        continue
    trs = tb[0].find_all('tr')
    # print('trs=', len(trs))
    d = {'code': codes[i]}
    for j in range(1, len(trs)):
        # pprint(trs[j])
        tds = trs[j].find_all('td')
        # pprint(ths)
        # pprint(tds)
        for k in range(len(tds)):
            td = tds[k].getText()
            d[m[k]] = td
        # test
        d['key'] = d['code'] + ' ' + d['dt']
        pprint(d)
        keys = ','.join(d.keys())
        question_marks = ','.join(list('?' * len(d)))
        values = tuple(d.values())
        # print('INSERT OR REPLACE INTO fund_b (' + keys + ') VALUES (' + question_marks + ')', values)
        con.execute('INSERT OR REPLACE INTO fund_r (' + keys + ') VALUES (' + question_marks + ')', values)

    con.commit()

'''
con.execute("""
CREATE TABLE fund_r
(
    key     NVARCHAR2 PRIMARY KEY,
    code    TEXT NOT NULL,
    dt      VARCHAR2,
    price1  VARCHAR2,
    price2  VARCHAR2,
    rt      VARCHAR2,
    bstat   VARCHAR2,
    sstat   VARCHAR2,
    dlv     VARCHAR2
)
""")
'''
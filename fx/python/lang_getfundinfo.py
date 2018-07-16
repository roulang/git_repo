# -*- coding: utf-8 -*-
import requests
import sqlite3
from bs4 import BeautifulSoup
import re
from pprint import pprint

m = {
    '基金全称':     'name',
    '基金简称':     'name2',
    '基金类型':     'type',
    '基金经理人':   'mgr',
    '基金管理人':   'com',
    '发行日期':     'st',
    '跟踪标的':     'trace',
}

# fn = '1.htm'
# soup = BeautifulSoup(open(fn), 'html.parser')

print("Read funds info from web, please wait...")
f = requests.get('http://fund.eastmoney.com/allfund.html')
try:
    f.raise_for_status()
except Exception as exc:
    print('There was a problem: %s' % exc)
    exit(1)

print("Read OK")
soup = BeautifulSoup(f.text, 'html.parser')
f.connection.close()

r = re.compile(r'\d{6}')
uls = soup.find_all('ul', class_='num_right')
codes = []
for i in range(len(uls)):
    lis = uls[i].find_all('li', class_='b')
    for j in range(len(lis)):
        c = r.search(lis[j].getText())
        if c:
            # test
            # print(c.group())
            codes.append(c.group())

print('read', len(codes), 'codes')

con = sqlite3.connect('c:/rou/db/abc.db')

# for i in range(1):
for i in range(len(codes)):
    # test
    # print(codes[i])
    # if codes[i] < '003324': continue
    print("Read fund (", codes[i], ") info from web, please wait...")
    url = "http://fund.eastmoney.com/f10/" + codes[i] + ".html"
    # print("url=", url)
    f = requests.get(url)
    try:
        f.raise_for_status()
    except Exception as exc:
        print('There was a problem: %s' % exc)
        exit(1)

    print("Read OK")
    soup = BeautifulSoup(f.text, 'lxml')
    f.connection.close()

    tb = soup.find_all('table', class_='info w790')
    if len(tb) == 0:
        continue
    trs = tb[0].find_all('tr')
    # print('trs=', len(trs))
    d = {'code': codes[i]}
    for j in range(len(trs)):
        # pprint(trs[j])
        ths = trs[j].find_all('th')
        tds = trs[j].find_all('td')
        # pprint(ths)
        # pprint(tds)
        if len(ths) != len(tds):
            continue
        for k in range(len(ths)):
            th = ths[k].getText()
            td = tds[k].getText()
            if th not in m.keys():
                continue
            d[m[th]] = td
    # test
    d['key'] = d['code'] + ' ' + d['mgr']
    # pprint(d)
    keys = ','.join(d.keys())
    question_marks = ','.join(list('?' * len(d)))
    values = tuple(d.values())
    # print('INSERT OR REPLACE INTO fund_b (' + keys + ') VALUES (' + question_marks + ')', values)
    con.execute('INSERT OR REPLACE INTO fund_b (' + keys + ') VALUES (' + question_marks + ')', values)
    con.commit()

'''
con.execute("""
CREATE TABLE fund_b
(
    key     NVARCHAR2 PRIMARY KEY,
    code    TEXT NOT NULL,
    name    NVARCHAR2,
    name2   NVARCHAR2,
    type    NVARCHAR2,
    mgr     NVARCHAR2,
    com     NVARCHAR2,
    st      NVARCHAR2,
    trace   NVARCHAR2
)
""")
'''

# -*- coding: utf-8 -*-
import pymongo
from pandas import DataFrame
import urllib2
from time import time
import time
from bs4 import BeautifulSoup
from pprint import pprint

print("Read fund info from web, please wait...")
url = 'http://fund.eastmoney.com/js/fundcode_search.js'
while True:
    try:
        r = urllib2.urlopen(url)
    except Exception as exc:
        # import traceback
        # print ('generic exception: ' + traceback.format_exc())
        # exit(1)
        print ('error %s, wait 5 seconds...' % exc)
        time.sleep(5)
    else:
        break

print("Read OK")
content = r.read()
# print content
content = content[11:]
# print content
content = content[:-1]
# print content
# content = [["a", "华夏成长"],["c", "混合型"]]
# print type(content)
# print content[0][1]
# content = '[["a", "华夏成长"],["c", "混合型"]]'
# print type(eval(content))
a = []
a = eval(content)
# print a[0][2]
# b = ['code', 'code2', 'catg', 'catg2', 'name']
b = [u'基金代码', u'基金代码2', u'基金简称', u'基金类型', u'基金类型2']
df = DataFrame(a, columns=b)
# df.set_index(u'基金代码', inplace=True)
# print df

client = pymongo.MongoClient('localhost', 27017)
collection = client['fund']['fund_info']
collection.ensure_index([('key', pymongo.ASCENDING)], unique=True)

for cd in df[u'基金代码']:
    print("Read fund_info (", cd, ") info from web, please wait...")
    url = "http://fund.eastmoney.com/f10/" + cd + ".html"
    # print("url=", url)
    while True:
        try:
            r = urllib2.urlopen(url)
        except Exception as exc:
            # import traceback
            # print ('generic exception: ' + traceback.format_exc())
            # exit(1)
            print ('error %s, wait 5 seconds...' % exc)
            time.sleep(5)
        else:
            break

    print("Read OK")
    content = r.read()
    soup = BeautifulSoup(content, 'lxml')

    tb = soup.find_all('table', class_='info w790')
    if len(tb) == 0:
        continue
    trs = tb[0].find_all('tr')
    # print('trs=', len(trs))
    d = {'code': cd}
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
            d[th] = td
    # test
    d['key'] = d['code'] + ' ' + d[u'基金经理人']
    # pprint(d)
    """数据插入到Mongo数据库中"""
    flt = {'key': d['key']}
    collection.update_one(flt, {'$set': d}, upsert=True)
    # break

# df2 = df.append(d, ignore_index=True)
# print df2.columns

# """数据插入到Mongo数据库中"""
# start = time()
# # 锁定集合，并创建索引
# client = pymongo.MongoClient('localhost', 27017)
# collection = client['fund']['fund_info']
# collection.ensure_index([('key', pymongo.ASCENDING)], unique=True)
#
# for i, row in df2.iterrows():
#     data = row.to_dict()
#     # print data['code']
#     flt = {'key': data['key']}
#     collection.update_one(flt, {'$set': data}, upsert=True)
#
# print(u'插入完毕，耗时：%s' % (time() - start))

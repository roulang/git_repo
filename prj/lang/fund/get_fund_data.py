# -*- coding: utf-8 -*-
import pymongo
import pandas as pd
import urllib2
from bs4 import BeautifulSoup
from pprint import pprint
import time

client = pymongo.MongoClient('localhost', 27017)
collection = client['fund']['fund_info']
# df = pd.DataFrame(list(collection.find()))
df = pd.DataFrame(list(collection.find({}, {'code': 1})))
df.set_index('code', inplace=True)
# print df.index
# print df['000002':'000005'].index
# for x in collection.find({}, {'code': 1}).limit(2):
#     print(x)
# print df[df['code'] >= '000002'][df['code'] <= '000005']['code']
# print type(df['000002':'000005'].index[1])
# a = u'日期'
# b = u'净值日期'
# print b.find(a)
# exit()
collection2 = client['fund']['fund_data']
collection2.ensure_index([('key', pymongo.ASCENDING)], unique=True)

n = 40
max_pg = 1
min_code = '002988'
# max_code = '000009'
# for cd in df[df['code'] > '006471']['code']:
for cd in df['code']:
# for cd in df[min_code:].index:
# for cd in df[min_code:max_code].index:
    for pg in range(1, max_pg + 1):
        url = "http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code=" + str(cd) + "&page=" + str(pg) + "&per=" + str(n) + "&sdate=&edate="
        print("Read fund (" + str(cd) + ") info from web, please wait...")
        print url
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
        content = r.read()
        # print content
        content = content[12:]
        content = content[:-1]
        # print content
        m = ['content', 'records', 'pages', 'curpage']
        content2 = content
        for c in m:
            content2 = content2.replace(c, '"' + c + '"')
        # print content2
        d = {'records': 0, 'pages': 0}
        try:
            d = eval(content2)
        except Exception:
            import traceback
            print ('generic exception: ' + traceback.format_exc())
            exit(1)
        pprint(d)
        records = d['records']
        pages = d['pages']
        if records == 0:
            print "no data"
            break

        # read data
        # soup = BeautifulSoup(content2, 'lxml')
        soup = BeautifulSoup(d['content'], 'lxml')
        tb = soup.find_all('table', class_='w782 comm lsjz')
        if len(tb) == 0:
            continue
        trs = tb[0].find_all('tr')
        print('trs=', len(trs))
        d = {'code': str(cd)}
        m = ['dt', 'price1', 'price2', 'rt', 'bstat', 'sstat', 'dlv']
        # pprint(trs[0])
        ths = trs[0].find_all('th')
        pprint(ths)
        # for k in range(len(ths)):
        #     th = ths[k].getText()

        for j in range(1, len(trs)):
            pprint(trs[j])
            tds = trs[j].find_all('td')
            pprint(tds)
            for k in range(len(tds)):
                th = ths[k].getText()
                td = tds[k].getText()
                try:
                    if th.find(u'日期') >= 0:
                        d[th] = str(td)
                    elif th.find(u'净值') >= 0:
                        if len(td) > 0:
                            d[th] = float(td)
                        else:
                            d[th] = ''
                    elif th.find(u'率') >= 0:
                        if len(td) > 0:
                            d[th] = float(td.strip('%')) / 100
                        else:
                            d[th] = ''
                    elif th.find(u'收益') >= 0:
                        if len(td) > 0:
                            d[th] = float(td)
                        else:
                            d[th] = ''
                    else:
                        d[th] = td
                except Exception:
                    d[th] = td
            d['key'] = d['code'] + ' ' + d[u'净值日期']
            # pprint(d)
            flt = {'key': d['key']}
            collection2.update_one(flt, {'$set': d}, upsert=True)

        if pg >= pages:
            break
        # break
    # break


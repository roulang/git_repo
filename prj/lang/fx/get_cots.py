# -*- coding: utf-8 -*-
import pymongo
import pandas as pd
from time import time

print("Read COTS from web, please wait...")
url = 'https://www.cftc.gov/dea/newcot/FinFutWk.txt'

df = pd.read_csv(
    # filepath_or_buffer='FinFutWk.txt',
    filepath_or_buffer=url,
    sep=',',
    header=None,
    skiprows=0,
    # nrows=10,
    # index_col=['DateTime'],
    # usecols=['Market_and_Exchange_Names', 'Report_Date_as_YYYY-MM-DD', 'CFTC_Contract_Market_Code'],
    # parse_dates=['Report_Date_as_YYYY-MM-DD'],
    # parse_dates=['DateTime'],
    error_bad_lines=False,
    na_values='NULL',
)
print("Read OK")

# print df

df2 = pd.read_csv(
    filepath_or_buffer='cot_var.txt',
    sep=' ',
    header=None,
    skiprows=0,
    # nrows=10,
    # index_col=['DateTime'],
    # usecols=['Market_and_Exchange_Names', 'Report_Date_as_YYYY-MM-DD', 'CFTC_Contract_Market_Code'],
    # parse_dates=['Report_Date_as_YYYY-MM-DD'],
    # parse_dates=['DateTime'],
    error_bad_lines=False,
    na_values='NULL',
)

# print df2.iloc[:][1]

df.columns = df2.iloc[:][1]

print "writing", len(df.index), "records..."

"""数据插入到Mongo数据库中"""
start = time()

# 锁定集合，并创建索引
client = pymongo.MongoClient('localhost', 27017)
collection = client['fx']['cots']
collection.ensure_index([('key', pymongo.ASCENDING)], unique=True)

for i, row in df.iterrows():
    data = row.to_dict()
    data['key'] = data['Market_and_Exchange_Names'] + ' ' + str(data['As_of_Date_In_Form_YYMMDD'])
    # print data['key']
    flt = {'key': data['key']}
    collection.update_one(flt, {'$set': data}, upsert=True)

print(u'插入完毕，耗时：%s' % (time() - start))

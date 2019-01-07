# -*- coding: utf-8 -*-
import pandas as pd
import pymongo

# df=pd.read_csv(
#     # filepath_or_buffer='FinFut16.txt',
#     # filepath_or_buffer='ff_calendar_thisweek.csv',
#     filepath_or_buffer='EURUSD_M1_2018_10.csv',
#     sep=',',
#     skiprows=0,
#     nrows=10,
#     # index_col=['DateTime'],
#     # usecols=['Market_and_Exchange_Names', 'Report_Date_as_YYYY-MM-DD', 'CFTC_Contract_Market_Code'],
#     # parse_dates=['Report_Date_as_YYYY-MM-DD'],
#     # parse_dates=['DateTime'],
#     error_bad_lines=False,
#     na_values='NULL',
# )

# print df.shape
# print df['Date'].dtype
# print df['Date']
pd.set_option('expand_frame_repr', False)
# pd.set_option('max_colwidth', 8)
# print df
# print df.columns
# print df.index
# print df.dtypes
# print df.sample(5)
# print df.sample(frac=0.5)
# print df.describe()
# print df[['Date','Time']]
# print df.iloc[0:5, 0:6]
# print df.iloc[1, 1]
# print df.iat[1, 1]
# print df.loc['090741']
# print df.loc['090741', 'Market_and_Exchange_Names']
# print df.loc['2018-03-04 22:04:00': '2018-03-04 22:24:00']
# df['CUR'] = 'EURUSD'
# df['Open_diff'] = (df['AskOpen'] - df['BidOpen'])*100000
# df['Close_diff'] = (df['AskClose'] - df['BidClose'])*100000
# df['High_diff'] = (df['AskHigh'] - df['BidHigh'])*100000
# df['Low_diff'] = (df['AskLow'] - df['BidLow'])*100000
# print df[['Open_diff', 'Close_diff']]
# print df[['Open_diff', 'Close_diff']].mean()
# print df[['Open_diff', 'Close_diff']].mean(axis=1)
# print df['Open_diff'].max()
# print df['Open_diff'].min()
# print df['Open_diff'].std()
# print df['Open_diff'].count()
# print df['Open_diff'].median()
# print df['Open_diff'].quantile(0.25)
# df['BidOpen_last'] = df['BidOpen'].shift(1)
# df['BidOpen_diff'] = (df['BidOpen'] - df['BidOpen_last'])*100000
# print df[['BidOpen', 'BidOpen_last', 'BidOpen_diff']]
# df['BidOpen_diff'] = df['BidOpen'].diff(1)
# print df
# del df['BidOpen_diff']
# df.drop(['BidOpen_diff'], axis=1, inplace=True)
# df['BidOpen_sum'] = df['BidOpen'].cumsum()
# print df[['BidOpen', 'BidOpen_sum']]
# df['BidOpen_diff'] = df['BidOpen'].pct_change(1)*100
# print df[['BidOpen', 'BidOpen_diff']]
# df['BidClose_diff'] = df['BidClose'].pct_change(1) + 1
# df['BidClose_diff2'] = df['BidClose_diff'].cumprod()
# print df[['BidClose_diff', 'BidClose_diff2']]
# df['BidClose_rank'] = df['BidClose'].rank(ascending=False, pct=False)
# print df[['BidClose', 'BidClose_rank']]
# print df['BidClose'].value_counts()
# print df['BidClose'] == 1.23309
# print df[df['BidClose'] == 1.23309]
# print df[(df['BidClose'] == 1.23309) & (df['BidClose'] == 1.23351)]
# df['BidOpen_diff'] = df['BidOpen'].pct_change(1)*100
# print df[['BidOpen', 'BidOpen_diff']]
# print df.dropna(how='any')
# print df.dropna(subset=['BidOpen_diff'], how='all')
# print df.fillna(value='没有')
# df['BidOpen_diff'].fillna(value=df['BidOpen'], inplace=True)
# print df[['BidOpen', 'BidOpen_diff']]
# print df.fillna(method='bfill')
# print df.notnull()
# print df.isnull()
# print df[df['BidOpen_diff'].notnull()]
# df.reset_index(inplace=True)
# print df
# print df.sort_values(by=['BidOpen'], ascending=1)
# print df.sort_values(by=['BidOpen', 'BidClose'], ascending=[1, 1])
# df.reset_index(inplace=True)
# df1 = df.iloc[0:5][['DateTime', 'BidOpen', 'BidClose']]
# print df1
# df2 = df.iloc[0:8][['DateTime', 'AskOpen', 'AskClose']]
# print df2
# print df1.append(df2)
# df3 = df1.append(df2, ignore_index=True)
# print df3
# df3.drop_duplicates(
#     subset=['DateTime'],
#     keep='last',
#     inplace=True,
# )
# print df3
# print df.rename(columns={'DateTime': 'TimeDate'})
# print pd.DataFrame().empty
# print df.T

# print df['Market_and_Exchange_Names'].str[:5]
# print df['Market_and_Exchange_Names'].str.upper()
# print df['Market_and_Exchange_Names'].str.lower()
# print df['Market_and_Exchange_Names'].str.len()
# print df['Market_and_Exchange_Names'].str.strip()
# print df['Market_and_Exchange_Names'].str.contains('CANAD')
# print df['Market_and_Exchange_Names'].str.replace('CANAD', 'can')
# print df['Market_and_Exchange_Names'].str.split('-').str[0]
# print df['Market_and_Exchange_Names'].str.split('-', expand=True)
# print df['Report_Date_as_YYYY-MM-DD']
# df['Report_Date_as_YYYY-MM-DD'] = pd.to_datetime(df['Report_Date_as_YYYY-MM-DD'])
# print df['Report_Date_as_YYYY-MM-DD'].dt.year
# print df['Report_Date_as_YYYY-MM-DD'].dt.month
# print df['Report_Date_as_YYYY-MM-DD'].dt.day
# print df['Report_Date_as_YYYY-MM-DD'].dt.hour
# print df['Report_Date_as_YYYY-MM-DD'].dt.week
# print df['Report_Date_as_YYYY-MM-DD'].dt.weekday_name
# print df['Report_Date_as_YYYY-MM-DD'].dt.is_month_start
# print df['Report_Date_as_YYYY-MM-DD'] + pd.Timedelta(days=1)

# df['rolling'] = df['BidClose'].rolling(3).mean()
# df['rolling'] = df['BidClose'].rolling(3).std()
# print df[['BidClose', 'rolling']]
# df['expanding'] = df['BidClose'].expanding().mean()
# print df[['BidClose', 'expanding']]
# df['a'] = '啊啊'
# df.to_csv('output.csv', encoding='gbk', index=False)

# print df

# import time
#
# def some_func():
#     import random
#     random = random.random()
#     if random >= 0.5:
#         return
#     else:
#         raise ValueError('报错！')
#
#
# max_try_num = 5
#
# try_num = 0
# while True:
#     try:
#         some_func()
#     except ValueError:
#         print '警告！运行出错，停止1秒再尝试'
#         try_num += 1
#         time.sleep(1)
#         if try_num > 5:
#             print '超过最大测试数，运行失败'
#             break
#     else:
#         print '运行成功了'
#         break

client = pymongo.MongoClient('localhost', 27017)
collection = client['fx']['cots']
df = pd.DataFrame(list(collection.find()))
print df
# print df.iloc[:, 0]
exit()

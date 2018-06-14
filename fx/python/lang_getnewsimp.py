# |----------------------------------------------
# |this program is test for python
# |----------------------------------------------
import os
import csv
import sqlite3

k = ['dtm', 'cur', 'ped', 'open_p', 'close_p', 'high_p', 'low_p']
fn = ['EURUSD', 'USDJPY', 'AUDUSD', 'NZDUSD', 'GBPUSD', 'USDCAD', 'USDCHF']

clt_dev = '50CA3DFB510CC5A8F28B48D1BF2A5702'
clt_test = '2010C2441A263399B34F537D91A53AC9'

pt = "C:/Users/lang/AppData/Roaming/MetaQuotes/Terminal/" + clt_test + "/MQL4/Files/"

imps = []
for j in range(len(fn)):
    file_name = pt + "lang_usd_news_imp_" + fn[j] + ".ex4.csv"
    if not (os.path.exists(file_name) and os.path.isfile(file_name)):
        print("no file", file_name)
        continue
    print("found file", file_name)
    f = open(file_name)
    r = csv.reader(f)

    n = 0
    for row in r:
        # print(n, '->', row)
        imp = dict()
        imp['key'] = row[0] + ' ' + row[1] + ' ' + row[2]
        for i in range(len(row)):
            row[i] = row[i].lstrip()
            row[i] = row[i].rstrip()
            imp[k[i]] = row[i]
            # print('[', n, ',', i, '] ', '>>', row[i])
        imps.append(imp)
        n += 1

    f.close()

con = sqlite3.connect('D:/rou/sync/workspace/fx/db/abc.db')
# con = sqlite3.connect(":memory:")

print("writing ", len(imps), " records.")

for i in range(len(imps)):
    keys = ','.join(imps[i].keys())
    question_marks = ','.join(list('?' * len(imps[i])))
    values = tuple(imps[i].values())
    # print('keys(', i, ')=', keys)
    # print('marks(', i, ')=', question_marks)
    # print('values(', i, ')=', values)
    con.execute('INSERT OR REPLACE INTO imp (' + keys + ') VALUES (' + question_marks + ')', values)

con.commit()

# for row in con.execute("SELECT * FROM evt"):
#     print(row)

'''
con.execute("""
CREATE TABLE imp
(
    key     TEXT PRIMARY KEY,
    dtm     DATETIME,
    cur     TEXT,
    ped     INT,
    open_p  FLOAT,
    close_p FLOAT,
    high_p  FLOAT,
    low_p   FLOAT
);
""")
'''


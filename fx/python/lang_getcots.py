import csv
import requests
import sqlite3

k = ['Market_and_Exchange_Names', 'As_of_Date_In_Form_YYMMDD', 'Report_Date_as_MM_DD_YYYY', 'CFTC_Contract_Market_Code',
     'CFTC_Market_Code', 'CFTC_Region_Code', 'CFTC_Commodity_Code', 'Open_Interest_All', 'Dealer_Positions_Long_All',
     'Dealer_Positions_Short_All', 'Dealer_Positions_Spread_All', 'Asset_Mgr_Positions_Long_All',
     'Asset_Mgr_Positions_Short_All', 'Asset_Mgr_Positions_Spread_All', 'Lev_Money_Positions_Long_All',
     'Lev_Money_Positions_Short_All', 'Lev_Money_Positions_Spread_All', 'Other_Rept_Positions_Long_All',
     'Other_Rept_Positions_Short_All', 'Other_Rept_Positions_Spread_All', 'Tot_Rept_Positions_Long_All',
     'Tot_Rept_Positions_Short_All', 'NonRept_Positions_Long_All', 'NonRept_Positions_Short_All',
     'Change_in_Open_Interest_All', 'Change_in_Dealer_Long_All', 'Change_in_Dealer_Short_All',
     'Change_in_Dealer_Spread_All', 'Change_in_Asset_Mgr_Long_All', 'Change_in_Asset_Mgr_Short_All',
     'Change_in_Asset_Mgr_Spread_All', 'Change_in_Lev_Money_Long_All', 'Change_in_Lev_Money_Short_All',
     'Change_in_Lev_Money_Spread_All', 'Change_in_Other_Rept_Long_All', 'Change_in_Other_Rept_Short_All',
     'Change_in_Other_Rept_Spread_All', 'Change_in_Tot_Rept_Long_All', 'Change_in_Tot_Rept_Short_All',
     'Change_in_NonRept_Long_All', 'Change_in_NonRept_Short_All', 'Pct_of_Open_Interest_All',
     'Pct_of_OI_Dealer_Long_All', 'Pct_of_OI_Dealer_Short_All', 'Pct_of_OI_Dealer_Spread_All',
     'Pct_of_OI_Asset_Mgr_Long_All', 'Pct_of_OI_Asset_Mgr_Short_All', 'Pct_of_OI_Asset_Mgr_Spread_All',
     'Pct_of_OI_Lev_Money_Long_All', 'Pct_of_OI_Lev_Money_Short_All', 'Pct_of_OI_Lev_Money_Spread_All',
     'Pct_of_OI_Other_Rept_Long_All', 'Pct_of_OI_Other_Rept_Short_All', 'Pct_of_OI_Other_Rept_Spread_All',
     'Pct_of_OI_Tot_Rept_Long_All', 'Pct_of_OI_Tot_Rept_Short_All', 'Pct_of_OI_NonRept_Long_All',
     'Pct_of_OI_NonRept_Short_All', 'Traders_Tot_All', 'Traders_Dealer_Long_All', 'Traders_Dealer_Short_All',
     'Traders_Dealer_Spread_All', 'Traders_Asset_Mgr_Long_All', 'Traders_Asset_Mgr_Short_All',
     'Traders_Asset_Mgr_Spread_All', 'Traders_Lev_Money_Long_All', 'Traders_Lev_Money_Short_All',
     'Traders_Lev_Money_Spread_All', 'Traders_Other_Rept_Long_All', 'Traders_Other_Rept_Short_All',
     'Traders_Other_Rept_Spread_All', 'Traders_Tot_Rept_Long_All', 'Traders_Tot_Rept_Short_All',
     'Conc_Gross_LE_4_TDR_Long_All', 'Conc_Gross_LE_4_TDR_Short_All', 'Conc_Gross_LE_8_TDR_Long_All',
     'Conc_Gross_LE_8_TDR_Short_All', 'Conc_Net_LE_4_TDR_Long_All', 'Conc_Net_LE_4_TDR_Short_All',
     'Conc_Net_LE_8_TDR_Long_All', 'Conc_Net_LE_8_TDR_Short_All', 'Contract_Units', 'CFTC_SubGroup_Code', 'Market',
     'Foo1', 'Foo2', 'FutOnly_or_Combined']

# from file
# f = open('C:/Users/lang/Desktop/FX/FinFut16_1.txt')
# r = csv.reader(f)

# for real

print("Read cot from web, please wait...")
f = requests.get('https://www.cftc.gov/dea/newcot/FinFutWk.txt')
print("Read OK")
d = f.text

f.close()

print("Write file")
f2 = open('FinFutWk.txt', 'w')
lines = d.split('\r\n')
n = len(lines)
for i in range(n):
    if i < (n - 1):
        f2.write(lines[i] + '\n')
    else:
        f2.write(lines[i])

print("Write OK")
f2.close()

f = open('FinFutWk.txt', 'r')
r = csv.reader(f)


n = 0
cots = []
for row in r:
    # print(n, '->', row)
    cot = dict()
    cot['key'] = row[0] + ' ' + row[1]
    for i in range(len(row)):
        row[i] = row[i].lstrip()
        row[i] = row[i].rstrip()
        cot[k[i]] = row[i]
        # print('[', n, ',', i, '] ', '>>', row[i])
    cots.append(cot)
    n += 1

f.close()

# for test
'''
for i in range(len(cots)):
    for k2 in (cots[i].keys()):
        print(i, ':', k2, '->', cots[i][k2])


exit()
'''
# for real

con = sqlite3.connect('C:/rou/db/abc.db')
# con = sqlite3.connect(":memory:")

for i in range(len(cots)):
    keys = ','.join(cots[i].keys())
    question_marks = ','.join(list('?' * len(cots[i])))
    values = tuple(cots[i].values())
    # print('keys(', i, ')=', keys)
    # print('marks(', i, ')=', question_marks)
    # print('values(', i, ')=', values)
    con.execute('INSERT OR REPLACE INTO cot (' + keys + ') VALUES (' + question_marks + ')', values)

con.commit()

'''
con.execute("""
CREATE TABLE cot
(
    key     TEXT PRIMARY KEY,
    Market_and_Exchange_Names TEXT,
    As_of_Date_In_Form_YYMMDD TEXT,
    Report_Date_as_MM_DD_YYYY TEXT,
    CFTC_Contract_Market_Code TEXT,
    CFTC_Market_Code TEXT,
    CFTC_Region_Code TEXT,
    CFTC_Commodity_Code TEXT,
    Open_Interest_All TEXT,
    Dealer_Positions_Long_All TEXT,
    Dealer_Positions_Short_All TEXT,
    Dealer_Positions_Spread_All TEXT,
    Asset_Mgr_Positions_Long_All TEXT,
    Asset_Mgr_Positions_Short_All TEXT,
    Asset_Mgr_Positions_Spread_All TEXT,
    Lev_Money_Positions_Long_All TEXT,
    Lev_Money_Positions_Short_All TEXT,
    Lev_Money_Positions_Spread_All TEXT,
    Other_Rept_Positions_Long_All TEXT,
    Other_Rept_Positions_Short_All TEXT,
    Other_Rept_Positions_Spread_All TEXT,
    Tot_Rept_Positions_Long_All TEXT,
    Tot_Rept_Positions_Short_All TEXT,
    NonRept_Positions_Long_All TEXT,
    NonRept_Positions_Short_All TEXT,
    Change_in_Open_Interest_All TEXT,
    Change_in_Dealer_Long_All TEXT,
    Change_in_Dealer_Short_All TEXT,
    Change_in_Dealer_Spread_All TEXT,
    Change_in_Asset_Mgr_Long_All TEXT,
    Change_in_Asset_Mgr_Short_All TEXT,
    Change_in_Asset_Mgr_Spread_All TEXT,
    Change_in_Lev_Money_Long_All TEXT,
    Change_in_Lev_Money_Short_All TEXT,
    Change_in_Lev_Money_Spread_All TEXT,
    Change_in_Other_Rept_Long_All TEXT,
    Change_in_Other_Rept_Short_All TEXT,
    Change_in_Other_Rept_Spread_All TEXT,
    Change_in_Tot_Rept_Long_All TEXT,
    Change_in_Tot_Rept_Short_All TEXT,
    Change_in_NonRept_Long_All TEXT,
    Change_in_NonRept_Short_All TEXT,
    Pct_of_Open_Interest_All TEXT,
    Pct_of_OI_Dealer_Long_All TEXT,
    Pct_of_OI_Dealer_Short_All TEXT,
    Pct_of_OI_Dealer_Spread_All TEXT,
    Pct_of_OI_Asset_Mgr_Long_All TEXT,
    Pct_of_OI_Asset_Mgr_Short_All TEXT,
    Pct_of_OI_Asset_Mgr_Spread_All TEXT,
    Pct_of_OI_Lev_Money_Long_All TEXT,
    Pct_of_OI_Lev_Money_Short_All TEXT,
    Pct_of_OI_Lev_Money_Spread_All TEXT,
    Pct_of_OI_Other_Rept_Long_All TEXT,
    Pct_of_OI_Other_Rept_Short_All TEXT,
    Pct_of_OI_Other_Rept_Spread_All TEXT,
    Pct_of_OI_Tot_Rept_Long_All TEXT,
    Pct_of_OI_Tot_Rept_Short_All TEXT,
    Pct_of_OI_NonRept_Long_All TEXT,
    Pct_of_OI_NonRept_Short_All TEXT,
    Traders_Tot_All TEXT,
    Traders_Dealer_Long_All TEXT,
    Traders_Dealer_Short_All TEXT,
    Traders_Dealer_Spread_All TEXT,
    Traders_Asset_Mgr_Long_All TEXT,
    Traders_Asset_Mgr_Short_All TEXT,
    Traders_Asset_Mgr_Spread_All TEXT,
    Traders_Lev_Money_Long_All TEXT,
    Traders_Lev_Money_Short_All TEXT,
    Traders_Lev_Money_Spread_All TEXT,
    Traders_Other_Rept_Long_All TEXT,
    Traders_Other_Rept_Short_All TEXT,
    Traders_Other_Rept_Spread_All TEXT,
    Traders_Tot_Rept_Long_All TEXT,
    Traders_Tot_Rept_Short_All TEXT,
    Conc_Gross_LE_4_TDR_Long_All TEXT,
    Conc_Gross_LE_4_TDR_Short_All TEXT,
    Conc_Gross_LE_8_TDR_Long_All TEXT,
    Conc_Gross_LE_8_TDR_Short_All TEXT,
    Conc_Net_LE_4_TDR_Long_All TEXT,
    Conc_Net_LE_4_TDR_Short_All TEXT,
    Conc_Net_LE_8_TDR_Long_All TEXT,
    Conc_Net_LE_8_TDR_Short_All TEXT,
    Contract_Units TEXT,
    CFTC_SubGroup_Code TEXT,
    Market TEXT,
    Foo1 TEXT,
    Foo2 TEXT,
    FutOnly_or_Combined TEXT
);
""")
'''

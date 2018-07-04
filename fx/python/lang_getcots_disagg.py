import csv
import requests
import sqlite3

k = ['Market_and_Exchange_Names','As_of_Date_In_Form_YYMMDD','Report_Date_as_YYYY_MM_DD',
    'CFTC_Contract_Market_Code','CFTC_Market_Code','CFTC_Region_Code','CFTC_Commodity_Code',
    'Open_Interest_All','Prod_Merc_Positions_Long_All','Prod_Merc_Positions_Short_All',
    'Swap_Positions_Long_All','Swap__Positions_Short_All','Swap__Positions_Spread_All',
    'M_Money_Positions_Long_All','M_Money_Positions_Short_All','M_Money_Positions_Spread_All',
    'Other_Rept_Positions_Long_All','Other_Rept_Positions_Short_All','Other_Rept_Positions_Spread_All',
    'Tot_Rept_Positions_Long_All','Tot_Rept_Positions_Short_All','NonRept_Positions_Long_All',
    'NonRept_Positions_Short_All','Open_Interest_Old','Prod_Merc_Positions_Long_Old',
    'Prod_Merc_Positions_Short_Old','Swap_Positions_Long_Old','Swap__Positions_Short_Old',
    'Swap__Positions_Spread_Old','M_Money_Positions_Long_Old','M_Money_Positions_Short_Old',
    'M_Money_Positions_Spread_Old','Other_Rept_Positions_Long_Old','Other_Rept_Positions_Short_Old',
    'Other_Rept_Positions_Spread_Old','Tot_Rept_Positions_Long_Old','Tot_Rept_Positions_Short_Old',
    'NonRept_Positions_Long_Old','NonRept_Positions_Short_Old','Open_Interest_Other',
    'Prod_Merc_Positions_Long_Other','Prod_Merc_Positions_Short_Other','Swap_Positions_Long_Other',
    'Swap__Positions_Short_Other','Swap__Positions_Spread_Other','M_Money_Positions_Long_Other',
    'M_Money_Positions_Short_Other','M_Money_Positions_Spread_Other','Other_Rept_Positions_Long_Other',
    'Other_Rept_Positions_Short_Other','Other_Rept_Positions_Spread_Other','Tot_Rept_Positions_Long_Other',
    'Tot_Rept_Positions_Short_Other','NonRept_Positions_Long_Other','NonRept_Positions_Short_Other',
    'Change_in_Open_Interest_All','Change_in_Prod_Merc_Long_All','Change_in_Prod_Merc_Short_All',
    'Change_in_Swap_Long_All','Change_in_Swap_Short_All','Change_in_Swap_Spread_All',
    'Change_in_M_Money_Long_All','Change_in_M_Money_Short_All','Change_in_M_Money_Spread_All',
    'Change_in_Other_Rept_Long_All','Change_in_Other_Rept_Short_All','Change_in_Other_Rept_Spread_All',
    'Change_in_Tot_Rept_Long_All','Change_in_Tot_Rept_Short_All','Change_in_NonRept_Long_All',
    'Change_in_NonRept_Short_All','Pct_of_Open_Interest_All','Pct_of_OI_Prod_Merc_Long_All',
    'Pct_of_OI_Prod_Merc_Short_All','Pct_of_OI_Swap_Long_All','Pct_of_OI_Swap_Short_All',
    'Pct_of_OI_Swap_Spread_All','Pct_of_OI_M_Money_Long_All','Pct_of_OI_M_Money_Short_All',
    'Pct_of_OI_M_Money_Spread_All','Pct_of_OI_Other_Rept_Long_All','Pct_of_OI_Other_Rept_Short_All',
    'Pct_of_OI_Other_Rept_Spread_All','Pct_of_OI_Tot_Rept_Long_All','Pct_of_OI_Tot_Rept_Short_All',
    'Pct_of_OI_NonRept_Long_All','Pct_of_OI_NonRept_Short_All','Pct_of_Open_Interest_Old',
    'Pct_of_OI_Prod_Merc_Long_Old','Pct_of_OI_Prod_Merc_Short_Old','Pct_of_OI_Swap_Long_Old',
    'Pct_of_OI_Swap_Short_Old','Pct_of_OI_Swap_Spread_Old','Pct_of_OI_M_Money_Long_Old',
    'Pct_of_OI_M_Money_Short_Old','Pct_of_OI_M_Money_Spread_Old','Pct_of_OI_Other_Rept_Long_Old',
    'Pct_of_OI_Other_Rept_Short_Old','Pct_of_OI_Other_Rept_Spread_Old','Pct_of_OI_Tot_Rept_Long_Old',
    'Pct_of_OI_Tot_Rept_Short_Old','Pct_of_OI_NonRept_Long_Old','Pct_of_OI_NonRept_Short_Old',
    'Pct_of_Open_Interest_Other','Pct_of_OI_Prod_Merc_Long_Other','Pct_of_OI_Prod_Merc_Short_Other',
    'Pct_of_OI_Swap_Long_Other','Pct_of_OI_Swap_Short_Other','Pct_of_OI_Swap_Spread_Other',
    'Pct_of_OI_M_Money_Long_Other','Pct_of_OI_M_Money_Short_Other','Pct_of_OI_M_Money_Spread_Other',
    'Pct_of_OI_Other_Rept_Long_Other','Pct_of_OI_Other_Rept_Short_Other','Pct_of_OI_Other_Rept_Spread_Other',
    'Pct_of_OI_Tot_Rept_Long_Other','Pct_of_OI_Tot_Rept_Short_Other','Pct_of_OI_NonRept_Long_Other',
    'Pct_of_OI_NonRept_Short_Other','Traders_Tot_All','Traders_Prod_Merc_Long_All',
    'Traders_Prod_Merc_Short_All','Traders_Swap_Long_All','Traders_Swap_Short_All','Traders_Swap_Spread_All',
    'Traders_M_Money_Long_All','Traders_M_Money_Short_All','Traders_M_Money_Spread_All',
    'Traders_Other_Rept_Long_All','Traders_Other_Rept_Short_All','Traders_Other_Rept_Spread_All',
    'Traders_Tot_Rept_Long_All','Traders_Tot_Rept_Short_All','Traders_Tot_Old','Traders_Prod_Merc_Long_Old',
    'Traders_Prod_Merc_Short_Old','Traders_Swap_Long_Old','Traders_Swap_Short_Old','Traders_Swap_Spread_Old',
    'Traders_M_Money_Long_Old','Traders_M_Money_Short_Old','Traders_M_Money_Spread_Old',
    'Traders_Other_Rept_Long_Old','Traders_Other_Rept_Short_Old','Traders_Other_Rept_Spread_Old',
    'Traders_Tot_Rept_Long_Old','Traders_Tot_Rept_Short_Old','Traders_Tot_Other',
    'Traders_Prod_Merc_Long_Other','Traders_Prod_Merc_Short_Other','Traders_Swap_Long_Other',
    'Traders_Swap_Short_Other','Traders_Swap_Spread_Other','Traders_M_Money_Long_Other',
    'Traders_M_Money_Short_Other','Traders_M_Money_Spread_Other','Traders_Other_Rept_Long_Other',
    'Traders_Other_Rept_Short_Other','Traders_Other_Rept_Spread_Other','Traders_Tot_Rept_Long_Other',
    'Traders_Tot_Rept_Short_Other','Conc_Gross_LE_4_TDR_Long_All','Conc_Gross_LE_4_TDR_Short_All',
    'Conc_Gross_LE_8_TDR_Long_All','Conc_Gross_LE_8_TDR_Short_All','Conc_Net_LE_4_TDR_Long_All',
    'Conc_Net_LE_4_TDR_Short_All','Conc_Net_LE_8_TDR_Long_All','Conc_Net_LE_8_TDR_Short_All',
    'Conc_Gross_LE_4_TDR_Long_Old','Conc_Gross_LE_4_TDR_Short_Old','Conc_Gross_LE_8_TDR_Long_Old',
    'Conc_Gross_LE_8_TDR_Short_Old','Conc_Net_LE_4_TDR_Long_Old','Conc_Net_LE_4_TDR_Short_Old',
    'Conc_Net_LE_8_TDR_Long_Old','Conc_Net_LE_8_TDR_Short_Old','Conc_Gross_LE_4_TDR_Long_Other',
    'Conc_Gross_LE_4_TDR_Short_Other','Conc_Gross_LE_8_TDR_Long_Other','Conc_Gross_LE_8_TDR_Short_Other',
    'Conc_Net_LE_4_TDR_Long_Other','Conc_Net_LE_4_TDR_Short_Other','Conc_Net_LE_8_TDR_Long_Other',
    'Conc_Net_LE_8_TDR_Short_Other','Contract_Units','CFTC_Contract_Market_Code_Quotes',
    'CFTC_Market_Code_Quotes','CFTC_Commodity_Code_Quotes','CFTC_SubGroup_Code','FutOnly_or_Combined']

# from file
# f = open('D:/rou/sync/workspace/fx/python/f_year.txt')
# r = csv.reader(f)

# for real

print("Read disagg from web, please wait...")
f = requests.get('https://www.cftc.gov/dea/newcot/f_disagg.txt')
print("Read OK")
d = f.text

f.close()

print("Write file")
f2 = open('f_disagg.txt', 'w')
lines = d.split('\r\n')
n = len(lines)
for i in range(n):
    if i < (n - 1):
        f2.write(lines[i] + '\n')
    else:
        f2.write(lines[i])

print("Write OK")
f2.close()

f = open('f_disagg.txt', 'r')
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
    con.execute('INSERT OR REPLACE INTO disagg (' + keys + ') VALUES (' + question_marks + ')', values)

con.commit()

'''
con.execute("""
CREATE TABLE [disagg](
  [key] TEXT PRIMARY KEY, 
  [Market_and_Exchange_Names] TEXT, 
  [As_of_Date_In_Form_YYMMDD] TEXT, 
  [Report_Date_as_YYYY_MM_DD] TEXT, 
  [CFTC_Contract_Market_Code] TEXT, 
  [CFTC_Market_Code] TEXT, 
  [CFTC_Region_Code] TEXT, 
  [CFTC_Commodity_Code] TEXT, 
  [Open_Interest_All] TEXT, 
  [Prod_Merc_Positions_Long_All] TEXT, 
  [Prod_Merc_Positions_Short_All] TEXT, 
  [Swap_Positions_Long_All] TEXT, 
  [Swap__Positions_Short_All] TEXT, 
  [Swap__Positions_Spread_All] TEXT, 
  [M_Money_Positions_Long_All] TEXT, 
  [M_Money_Positions_Short_All] TEXT, 
  [M_Money_Positions_Spread_All] TEXT, 
  [Other_Rept_Positions_Long_All] TEXT, 
  [Other_Rept_Positions_Short_All] TEXT, 
  [Other_Rept_Positions_Spread_All] TEXT, 
  [Tot_Rept_Positions_Long_All] TEXT, 
  [Tot_Rept_Positions_Short_All] TEXT, 
  [NonRept_Positions_Long_All] TEXT, 
  [NonRept_Positions_Short_All] TEXT, 
  [Open_Interest_Old] TEXT, 
  [Prod_Merc_Positions_Long_Old] TEXT, 
  [Prod_Merc_Positions_Short_Old] TEXT, 
  [Swap_Positions_Long_Old] TEXT, 
  [Swap__Positions_Short_Old] TEXT, 
  [Swap__Positions_Spread_Old] TEXT, 
  [M_Money_Positions_Long_Old] TEXT, 
  [M_Money_Positions_Short_Old] TEXT, 
  [M_Money_Positions_Spread_Old] TEXT, 
  [Other_Rept_Positions_Long_Old] TEXT, 
  [Other_Rept_Positions_Short_Old] TEXT, 
  [Other_Rept_Positions_Spread_Old] TEXT, 
  [Tot_Rept_Positions_Long_Old] TEXT, 
  [Tot_Rept_Positions_Short_Old] TEXT, 
  [NonRept_Positions_Long_Old] TEXT, 
  [NonRept_Positions_Short_Old] TEXT, 
  [Open_Interest_Other] TEXT, 
  [Prod_Merc_Positions_Long_Other] TEXT, 
  [Prod_Merc_Positions_Short_Other] TEXT, 
  [Swap_Positions_Long_Other] TEXT, 
  [Swap__Positions_Short_Other] TEXT, 
  [Swap__Positions_Spread_Other] TEXT, 
  [M_Money_Positions_Long_Other] TEXT, 
  [M_Money_Positions_Short_Other] TEXT, 
  [M_Money_Positions_Spread_Other] TEXT, 
  [Other_Rept_Positions_Long_Other] TEXT, 
  [Other_Rept_Positions_Short_Other] TEXT, 
  [Other_Rept_Positions_Spread_Other] TEXT, 
  [Tot_Rept_Positions_Long_Other] TEXT, 
  [Tot_Rept_Positions_Short_Other] TEXT, 
  [NonRept_Positions_Long_Other] TEXT, 
  [NonRept_Positions_Short_Other] TEXT, 
  [Change_in_Open_Interest_All] TEXT, 
  [Change_in_Prod_Merc_Long_All] TEXT, 
  [Change_in_Prod_Merc_Short_All] TEXT, 
  [Change_in_Swap_Long_All] TEXT, 
  [Change_in_Swap_Short_All] TEXT, 
  [Change_in_Swap_Spread_All] TEXT, 
  [Change_in_M_Money_Long_All] TEXT, 
  [Change_in_M_Money_Short_All] TEXT, 
  [Change_in_M_Money_Spread_All] TEXT, 
  [Change_in_Other_Rept_Long_All] TEXT, 
  [Change_in_Other_Rept_Short_All] TEXT, 
  [Change_in_Other_Rept_Spread_All] TEXT, 
  [Change_in_Tot_Rept_Long_All] TEXT, 
  [Change_in_Tot_Rept_Short_All] TEXT, 
  [Change_in_NonRept_Long_All] TEXT, 
  [Change_in_NonRept_Short_All] TEXT, 
  [Pct_of_Open_Interest_All] TEXT, 
  [Pct_of_OI_Prod_Merc_Long_All] TEXT, 
  [Pct_of_OI_Prod_Merc_Short_All] TEXT, 
  [Pct_of_OI_Swap_Long_All] TEXT, 
  [Pct_of_OI_Swap_Short_All] TEXT, 
  [Pct_of_OI_Swap_Spread_All] TEXT, 
  [Pct_of_OI_M_Money_Long_All] TEXT, 
  [Pct_of_OI_M_Money_Short_All] TEXT, 
  [Pct_of_OI_M_Money_Spread_All] TEXT, 
  [Pct_of_OI_Other_Rept_Long_All] TEXT, 
  [Pct_of_OI_Other_Rept_Short_All] TEXT, 
  [Pct_of_OI_Other_Rept_Spread_All] TEXT, 
  [Pct_of_OI_Tot_Rept_Long_All] TEXT, 
  [Pct_of_OI_Tot_Rept_Short_All] TEXT, 
  [Pct_of_OI_NonRept_Long_All] TEXT, 
  [Pct_of_OI_NonRept_Short_All] TEXT, 
  [Pct_of_Open_Interest_Old] TEXT, 
  [Pct_of_OI_Prod_Merc_Long_Old] TEXT, 
  [Pct_of_OI_Prod_Merc_Short_Old] TEXT, 
  [Pct_of_OI_Swap_Long_Old] TEXT, 
  [Pct_of_OI_Swap_Short_Old] TEXT, 
  [Pct_of_OI_Swap_Spread_Old] TEXT, 
  [Pct_of_OI_M_Money_Long_Old] TEXT, 
  [Pct_of_OI_M_Money_Short_Old] TEXT, 
  [Pct_of_OI_M_Money_Spread_Old] TEXT, 
  [Pct_of_OI_Other_Rept_Long_Old] TEXT, 
  [Pct_of_OI_Other_Rept_Short_Old] TEXT, 
  [Pct_of_OI_Other_Rept_Spread_Old] TEXT, 
  [Pct_of_OI_Tot_Rept_Long_Old] TEXT, 
  [Pct_of_OI_Tot_Rept_Short_Old] TEXT, 
  [Pct_of_OI_NonRept_Long_Old] TEXT, 
  [Pct_of_OI_NonRept_Short_Old] TEXT, 
  [Pct_of_Open_Interest_Other] TEXT, 
  [Pct_of_OI_Prod_Merc_Long_Other] TEXT, 
  [Pct_of_OI_Prod_Merc_Short_Other] TEXT, 
  [Pct_of_OI_Swap_Long_Other] TEXT, 
  [Pct_of_OI_Swap_Short_Other] TEXT, 
  [Pct_of_OI_Swap_Spread_Other] TEXT, 
  [Pct_of_OI_M_Money_Long_Other] TEXT, 
  [Pct_of_OI_M_Money_Short_Other] TEXT, 
  [Pct_of_OI_M_Money_Spread_Other] TEXT, 
  [Pct_of_OI_Other_Rept_Long_Other] TEXT, 
  [Pct_of_OI_Other_Rept_Short_Other] TEXT, 
  [Pct_of_OI_Other_Rept_Spread_Other] TEXT, 
  [Pct_of_OI_Tot_Rept_Long_Other] TEXT, 
  [Pct_of_OI_Tot_Rept_Short_Other] TEXT, 
  [Pct_of_OI_NonRept_Long_Other] TEXT, 
  [Pct_of_OI_NonRept_Short_Other] TEXT, 
  [Traders_Tot_All] TEXT, 
  [Traders_Prod_Merc_Long_All] TEXT, 
  [Traders_Prod_Merc_Short_All] TEXT, 
  [Traders_Swap_Long_All] TEXT, 
  [Traders_Swap_Short_All] TEXT, 
  [Traders_Swap_Spread_All] TEXT, 
  [Traders_M_Money_Long_All] TEXT, 
  [Traders_M_Money_Short_All] TEXT, 
  [Traders_M_Money_Spread_All] TEXT, 
  [Traders_Other_Rept_Long_All] TEXT, 
  [Traders_Other_Rept_Short_All] TEXT, 
  [Traders_Other_Rept_Spread_All] TEXT, 
  [Traders_Tot_Rept_Long_All] TEXT, 
  [Traders_Tot_Rept_Short_All] TEXT, 
  [Traders_Tot_Old] TEXT, 
  [Traders_Prod_Merc_Long_Old] TEXT, 
  [Traders_Prod_Merc_Short_Old] TEXT, 
  [Traders_Swap_Long_Old] TEXT, 
  [Traders_Swap_Short_Old] TEXT, 
  [Traders_Swap_Spread_Old] TEXT, 
  [Traders_M_Money_Long_Old] TEXT, 
  [Traders_M_Money_Short_Old] TEXT, 
  [Traders_M_Money_Spread_Old] TEXT, 
  [Traders_Other_Rept_Long_Old] TEXT, 
  [Traders_Other_Rept_Short_Old] TEXT, 
  [Traders_Other_Rept_Spread_Old] TEXT, 
  [Traders_Tot_Rept_Long_Old] TEXT, 
  [Traders_Tot_Rept_Short_Old] TEXT, 
  [Traders_Tot_Other] TEXT, 
  [Traders_Prod_Merc_Long_Other] TEXT, 
  [Traders_Prod_Merc_Short_Other] TEXT, 
  [Traders_Swap_Long_Other] TEXT, 
  [Traders_Swap_Short_Other] TEXT, 
  [Traders_Swap_Spread_Other] TEXT, 
  [Traders_M_Money_Long_Other] TEXT, 
  [Traders_M_Money_Short_Other] TEXT, 
  [Traders_M_Money_Spread_Other] TEXT, 
  [Traders_Other_Rept_Long_Other] TEXT, 
  [Traders_Other_Rept_Short_Other] TEXT, 
  [Traders_Other_Rept_Spread_Other] TEXT, 
  [Traders_Tot_Rept_Long_Other] TEXT, 
  [Traders_Tot_Rept_Short_Other] TEXT, 
  [Conc_Gross_LE_4_TDR_Long_All] TEXT, 
  [Conc_Gross_LE_4_TDR_Short_All] TEXT, 
  [Conc_Gross_LE_8_TDR_Long_All] TEXT, 
  [Conc_Gross_LE_8_TDR_Short_All] TEXT, 
  [Conc_Net_LE_4_TDR_Long_All] TEXT, 
  [Conc_Net_LE_4_TDR_Short_All] TEXT, 
  [Conc_Net_LE_8_TDR_Long_All] TEXT, 
  [Conc_Net_LE_8_TDR_Short_All] TEXT, 
  [Conc_Gross_LE_4_TDR_Long_Old] TEXT, 
  [Conc_Gross_LE_4_TDR_Short_Old] TEXT, 
  [Conc_Gross_LE_8_TDR_Long_Old] TEXT, 
  [Conc_Gross_LE_8_TDR_Short_Old] TEXT, 
  [Conc_Net_LE_4_TDR_Long_Old] TEXT, 
  [Conc_Net_LE_4_TDR_Short_Old] TEXT, 
  [Conc_Net_LE_8_TDR_Long_Old] TEXT, 
  [Conc_Net_LE_8_TDR_Short_Old] TEXT, 
  [Conc_Gross_LE_4_TDR_Long_Other] TEXT, 
  [Conc_Gross_LE_4_TDR_Short_Other] TEXT, 
  [Conc_Gross_LE_8_TDR_Long_Other] TEXT, 
  [Conc_Gross_LE_8_TDR_Short_Other] TEXT, 
  [Conc_Net_LE_4_TDR_Long_Other] TEXT, 
  [Conc_Net_LE_4_TDR_Short_Other] TEXT, 
  [Conc_Net_LE_8_TDR_Long_Other] TEXT, 
  [Conc_Net_LE_8_TDR_Short_Other] TEXT, 
  [Contract_Units] TEXT, 
  [CFTC_Contract_Market_Code_Quotes] TEXT, 
  [CFTC_Market_Code_Quotes] TEXT, 
  [CFTC_Commodity_Code_Quotes] TEXT, 
  [CFTC_SubGroup_Code] TEXT, 
  [FutOnly_or_Combined] TEXT
);
""")
'''


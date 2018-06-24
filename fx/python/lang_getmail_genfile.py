from imapclient import IMAPClient
from pyzmail import PyzMessage
from smtplib import SMTP_SSL
from email.mime.text import MIMEText
from email.header import Header
from pprint import pprint

curs = ['USD', 'EUR', 'JPY', 'AUD', 'NZD', 'CAD', 'GBP', 'CHF']

clt_dev = '50CA3DFB510CC5A8F28B48D1BF2A5702'
clt_test = '2010C2441A263399B34F537D91A53AC9'
clt_real = 'BB190E062770E27C3E79391AB0D1A117'

imapserver = 'imap.163.com'
account = 'roulang_2018@163.com'
pwd = 'tel648'

imapObj = IMAPClient(imapserver, ssl=True)
imapObj.login(account, pwd)
imapObj.select_folder('INBOX', readonly=False)
UIDs = imapObj.search(['UNSEEN'])
UIDs.sort()
# pprint(UIDs)
rawMessages = imapObj.fetch(UIDs, ['BODY[]'])

msgs = []
for uid in UIDs:
    msg = dict()
    raw = PyzMessage.factory(rawMessages[uid][b'BODY[]'])
    msg['from'] = raw.get_address('from')[1]
    msg['subject'] = raw.get_subject()
    if raw.text_part is not None:
        msg1 = raw.text_part.get_payload().decode(raw.text_part.charset)
        msg['body'] = msg1[0]
    elif raw.html_part is not None:
        msg['body'] = raw.html_part.get_payload().decode(raw.html_part.charset)
    msgs.append(msg)

imapObj.logout()

# test
pprint(msgs)


smtpserver = 'smtp.163.com:465'
sender = 'roulang_2018@163.com'
receiver = 'roulang_2008@sina.com'

smtpObj = SMTP_SSL(smtpserver)
smtpObj.login(account, pwd)

pt = 'C:/Users/lang/AppData/Roaming/MetaQuotes/Terminal/' + clt_test + '/MQL4/Files/'
pt2 = 'C:/Users/lang/AppData/Roaming/MetaQuotes/Terminal/' + clt_real + '/MQL4/Files/'
for msg in msgs:
    cur = msg['subject'].upper()
    cur1 = cur[0:3]
    cur2 = cur[3:6]
    if ((cur1 not in curs) or (cur2 not in curs)):
    	continue
    com = msg['body']

    fn = pt + 'lang_' + cur
    f = open(fn, 'w', newline='')
    f.write(com)
    f.close()
    fn2 = pt2 + 'lang_' + cur
    f2 = open(fn2, 'w', newline='')
    f2.write(com)
    f2.close()

    sub = cur + ' is set to ' + com
    rep = MIMEText('')
    rep['Subject'] = Header(sub)
    rep['From'] = sender
    rep['To'] = receiver
    smtpObj.sendmail(sender, receiver, rep.as_string())

smtpObj.quit()

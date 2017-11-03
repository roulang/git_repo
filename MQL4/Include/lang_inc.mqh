//+------------------------------------------------------------------+
//|                                                         lang.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <stderror.mqh> 
#include <stdlib.mqh> 

//currency
#define EURUSD "EURUSD"
#define USDJPY "USDJPY"
#define AUDUSD "AUDUSD"
#define NZDUSD "NZDUSD"
#define USDCAD "USDCAD"
#define GBPUSD "GBPUSD"
#define USDCHF "USDCHF"
#define XAUUSD "XAUUSD"
#define GOLD   "GOLD"      //for FxPro
#define GBPJPY "GBPJPY"

#define SLASH  "/"
#define DOT    "."

//datetime
#define SEC_H1 3600

#define MAX_INT 2147483647

#define SEC_D1 86400

//each time period (GMT)
const string us1="13:00";  //usa
const string ue2="21:00";  //usa
const string as1="00:00";  //asia
const string ae2="08:00";  //asia
const string gs1="07:00";  //europe
const string ge2="15:00";  //europe
const  int ASIA_PD = 1;
const  int AMA_PD = 4;
const  int EUR_PD = 2;

int      LossStopPt = 150;
int      ProfitStopPt = 300;
int      OOPt = 100;

//struct
struct s_News
{ 
   double n;         //index
   string cur;       //currency 
   datetime dt;      //date
   double for_rate;  //rate change (0:not rate,1:is rate)
}; 

struct s_Order
{
   int      tic;        //ticket
   string   sym;        //symbol
   int      type;       //buy or sell
   double   lots;       //
   double   open_p;     //open price
   datetime open_t;     //open time
   double   sl_p;       //stop loss price
   double   tp_p;       //take profit price
   double   profit;     //profit
   double   close_p;    //close price
   datetime close_t;    //close time
   string   com;        //comment   
   int      mag;        //magic number
};

//input
input bool     i_for_test=false;

//global
bool           g_debug=false;
bool           g_sendmail=false;

//global
const string   g_LockFileName="#Lock#";
const string   g_OrderHisFileName="lang_history_orders.csv";            //history order data file
const string   g_OrderHisFileName_all="lang_history_orders_all.csv";    //history order data file(all)
const string   g_OrderSendFileName="lang_send_orders.csv";              //order data file
const string   g_NewsFileName="lang_news.ex4.csv";

datetime CurrentTimeStamp;
int      g_LockFileH=0;          //lock file handle
s_News   g_News[];
int      g_TimerSecond=SEC_H1*1;
int      g_news_bef=SEC_H1*2;     //2 hr before news
int      g_news_aft=SEC_H1*2;     //2 hr after news
int      g_srv_tz_offset=24;
int      g_server_timezone_offset=3;

//+------------------------------------------------------------------+
// isNewBar: check new bar
// ret:  0, no new bar
//       1, new bar, barshift=1
//+------------------------------------------------------------------+
int isNewBar()
{
   if (CurrentTimeStamp != Time[0]) {
      CurrentTimeStamp = Time[0];
      return 1;
   } else {
      return 0;
   }
}

int delAllObj()
{
   int obj_total=ObjectsTotal();
   PrintFormat("Total %d objects",obj_total);
   for(int i=obj_total-1;i>=0;i--) {
      string name=ObjectName(i);
      PrintFormat("object %d: %s",i,name);
      ObjectDelete(name);
   }
   return(obj_total);
}

bool mailNoticeOrderOpen(int arg_tic,string arg_sym,int arg_type,double arg_lots,double arg_p,double arg_sl,double arg_tp,string arg_com,int arg_mag)
{
/*
         int tic=OrderTicket();
         datetime tm1=OrderOpenTime();
         string tp=getOrderTp(OrderType());
         double lots=OrderLots();
         string sym=OrderSymbol();
         string p1=dToStr(sym,OrderOpenPrice());
         string sl_p=dToStr(sym,OrderStopLoss());
         string tp_p=dToStr(sym,OrderTakeProfit());
         datetime tm2=OrderCloseTime();
         string p2=dToStr(sym,OrderClosePrice());
         double pt=OrderProfit();
         string co=OrderComment();
         int mg=OrderMagicNumber();
*/
   if (!g_sendmail) return true;
   
   string EmailSubject=StringConcatenate("[",arg_sym,"]",getOrderTp(arg_type)," order(#",arg_tic,"#)(",arg_lots," lots) placed");
   double sl_pt=0,tp_pt=0;
   double vpoint=MarketInfo(arg_sym,MODE_POINT);
   if (arg_sl != 0) sl_pt=NormalizeDouble((arg_p-arg_sl)/vpoint,0);
   if (arg_tp != 0) tp_pt=NormalizeDouble((arg_p-arg_tp)/vpoint,0);
   
   string EmailBody=StringConcatenate(EmailSubject," at ",dToStr(NULL,arg_p),", lose stop at ",dToStr(NULL,arg_sl),"(",sl_pt,"pt), profit stop at ",dToStr(NULL,arg_tp),"(",tp_pt,"pt), ",arg_com,"(",arg_mag,").");
   // Sample output: "EURUSD Buy order(#1233456#)(0.1 lots) placed at 1.4545, lose stop at 1.4545(-200), profit stop at 1.4545(+200), tt stg(12345)."
   
   ResetLastError();
   if (!SendMail(EmailSubject,EmailBody)) {
      return false;
   }

   return true;

}

bool mailNoticeOrderMod(int arg_tic,string arg_sym,int arg_type,double arg_p,double arg_sl,double arg_tp)
{
/*
         int tic=OrderTicket();
         datetime tm1=OrderOpenTime();
         string tp=getOrderTp(OrderType());
         double lots=OrderLots();
         string sym=OrderSymbol();
         string p1=dToStr(sym,OrderOpenPrice());
         string sl_p=dToStr(sym,OrderStopLoss());
         string tp_p=dToStr(sym,OrderTakeProfit());
         datetime tm2=OrderCloseTime();
         string p2=dToStr(sym,OrderClosePrice());
         double pt=OrderProfit();
         string co=OrderComment();
         int mg=OrderMagicNumber();
*/
   if (!g_sendmail) return true;
   
   string EmailSubject=StringConcatenate("[",arg_sym,"]",getOrderTp(arg_type)," order(#",arg_tic,"#) modified");
   double sl_pt=0,tp_pt=0;
   double vpoint=MarketInfo(arg_sym,MODE_POINT);
   if (arg_sl != 0) sl_pt=NormalizeDouble((arg_p-arg_sl)/vpoint,0);
   if (arg_tp != 0) tp_pt=NormalizeDouble((arg_p-arg_tp)/vpoint,0);
   
   string EmailBody=StringConcatenate(EmailSubject," at ",dToStr(NULL,arg_p),", lose stop at ",dToStr(NULL,arg_sl),"(",sl_pt,"pt), profit stop at ",dToStr(NULL,arg_tp),"(",tp_pt,"pt).");
   // Sample output: "EURUSD Buy order(#1233456#)(0.1 lots) placed at 1.4545, lose stop at 1.4545(-200), profit stop at 1.4545(+200)."
   
   ResetLastError();
   if (!SendMail(EmailSubject,EmailBody)) {
      Print("Operation SendMail failed, error: ",GetLastError());
      return false;
   }

   return true;

}

string getOrderTp(int arg_type)
{
   /*
   OP_BUY - buy order,
   OP_SELL - sell order,
   OP_BUYLIMIT - buy limit pending order,
   OP_BUYSTOP - buy stop pending order,
   OP_SELLLIMIT - sell limit pending order,
   OP_SELLSTOP - sell stop pending order.
   */
   
   switch (arg_type) {
      case OP_BUY:
         return "Buy";
      case OP_SELL:
         return "Sell";
      case OP_BUYLIMIT:
         return "BuyLimit";
      case OP_BUYSTOP:
         return "BuyStop";
      case OP_SELLLIMIT:
         return "SellLimit";
      case OP_SELLSTOP:
         return "SellStop";
      default:
         return "N/A";
   }
   
}

string dToStr(string arg_sym,double arg_value,int arg_digits=0)
{
   if (arg_value==0) return "0";
   if (arg_digits>0) return DoubleToStr(arg_value,arg_digits);
   
   string cur;
   if (arg_sym==NULL) cur=Symbol();
   else cur=arg_sym;
   
   int vdigits = (int)MarketInfo(cur,MODE_DIGITS);
   return DoubleToStr(arg_value,vdigits);
}

int writeOrderHistoryToFile(int arg_wrt_all=0)
{

   int orderTickets[];
   string file_name;
   if (arg_wrt_all==0) {
      file_name=g_OrderHisFileName;
   } else {
      file_name=g_OrderHisFileName_all;
   }
   int h=FileOpen(file_name,FILE_CSV|FILE_SHARE_READ,',');
   if(h==INVALID_HANDLE) {
      Print("Operation FileOpen failed, error: ",GetLastError());
      return 0;
   }
   
   int ln=getFileLine(h);
   if (ln<1) return 0;
   if (ln>1) ArrayResize(orderTickets,ln-1);  //skip head line
   else ArrayResize(orderTickets,1);

   int cur_tics_n=0;
   if (ln>1) {    //have order record
      cur_tics_n=rdOrderTicketsFromFile(h,orderTickets);
      ArraySort(orderTickets);
   } else {       //not have any record
      orderTickets[0]=0;
   }
   FileClose(h);
   
   ResetLastError();
   int cnt=OrdersHistoryTotal();
   if (cnt<=0) {
      Print("Operation OrdersTotal failed, error: ",GetLastError());
      return 0;
   }
   
   Print("write history order file");
   ResetLastError();
   h=FileOpen(file_name,FILE_READ|FILE_WRITE|FILE_CSV,',');
   if(h==INVALID_HANDLE) {
      Print("Operation FileOpen failed, error: ",GetLastError());
      return 0;
   }
   
   ResetLastError();
   //move to file end to add order record
   if (!FileSeek(h,0,SEEK_END)) {
      Print("Operation FileSeek failed, error: ",GetLastError());
      FileClose(h);
      return 0;
   }
   
   /*
   //write header
   ResetLastError();
   if (!FileWrite(h,"0","order","open time","type#","type","size","symbol","open price","S/L","T/P","close time","close price","profit","comment","magic")) {
      Print("Operation FileWrite failed, error: ",GetLastError());
      FileClose(h);
      return;
   }
   */
   
   int n=0;
   for(int i=0;i<cnt;i++) {
      ResetLastError();
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) {
         /* 17
         OrderClosePrice(), ok
         OrderCloseTime(), ok
         OrderComment(), ok
         OrderCommission(), 
         OrderExpiration(), 
         OrderLots(), ok
         OrderMagicNumber(), ok
         OrderOpenPrice(), ok
         OrderOpenTime(), ok
         OrderPrint(), 
         OrderProfit(), ok
         OrderStopLoss(), ok
         OrderSwap(), 
         OrderSymbol(), ok
         OrderTakeProfit(), ok
         OrderTicket(), ok
         OrderType(), ok
         */
         s_Order order;
         order.type=OrderType();
         //modified at 20170921
         if (arg_wrt_all==0) {
            if (order.type!=OP_BUY && order.type!=OP_SELL) continue;   //skip pending cancel order
         }
         order.tic=OrderTicket();
         int t=ArrayBsearch(orderTickets,order.tic);
         if (orderTickets[t]==order.tic) continue;  //found order exists in the file, skip.
         n++;
         order.open_t=OrderOpenTime();
         order.lots=OrderLots();
         order.sym=OrderSymbol();
         order.open_p=OrderOpenPrice();
         order.sl_p=OrderStopLoss();
         order.tp_p=OrderTakeProfit();
         order.close_t=OrderCloseTime();
         order.close_p=OrderClosePrice();
         order.profit=OrderProfit();
         order.com=OrderComment();
         order.mag=OrderMagicNumber();
         
         ResetLastError();
         //write file
         if (!wrtOneOrderToFile(h,n+cur_tics_n,order)) {
            Print("Operation FileWrite failed, error: ",GetLastError());
            FileClose(h);
            return 0;
         }
      } else {
         Print("Operation OrderSelect failed, error: ",GetLastError());
      }
   }
   
   FileClose(h);
   
   return n;
   
}

//+------------------------------------------------------------------+
//|"0","order","open time","type#","type","size","symbol","open price","S/L","T/P","close time","close price","profit","comment","magic"
//+------------------------------------------------------------------+
bool wrtOneOrderToFile(int h, int n, s_Order &order)
{
   string tp=getOrderTp(order.type);
   string p1=dToStr(order.sym,order.open_p);
   string sl_p=dToStr(order.sym,order.sl_p);
   string tp_p=dToStr(order.sym,order.tp_p);
   string p2=dToStr(order.sym,order.close_p);
   string lots=dToStr(NULL,order.lots,2);
   string o_t=covDateString(TimeToString(order.open_t),SLASH);
   string c_t=covDateString(TimeToString(order.close_t),SLASH);
   //Print("1=",tic,",2=",tm1,",3=",tp,",4=",lots,",5=",sym);
   //Print("6=",p1,",7=",sl_p,",8=",tp_p,",9=",tm2,",10=",p2);
   //Print("11=",pt,",12=",co,",13=",mg);
   
   //"0","order","open time","type#","type","size","symbol","open price","S/L","T/P","close time","close price","profit","comment","magic"
   //uint ret=FileWrite(h,n,order.tic,order.open_t,order.type,tp,lots,order.sym,p1,sl_p,tp_p,order.close_t,p2,order.profit,order.com,order.mag);
   uint ret=FileWrite(h,n,order.tic,o_t,order.type,tp,lots,order.sym,p1,sl_p,tp_p,c_t,p2,order.profit,order.com,order.mag);
   
   if (ret>0) return true;
   else return false; 
}

//+------------------------------------------------------------------+
//|"0","order","open time","type#","type","size","symbol","open price","S/L","T/P","close time","close price","profit","comment","magic"
//+------------------------------------------------------------------+
bool rdOneOrderFromFile(int h, s_Order &order)
{
   double n=FileReadNumber(h);
   if (n==0) rdSkipOneLineFromFile(h);
   while(!FileIsEnding(h) && !FileIsLineEnding(h)) {
      order.tic=(int)FileReadNumber(h);
      //order.open_t=FileReadDatetime(h);
      order.open_t=StringToTime(covDateString(FileReadString(h),DOT));
      order.type=(int)FileReadNumber(h);
      //skip one
      string dummy=FileReadString(h);
      order.lots=FileReadNumber(h);
      order.sym=FileReadString(h);
      order.open_p=FileReadNumber(h);
      order.sl_p=FileReadNumber(h);
      order.tp_p=FileReadNumber(h);
      //order.close_t=FileReadDatetime(h);
      order.close_t=StringToTime(covDateString(FileReadString(h),DOT));
      order.close_p=FileReadNumber(h);
      order.profit=FileReadNumber(h);
      order.com=FileReadString(h);
      order.mag=(int)FileReadNumber(h);
   }
   
   return true;
}

int rdOrderTicketsFromFile(int h, int &tics[])
{
   if (!FileSeek(h,0,SEEK_SET)) return 0;

   int n=0;
   n=(int)FileReadNumber(h);
   if (n==0) rdSkipOneLineFromFile(h);
   
   int cnt=0;
   while(!FileIsEnding(h)) {
      n=(int)FileReadNumber(h);
      tics[cnt]=(int)FileReadNumber(h);
      rdSkipOneLineFromFile(h);
      cnt++;
   }
   
   return cnt;
}

void rdSkipOneLineFromFile(int h)
{
   while(!FileIsLineEnding(h)) {
      //Print(FileReadString(h));
      FileReadString(h);  //skip item
   }
}

int getFileLine(int h)
{
   //store current pos
   ulong p=FileTell(h);
   
   //move file to head
   if (!FileSeek(h,0,SEEK_SET)) return 0;
   
   int cnt=0;
   while(!FileIsEnding(h)) {
      string s;
      s=FileReadString(h);
      rdSkipOneLineFromFile(h);
      cnt++;
   }
   
   //restore current pos
   FileSeek(h,p,SEEK_SET);
   
   return cnt;
}

bool getFileLock()
{
   ResetLastError();
   int h=FileOpen(g_LockFileName,FILE_WRITE|FILE_BIN,',');  //try to open file to get a lock
   if(h==INVALID_HANDLE) {
      //Print("Operation FileOpen failed, error: ",GetLastError());
      return false;
   }
   g_LockFileH=h;
   return true;
}

void releaseFileLock()
{
   if (g_LockFileH==0) return;
   FileClose(g_LockFileH);
   g_LockFileH=0;
   
   ResetLastError();
   if (!FileDelete(g_LockFileName)) {
      Print("Operation FileDelete failed, error: ",GetLastError());
   }
}

int news_read()
{
   int cnt=0;
   int time_offset=getClientServerOffset();
   Print("time_offset=",time_offset);
   int h=FileOpen(g_NewsFileName,FILE_CSV|FILE_SHARE_READ,',');
   if(h!=INVALID_HANDLE) {
      //read record count
      while(!FileIsEnding(h)) {
         string s;
         s=FileReadString(h);    //1
         if(g_debug) Print(s);
         s=FileReadString(h);    //2
         if(g_debug) Print(s);
         s=FileReadString(h);    //3
         if(g_debug) Print(s);
         s=FileReadString(h);    //4
         if(g_debug) Print(s);
         cnt++;
      }
      
      ArrayResize(g_News,cnt);
      cnt=0;
      //move to file's head
      if (FileSeek(h,0,SEEK_SET)) {
         while(!FileIsEnding(h)) {
            g_News[cnt].n=FileReadNumber(h);
            if(g_debug) Print(g_News[cnt].n);
            g_News[cnt].cur=FileReadString(h);
            if(g_debug) Print(g_News[cnt].cur);
            g_News[cnt].dt=FileReadDatetime(h)-time_offset*SEC_H1;
            if(g_debug) Print(g_News[cnt].dt);
            g_News[cnt].for_rate=FileReadNumber(h);
            if(g_debug) Print(g_News[cnt].for_rate);
            cnt++;
         }
      }
      
      FileClose(h);
   } else {
      Print("Operation FileOpen failed, error: ",ErrorDescription(GetLastError()));
      FileClose(h);
   }

   return cnt;
}

//+------------------------------------------------------------------+
//| Timer function
//| argSec: timer seconds
//+------------------------------------------------------------------+
bool timer_init(int argSec=0)
{
   if(g_debug) Print("timer_init");
   if (argSec==0) argSec=g_TimerSecond;
   bool ret=EventSetTimer(argSec);
   return(ret);  
}

//+------------------------------------------------------------------+
//| Timer function
//+------------------------------------------------------------------+
void timer_deinit()
{
   if(g_debug) Print("timer_deinit");
   //relase timer
   EventKillTimer();
}


//+------------------------------------------------------------------+
//| Convert Date format string
//| arg_pat: "." or ","
//| 2017.01.01 <-> 2017/01/01
//+------------------------------------------------------------------+
string covDateString(string arg_date_str,string arg_pat)
{
   string s=arg_date_str;
   int p=0;
   if (StringCompare(arg_pat,SLASH)==0 && StringFind(s,DOT)>=0) {     //convert "." to "/"
      p=StringReplace(s,DOT,SLASH);
   } else if (StringCompare(arg_pat,DOT)==0 && StringFind(s,SLASH)>=0) {
      p=StringReplace(s,SLASH,DOT);
   }
   return s;
}

void PrintTwoDimArray(double &arg_array[][])
{
   for (int i=0;i<ArrayRange(arg_array,0);i++) {
      for (int j=0;j<ArrayRange(arg_array,1);j++) {
         Print("arg_array[",i,",",j,"]=",arg_array[i][j]);
      }
   }
}
int getServerGMTOffset(void)
{
   if (MathAbs(g_srv_tz_offset)<24) {
      return g_srv_tz_offset;
   }   

   datetime srv_t=TimeCurrent();
   //Print("srv_t=",srv_t);
   datetime gmt=TimeGMT();
   //Print("gmt=",gmt);
   datetime t_offset;
   if (srv_t>gmt) {
      t_offset=srv_t-gmt;
   } else {
      t_offset=gmt-srv_t;
   }
   //Print("t_offset=",t_offset);
   int h_offset=TimeHour(t_offset);
   int m_offset=TimeMinute(t_offset);
   if (m_offset>=30) h_offset++;
   
   g_srv_tz_offset=h_offset;
   
   return g_srv_tz_offset;
}
int getClientServerOffset(void)
{
   if (MathAbs(g_server_timezone_offset)<24) {
      g_srv_tz_offset=g_server_timezone_offset;
   }
   int clt_offset=-TimeGMTOffset()/SEC_H1;
   //Print("clt_offset=",clt_offset);
   int srv_offset=getServerGMTOffset();
   //Print("srv_offset=",srv_offset);
   return(clt_offset-srv_offset);
}
//+------------------------------------------------------------------+
//| Time function
//+------------------------------------------------------------------+
bool isCurPd(string arg_symbol,int arg_shift,int arg_bef=0,int arg_aft=0)
{
   bool ret=false;
   string cur;
   if (arg_symbol==NULL) cur=Symbol();
   else cur=arg_symbol;

   int pd=TimepdValue(arg_shift,arg_bef,arg_aft);
   
   if (g_debug) {
      printf("symbo=%s,pd=%d",cur,pd);
   }
   int pd2=pd & AMA_PD;
   if (pd2==AMA_PD) return true;
    
   if          (StringFind(cur,EURUSD)>=0) {
      pd2=pd & EUR_PD;
      if (g_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==EUR_PD) return true;
   } else if   (StringFind(cur,USDJPY)>=0) {
      pd2= pd & ASIA_PD;
      if (g_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==ASIA_PD) return true;
   } else if   (StringFind(cur,AUDUSD)>=0) {
      pd2= pd & ASIA_PD;
      if (g_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==ASIA_PD) return true;
   } else if   (StringFind(cur,NZDUSD)>=0) {
      pd2= pd & ASIA_PD;
      if (g_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==ASIA_PD) return true;
   } else if   (StringFind(cur,USDCAD)>=0) {
   } else if   (StringFind(cur,GBPUSD)>=0) {
      pd2=pd & EUR_PD;
      if (g_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==EUR_PD) return true;
   } else if   (StringFind(cur,USDCHF)>=0) {
      pd2=pd & EUR_PD;
      if (g_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==EUR_PD) return true;
   } else if   (StringFind(cur,XAUUSD)>=0 || StringFind(cur,GOLD)>=0) {
   }
   return false;
}
//+------------------------------------------------------------------+
//| Time strategy
//| ret^ASIA_PD==1:asia
//| ret^AMA_PD==4:america
//| ret^EUR_PD==2:europa
//+------------------------------------------------------------------+
int TimepdValue(int arg_shift,int arg_bef=0,int arg_aft=0,int arg_tz_offset_h=0)
{
   int ret=0;

   int srv_offset_h;
   if (arg_tz_offset_h==0) {
      srv_offset_h=getServerGMTOffset();
   } else {
      srv_offset_h=arg_tz_offset_h;
   }
   
   datetime svr_t=Time[arg_shift];
   datetime t_gmo=svr_t-srv_offset_h*SEC_H1;
   string t=TimeToStr(t_gmo,TIME_MINUTES);     

   if (arg_bef==0 && arg_aft==0) {
      //asia
      if (StringCompare(t,as1,true)>=0 && StringCompare(t,ae2,true)<0) {
         ret+=ASIA_PD;
      }
      //euro
      if (StringCompare(t,gs1,true)>=0 && StringCompare(t,ge2,true)<0) {
         ret+=EUR_PD;
      }
      //america
      if (StringCompare(t,us1,true)>=0 && StringCompare(t,ue2,true)<0) {
         ret+=AMA_PD;
      }
      return ret;
   }
   
   datetime tm0=t_gmo;
   datetime tm1=t_gmo+arg_bef;
   datetime tm2=t_gmo-arg_aft;
   int d0=TimeDay(tm0);
   int d1=TimeDay(tm1);
   int d2=TimeDay(tm2);

   datetime t0,t1,t2;
   if (d0!=d1) {
      t0=StringToTime(StringConcatenate("2010.10.09 ",t));
   } else if (d0!=d2) {
      t0=StringToTime(StringConcatenate("2010.10.11 ",t));
   } else {
      t0=StringToTime(StringConcatenate("2010.10.10 ",t));
   }
   
   //asia
   t1=StringToTime(StringConcatenate("2010.10.10 ",as1))-arg_bef;
   t2=StringToTime(StringConcatenate("2010.10.10 ",ae2))+arg_aft;
   if (t0>=t1 && t0<t2) {
      //Print("t0=",t0,",t1=",t1,",t2=",t2);
      ret+=ASIA_PD;
   }
   //euro
   t1=StringToTime(StringConcatenate("2010.10.10 ",gs1))-arg_bef;
   t2=StringToTime(StringConcatenate("2010.10.10 ",ge2))+arg_aft;
   if (t0>=t1 && t0<t2) {
      //Print("t0=",t0,",t1=",t1,",t2=",t2);
      ret+=EUR_PD;
   }
   
   //america
   t1=StringToTime(StringConcatenate("2010.10.10 ",us1))-arg_bef;
   t2=StringToTime(StringConcatenate("2010.10.10 ",ue2))+arg_aft;
   if (t0>=t1 && t0<t2) {
      //Print("t0=",t0,",t1=",t1,",t2=",t2);
      ret+=AMA_PD;
   }
   
   return ret;
}
int getSlippage(string arg_symbol,int arg_slip_pips)
{
   string cur;
   if (arg_symbol==NULL) cur=Symbol();
   else cur=arg_symbol;

   int calc_digits=(int)MarketInfo(cur,MODE_DIGITS);
   int calc_slip_pips=0;
   if (calc_digits==2 || calc_digits==4) {
      calc_slip_pips=arg_slip_pips;
   } else if (calc_digits==3 || calc_digits==5) {
      calc_slip_pips=arg_slip_pips*10;
   }
   return calc_slip_pips;
}

//+------------------------------------------------------------------+
//| Time of news function
//+------------------------------------------------------------------+
bool isNewsPd(string arg_sym,int arg_shift,int arg_news_bef=0,int arg_news_aft=0)
{
   string cur;
   if (arg_sym==NULL) cur=Symbol();
   else cur=arg_sym;
   if (arg_news_bef==0) arg_news_bef=g_news_bef;
   if (arg_news_aft==0) arg_news_aft=g_news_aft;
   
   for (int i=0;i<ArraySize(g_News);i++) {
      if (isNewsRelated(cur,g_News[i].cur)) {
         datetime t=Time[arg_shift];
         datetime t2=g_News[i].dt;
         if (t>=(t2-arg_news_bef) && t<(t2+arg_news_aft)) {
            //Print("g_News[i].cur=",g_News[i].cur,",t=",t,",t2=",t2);
            return true;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Time of news function(for rate control)
//| return:0,not pd;1,news(not rate),2,news(is rate)
//+------------------------------------------------------------------+
int isNewsPd3(string symbol,int shift)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;
   
   for (int i=0;i<ArraySize(g_News);i++) {
      if (isNewsRelated(cur,g_News[i].cur)) {
         datetime t=Time[shift];
         datetime t2=g_News[i].dt;
         if (t>=(t2-60) && t<t2) {
            //Print("g_News[i].cur=",g_News[i].cur,",t=",t,",t2=",t2,",t2-60=",(t2-60));
            if (g_News[i].for_rate==0) return 1;
            if (g_News[i].for_rate==1) return 2;
         }
      }
   }
   
   return 0;
}

bool isNewsRelated(string arg_symbol,string arg_currency)
{
   string cur;
   if (arg_symbol==NULL) cur=Symbol();
   else cur=arg_symbol;
   
   /*
   if(i_skip_jpychf_usd_relate && StringCompare(arg_currency,"USD")==0) {   //USD currency
      if(StringFind(cur,"JPY")>=0 || StringFind(cur,"CHF")>=0)    //exclude JPY and CHF
         return false;
      return true;
   }
   */
   
   if(StringFind(cur,arg_currency)>=0 || (StringCompare(arg_currency,"USD")==0 && StringFind(cur,"GOLD")>=0))
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
// ea_init: ea init
//+------------------------------------------------------------------+
void ea_init()
{
   CurrentTimeStamp = Time[0];
   getClientServerOffset();
}

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
#define DASH  "-"

//datetime
#define SEC_H1 3600

#define MAX_INT 2147483647

#define SEC_D1 86400

//each time period (GMT)
const string us1="12:00";  //usa
const string ue2="20:00";  //usa
const string as1="00:00";  //asia
const string ae2="08:00";  //asia
const string gs1="08:00";  //europe
const string ge2="16:00";  //europe
const  int ASIA_PD = 1;
const  int AMA_PD = 4;
const  int EUR_PD = 2;

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
   int      ped;        //period   
};
struct s_Price
{
   int      ped;
   double   open;
   double   close;
   double   high;
   double   low;
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
const string   g_EUR_RB_OrderFileName="lang_eur_rb_orders.csv";         //order data file
const string   g_JPY_RB_OrderFileName="lang_jpy_rb_orders.csv";         //order data file
const string   g_AUD_RB_OrderFileName="lang_aud_rb_orders.csv";         //order data file
const string   g_NZD_RB_OrderFileName="lang_nzd_rb_orders.csv";         //order data file
const string   g_CAD_RB_OrderFileName="lang_cad_rb_orders.csv";         //order data file
const string   g_GBP_RB_OrderFileName="lang_gbp_rb_orders.csv";         //order data file
const string   g_CHF_RB_OrderFileName="lang_chf_rb_orders.csv";         //order data file
const string   g_XAU_RB_OrderFileName="lang_xau_rb_orders.csv";       //order data file

datetime CurrentTimeStamp;
int      g_LockFileH=0;          //lock file handle
s_News   g_News[];
int      g_TimerSecond=SEC_H1*1;
int      g_news_bef=SEC_H1*2;     //2 hr before news
int      g_news_aft=SEC_H1*2;     //2 hr after news
int      g_srv_tz_offset=24;
int      g_server_timezone_offset=2;   //summer time(5-10)=3,not summer time(11-4)=2

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
   
   datetime dt=Time[0];
   string t1=StringConcatenate(TimeMonth(dt),"/",TimeDay(dt));
   string t2=TimeToStr(dt,TIME_MINUTES);
   string t=StringConcatenate("[",t1," ",t2,"]");

   string EmailSubject=StringConcatenate("[",arg_sym,"][",t,"]",getOrderTp(arg_type)," order(#",arg_tic,"#)(",arg_lots," lots) placed");
   double sl_pt=0,tp_pt=0,p_pt=0;
   double vpoint=MarketInfo(arg_sym,MODE_POINT);
   double ask_price=Ask,bid_price=Bid;
   
   if (arg_type==OP_BUYLIMIT) {
      p_pt=NormalizeDouble((ask_price-arg_p)/vpoint,0);
   }
   if (arg_type==OP_BUYSTOP) {
      p_pt=NormalizeDouble((arg_p-ask_price)/vpoint,0);
   }
   if (arg_type==OP_SELLLIMIT) {
      p_pt=NormalizeDouble((arg_p-bid_price)/vpoint,0);
   }
   if (arg_type==OP_SELLSTOP) {
      p_pt=NormalizeDouble((bid_price-arg_p)/vpoint,0);
   }
   if (arg_sl != 0) {
      sl_pt=NormalizeDouble((arg_p-arg_sl)/vpoint,0);
      if (arg_type==OP_BUY || arg_type==OP_BUYLIMIT || arg_type==OP_BUYSTOP) {
         sl_pt=-MathAbs(sl_pt);
      }
      if (arg_type==OP_SELL || arg_type==OP_SELLLIMIT || arg_type==OP_SELLSTOP) {
         sl_pt=MathAbs(sl_pt);
      }
   }
   if (arg_tp != 0) {
      tp_pt=NormalizeDouble((arg_p-arg_tp)/vpoint,0);
      if (arg_type==OP_BUY || arg_type==OP_BUYLIMIT || arg_type==OP_BUYSTOP) {
         tp_pt=MathAbs(tp_pt);
      }
      if (arg_type==OP_SELL || arg_type==OP_SELLLIMIT || arg_type==OP_SELLSTOP) {
         tp_pt=-MathAbs(tp_pt);
      }
   }
   
   string EmailBody=StringConcatenate(EmailSubject," at ",dToStr(NULL,arg_p),"(",p_pt,"), lose stop at ",dToStr(NULL,arg_sl),"(",sl_pt,"pt), profit stop at ",dToStr(NULL,arg_tp),"(",tp_pt,"pt), ",arg_com,"(",arg_mag,").");
   // Sample output: "EURUSD Buy order(#1233456#)(0.1 lots) placed at 1.4545(0), lose stop at 1.4545(-200), profit stop at 1.4545(+200), tt stg(12345)."
   
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
   
   datetime dt=Time[0];
   string t1=StringConcatenate(TimeMonth(dt),"/",TimeDay(dt));
   string t2=TimeToStr(dt,TIME_MINUTES);
   string t=StringConcatenate("[",t1," ",t2,"]");

   string EmailSubject=StringConcatenate("[",arg_sym,"][",t,"]",getOrderTp(arg_type)," order(#",arg_tic,"#) modified");
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

bool mailNotice(string arg_sub,string arg_body)
{
   if (!g_sendmail) return true;
   
   string EmailSubject=arg_sub;   
   string EmailBody=arg_body;
   
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
string getPeriodTp(int arg_period=PERIOD_CURRENT)
{
   if (arg_period==PERIOD_CURRENT) {
      arg_period=Period();
   }
   switch (arg_period) {
      case PERIOD_W1:
         return "W1";
      case PERIOD_D1:
         return "D1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_H1:
         return "H1";
      case PERIOD_M30:
         return "M30";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M1:
         return "M1";
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
            //if (order.type!=OP_BUY && order.type!=OP_SELL) continue;   //skip pending cancel order
            //add Slippage(only for fxcm?) by 2017/12/15
            if (order.type!=OP_BUY && order.type!=OP_SELL && order.type!=6) continue;   //skip pending cancel order
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
         order.ped=1;   //N/A
         
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
   string ped=getPeriodTp(order.ped);
   //Print("1=",tic,",2=",tm1,",3=",tp,",4=",lots,",5=",sym);
   //Print("6=",p1,",7=",sl_p,",8=",tp_p,",9=",tm2,",10=",p2);
   //Print("11=",pt,",12=",co,",13=",mg);
   
   //"0","order","open time","type#","type","size","symbol","open price","S/L","T/P","close time","close price","profit","comment","magic"
   //uint ret=FileWrite(h,n,order.tic,order.open_t,order.type,tp,lots,order.sym,p1,sl_p,tp_p,order.close_t,p2,order.profit,order.com,order.mag);
   uint ret=FileWrite(h,n,order.tic,o_t,order.type,tp,lots,order.sym,p1,sl_p,tp_p,c_t,p2,order.profit,order.com,order.mag,ped);
   
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
   //Print("time_offset=",time_offset);
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
int usd_news_read(s_News &arg_news[])
{
   int cnt=0;
   int time_offset=getClientServerOffset();
   //Print("time_offset=",time_offset);
   string fn="lang_usd_news.ex4.csv";
   int h=FileOpen(fn,FILE_CSV|FILE_SHARE_READ,',');
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
      
      ArrayResize(arg_news,cnt);
      cnt=0;
      //move to file's head
      if (FileSeek(h,0,SEEK_SET)) {
         while(!FileIsEnding(h)) {
            arg_news[cnt].dt=FileReadDatetime(h)-time_offset*SEC_H1;
            if(g_debug) Print(arg_news[cnt].dt);
            arg_news[cnt].cur=FileReadString(h);
            if(g_debug) Print(arg_news[cnt].cur);
            arg_news[cnt].cur=FileReadString(h);
            if(g_debug) Print(arg_news[cnt].cur);
            arg_news[cnt].cur=FileReadString(h);
            if(g_debug) Print(arg_news[cnt].cur);
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
int news_impact_write(s_News &arg_news[], s_Price &arg_prices[])
{
   int cnt=0;
   int time_offset=getClientServerOffset();
   //Print("time_offset=",time_offset);
   string cur=Symbol();
   string fn="lang_usd_news_imp_" + cur + ".ex4.csv";
   int h=FileOpen(fn,FILE_WRITE|FILE_CSV,',');
   if(h==INVALID_HANDLE) {
      Print("Operation FileOpen failed, error: ",GetLastError());
      return 0;
   }

   ResetLastError();
   for(int i=0;i<ArraySize(arg_news);i++) {
      string dts=covDateString2(TimeToString(arg_news[i].dt+time_offset*SEC_H1),DASH);
      if (arg_prices[i].open==0) continue;
      int    ped=arg_prices[i].ped;
      string ops=dToStr(cur,arg_prices[i].open);
      string cls=dToStr(cur,arg_prices[i].close);
      string highs=dToStr(cur,arg_prices[i].high);
      string lows=dToStr(cur,arg_prices[i].low);
      uint ret=FileWrite(h,dts,cur,ped,ops,cls,highs,lows);
      if (ret<=0) {
         Print("Operation FileWrite failed, error: ",GetLastError());
         FileClose(h);
         return 0;
      }
      cnt++;
   }

   FileClose(h);
   
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
//+------------------------------------------------------------------+
//| Convert Date format string
//| 2017.01.01 <-> 2017/01/01
//+------------------------------------------------------------------+
string covDateString2(string arg_date_str,string arg_pat)
{
   string s=arg_date_str;
   int p=0;
   if (StringFind(s,DOT)>=0) {     //convert "." to "/"
      p=StringReplace(s,DOT,DASH);
   } else if (StringFind(s,SLASH)>=0) {
      p=StringReplace(s,SLASH,DASH);
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
bool isNewsPd(string arg_sym,int arg_shift,int arg_news_bef,int arg_news_aft=0)
{
   string cur;
   if (arg_sym==NULL) cur=Symbol();
   else cur=arg_sym;
   //if (arg_news_bef==0) arg_news_bef=g_news_bef;
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
//last bar of weekend
bool isEndOfWeek(int arg_shift)
{
   datetime t=Time[arg_shift];
   int d=TimeDayOfWeek(t);
   if (d>=1 && d<5) return false;   //from monday to thursday
   if (d==0 || d==6) return true;    //sunday or sataday
   int h=TimeHour(t);
   int m=TimeMinute(t);

   int ped=Period();
   switch (ped) {
      case PERIOD_H1:
         if (h==23) return true;
      case PERIOD_M30:
         if (h==23 && m==30) return true;
      case PERIOD_M15:
         if (h==23 && m==45) return true;
      case PERIOD_M5:
         if (h==23 && m==55) return true;
      case PERIOD_M1:
         if (h==23 && m==59) return true;
      default:
         return false;
   }

   return false;
}

//+------------------------------------------------------------------+
//| send order mail
//| arg_otp:order type(OP_BUY,OP_SELL)
//| arg_price[]:
//| arg_price_pt[]:
//| arg_ls_price[]:
//| arg_ls_price_pt[]:
//| arg_tp_price[]:
//| arg_tp_price_pt[]:
//| arg_lot[]:
//| arg_comment[]:
//| arg_msg[]:
//| arg_cnt:order count
//|
//| ->format see below
//| -------buy rebound------
//| price(pt)|ls_price(pt)|tp_price(pt)|lot|comment
//+------------------------------------------------------------------+
bool sendOrderMail(  string arg_title,int arg_cnt,string &arg_msg[],
                     double &arg_price[],int &arg_price_pt[],
                     double &arg_ls_price[],int &arg_ls_price_pt[],
                     double &arg_tp_price[],int &arg_tp_price_pt[],
                     double &arg_lot[],string &arg_comment[],
                  )
{
   string mail_title=arg_title;
   string mail_body="";
   string str_fmt="";
   string temp_string="";
   int    dgt=Digits;
   
   if (arg_cnt==0) {
      Print("Nothing to send.");
      return false;
   }
   
   for (int i=0;i<arg_cnt;i++) {
      //msg
      temp_string=StringConcatenate("---",arg_msg[i],"---\r\n");
      StringAdd(mail_body,temp_string);
      
      //price
      if (arg_price_pt[i]==0) {
         str_fmt=StringFormat("%%.%df(ask|bid)|%%.%df(%%d)|%%.%df(%%d)|%%.2f|\"%%s\"\r\n",dgt,dgt,dgt);
         temp_string=StringFormat(  str_fmt,arg_price[i],
                                    arg_ls_price[i],arg_ls_price_pt[i],
                                    arg_tp_price[i],arg_tp_price_pt[i],
                                    arg_lot[i],arg_comment[i]
                                 );
      } else {
         str_fmt=StringFormat("%%.%df(%%d)|%%.%df(%%d)|%%.%df(%%d)|%%.2f|\"%%s\"\r\n",dgt,dgt,dgt);
         temp_string=StringFormat(  str_fmt,arg_price[i],arg_price_pt[i],
                                    arg_ls_price[i],arg_ls_price_pt[i],
                                    arg_tp_price[i],arg_tp_price_pt[i],
                                    arg_lot[i],arg_comment[i]
                                 );
      }
      StringAdd(mail_body,temp_string);

   }
   
   if (g_debug) {
      Print("mail_title=",mail_title);
      Print("mail_body=",mail_body);
   }
   
   return mailNotice(mail_title,mail_body);
   
}
//+------------------------------------------------------------------+
//| arg_otp:order type(OP_BUY,OP_SELL)
//| arg_price[]:
//| arg_price_pt[]:
//| arg_ls_price[]:
//| arg_ls_price_pt[]:
//| arg_tp_price[]:
//| arg_tp_price_pt[]:
//| arg_lot[]:
//| arg_comment[]:
//| arg_msg[]:
//| arg_cnt:order count
//|
//| ->format see below
//| EUR,time,ped,BUY_RB,price,pt,ls_price,pt,tp_price,pt,lot,comment,high,base,low
//| EUR,time,ped,BUY_BK,price,pt,ls_price,pt,tp_price,pt,lot,comment,high,base,low
//+------------------------------------------------------------------+
bool wrtOrderMail(   datetime arg_dt,int arg_cnt,string &arg_msg[],
                     double &arg_price[],int &arg_price_pt[],
                     double &arg_ls_price[],int &arg_ls_price_pt[],
                     double &arg_tp_price[],int &arg_tp_price_pt[],
                     double &arg_lot[],string &arg_comment[],double &arg_lvl_price[]
                  )
{
   string mail_body="";
   string str_fmt="";
   string temp_string="";
   int    dgt=Digits;
   string sym=Symbol();
   string tm=covDateString(TimeToString(arg_dt),SLASH);
   string ped=getPeriodTp();
   
   if (arg_cnt==0) {
      Print("Nothing to send.");
      return false;
   }
   
   
   for (int i=0;i<arg_cnt;i++) {
      //msg
      temp_string=StringConcatenate(sym,",",tm,",",ped,",",arg_msg[i]);
      StringAdd(mail_body,temp_string);

      str_fmt=StringFormat(",%%.%df,%%.%df,%%.%df,",dgt,dgt,dgt);
      temp_string=StringFormat(str_fmt,arg_lvl_price[0],arg_lvl_price[1],arg_lvl_price[2]);
      StringAdd(mail_body,temp_string);
      
      //price
      if (arg_price_pt[i]==0) {
         str_fmt=StringFormat("%%.%df,%%.%df,%%d,%%.%df,%%d,%%.2f,%%s",dgt,dgt,dgt);
         temp_string=StringFormat(  str_fmt,arg_price[i],
                                    arg_ls_price[i],arg_ls_price_pt[i],
                                    arg_tp_price[i],arg_tp_price_pt[i],
                                    arg_lot[i],arg_comment[i]
                                 );
      } else {
         str_fmt=StringFormat("%%.%df,%%d,%%.%df,%%d,%%.%df,%%d,%%.2f,%%s",dgt,dgt,dgt);
         temp_string=StringFormat(  str_fmt,arg_price[i],arg_price_pt[i],
                                    arg_ls_price[i],arg_ls_price_pt[i],
                                    arg_tp_price[i],arg_tp_price_pt[i],
                                    arg_lot[i],arg_comment[i]
                                 );
      }
      StringAdd(mail_body,temp_string);
      if (i!=arg_cnt-1) {
         StringAdd(mail_body,"\r\n");
      }
   }
   
   if (g_debug) {
      Print("mail_body=",mail_body);
   }
   
   //write file
   string file_name=NULL;
   if (StringFind(sym,EURUSD)>=0) {
      file_name=g_EUR_RB_OrderFileName;
   }
   if (StringFind(sym,USDJPY)>=0) {
      file_name=g_JPY_RB_OrderFileName;
   }
   if (StringFind(sym,AUDUSD)>=0) {
      file_name=g_AUD_RB_OrderFileName;
   }
   if (StringFind(sym,NZDUSD)>=0) {
      file_name=g_NZD_RB_OrderFileName;
   }
   if (StringFind(sym,USDCAD)>=0) {
      file_name=g_CAD_RB_OrderFileName;
   }
   if (StringFind(sym,GBPUSD)>=0) {
      file_name=g_GBP_RB_OrderFileName;
   }
   if (StringFind(sym,USDCHF)>=0) {
      file_name=g_CHF_RB_OrderFileName;
   }
   if (StringFind(sym,GOLD)>=0 || StringFind(sym,XAUUSD)>=0) {
      file_name=g_XAU_RB_OrderFileName;
   }
   
   if (file_name==NULL) return false;
   
   Print("write order command to file");
   ResetLastError();
   int h=FileOpen(file_name,FILE_READ|FILE_WRITE|FILE_TXT);
   if(h==INVALID_HANDLE) {
      Print("Operation FileOpen failed, error: ",GetLastError());
      return false;
   }

   ResetLastError();
   //move to file end to add order record
   if (!FileSeek(h,0,SEEK_END)) {
      Print("Operation FileSeek failed, error: ",GetLastError());
      FileClose(h);
      return false;
   }
   
   uint ret=FileWrite(h,mail_body);

   FileClose(h);

   if (ret>0) return true;
   else return false; 
   
}

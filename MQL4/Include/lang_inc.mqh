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

//input
input bool  i_debug = false;
input int   i_equity_percent = 1;
input bool  i_sendmail=true;

//currency
#define EURUSD "EURUSD."
#define USDJPY "USDJPY."
#define AUDUSD "AUDUSD."
#define NZDUSD "NZDUSD."
#define USDCAD "USDCAD."
#define GBPUSD "GBPUSD."
#define USDCHF "USDCHF."
#define XAUUSD "XAUUSD."
#define GBPJPY "GBPJPY."

//datetime
#define SEC_H1 3600
#define SEC_D1 86400

//int      EquityPercent = 1;
int      LossStopPt = 150;
int      ProfitStopPt = 300;
int      OOPt = 100;
//double   Vol = 0.1;

//bool     debug = false;

//struct
struct s_News
{ 
   double n;      //index
   string cur;    // currency 
   datetime dt;   // date 
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

//global
double   g_max_lots = 0.1;
datetime CurrentTimeStamp;
int      g_LockFileH=0;          //lock file handle
string   g_LockFileName="#Lock#";
string   g_OrderHisFileName="lang_history_orders.ex4.csv";   //history order data file

s_News   g_News[];
string   g_NewsFileName="lang_news.ex4.csv";
int      g_TimeZoneOffset=SEC_H1*5;
int      g_TimerSecond=SEC_H1*1;
int      g_news_bef=SEC_H1*2;     //2 hr before news
int      g_news_aft=SEC_H1*2;     //2 hr after news


//+------------------------------------------------------------------+
// OrderBuy (auto set risk volume) deprecated
// p: Price (0 for not set, buy current)
// ls_value: Loss Stop Value (0 for not set, use LossStopPt)
// ps_value: Profit Stop Value (0 use ProfitStopPt, -1 not set profit stop)
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
/*
int OrderBuy(double p, double ls_value, double ps_value, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price = Ask;
   int cmd = OP_BUY;
   if (p != 0) {
	   if (p > price) {
		   cmd = OP_BUYSTOP;
	   } else {
		   cmd = OP_BUYLIMIT;
	   }
      price = p + g;
   }

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (ls_value == 0) {
      ls_price = NormalizeDouble(price - LossStopPt * pt, Digits);
	   ls_pt = LossStopPt;
   } else {
      ls_price = ls_value;
      ls_pt = NormalizeDouble((price - ls_price) / pt, 0);
   }
   
   if (ps_value == 0) {
      ps_price = NormalizeDouble(price + ProfitStopPt * pt, Digits);
	   ps_pt = ProfitStopPt;
   } else if (ps_value == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = ps_value;
      ps_pt = NormalizeDouble((ps_price - price) / pt, 0);
   }

   double risk_vol = getVolume(EquityPercent, ls_pt);
   if (risk_vol > Vol) risk_vol = Vol;
   
   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, 0, ls_price, ps_price, comment, magic, 0, Green);
   }
   
   if (ret != 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   return ret;
}
*/

//+------------------------------------------------------------------+
// OrderBuy2 (auto set risk volume)
// argPrice: Price (0 for not set, buy current)
// argLsPrice: Loss Stop Value (0 for not set, use LossStopPt)
// argPsPrice: Profit Stop Value (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderBuy2(double argPrice, double argLsPrice, double argPsPrice, int argMag)
{
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price = Ask;
   int cmd = OP_BUY;
   if (argPrice != 0) {
	   if (argPrice > price) {
		   cmd = OP_BUYSTOP;
	   } else {
		   cmd = OP_BUYLIMIT;
	   }
      price = argPrice + g;
   }

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (argLsPrice == 0) {
      ls_price = NormalizeDouble(price - LossStopPt * pt, Digits);
	   ls_pt = LossStopPt;
   } else {
      ls_price = argLsPrice;
      ls_pt = NormalizeDouble((price - ls_price) / pt, 0);
   }
   
   if (argPsPrice == 0) {
      ps_price = NormalizeDouble(price + ProfitStopPt * pt, Digits);
	   ps_pt = ProfitStopPt;
   } else if (argPsPrice == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = argPsPrice;
      ps_pt = NormalizeDouble((ps_price - price) / pt, 0);
   }

   double risk_vol = getVolume(i_equity_percent, ls_pt);
   if (risk_vol > g_max_lots) risk_vol = g_max_lots;
   
   //<<<<debug
   if (i_debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int ret = 0;
   if (!i_debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, 0, ls_price, ps_price, "", argMag, 0, Green);
   }
   
   if (ret <0 )
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd,risk_vol,price,ls_price,ps_price,"",argMag);
      return true;
   }
   else return false;
}

//+------------------------------------------------------------------+
// OrderSell (auto set risk volume) deprecated
// p: Price (0 for not set, sell current)
// ls_value: Loss Stop Value (0 for not set, use LossStopPt)
// ps_value: Profit Stop Value (0 use ProfitStopPt, -1 not set profit stop)
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
/*
int OrderSell(double p, double ls_value, double ps_value, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price = Bid;
   int cmd = OP_SELL;
   if (p != 0) {
	   if (p > price) {
		   cmd = OP_SELLLIMIT;
	   } else {
		   cmd = OP_SELLSTOP;
	   }
      price = p;
   }

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (ls_value == 0) {
      ls_price = NormalizeDouble(price + LossStopPt * pt, Digits);
	   ls_pt = LossStopPt;
   } else {
      ls_price = ls_value + g;
      ls_pt = NormalizeDouble((ls_price - price) / pt, 0);
   }
   
   if (ps_value == 0) {
      ps_price = NormalizeDouble(price - ProfitStopPt * pt, Digits);
	   ps_pt = ProfitStopPt;
   } else if (ps_value == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = ps_value + g;
      ps_pt = NormalizeDouble((price- ps_price) / pt, 0);
   }

   double risk_vol = getVolume(EquityPercent, ls_pt);
   if (risk_vol > Vol) risk_vol = Vol;

   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, 0, ls_price, ps_price, comment, magic, 0, Red);
   }
   
   if (ret != 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   return ret;
}
*/

//+------------------------------------------------------------------+
// OrderSell2 (auto set risk volume)
// argPrice: Price (0 for not set, sell current)
// argLsPrice: Loss Stop Value (0 for not set, use LossStopPt)
// argPsPrice: Profit Stop Value (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderSell2(double argPrice, double argLsPrice, double argPsPrice, int argMag)
{
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price = Bid;
   int cmd = OP_SELL;
   if (argPrice != 0) {
	   if (argPrice > price) {
		   cmd = OP_SELLLIMIT;
	   } else {
		   cmd = OP_SELLSTOP;
	   }
      price = argPrice;
   }

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (argLsPrice == 0) {
      ls_price = NormalizeDouble(price + LossStopPt * pt, Digits);
	   ls_pt = LossStopPt;
   } else {
      ls_price = argLsPrice + g;
      ls_pt = NormalizeDouble((ls_price - price) / pt, 0);
   }
   
   if (argPsPrice == 0) {
      ps_price = NormalizeDouble(price - ProfitStopPt * pt, Digits);
	   ps_pt = ProfitStopPt;
   } else if (argPsPrice == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = argPsPrice + g;
      ps_pt = NormalizeDouble((price- ps_price) / pt, 0);
   }

   double risk_vol = getVolume(i_equity_percent, ls_pt);
   if (risk_vol > g_max_lots) risk_vol = g_max_lots;

   //<<<<debug
   if (i_debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int ret = 0;
   if (!i_debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, 0, ls_price, ps_price, "", argMag, 0, Red);
   }
   
   if (ret < 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd,risk_vol,price,ls_price,ps_price,"",argMag);   
      return true;
   }
   else return false;

}

//+------------------------------------------------------------------+
// OrderOO (buy stop and sell stop at two directions,auto set risk volume)
// argOPt: offset point
// argLsPt: Loss Stop Point (0 for not set, use LossStopPt)
// argPsPt: Profit Stop Point (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderOO(int argMag, int argOPt=0, int argLsPt=0, int argPsPt=0)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   if (argOPt == 0) argOPt = OOPt;
   double price1 = Bid;
   price1 = NormalizeDouble(price1 - argOPt * pt, Digits);  //sell price
   double price2 = Ask;
   price2 = NormalizeDouble(price2 + argOPt * pt, Digits);  //buy price
   int cmd1 = OP_SELLSTOP;
   int cmd2 = OP_BUYSTOP;

   if (argLsPt == 0) argLsPt = LossStopPt;
   if (argPsPt == 0) argPsPt = ProfitStopPt;
   
   double ls_price1; //sell's lose stop
   double ps_price1; //sell's profit stop
   ls_price1 = NormalizeDouble(price1 + argLsPt * pt, Digits);
   if (argPsPt == -1) {
      ps_price1 = 0;
   } else {
      ps_price1 = NormalizeDouble(price1 - argPsPt * pt, Digits);
   }

   double ls_price2; //buy's lose stop
   double ps_price2; //buy's profit stop
   ls_price2 = NormalizeDouble(price2 - argLsPt * pt, Digits);
   if (argPsPt == -1) {
      ps_price2 = 0;
   } else {
      ps_price2 = NormalizeDouble(price2 + argPsPt * pt, Digits);
   }

   double risk_vol = getVolume(i_equity_percent, argLsPt);
   if (risk_vol > g_max_lots) risk_vol = g_max_lots;

   //<<<<debug
   if (i_debug) {
      Print("<<<<debug");
      printf("command1=%d", cmd1);
      printf("command2=%d", cmd2);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price1=%.5f", price1);
      printf("price2=%.5f", price2);
      printf("loss stop point=%.5f", argLsPt);
      printf("profit stop point=%.5f", argPsPt);
      printf("loss stop price1=%.5f", ls_price1);
      printf("profit stop price1=%.5f", ps_price1);
      printf("loss stop price2=%.5f", ls_price2);
      printf("profit stop price2=%.5f", ps_price2);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!i_debug) {
      ret = OrderSend(Symbol(), cmd1, risk_vol, price1, 0, ls_price1, ps_price1, "", argMag, 0, Red);  //sell stop order
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd1,risk_vol,price1,ls_price1,ps_price1,"",argMag);   
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }
   
   if (!i_debug) {
      ret = OrderSend(Symbol(), cmd2, risk_vol, price2, 0, ls_price2, ps_price2, "", argMag, 0, Green); //buy stop order
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd2,risk_vol,price2,ls_price2,ps_price2,"",argMag);   
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }

   return true;

}

//+------------------------------------------------------------------+
// OrderOO (buy stop and sell stop at two directions,auto set risk volume)
// argPrice1: sell stop price
// argPrice2: buy stop price
// argLs1: loss stop price for sell stop (0 for not set, use LossStopPt)
// argPs1: profit stop price for sell stop (0 use ProfitStopPt, -1 not set profit stop)
// argLs2: loss stop price for buy stop (0 for not set, use LossStopPt)
// argPs2: profit stop price for buy stop (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderOO2(int argMag, double argPrice1, double argPrice2, double argLs1=0, double argPs1=0, double argLs2=0, double argPs2=0)
{
   
   if (argPrice1>=argPrice2 || argPrice1>=Bid || argPrice2<=Ask ) return false;

   double pt=Point;
   double g=Ask-Bid;
   double gap=NormalizeDouble(g / pt, 0);
   
   double price1=argPrice1;       //sell stop price
   double price2=argPrice2;       //buy stop price
   int cmd1=OP_SELLSTOP;
   int cmd2=OP_BUYSTOP;
   
   double ls_price1; //lose stop price for sell stop
   double ps_price1; //profit stop price for sell stop
   if (argLs1==0) ls_price1=NormalizeDouble(price1+LossStopPt*pt,Digits);
   else ls_price1=argLs1;
   if (argPs1==0) ps_price1=NormalizeDouble(price1-ProfitStopPt*pt,Digits);
   else if(argPs1==-1) ps_price1=0;
   else ps_price1=argPs1;

   double ls_price2; //lose stop price for buy stop
   double ps_price2; //profit stop price for buy stop
   if (argLs2==0) ls_price2=NormalizeDouble(price1-LossStopPt*pt,Digits);
   else ls_price2=argLs2;
   if (argPs2==0) ps_price2=NormalizeDouble(price1+ProfitStopPt*pt,Digits);
   else if(argPs2==-1) ps_price2=0;
   else ps_price2=argPs2;

   double ls_pt1=(ls_price1-price1)/pt;
   double ls_pt2=(price2-ls_price2)/pt;
   double ls_pt=MathMax(ls_pt1,ls_pt2);
   double risk_vol=getVolume(i_equity_percent, ls_pt);
   if (risk_vol>g_max_lots) risk_vol=g_max_lots;

   //<<<<debug
   if (i_debug) {
      Print("<<<<debug");
      printf("command1=%d", cmd1);
      printf("command2=%d", cmd2);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price1=%.5f", price1);
      printf("price2=%.5f", price2);
      printf("loss stop price1=%.5f", ls_price1);
      printf("profit stop price1=%.5f", ps_price1);
      printf("loss stop price2=%.5f", ls_price2);
      printf("profit stop price2=%.5f", ps_price2);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int ret=0;
   if (!i_debug) {
      ret = OrderSend(Symbol(), cmd1, risk_vol, price1, 0, ls_price1, ps_price1, "", argMag, 0, Red);  //sell stop order
   }
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd1,risk_vol,price1,ls_price1,ps_price1,"",argMag);   
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }

   ret=0;
   if (!i_debug) {
      ret = OrderSend(Symbol(), cmd2, risk_vol, price2, 0, ls_price2, ps_price2, "", argMag, 0, Green); //buy stop order
   }
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd2,risk_vol,price2,ls_price2,ps_price2,"",argMag);   
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }

   return true;

}

// type:1 buy,2 buy stop,-1 sell,-2 sell stop,0 all
int OrderCloseA(string symbol, int type, int magic)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   //Print("1=",symbol,",2=",type,",3=",comment,",4=",magic);
   int t=OrdersTotal();
   //Print("t=",t);
   int cnt=0;
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      //Print("ret=",ret);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         if((type==0 && StringCompare(OrderSymbol(),cur)==0 && OrderMagicNumber()==magic) ||
            (type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic) ||
            (type==2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUYSTOP && OrderMagicNumber()==magic) ||
            (type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic) ||
            (type==-2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELLSTOP && OrderMagicNumber()==magic)) 
         {
            if(OrderType()==OP_BUY) {
               //Print("send close buy order command");
               ret=OrderClose(OrderTicket(),OrderLots(),Bid,0,Green);
            }
            if(OrderType()==OP_SELL) {
               //Print("send close sell order command");
               ret=OrderClose(OrderTicket(),OrderLots(),Ask,0,Red);
            }
            if(OrderType()==OP_BUYSTOP) {
               //Print("send delete order command");
               ret=OrderDelete(OrderTicket(),Green);
            }
            if(OrderType()==OP_SELLSTOP) {
               //Print("send delete order command");
               ret=OrderDelete(OrderTicket(),Red);
            }
            
            if (ret!=true) {
               int check=GetLastError(); 
               if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
            } else {
               cnt++;
            }
         }
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return cnt;
}

// type:1 buy,2 buy stop,-1 sell,-2 sell stop,0 all
bool FindOrderA(string symbol, int type, int magic)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         if((type==0 && StringCompare(OrderSymbol(),cur)==0 && OrderMagicNumber()==magic) ||
            (type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic) ||
            (type==2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUYSTOP && OrderMagicNumber()==magic) ||
            (type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic) ||
            (type==-2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELLSTOP && OrderMagicNumber()==magic)) 
         {
            return true;
         }
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return false;
}

//+------------------------------------------------------------------+
// getVolume: get risk volume
// ep: equity percent. ex,1=1%,2=2% (0 for not set, use )
// ls_point: Loss Stop Point
//+------------------------------------------------------------------+
double getVolume(int ep, double ls_point)
{
   double risk_amount = AccountEquity() * ep / 100;
   double tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);
   if (tick_value == 0) return 1;
   double volume = risk_amount / (ls_point * tick_value);
   volume = NormalizeDouble(volume, 2);
   
   //<<<<debug
   if (i_debug) {
      Print("<<<<debug");
      printf("risk amount=%.5f", risk_amount);
      printf("tick value=%.5f", tick_value);
      printf("volume=%.5f", volume);
      Print("debug>>>>");
   }
   //debug>>>>
   return volume;
   
}

//+------------------------------------------------------------------+
// ea_init: ea init
//+------------------------------------------------------------------+
void ea_init()
{
   CurrentTimeStamp = Time[0];
}
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

//+------------------------------------------------------------------+
//| moving stop function
//| type:1 buy,-1 sell
//| spt:stop point
//+------------------------------------------------------------------+
bool movingStop(string symbol, int type, int magic, int shift, int spt)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   bool ret2=false;
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         if((type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic))
         {
            //buy order
            //double cur_price=Bid;
            double cur_price=Close[shift];
            double max_lose_stop_price=NormalizeDouble(cur_price-spt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            if (max_lose_stop_price>cur_lose_stop_price) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit(),0,Green);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         if((type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic)) 
         {
            //sell order
            //double cur_price=Ask;
            double cur_price=Close[shift];
            double max_lose_stop_price=NormalizeDouble(cur_price+spt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            if (max_lose_stop_price<cur_lose_stop_price || cur_lose_stop_price==0) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit(),0,Red);
               if (!ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return ret2;
}

//+------------------------------------------------------------------+
//| moving stop function (set to min profit point)
//| type:1 buy,-1 sell
//| tpt:threhold point
//| ppt:profit point
//+------------------------------------------------------------------+
bool movingStop2(string symbol, int type, int magic, int shift, int tpt, int ppt)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   bool ret2=false;
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         if((type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic))
         {
            //buy order
            //double cur_price=Bid;
            double cur_price=Close[shift];
            double threhold_price=NormalizeDouble(OrderOpenPrice()+tpt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            double min_profit_price=NormalizeDouble(OrderOpenPrice()+ppt,Digits);
            if (cur_price>threhold_price && cur_lose_stop_price<min_profit_price) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),min_profit_price,OrderTakeProfit(),0,Green);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),min_profit_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         if((type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic)) 
         {
            //sell order
            //double cur_price=Ask;
            double cur_price=Close[shift];
            double threhold_price=NormalizeDouble(OrderOpenPrice()-tpt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            double min_profit_price=NormalizeDouble(OrderOpenPrice()-ppt,Digits);
            if (cur_price<threhold_price && cur_lose_stop_price>min_profit_price) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),min_profit_price,OrderTakeProfit(),0,Red);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),min_profit_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return ret2;
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
   if (!i_sendmail) return true;
   
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
   if (!i_sendmail) return true;
   
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

int writeOrderHistoryToFile()
{

   int orderTickets[];
   
   int h=FileOpen(g_OrderHisFileName,FILE_CSV|FILE_SHARE_READ,',');
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
   h=FileOpen(g_OrderHisFileName,FILE_READ|FILE_WRITE|FILE_CSV,',');
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
         if (order.type!=OP_BUY && order.type!=OP_SELL) continue;   //skip pending cancel order
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
   //Print("1=",tic,",2=",tm1,",3=",tp,",4=",lots,",5=",sym);
   //Print("6=",p1,",7=",sl_p,",8=",tp_p,",9=",tm2,",10=",p2);
   //Print("11=",pt,",12=",co,",13=",mg);
   
   //"0","order","open time","type#","type","size","symbol","open price","S/L","T/P","close time","close price","profit","comment","magic"
   uint ret=FileWrite(h,n,order.tic,order.open_t,order.type,tp,lots,order.sym,p1,sl_p,tp_p,order.close_t,p2,order.profit,order.com,order.mag);
   
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
      order.open_t=FileReadDatetime(h);
      order.type=(int)FileReadNumber(h);
      //skip one
      string dummy=FileReadString(h);
      order.lots=FileReadNumber(h);
      order.sym=FileReadString(h);
      order.open_p=FileReadNumber(h);
      order.sl_p=FileReadNumber(h);
      order.tp_p=FileReadNumber(h);
      order.close_t=FileReadDatetime(h);
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
   int h=FileOpen(g_NewsFileName,FILE_CSV|FILE_SHARE_READ,',');
   if(h!=INVALID_HANDLE) {
      //read record count
      while(!FileIsEnding(h)) {
         string s;
         s=FileReadString(h);
         if(i_debug) Print(s);
         s=FileReadString(h);
         if(i_debug) Print(s);
         s=FileReadString(h);
         if(i_debug) Print(s);
         cnt++;
      }
      
      ArrayResize(g_News,cnt);
      cnt=0;
      //move to file's head
      if (FileSeek(h,0,SEEK_SET)) {
         while(!FileIsEnding(h)) {
            g_News[cnt].n=FileReadNumber(h);
            if(i_debug) Print(g_News[cnt].n);
            g_News[cnt].cur=FileReadString(h);
            if(i_debug) Print(g_News[cnt].cur);
            g_News[cnt].dt=FileReadDatetime(h)-g_TimeZoneOffset;
            if(i_debug) Print(g_News[cnt].dt);
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
   if(i_debug) Print("timer_init");
   if (argSec==0) argSec=g_TimerSecond;
   bool ret=EventSetTimer(argSec);
   return(ret);  
}

//+------------------------------------------------------------------+
//| Timer function
//+------------------------------------------------------------------+
void timer_deinit()
{
   if(i_debug) Print("timer_deinit");
   //relase timer
   EventKillTimer();
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
      if (StringFind(cur,g_News[i].cur)>=0) {
         datetime t=Time[arg_shift];
         datetime t2=g_News[i].dt;
         if (t>=(t2-arg_news_bef) && t<(t2+arg_news_aft)) return true;
      }
   }
   
   return false;
}
//+------------------------------------------------------------------+
//| Time of news function
//+------------------------------------------------------------------+
bool isNewsPd2(string symbol,int shift)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;
   
   for (int i=0;i<ArraySize(g_News);i++) {
      if (StringFind(cur,g_News[i].cur)>=0) {
         datetime t=Time[shift];
         datetime t2=g_News[i].dt;
         if (t>=(t2-60) && t<t2) return true;
      }
   }
   
   return false;
}

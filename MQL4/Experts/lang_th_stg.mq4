//+------------------------------------------------------------------+
//|                                                  lang_th_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ea_inc.mqh>

//--------------------------------

//--- input
input int   i_min_ls_pt=300;
input bool  i_his_order_wrt=false;        //history order write control
input int   i_fast_pd=12;
input int   i_slow_pd=26;
input int   i_singal_pd=9;
input int   i_mode=MODE_SIGNAL;     //0:Main,1:Signal
input double   i_deviation=2;
input int   i_range_ratio=1;
input double   i_macd_gap=0.0020;
input datetime i_inspect_dt=D'2016.11.30 04:00';
input int   i_open_filter=0;
input int   i_close_filter=0;

//--- global
int      g_magic=5;        //trend horse
//bool     g_has_order=false;
datetime g_orderdt;

//int g_ma_cross=0;    //1,fast ma up cross slow ma;-1,fast ma down cross slow ma
//int g_adx_status=0;  //1,above 40(default);-1,below 40(default)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   g_debug=false;
   
   if (g_debug) {
      Print("OnInit()");
   }
   
   ea_init();
   
   /*
   if (!i_for_test) {
      if (!timer_init(SEC_H1)) return(INIT_FAILED);
   }
   
   news_read();
   */
   
   return(INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if (g_debug) {
      Print("OnDeinit()");
   }

   /*
   if (!i_for_test) {
      timer_deinit();
   }
   */

   if (i_his_order_wrt) {
      if (getFileLock()) {
         writeOrderHistoryToFile();
         releaseFileLock();
      }
   }
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   if (isNewBar()==0) return;
   
   int cur_bar_shift=0;
   int last_bar_shift=1;
   datetime now=Time[cur_bar_shift];
   bool has_order=true;
   
   //check if exists any order
   if (FindOrderA(NULL,1,g_magic)) {  //found buy order
      if (ifClose(cur_bar_shift)) {
         Print("closed buy order");
         if (!FindOrderA(NULL,0,g_magic)) {
            has_order=false;
         }
      }
      /*
      //move lose stop
      if (movingStop3(NULL,g_magic,last_bar_shift)) {
         Print("movingstop of buy order");
      }
      */
   } else if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
      if (ifClose(cur_bar_shift)) {
         Print("closed buy order");
         if (!FindOrderA(NULL,0,g_magic)) {
            has_order=false;
         }
      }
      /*
      //move lose stop
      if (movingStop3(NULL,g_magic,last_bar_shift)) {
         Print("movingstop of buy order");
      }
      */
   } else {    //not found buy and sell order
      has_order=false;
   }
   
   /*
   //news time skip control
   bool newsPd=isNewsPd(NULL,cur_bar_shift,i_news_bef,i_news_aft);
   if (i_news_skip && newsPd) {     //in news time
      if (has_order) {
         Print("new time skip control:news time start, close all order");
         OrderCloseA(NULL,0,g_magic);   //close all order
         if (!FindOrderA(NULL,0,g_magic)) {
            has_order=false;
         }
      } else {
         Print("news time skip control:news time start, do not take action");
      }
      return;
   }
   */

   double ls_tgt_price;
   /*
   int sign=isTrendStgOpen2(last_bar_shift,ls_tgt_price,i_slow_pd,i_fast_pd,i_singal_pd,i_mode,i_deviation,i_range_ratio);
   //| return value: 6,macd break to plus,macd fast is above range high;-5,macd break to minus,macd fast is below range low;
   //|               5,macd break to plus;-5,macd break to minus;
   //|               4,macd is plus,macd fast is above range high;-4,macd is minus,macd fast is below range low;
   //|               3,macd is plus,fast ma is above slow ma;-3,macd is minus,fast ma is below slow ma;
   //|               2,macd is plus,fast ma is below slow ma;-2,macd is minus,fast ma is below slow ma;
   //|               1,macd is plus;-1,macd is minus;
   //|               0:n/a
   */
   int macd_status=0,bar_status=0;
   double macd_slow=0,macd_fast=0,macd_range=0;
   //fast
   int sign2=isTrendStgOpen3(last_bar_shift,ls_tgt_price,macd_slow,macd_fast,macd_range,macd_status,bar_status,i_slow_pd,i_fast_pd,i_singal_pd,MODE_MAIN,i_deviation,i_range_ratio);
   
   //slow
   int sign=isTrendStgOpen3(last_bar_shift,ls_tgt_price,macd_slow,macd_fast,macd_range,macd_status,bar_status,i_slow_pd,i_fast_pd,i_singal_pd,i_mode,i_deviation,i_range_ratio);
   //| return value: +10,macd is break plus;-10,macd is break minus;
   //|               1,macd is plus;-1,macd is minus;
   //| return value: arg_macd_status
   //|               fast>slow,same direction,up,5;
   //|               fast>slow,different direction(fast down,slow up),4;
   //|               fast>slow,different direction(fast up,slow down),3;
   //|               fast>slow,same direction(fast down,slow down),2;
   //|               fast>slow,no direction,1;
   //|               -----------
   //|               fast<slow,same direction,down,-5;
   //|               fast<slow,different direction(fast up,slow down),-4;
   //|               fast<slow,different direction(fast down,slow up),-3;
   //|               fast<slow,same direction(fast up,slow up),-2;
   //|               fast<slow,no direction,-1;
   //|               -----------
   //|               fast is above slow range upper:+10  
   //|               fast is below slow range lower:-10  
   //|               fast is above slow band upper:+20  
   //|               fast is below slow band lower:-20  
   //|               -----------
   //|               n/a:0
   //| return value: arg_bar_status
   //|               1,positive bar;-1,negative bar

   int open=0;          //1:open buy;-1:open sell
   int open2=0;          //1:open buy;-1:open sell
   if (i_open_filter==0) {          //base
      if (sign>0 && sign2>0) open=1;                    //slow and fast macd is plus
      if (sign<0 && sign2<0) open=-1;                   //slow and fast macd is minus
   } else if (i_open_filter==1) {   //add filter
      if (sign>0 && sign2>0 && macd_status>0) open=1;   //slow and fast macd is plus, fast>slow
      if (sign<0 && sign2<0 && macd_status<0) open=-1;  //slow and fast macd is minus, fast<slow
   } else if (i_open_filter==2) {   //add filter
      if (sign>0 && sign2>0 && ((macd_status<10 && macd_status>=4) || (macd_status<20 && macd_status>=14) || (macd_status<30 && macd_status>=24) || macd_status>=34)) open=1;         //macd is plus, fast>slow, same direction
      if (sign<0 && sign2<0 && ((macd_status>-10 && macd_status<=-4) || (macd_status>-20 && macd_status<=-14) || (macd_status>-30 && macd_status<=-24) || macd_status<=-34)) open=-1;  //macd is minus, fast<slow, same direction
   } else if (i_open_filter==3) {   //add filter
      //if (sign>0 && sign2>0 && ((macd_status>=15 && macd_status<20) || macd_status>=35)) open=1;         //slow and fast macd is plus, fast>slow+upper range
      //if (sign<0 && sign2<0 && ((macd_status<=-15 && macd_status>-20) || macd_status<=-35)) open=-1;     //slow and fast macd is minus, fast<slow-lower range
      if (sign>0 && sign2>0 && ((macd_status>=10 && macd_status<20) || macd_status>=30)) open=1;         //slow and fast macd is plus, fast>slow+upper range
      if (sign<0 && sign2<0 && ((macd_status<=-10 && macd_status>-20) || macd_status<=-30)) open=-1;     //slow and fast macd is minus, fast<slow-lower range
   } else if (i_open_filter==4) {   //add filter
      if (sign>0 && sign2>0 && ((macd_status>=20 && macd_status<30) || macd_status>=30)) open=1;       //slow and fast macd is plus, fast>slow+upper band
      if (sign<0 && sign2<0 && ((macd_status<=-20 && macd_status>-30) || macd_status<=-30)) open=-1;    //slow and fast macd is minus, fast<slow-lower band
   } else if (i_open_filter==5) {   //add filter
      if (sign>0 && sign2>0 && macd_status>=30) open=1;        //slow and fast macd is plus, fast>slow+upper range, fast>slow+upper band
      if (sign<0 && sign2<0 && macd_status<=-30) open=-1;      //slow and fast macd is minus, fast<slow-lower range, fast<slow-lower band
   } else if (i_open_filter==6) {   //add filter
      if (sign>0 && sign2>0 && bar_status>0) open=1;
      if (sign<0 && sign2<0 && bar_status<0) open=-1;
   } else if (i_open_filter==7) {   //add filter
      if (sign>0 && sign2>0 && macd_status>=10) open=1;        //slow and fast macd is plus, fast>slow+upper band or fast>slow+upper range
      if (sign<0 && sign2<0 && macd_status<=-10) open=-1;      //slow and fast macd is minus, fast<slow-lower band or fast<slow-lower range
   } else if (i_open_filter==8) {   //add filter
      if (sign>0 && sign2>0 && macd_fast>MathAbs(i_macd_gap)) open=1;                    //slow and fast macd is plus
      if (sign<0 && sign2<0 && macd_fast<-MathAbs(i_macd_gap)) open=-1;                   //slow and fast macd is minus
   } else if (i_open_filter==9) {   //add filter
      if (macd_status>=30) macd_status-=30;
      if (macd_status>=20) macd_status-=20;
      if (macd_status>=10) macd_status-=10;
      if (macd_status<=-30) macd_status+=30;
      if (macd_status<=-20) macd_status+=20;
      if (macd_status<=-10) macd_status+=10;
      if (sign>0 && sign2>0 && macd_status==5 && macd_fast>MathAbs(i_macd_gap)) open=1;                    //slow and fast macd is plus
      if (sign<0 && sign2<0 && macd_status==-5 && macd_fast<-MathAbs(i_macd_gap)) open=-1;                   //slow and fast macd is minus      
   } else if (i_open_filter==10) {   //add filter
      if (macd_status>=30) macd_status-=30;
      if (macd_status>=20) macd_status-=20;
      if (macd_status>=10) macd_status-=10;
      if (macd_status<=-30) macd_status+=30;
      if (macd_status<=-20) macd_status+=20;
      if (macd_status<=-10) macd_status+=10;
      if (sign>0 && sign2>0 && macd_status>0 && macd_fast>MathAbs(i_macd_gap)) open=1;                    //slow and fast macd is plus
      if (sign<0 && sign2<0 && macd_status<0 && macd_fast<-MathAbs(i_macd_gap)) open=-1;                   //slow and fast macd is minus      
      if (sign>10 && sign2>0) open2=1;                       //slow and fast macd is plus
      if (sign<-10 && sign2<0) open2=-1;                     //slow and fast macd is minus
   } else if (i_open_filter==11) {   //add filter
      //if (sign>0 && sign2>0 && ((macd_status>=15 && macd_status<20) || macd_status>=35)) open=1;         //slow and fast macd is plus, fast>slow+upper range
      //if (sign<0 && sign2<0 && ((macd_status<=-15 && macd_status>-20) || macd_status<=-35)) open=-1;     //slow and fast macd is minus, fast<slow-lower range
      //if (sign>0 && sign2>0 && ((macd_status>=10 && macd_status<20) || macd_status>=30)) open=1;         //slow and fast macd is plus, fast>slow+upper range
      //if (sign<0 && sign2<0 && ((macd_status<=-10 && macd_status>-20) || macd_status<=-30)) open=-1;     //slow and fast macd is minus, fast<slow-lower range
      if (sign>0 && sign2>0 && MathAbs(macd_range)<=MathAbs(i_macd_gap)) open=1;         //slow and fast macd is plus, fast>slow+upper range
      if (sign<0 && sign2<0 && MathAbs(macd_range)<=MathAbs(i_macd_gap)) open=-1;     //slow and fast macd is minus, fast<slow-lower range
   }

   int close=0;         //1:close buy;-1:close sell
   int close2=0;         //1:close buy;-1:close sell
   if (i_close_filter==0) {         //base
      if (sign>0) close=-1;                  //slow macd is plus
      if (sign<0) close=1;                   //slow macd is minus
   }else if (i_close_filter==1) {   //
      if (sign2>0) close=-1;                  //fast macd is plus
      if (sign2<0) close=1;                   //fast macd is minus
   }else if (i_close_filter==2) {   //
      if (macd_status>=30) macd_status-=30;
      if (macd_status>=20) macd_status-=20;
      if (macd_status>=10) macd_status-=10;
      if (macd_status<=-30) macd_status+=30;
      if (macd_status<=-20) macd_status+=20;
      if (macd_status<=-10) macd_status+=10;
      //if (sign>0 || (sign<0 && sign2<0 && macd_status>=-2)) close=-1;    //
      //if (sign<0 || (sign>0 && sign2>0 && macd_status<=2)) close2=1;     //
      if (sign>0 || (sign<0 && sign2<0 && macd_status>0)) close=-1;    //
      if (sign<0 || (sign>0 && sign2>0 && macd_status<0)) close2=1;     //
   }
   if ((close==-1 || close2==-1) && has_order) {
      //close opposit sell order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
         Print("close opposit(sell) order");
      }
   }
   /*
   if (sign==2 && has_order) {
      //close buy order
      if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
         Print("close buy order");
      }
   }
   */
   if ((close==1 || close2==1) && has_order) {
      //close opposit buy order
      if (OrderCloseA(NULL,1,g_magic)>0) {   //close buy order
         Print("close opposit(buy) order");
      }
   }
   /*
   if (sign==-2 && has_order) {
      //close sell order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
         Print("close sell order");
      }
   }
   */
   /*
   if (sign==1 && g_ma_cross==0 && has_order) {
      //close all order
      if (OrderCloseA(NULL,0,g_magic)>0) {  //close all order
         Print("close all order");
      }
   }
   */
   
   if (!FindOrderA(NULL,0,g_magic)) {
      has_order=false;
   }
   
   
   //debug
   if (now==i_inspect_dt) {
      Print("1.time=",now);
      Print("1.sign=",sign);
      Print("1.sign2=",sign2);
      Print("1.macd_fast=",macd_fast);
      Print("1.macd_slow=",macd_slow);
      Print("1.macd_range=",macd_range);
      Print("1.macd_status=",macd_status);
      Print("1.has_order=",has_order);
   }
   
   
   /*
   //modify buy order
   if (sign==2 && has_order) {
      if (FindOrderA(NULL,1,g_magic)) {   //buy order
         //moving stop
         double price,ls_price;
         price=Bid;
         int ls_pt=(int)NormalizeDouble((price-ls_tgt_price)/Point,0);
         if (ls_pt<i_min_ls_pt) {
            ls_price=NormalizeDouble(price-i_min_ls_pt*Point,Digits);
            Print("adjust ls_price(",ls_tgt_price," to at least ",i_min_ls_pt,"pt below(",ls_price,")");
         } else {
            ls_price=ls_tgt_price;
         }
         if (movingStop4(NULL,1,g_magic,ls_price,i_min_ls_pt)) {
            Print("movingstop of buy order");
         }
      }
   }

   //modify sell order
   if (sign==-2 && has_order) {
      if (FindOrderA(NULL,-1,g_magic)) {   //sell order
         //moving stop
         double price,ls_price;
         price=Ask;
         int ls_pt=(int)NormalizeDouble((ls_tgt_price-price)/Point,0);
         if (ls_pt<i_min_ls_pt) {
            ls_price=NormalizeDouble(price+i_min_ls_pt*Point,Digits);
            Print("adjust ls_price(",ls_tgt_price," to at least ",i_min_ls_pt,"pt above(",ls_price,")");
         } else {
            ls_price=ls_tgt_price;
         }
         if (movingStop4(NULL,-1,g_magic,ls_price,i_min_ls_pt)) {
            Print("movingstop of sell order");
         }
      }
   }
   */
   
   //open buy
   if ((open==1 || open2==1) && !has_order) {
      Print("Open buy order,",now);
      double price,ls_price;
      price=Bid;
      int ls_pt=(int)NormalizeDouble((price-ls_tgt_price)/Point,0);
      if (ls_pt<i_min_ls_pt) {
         ls_price=NormalizeDouble(price-i_min_ls_pt*Point,Digits);
         Print("adjust ls_price(",ls_tgt_price," to at least ",i_min_ls_pt,"pt below(",ls_price,")");
      } else {
         ls_price=ls_tgt_price;
      }

      if (OrderBuy2(0,ls_price,-1,g_magic)) {
         has_order=true;
         g_orderdt=now;
      }
   }
   
   //open sell
   if ((open==-1 ||open2==-1) && !has_order) {
      Print("Open sell order,",now);
      double price,ls_price;
      price=Ask;
      int ls_pt=(int)NormalizeDouble((ls_tgt_price-price)/Point,0);
      if (ls_pt<i_min_ls_pt) {
         ls_price=NormalizeDouble(price+i_min_ls_pt*Point,Digits);
         Print("adjust ls_price(",ls_tgt_price," to at least ",i_min_ls_pt,"pt above(",ls_price,")");
      } else {
         ls_price=ls_tgt_price;
      }

      if (OrderSell2(0,ls_price,-1,g_magic)) {
         has_order=true;
         g_orderdt=now;
      }
   }
   
}
bool ifClose(int arg_shift)
{
   /*
   if(isEndOfWeek(arg_shift)) {
      Print("market close,close all buy/sell order");
      if (OrderCloseA(NULL,0,g_magic)>0) return true;
   }
   */
   /*
   if (isTrendStgClose(arg_shift,g_adx_status)==1) {   //close buy or sell
      Print("trend close condition met,close buy or sell order");
      bool ret=OrderCloseA(NULL,1,g_magic);
      bool ret2=OrderCloseA(NULL,-1,g_magic);
      if (ret>0 || ret2>0) return true;
   }
   */
   
   return false;
}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (g_debug) {
      Print("OnTimer()");
   }
   
   /*
   if (!i_for_test) {
      news_read();
   }
   */
}

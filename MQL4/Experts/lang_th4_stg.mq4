//+------------------------------------------------------------------+
//|                                                 lang_th2_stg.mq4 |
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
input int   i_order_cnt=1;
input int   i_min_ls_pt=200;
input double i_band_ratio=0;
input int   i_st=0;
input bool  i_debug=true;

//--- global
int      g_magic=7;        //trend break and rebound
//datetime g_orderdt;
//int      g_com=0;    //1:buy,2:sell,0:N/A
int      g_st=0;  //1 for touch band high, -1 for touch band low

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
   g_magic+=Period();
   
   if (!i_for_test) {
      //if (!timer_init(SEC_H1)) return(INIT_FAILED);
      //news_impact();
   }
   
   g_st=i_st;
   
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
   int weekday=TimeDayOfWeek(now);

   if (ifClose(cur_bar_shift)) {
      Print("closed all order");
      return;
   }

   bool has_order=true;
      
   double ls_tgt_price;
   double sign=iCustom(NULL,PERIOD_CURRENT,"lang_th4_ind",false,i_band_ratio,0,last_bar_shift);

   //debug
   if (i_debug) {
      datetime t=Time[last_bar_shift];
      Print("time=",t,",signal=",sign,",g_st=",g_st);
   }
   
   if (sign>=0) {
      //close sell order
      if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
         if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
            Print("signal>=0,close sell order");
         }
      }
   }
   if (sign<=0) {
      //close buy order
      if(FindOrderA(NULL,1,g_magic)) {  //found buy order
         if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
            Print("signal<=0,close buy order");
         }
      }
   }
   
   if (sign==3) {    //touch band high
      g_st=1;
   } else 
   if (sign==-3) {   //touch band low
      g_st=-1;
   }
   
   if (sign==0) {
      g_st=0;
   }

   if (sign>0) {
      if (g_st<0) g_st=0;
   } else
   if (sign<0) {
      if (g_st>0) g_st=0;
   }
   
   int buy_order_cnt,sell_order_cnt;
   buy_order_cnt=sell_order_cnt=0;
   double order_pft=0;
   if (!FindOrderCnt(NULL,g_magic,buy_order_cnt,sell_order_cnt,order_pft)) {
      has_order=false;
   } else {
      //moving stop set to nonrisk
      if (movingStop3(NULL,g_magic,last_bar_shift)) {
         Print("moving stop!");
      }
   }
   if (i_debug) {
      datetime t=Time[last_bar_shift];
      Print("time=",t,",b_cnt=",buy_order_cnt,",s_cnt=",sell_order_cnt,",profit=",order_pft);
   }

   int dev2=4;
   double d4_low=iBands(NULL,PERIOD_CURRENT,720,dev2,0,PRICE_CLOSE,MODE_LOWER,last_bar_shift);
   double d4_high=iBands(NULL,PERIOD_CURRENT,720,dev2,0,PRICE_CLOSE,MODE_UPPER,last_bar_shift);

   //open buy
   if (sign==2 && g_st==1) {  //touched band high and touching band ma
      ls_tgt_price=d4_low;
      Print("Open buy order,",now);
      double price,price2,ls_price;
      price=Ask;
      price2=Bid;
      int ls_pt=(int)NormalizeDouble((price-ls_tgt_price)/Point,0);
      if (ls_pt>=i_min_ls_pt) {
         ls_price=ls_tgt_price;
         /*
         for (int i=0;i<i_order_cnt;i++) {
            double tp_price=price2+(i+1)*ls_pt*Point;
            if (OrderBuy2(0,ls_price,tp_price,g_magic)) {
               Print("buy order opened for ",i);
            }
         }
         */
         if (i_order_cnt>buy_order_cnt) {
            if (OrderBuy2(0,ls_price,-1,g_magic)) {
               Print("buy order opened for ",buy_order_cnt);
            }
         }
      } else {
         Print("ls_pt (",ls_pt," is not enough for ",i_min_ls_pt);
      }
   }
   
   //open sell
   if (sign==-2 && g_st==-1) {  //touched band low and touching band ma
      ls_tgt_price=d4_high;
      Print("Open sell order,",now);
      double price,price2,ls_price;
      price=Bid;
      price2=Ask;
      int ls_pt=(int)NormalizeDouble((ls_tgt_price-price)/Point,0);

      if (ls_pt>=i_min_ls_pt) {
         ls_price=ls_tgt_price;
         /*
         for (int i=0;i<i_order_cnt;i++) {
            double tp_price=price2-(i+1)*ls_pt*Point;
            if (OrderSell2(0,ls_price,tp_price,g_magic)) {
               Print("sell order opened for ",i);
            }
         }
         */
         if (i_order_cnt>sell_order_cnt) {
            if (OrderSell2(0,ls_price,-1,g_magic)) {
               Print("sell order opened for ",sell_order_cnt);
            }
         }
      } else {
         Print("ls_pt (",ls_pt," is not enough for ",i_min_ls_pt);
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
   
   return false;
}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (g_debug) {
      Print("OnTimer()");
   }

   if (!i_for_test) {
      //g_com=file_read();
      //news_impact();
   }
}

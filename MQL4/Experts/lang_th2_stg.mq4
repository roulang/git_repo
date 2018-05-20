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
input int   i_short_pd=5;
input int   i_mid_pd=10;
input int   i_long_pd=20;
input int   i_exp_pd=0;
input bool  i_debug=true;

//--- global
int      g_magic=6;        //trend rebound
//datetime g_orderdt;
int      g_com=0;

int g_last_band_st=0;

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
   //g_magic+=Period();
   
   if (!i_for_test) {
      if (!timer_init(SEC_H1)) return(INIT_FAILED);
   }
   
   //news_read();
   
   
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

   if (ifClose(cur_bar_shift)) {
      Print("closed all order");
      return;
   }

   bool has_order=true;
   
   /*
   if (!FindOrderA(NULL,0,g_magic)) {
      has_order=false;
   }
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
   //int sign=isTrendStgOpen4(last_bar_shift,ls_tgt_price,g_last_band_st,i_exp_pd);
   int dev2=4;
   double d4_low=iBands(NULL,PERIOD_CURRENT,i_mid_pd,dev2,0,PRICE_CLOSE,MODE_LOWER,last_bar_shift);
   double d4_high=iBands(NULL,PERIOD_CURRENT,i_mid_pd,dev2,0,PRICE_CLOSE,MODE_UPPER,cur_bar_shift);
   double sign=iCustom(NULL,PERIOD_CURRENT,"lang_th2_ind",false,i_short_pd,i_mid_pd,i_long_pd,i_exp_pd,0,last_bar_shift);

   //debug
   if (i_debug) {
      datetime t=Time[last_bar_shift];
      Print("time=",t,"signal=",sign,",com=",g_com);
   }
   
   
   if (sign>=0 || g_com>=0) {
      //close sell order
      if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
         if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
            Print("(signal/com)>=0,close sell order");
         }
      }
   }
   if (sign<=0 || g_com<=0) {
      //close buy order
      if(FindOrderA(NULL,1,g_magic)) {  //found buy order
         if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
            Print("(signal/com)<=0,close buy order");
         }
      }
   }
   
   int buy_order_cnt,sell_order_cnt;
   buy_order_cnt=sell_order_cnt=0;
   if (!FindOrderCnt(NULL,g_magic,buy_order_cnt,sell_order_cnt)) {
      has_order=false;
   }
   if (i_debug) {
      datetime t=Time[last_bar_shift];
      Print("time=",t,"b_cnt=",buy_order_cnt,",s_cnt=",sell_order_cnt);
   }

   //open buy
   if (sign==2 && g_com>0 && !has_order) {
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
            double tp_price=price2+(i_order_cnt-buy_order_cnt)*ls_pt*Point;
            if (OrderBuy2(0,ls_price,tp_price,g_magic)) {
               Print("buy order opened for ",buy_order_cnt);
            }
         }
      } else {
         Print("ls_pt (",ls_pt," is not enough for ",i_min_ls_pt);
      }
   }
   
   //open sell
   if (sign==-2 && g_com<0 && !has_order) {
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
            double tp_price=price2-(i_order_cnt-sell_order_cnt)*ls_pt*Point;
            if (OrderSell2(0,ls_price,tp_price,g_magic)) {
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
      g_com=file_read();
      //news_read();
   }
}

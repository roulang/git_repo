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

//--- global
int      g_magic=5;        //trend horse
//bool     g_has_order=false;
datetime g_orderdt;

int g_ma_cross=0;    //1,fast ma up cross slow ma;-1,fast ma down cross slow ma
int g_adx_status=0;  //1,above 40(default);-1,below 40(default)
int g_min_ls_pt=300;

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
   int sign=isTrendStgOpen(last_bar_shift,g_ma_cross,ls_tgt_price);
   if (sign>=1 && has_order) {
      //close opposit sell order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
         Print("close opposit(sell) order");
      }
   }
   if (sign<=-1 && has_order) {
      //close opposit buy order
      if (OrderCloseA(NULL,1,g_magic)>0) {   //close buy order
         Print("close opposit(buy) order");
      }
   }
   /*
   if (sign==1 $$ g_ma_cross==0 && has_order) {
      //close all order
      if (OrderCloseA(NULL,0,g_magic)>0) {  //close all order
         Print("close all order");
      }
   }
   */
   
   if (!FindOrderA(NULL,0,g_magic)) {
      has_order=false;
   }
   
   //modify buy order
   if (sign==3 && has_order) {
      if (FindOrderA(NULL,1,g_magic)) {   //buy order
         //moving stop
         double price,ls_price;
         price=Bid;
         int ls_pt=(int)NormalizeDouble((price-ls_tgt_price)/Point,0);
         if (ls_pt<g_min_ls_pt) {
            ls_price=NormalizeDouble(price-g_min_ls_pt*Point,Digits);
            Print("adjust ls_price(",ls_tgt_price," to at least ",g_min_ls_pt,"pt below(",ls_price,")");
         } else {
            ls_price=ls_tgt_price;
         }
         if (movingStop4(NULL,1,g_magic,ls_price,g_min_ls_pt)) {
            Print("movingstop of buy order");
         }
      }
   }

   //modify sell order
   if (sign==-3 && has_order) {
      if (FindOrderA(NULL,-1,g_magic)) {   //sell order
         //moving stop
         double price,ls_price;
         price=Ask;
         int ls_pt=(int)NormalizeDouble((ls_tgt_price-price)/Point,0);
         if (ls_pt<g_min_ls_pt) {
            ls_price=NormalizeDouble(price+g_min_ls_pt*Point,Digits);
            Print("adjust ls_price(",ls_tgt_price," to at least ",g_min_ls_pt,"pt above(",ls_price,")");
         } else {
            ls_price=ls_tgt_price;
         }
         if (movingStop4(NULL,-1,g_magic,ls_price,g_min_ls_pt)) {
            Print("movingstop of sell order");
         }
      }
   }

   //open buy
   if (sign==3 && !has_order) {
      Print("Open buy order,",now);
      double price,ls_price;
      price=Bid;
      int ls_pt=(int)NormalizeDouble((price-ls_tgt_price)/Point,0);
      if (ls_pt<g_min_ls_pt) {
         ls_price=NormalizeDouble(price-g_min_ls_pt*Point,Digits);
         Print("adjust ls_price(",ls_tgt_price," to at least ",g_min_ls_pt,"pt below(",ls_price,")");
      } else {
         ls_price=ls_tgt_price;
      }

      if (OrderBuy2(0,ls_price,-1,g_magic)) {
         has_order=true;
         g_orderdt=now;
      }
   }
   
   //open sell
   if (sign==-3 && !has_order) {
      Print("Open sell order,",now);
      double price,ls_price;
      price=Ask;
      int ls_pt=(int)NormalizeDouble((ls_tgt_price-price)/Point,0);
      if (ls_pt<g_min_ls_pt) {
         ls_price=NormalizeDouble(price+g_min_ls_pt*Point,Digits);
         Print("adjust ls_price(",ls_tgt_price," to at least ",g_min_ls_pt,"pt above(",ls_price,")");
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
   
   if (isTrendStgClose(arg_shift,g_adx_status)==1) {   //close buy or sell
      Print("trend close condition met,close buy or sell order");
      bool ret=OrderCloseA(NULL,1,g_magic);
      bool ret2=OrderCloseA(NULL,-1,g_magic);
      if (ret>0 || ret2>0) return true;
   }
   
   return false;
}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (g_debug) {
      Print("OnTimer()");
   }

   if (!i_for_test) {
      news_read();
   }
}

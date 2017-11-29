//+------------------------------------------------------------------+
//|                                                 lang_evt_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ea_inc.mqh>

//--- global
int      g_magic=1;        //evt(break)
bool     g_has_order=false;
datetime g_orderdt;

//--------------------------------

//input

//global
int      g_ls_pt=50;
int      g_hl_gap_pt=150;
double   g_hl_gap_ratio=2;

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
   
   if (!i_for_test) {
      if (!timer_init(SEC_H1)) return(INIT_FAILED);
   }
   
   news_read();

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
   
   if (!i_for_test) {
      timer_deinit();
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

   //check if exists any order
   if (g_has_order) {
      if (FindOrderA(NULL,1,g_magic)) {  //found buy order
         if (ifClose(last_bar_shift,1)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
         /*
         //move lose stop
         if (movingStop3(NULL,g_magic,last_bar_shift)) {
            Print("movingstop of buy order");
         }
         */
      } else if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
         if (ifClose(last_bar_shift,-1)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
         /*
         //move lose stop
         if (movingStop3(NULL,g_magic,last_bar_shift)) {
            Print("movingstop of buy order");
         }
         */
      } else {    //not found buy and sell order
         g_has_order=false;
      }
   }
   
   //news time control
   bool newsPd=isNewsPd(NULL,cur_bar_shift,0,i_news_aft);
   if (i_time_control && !newsPd) {          //avoid to open break order in non-event time
      //Print("avoid to break in not event time.");
      return;
   }

   double price[2],ls_price[2];
   int sign;
   sign=isQuickShootOpen(last_bar_shift,g_ls_pt,g_hl_gap_pt,g_hl_gap_ratio,price,ls_price,true);
   
   if (sign==1 && g_has_order) {    //break up,have order
      //close opposit order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
         Print("close opposit(sell) order");
         g_has_order=false;
      }
   }

   if (sign==-1 && g_has_order) {   //break down,have order
      //close opposit order
      if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
         Print("close opposit(buy) order");
         g_has_order=false;
      }
   }
   
   //break(up)
   if (sign==1 && !g_has_order) {
      Print("ready to break up.create buy order.");
      double ls_gap=NormalizeDouble(price[0]-ls_price[0],Digits);
      int ls_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("price=",price[0],",ls_price=",ls_price[0],",ls_gap_pt=",ls_gap_pt);
      if (!g_debug) {
         bool ret;
         ret=OrderBuy2(0,ls_price[0],-1,g_magic);
         if (ret) {
            g_has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }

   //break(down)
   if (sign==-1 && !g_has_order) {
      Print("ready to break down.create sell order.");
      double ls_gap=NormalizeDouble(ls_price[1]-price[1],Digits);
      int ls_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("price=",price[1],",ls_price=",ls_price[1],",ls_gap_pt=",ls_gap_pt);
      if (!g_debug) {
         bool ret;
         ret=OrderSell2(0,ls_price[1],-1,g_magic);
         if (ret) {
            g_has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }

}
//arg_status:1,has buy order;-1,has sell order
bool ifClose(int arg_shift,int arg_status)
{
   if(isEndOfWeek(arg_shift)) {
      Print("market close,close all buy/sell order");
      if (OrderCloseA(NULL,0,g_magic)>0) return true;
   }
   
   int ret=isQuickShootClose(arg_shift);
   if (ret==1 && arg_status==-1) {  //close sell
      Print("qs close sell meet, close sell order");
      if (OrderCloseA(NULL,-1,g_magic)>0) return true;
   }
   if (ret==-1 && arg_status==1) {  //close buy
      Print("gs close buy meet, close buy order");
      if (OrderCloseA(NULL,1,g_magic)>0) return true;
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

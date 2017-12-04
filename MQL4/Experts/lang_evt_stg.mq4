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
int      g_magic=1;              //evt(high/low buy/sell stop)
bool     g_has_order=false;
datetime g_orderdt;
int      g_time_ped=SEC_H1;      //60 minutes

//--------------------------------

//input

//global
int      g_thpt=80;
int      g_thpt2=50;
int      g_offset_pt=20;
int      g_expand=1;
int      g_long=1;
int      g_range=20;
int      g_max_ls_pt=200;

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

   int isPd3=isNewsPd3(NULL,cur_bar_shift);    //news zone control
   
   /*
   if (isPd3>0 && g_has_order) {
      Print("news time start, close all order");
      OrderCloseA(NULL,0,g_magic);   //close all order
      if (!FindOrderA(NULL,0,g_magic)) {
         g_has_order=false;
      }
   }
   */

   //check if exists any order
   if (g_has_order) {
      if (FindOrderA(NULL,1,g_magic)) {  //found buy order
         if (OrderCloseA(NULL,-2,g_magic)>0) {   //close sellstop order
            Print("found buy order,close sellstop order");
         }
         /*
         //move lose stop
         if (movingStop3(NULL,g_magic,last_bar_shift)) {
            Print("movingstop of buy order");
         }
         */
         
         if (ifClose(last_bar_shift,1)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      } else if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
         if (OrderCloseA(NULL,2,g_magic)>0) {    //close buystop order
            Print("found sell order,close buystop order");
         }
         /*
         //move lose stop
         if (movingStop3(NULL,g_magic,last_bar_shift)) {
            Print("movingstop of buy order");
         }
         */

         if (ifClose(last_bar_shift,-1)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      } else {    //not found buy and sell order
         //Print("not found buy and sell order");
         if (isPd3>0 && now!=g_orderdt) {    //another news time start
            Print("another news time start, close old order and open new");
            OrderCloseA(NULL,-2,g_magic);    //close sellstop order
            OrderCloseA(NULL,2,g_magic);     //close buystop order
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         } else
         if ((now-g_orderdt)>g_time_ped) {   //timeover
            Print("over time, close buy stop and sell stop order");
            OrderCloseA(NULL,-2,g_magic);    //close sellstop order
            OrderCloseA(NULL,2,g_magic);     //close buystop order
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      }
   }
   
   if (isPd3>0 && !g_has_order) {
      double price[2],ls_price[2];
      
      getHighLow_Value(cur_bar_shift,g_expand,g_range,g_long,g_thpt,g_thpt2,g_offset_pt,g_max_ls_pt,price,ls_price);

      if (price[0]>0 && ls_price[0]>0) {
         Print("Open buy stop order,",now);
         if (OrderBuy2(price[0],ls_price[0],-1,g_magic)) {
            g_has_order=true;
            g_orderdt=now;
         }
      }
      if (price[1]>0 && ls_price[1]>0) {
         Print("Open sell stop order,",now);
         if (OrderSell2(price[1],ls_price[1],-1,g_magic)) {
            g_has_order=true;
            g_orderdt=now;
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

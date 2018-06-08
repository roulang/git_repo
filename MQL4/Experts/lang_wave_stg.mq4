//+------------------------------------------------------------------+
//|                                                 lang_wave_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_inc.mqh>
#include <lang_stg_inc.mqh>

//--- input
input int   i_deviation_st=0;          // Deviation,should set to equal to zigzag's deviation value
input int   i_deviation_md=0;          // Deviation,should set to equal to zigzag's deviation value
input int   i_deviation_lg=0;          // Deviation,should set to equal to zigzag's deviation value
input int   i_thredhold=0;          // breakthrough thredhold point
input bool  i_time_control=false;   // time zone control
input bool  i_news_skip=false;      // news zone skip
input int   i_news_bef=SEC_H1/4;    // news before 15 minutes
input int   i_news_aft=SEC_H1;      //news after 1 hour
input int   i_zone_bef=SEC_H1/2;    //time zone before 30 minutes
input int   i_zone_aft=SEC_H1;      //time zone after 1 hour

//--- global
int      g_rp=1;           //risk percentage
int      g_magic=3;        //break or kick back
bool     g_has_order=false;
datetime g_orderdt;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   if (i_debug) {
      Print("OnInit()");
   }
   
   ea_init();
   
   if (!i_for_test) {
      if (!timer_init(SEC_H1)) return(INIT_FAILED);
   }
   
   news_read();
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if (i_debug) {
      Print("OnDeinit()");
   }
   
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   int bar_shift=isNewBar();
   if (bar_shift==0) return;

   datetime now=Time[bar_shift-1];

   //check if exists any order
   if (g_has_order) {
      if       (FindOrderA(NULL,1,g_magic)) {  //found buy order
         if (ifClose(bar_shift)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      } else if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
         if (ifClose(bar_shift)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      } else {    //not found buy and sell order
         g_has_order=false;
      }
   }
   
   //news time skip control
   bool newsPd=isNewsPd(NULL,bar_shift,i_news_bef,i_news_aft);
   if (g_has_order && i_news_skip && newsPd) {
      Print("new time skip control:news time start, close all order");
      OrderCloseA(NULL,0,g_magic);   //close all order
      if (!FindOrderA(NULL,0,g_magic)) {
         g_has_order=false;
      }
      return;
   }

   int lst_stupi,lst_mdupi,lst_stdwi,lst_mddwi;
   int sign=getZigTurn(bar_shift,i_deviation_st,i_deviation_md,i_deviation_lg,i_thredhold,lst_stupi,lst_mdupi,lst_stdwi,lst_mddwi);
   
   //active time zone control
   bool curPd=isCurPd(NULL,bar_shift,i_zone_bef,i_zone_aft);
   if ((sign==3 || sign==-3) && i_time_control && !curPd) {
      Print("timezone control:not active time.");
      return;
   }
   if ((sign==3 || sign==-3) && i_news_skip && newsPd) {
      Print("news time skip control:not active time.");
      return;
   }
   
   if (sign==3 && g_has_order) {    //turn up,have order
      //close opposit order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
         Print("close opposit(sell) order");
         g_has_order=false;
      }
   }
   if (sign==3 && !g_has_order) {   //turn up
      Print("ready to turn up.create buy order.");
      double ls_price,tp_price;
      ls_price=Low[bar_shift+lst_mdupi];
      //tp_price=High[bar_shift+lst_mddwi];
      tp_price=-1;
      if (OrderBuy2(0,ls_price,tp_price,g_magic)) {
         g_has_order=true;
         g_orderdt=now;
         return;
      }
   }
   if (sign==-3 && g_has_order) {   //turn down,have order
      //close opposit order
      if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
         Print("close opposit(buy) order");
         g_has_order=false;
      }
   }
   if (sign==-3 && !g_has_order) {  //turn down
      Print("ready to turn down.create sell order.");
      double ls_price,tp_price;
      ls_price=High[bar_shift+lst_mddwi];
      //tp_price=Low[bar_shift+lst_mdupi];
      tp_price=-1;
      if (OrderSell2(0,ls_price,tp_price,g_magic)) {
         g_has_order=true;
         g_orderdt=now;
         return;
      }
   }
}
bool ifClose(int arg_shift)
{
   bool ret=false;
   
   int op1=ShotShootStgValue(arg_shift+1);   //par and avg control
   int op2=ShotShootStgValue(arg_shift);     //par and avg control
   
   if ((op1<0 && op2<0)) {  // close buy signal
      printf("close buy order");
      if (OrderCloseA(NULL,1,g_magic)>0) return true;
   }

   if ((op1>0 && op2>0)) {  // close sell signal
      printf("close sell order");
      if (OrderCloseA(NULL,-1,g_magic)>0) return true;
   }
   
   return false;
}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (i_debug) {
      Print("OnTimer()");
   }

   if (!i_for_test) {
      news_read();
   }
}

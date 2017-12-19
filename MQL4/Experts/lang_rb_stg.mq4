//+------------------------------------------------------------------+
//|                                                 lang_ea_test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ea_inc.mqh>

//--- global
int      g_magic=3;        //rebound and break
//bool     g_has_order=false;
datetime g_orderdt;
int      g_ls_pt=50;
string   g_comment="3";

//--------------------------------

//input
input int      i_range=20;
input int      i_thredhold_pt=0;
input int      i_expand=1;
input bool     i_manual=false;

//global
int      g_tp_offset=10;
int      g_zone_aft=-SEC_H1*4;

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
   
   double price[4],ls_price[4],tp_price[4][2];
   int ls_price_pt[4],tp_price_pt[4][2];
   int high_low_touch_status=0;
   int touch_status=0;
   int sign;
   //sign=isBreak_Rebound2(last_bar_shift,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,touch_status,i_range,i_thredhold_pt,i_expand,5,150,20);
   /*
   sign=isBreak_Rebound3(last_bar_shift,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,
                        range_high2,range_low2,range_high2_gap_pt,range_low2_gap_pt,touch_status,
                        i_range,i_thredhold_pt,i_expand,5,150,20);
   */
   sign=getHighLow_Value2(last_bar_shift,touch_status,price,ls_price,tp_price,ls_price_pt,tp_price_pt,g_ls_pt);
   
   if (touch_status>=3 && has_order) {    //break up,have order
      //close opposit order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
         Print("close opposit(sell) order");
         has_order=false;
      }
   }

   if (touch_status<=-3 && has_order) {   //break down,have order
      //close opposit order
      if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
         Print("close opposit(buy) order");
         has_order=false;
      }
   }
   
   //active time zone control
   bool curPd=isCurPd(NULL,cur_bar_shift,i_zone_bef,g_zone_aft);
   if (MathAbs(sign)==3 && i_time_control && !curPd) {      //break
      Print("timezone control:avoid to break in non-active time.");
      return;
   }
   /*
   if (MathAbs(sign)==2 && i_time_control && curPd) {       //rebound
      Print("news time skip control:not active time.");
      return;
   }
   */
   
   //open order
   //buy_break/buy_rebound/sell_break/sell_rebound
   int buy_break_idx=0;
   int buy_rebound_idx=1;
   int sell_break_idx=2;
   int sell_rebound_idx=3;
   int idx=-1;
   
   if (!has_order) {
      switch(sign) {
         case 2:        //rebound(up)
            Print("ready to turn up.create buy order.");
            idx=buy_rebound_idx;
            break;
         case -2:       //rebound(down)
            Print("ready to turn down.create sell order.");
            idx=sell_rebound_idx;
            break;
         case 3:        //break(up)
            Print("ready to break up.create buy order.");
            idx=buy_break_idx;
            break;
         case -3:       //break(down)
            Print("ready to break down.create sell order.");
            idx=sell_break_idx;
            break;
         case 4:        //break(up) second
            Print("ready to break up(second).create buy order.");
            idx=buy_break_idx;
            break;
         case -4:       //break(down) second
            Print("ready to break down(second).create sell order.");
            idx=sell_break_idx;
            break;
         default:
            break;
      }
      
      if (idx>=0 && !g_debug && !i_manual) {
         double t_price=price[idx];
         double t_ls_price=ls_price[idx];
         double t_ls_gap=MathAbs(ls_price_pt[idx]);
         double t_tp_price=tp_price[idx][0];
         double t_tp_price2=tp_price[idx][1];
         int t_tp_gap_pt=MathAbs(tp_price_pt[idx][0]);
         int t_tp_gap2_pt=MathAbs(tp_price_pt[idx][1]);

         Print("Time=",Time[cur_bar_shift]);
         Print("price=",t_price,",ls_price=",t_ls_price,",ls_gap=",t_ls_gap);
         Print("tp_price=",t_tp_price,",tp_price2=",t_tp_price2,",tp_gap_pt=",t_tp_gap_pt,",tp_gap2_pt=",t_tp_gap2_pt);
   
         bool ret,ret2;
         ret=ret2=0;
         if (t_tp_price>0) {
            ret=OrderBuy2(0,t_ls_price,t_tp_price,g_magic);
         }
         if (t_tp_price2>0) {
            ret2=OrderBuy2(0,t_ls_price,t_tp_price2,g_magic);
         }
         if (ret || ret2) {
            //has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }
}
bool ifClose(int arg_shift)
{
   if(isEndOfWeek(arg_shift)) {
      Print("market close,close all buy/sell order");
      if (OrderCloseA(NULL,0,g_magic)>0) return true;
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

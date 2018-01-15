//+------------------------------------------------------------------+
//|                                                lang_evt2_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ea_inc.mqh>

//--- input
input int   i_th_pt=100;
input int   i_th2_pt=50;
input int   i_time_ped=SEC_H1/4;

//--- global
int      g_magic=11;              //evt(break)
int      g_magic2=12;             //evt(rebound)

//bool     g_has_order=false;
datetime g_start_dt;
bool     g_start=false;
double   g_price[2],g_ls_price[2];
double   g_price_range;

//--------------------------------

//global
int      g_expand=1;
int      g_long=1;
int      g_range=20;
double   g_ls_ratio=0.6;
double   g_high_low_range=0;

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

   bool has_order=true;
   int cur_bar_shift=0;
   int last_bar_shift=1;
   datetime now=Time[cur_bar_shift];

   int isPd3=isNewsPd3(NULL,cur_bar_shift);     //news zone control
   
   //check if exists any break order
   if (FindOrderA(NULL,1,g_magic)) {            //found buy order (break)
      if (ifClose(last_bar_shift,1,1)) {
         Print("closed buy break order");
      }
   }
   if (FindOrderA(NULL,-1,g_magic)) {           //found sell order (break)
      if (ifClose(last_bar_shift,-1,1)) {
         Print("closed sell break order");
      }
   }

   //check if exists any rebound order
   if (FindOrderA(NULL,1,g_magic2)) {           //found buy order (rebound)
      if (ifClose(last_bar_shift,1)) {
         Print("closed buy rebound order");
      }
   }
   if (FindOrderA(NULL,-1,g_magic2)) {          //found sell order (rebound)
      if (ifClose(last_bar_shift,-1)) {
         Print("closed sell rebound order");
      }
   }

   if (!FindOrderA(NULL,0,g_magic) && !FindOrderA(NULL,0,g_magic2)) {
      has_order=false;
   }
   
   /*
   if (isPd3>0 && g_has_order) {
      Print("news time start, close all order");
      OrderCloseA(NULL,0,g_magic);   //close all order
      if (!FindOrderA(NULL,0,g_magic)) {
         g_has_order=false;
      }
   }
   */

   if (g_start && (now-g_start_dt)>i_time_ped) {   //timeover
      Print("news time over, avoid to open order");
      g_start=false;
   }
   
   if (isPd3>0) {
      Print("news time start, prepare to open order");
      g_start=true;
      g_start_dt=now;
      getHighLow_Value(cur_bar_shift,g_expand,g_range,g_long,i_th_pt,i_th2_pt,0,0,g_price,g_ls_price);
      if (g_price[0]>0 && g_price[1]>0) {
         g_high_low_range=g_price[0]-g_price[1];
         g_high_low_range=NormalizeDouble(g_high_low_range,Digits);
         Print("high_range=",g_price[0],",low_range=",g_price[1]);
      } else {
         g_high_low_range=0;
      }
   }
   
   if (g_start && !has_order) {
      double ask_price=Ask;
      double bid_price=Bid;
      double last_bar_open=Open[last_bar_shift];
      double last_bar_close=Close[last_bar_shift];
      double last_bar_high=High[last_bar_shift];
      double last_bar_low=Low[last_bar_shift];
      int last_bar_status=0;
      double last_bar_sub_high=0;
      double last_bar_sub_low=0;
      if (last_bar_open>last_bar_close) last_bar_status=1;     //negative bar
      if (last_bar_status==0) {
         last_bar_sub_high=last_bar_close;      //positive bar
         last_bar_sub_low=last_bar_open;        //positive bar
      } else {
         last_bar_sub_high=last_bar_open;       //negative bar
         last_bar_sub_low=last_bar_close;       //negative bar
      }
      //check bar status
      double high_price=g_price[0];
      double low_price=g_price[1];
      if (g_high_low_range>0) {
         if (last_bar_low<low_price && last_bar_sub_low>low_price) {      //rebound up
            Print("Open buy order(rebound up),",now);
            double ls_tgt_price=last_bar_low-i_ls_pt*Point;
            ls_tgt_price=NormalizeDouble(ls_tgt_price,Digits);
            int    ls_tgt_pt=(int)NormalizeDouble((bid_price-ls_tgt_price)/Point,0);
            int    tp_tgt_pt=2*ls_tgt_pt;
            double tp_tgt_price=bid_price+tp_tgt_pt*Point;
            tp_tgt_price=NormalizeDouble(tp_tgt_price,Digits);
            if (OrderBuy2(0,ls_tgt_price,tp_tgt_price,g_magic2)) {    //open buy rebound order
               has_order=true;
            }
         } else
         if (last_bar_low<low_price && last_bar_sub_low<low_price && last_bar_status==1) {      //break down
            Print("Open sell order(break down),",now);
            double ls_tgt_price=low_price+g_high_low_range*g_ls_ratio;
            ls_tgt_price=NormalizeDouble(ls_tgt_price,Digits);
            int    ls_tgt_pt=(int)NormalizeDouble((ls_tgt_price-ask_price)/Point,0);
            if (OrderSell2(0,ls_tgt_price,-1,g_magic)) {             //open sell break order
               has_order=true;
            }
         } else
         if (last_bar_high>high_price && last_bar_sub_high<high_price) {  //rebound down
            Print("Open sell order(rebound down),",now);
            double ls_tgt_price=last_bar_high+i_ls_pt*Point;
            ls_tgt_price=NormalizeDouble(ls_tgt_price,Digits);
            int    ls_tgt_pt=(int)NormalizeDouble((ls_tgt_price-ask_price)/Point,0);
            int    tp_tgt_pt=2*ls_tgt_pt;
            double tp_tgt_price=ask_price-tp_tgt_pt*Point;
            tp_tgt_price=NormalizeDouble(tp_tgt_price,Digits);
            if (OrderSell2(0,ls_tgt_price,tp_tgt_price,g_magic2)) {  //open sell rebound order
               has_order=true;
            }
         } else
         if (last_bar_high>high_price && last_bar_sub_high>high_price && last_bar_status==0) {  //break up
            Print("Open buy order(break up),",now);
            double ls_tgt_price=high_price-g_high_low_range*g_ls_ratio;
            ls_tgt_price=NormalizeDouble(ls_tgt_price,Digits);
            int    ls_tgt_pt=(int)NormalizeDouble((bid_price-ls_tgt_price)/Point,0);
            if (OrderBuy2(0,ls_tgt_price,-1,g_magic)) {    //open buy break order
               has_order=true;
            }
         }
      }

   }

}
//arg_status:1,has buy order;-1,has sell order
//arg_qs:0 for rebound,1 for break
bool ifClose(int arg_shift,int arg_status,int arg_qs=0)
{
   if(isEndOfWeek(arg_shift)) {
      Print("market close,close all buy/sell break/rebound order");
      int ret=0,ret2=0;
      if (arg_qs==1 && OrderCloseA(NULL,0,g_magic)>0) return true;   //close break order
      if (arg_qs==0 && OrderCloseA(NULL,0,g_magic2)>0) return true;  //close rebound order
   }
   
   if (arg_qs==1) {     //check to close break order
      int ret=isQuickShootClose(arg_shift);
      if (ret==1 && arg_status==-1) {  //close sell
         Print("qs close sell meet, close sell order");
         if (OrderCloseA(NULL,-1,g_magic)>0) return true;
      }
      if (ret==-1 && arg_status==1) {  //close buy
         Print("gs close buy meet, close buy order");
         if (OrderCloseA(NULL,1,g_magic)>0) return true;
      }
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

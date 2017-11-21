//+------------------------------------------------------------------+
//|                                                lang_news_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ea_inc.mqh>

//--- input
input bool     i_skiptd=false;   //skip trend control
input int      i_range=20;
input int      i_thredhold_pt=100;
input int      i_expand=1;
input int      i_long=1;

//global
int      g_tp_offset=20;

//--- global
//string   com="event stg";
int      g_magic=1;        //event magic
bool     g_has_order=false;
datetime g_orderdt;
int      g_time_ped=600;  //10 minutes

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   g_debug=false;
   
   if (g_debug) {
      Print("OnInit()");
   }
   ea_init();
   
   //Print("has_order=",has_order);
   
   if (!i_for_test) {
      if (!timer_init()) return(INIT_FAILED);
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
   if (isPd3>0 && !g_has_order) {
      double price[2],ls_price[2],tp_price[2];
      getHighLow_Value(cur_bar_shift,i_expand,i_range,i_long,i_thredhold_pt,g_tp_offset,price,ls_price,tp_price);
      
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
      return;
   }

   if (g_has_order) {
      if       (FindOrderA(NULL,1,g_magic)) {  //found buy order
         Print("found buy order,close sellstop order");
         OrderCloseA(NULL,-2,g_magic);   //close sellstop order
         
         /*
         //move lose stop, set no risk
         if (movingStop2(NULL,1,mag,bar_shift,i_SL,0)) {
            Print("movingstop of buy order");
         }
         */
         if (ifClose(last_bar_shift)) {
            //Print("closed buy order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      } else if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
         Print("found sell order,close buystop order");
         OrderCloseA(NULL,2,g_magic);    //close buystop order
         
         /*
         //move lose stop, set no risk
         if (movingStop2(NULL,-1,mag,bar_shift,i_SL,0)) {
            Print("movingstop of sell order");
         }
         */
         if (ifClose(last_bar_shift)) {
            //Print("closed sell order");
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      } else {    //not found buy and sell order
         //Print("not found buy and sell order");
         if ((now-g_orderdt)>g_time_ped) {  //timeover
            Print("over time, close buy stop and sell stop order");
            OrderCloseA(NULL,-2,g_magic);   //close sellstop order
            OrderCloseA(NULL,2,g_magic);    //close buystop order
            if (!FindOrderA(NULL,0,g_magic)) {
               g_has_order=false;
            }
         }
      }
   }
   
   //Print("has_order=",has_order);
   
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   if(g_debug) Print("OnTimer()");
   if (!i_for_test) {
      news_read();
   }
}
//+------------------------------------------------------------------+
bool ifClose(int shift)
{
   bool ret=false;
   
   int op1=ShotShootStgValue(shift+1);   //par and avg control
   int op2=ShotShootStgValue(shift);     //par and avg control
   int td=0;
   if (!i_skiptd) td=TrendStgValue2(shift);          //trend control
   
   if ((op1<0 && op2<0)||td==3) {  // close buy signal
      printf("close buy order");
      if (OrderCloseA(NULL,1,g_magic)>0) return true;
   }

   if ((op1>0 && op2>0)||td==-3) {  // close sell signal
      printf("close sell order");
      if (OrderCloseA(NULL,-1,g_magic)>0) return true;
   }
   
   return false;
}

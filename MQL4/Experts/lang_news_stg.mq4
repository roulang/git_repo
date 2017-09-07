//+------------------------------------------------------------------+
//|                                                lang_news_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_stg_inc.mqh>

//--- input
input int      i_SL=100;         //take lose point
input int      i_rate_SL=100;    //take lose point(rate control)
input int      i_OPT=150;        //oo offset
input bool     i_skiptd=false;   //skip trend control
input bool     i_rate_ctl=true;  //rate control(not do OO,avoid slippage)

//--- global
//string   com="event stg";
int      mag=1;         //event magic
int      time_ped=300;  //5 minutes
bool     has_order=false;
datetime orderdt;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if (i_debug) {
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
   if (i_debug) {
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
   int bar_shift=isNewBar();
   if (bar_shift==0) return;

   datetime now=Time[bar_shift-1];
   
/*
   bool isPd2=isNewsPd2(NULL,bar_shift-1);    //news zone control
   if (isPd2 && !has_order) {
      //Print("Open oo order");
      if (OrderOO(mag,i_OPT,i_SL,-1)) {
         has_order=true;
         orderdt=now;
         return;
      }
   }
*/
   int isPd3=isNewsPd3(NULL,bar_shift-1);    //news zone control
   if (isPd3>0 && !has_order) {
      if (!i_rate_ctl) {
         //Print("Open oo order");
         if (OrderOO(mag,i_OPT,i_SL,-1)) {
            has_order=true;
            orderdt=now;
            return;
         }
      } else {
         if (isPd3==1) {            //not rate change news
            //Print("Open oo order");
            if (OrderOO(mag,i_OPT,i_SL,-1)) {
               has_order=true;
               orderdt=now;
               return;
            }
         } else if (isPd3==2) {     //is rate change news
            if (OrderOO3(mag,i_rate_SL,-1)) {
               has_order=true;
               orderdt=now;
               return;
            }
         }
      }
   }

   if (has_order) {
      if       (FindOrderA(NULL,1,mag)) {  //found buy order
         //Print("found buy order,close sellstop order");
         OrderCloseA(NULL,-2,mag);   //close sellstop order

         //move lose stop, set no risk
         if (movingStop2(NULL,1,mag,bar_shift,i_SL,0)) {
            Print("movingstop of buy order");
         }
         
         if (ifClose(bar_shift)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,mag)) {
               has_order=false;
            }
         }
      } else if(FindOrderA(NULL,-1,mag)) {  //found sell order
         //Print("found sell order,close buystop order");
         OrderCloseA(NULL,2,mag);    //close buystop order

         //move lose stop, set no risk
         if (movingStop2(NULL,-1,mag,bar_shift,i_SL,0)) {
            Print("movingstop of sell order");
         }

         if (ifClose(bar_shift)) {
            Print("closed sell order");
            if (!FindOrderA(NULL,0,mag)) {
               has_order=false;
            }
         }
      } else {    //not found buy and sell order
         //Print("not found buy and sell order");
         if ((now-orderdt)>time_ped) {  //timeover
            Print("over time, close buy stop and sell stop order");
            OrderCloseA(NULL,-2,mag);   //close sellstop order
            OrderCloseA(NULL,2,mag);    //close buystop order
            if (!FindOrderA(NULL,0,mag)) {
               has_order=false;
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
   if(i_debug) Print("OnTimer()");
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
      if (OrderCloseA(NULL,1,mag)>0) return true;
   }

   if ((op1>0 && op2>0)||td==-3) {  // close sell signal
      printf("close sell order");
      if (OrderCloseA(NULL,-1,mag)>0) return true;
   }
   
   return false;
}
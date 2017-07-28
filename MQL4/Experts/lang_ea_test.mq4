//+------------------------------------------------------------------+
//|                                                 lang_ea_test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_inc.mqh>
#include <lang_stg_inc.mqh>

//--- input parameters
input int   sl=100;      //take lose point
input int   opt=100;     //oo offset
input int   time_ped=300;  //5 minutes

//--- local
string   com="event stg";
int      mag=12345;
bool     has_order=false;
datetime orderdt;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   debug=false;
   if (debug) {
      Print("OnInit()");
   }
   
   //LossStopPt=sl;
   Vol=1;

   ea_init();
   
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
   if (debug) {
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
   
   bool isPd2=isNewsPd2(NULL,bar_shift-1);    //news zone control
   if (isPd2 && !has_order) {
      //Print("Open oo order");
      OrderOO(com, mag,opt,sl,-1);
      has_order=true;
      orderdt=now;
      return;
   }
   
   if (has_order) {
      if       (FindOrderA(Symbol(),1,com,mag)) {  //found buy order
         //Print("found buy order,close sellstop order");
         //OrderCloseA(Symbol(),-2,com,mag);   //close sellstop order
         if (ifClose(bar_shift)) {
            Print("closed buy order");
            if (!FindOrderA(Symbol(),0,com,mag)) {
               has_order=false;
            }
         }
      } else if(FindOrderA(Symbol(),-1,com,mag)) {  //found sell order
         //Print("found sell order,close buystop order");
         //OrderCloseA(Symbol(),2,com,mag);    //close buystop order
         if (ifClose(bar_shift)) {
            Print("closed sell order");
            if (!FindOrderA(Symbol(),0,com,mag)) {
               has_order=false;
            }
         }
      } else {    //not found buy and sell order
         //Print("not found buy and sell order");
         if ((now-orderdt)>time_ped) {  //timeover
            Print("over time, close buy stop and sell stop order");
            OrderCloseA(Symbol(),-2,com,mag);   //close sellstop order
            OrderCloseA(Symbol(),2,com,mag);    //close buystop order
            if (!FindOrderA(Symbol(),0,com,mag)) {
               has_order=false;
            }
         }
      }
      
   }

}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (debug) {
      Print("OnTimer()");
   }
}
//+------------------------------------------------------------------+
bool ifClose(int shift)
{
   bool ret=false;
   
   int op1=ShotShootStgValue(shift+1);   //par and avg control
   int op2=ShotShootStgValue(shift);     //par and avg control
   int td=TrendStgValue(shift);          //trend control

   //if (td<0) {  // close buy signal
   if (op1<0 && op2<0) {  // close buy signal
      printf("close buy order");
      if (OrderCloseA(Symbol(),1,com,mag)>0) return true;
   }
   //if (td>0) {  // close sell signal
   if (op1>0 && op2>0) {  // close sell signal
      printf("close sell order");
      if (OrderCloseA(Symbol(),-1,com,mag)>0) return true;
   }
   
   return false;
}

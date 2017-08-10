//+------------------------------------------------------------------+
//|                                         lang_short_shoot_stg.mq4 |
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
input int      tp=50;      //take profit point
input int      sl=50;     //take lose point

//--- local
string com="short_shoot";
int mag=12345;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
//---
   LossStopPt=sl;
   ProfitStopPt=tp;
   EquityPercent=1;
   Vol=1;
   debug=false;
   if (debug) {
      Print("OnInit()");
   }
   ea_init();
   
   //if (!timer_init()) return(INIT_FAILED);
   
   //news_read();
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
   //timer_deinit();
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   int bar_shift=isNewBar();
   if (bar_shift==0) return;
   
   int op1=ShotShootStgValue(bar_shift+1);   //par and avg control
   int op2=ShotShootStgValue(bar_shift);     //par and avg control
   //int td=TrendStgValue(bar_shift);          //trend control
   int td2=TrendStgValue2(bar_shift);          //trend control
   //int pd=TimepdValue(bar_shift-1);          //time control
   int at=ATRValue(bar_shift-1);             //atr control
   bool isPd=isCurPd(NULL,bar_shift-1);      //time zone control
   //bool isPd2=isNewsPd(NULL,bar_shift-1);    //news zone control
   
   if (debug) {
      Print("OnTick()");
      printf("lang_shoot:signal1=%.0f",op1);
      printf("lang_shoot:signal2=%.0f",op2);
   }
   //if (op1>=5 && op2>=4 && td>0 && isPd2 && at>0) {  // buy signal
   if (op1>=5 && op2>=4 && isPd && at>0) {  // buy signal
      if (debug) {
         printf("close sell order and open buy order");
      } else {
         if (FindOrderA(Symbol(),1,com,mag) == false) {
            OrderCloseA(Symbol(),0,com,mag);
            if (OrderBuy2(0,0,-1,com,mag) != 0) {
               printf("buy error");
            }
         }
      }
   }
 
   //if (op1<=-5 && op2<=-4 && td<0 && isPd2 && at>0) {  //sell signal
   if (op1<=-5 && op2<=-4 && isPd && at>0) {  //sell signal
      if (debug) {
         printf("close buy order and open sell order");
      } else {
         if (FindOrderA(Symbol(),-1,com,mag)== false) {
            OrderCloseA(Symbol(),0,com,mag);
            if (OrderSell2(0,0,-1,com,mag) != 0) {
               printf("sell error");
            }
         }
      }
   }

   //if (op1<0 && op2<0) {  // close buy signal
   if ((op1<0 && op2<0) || td2==3) {  // close buy signal
      if (debug) {
         printf("close buy order");
      } else {
         OrderCloseA(Symbol(),1,com,mag);
      }
   }
   //if (op1>0 && op2>0) {  // close sell signal
   if ((op1>0 && op2>0) || td2==-3) {  // close sell signal
      if (debug) {
         printf("close sell order");
      } else {
         OrderCloseA(Symbol(),-1,com,mag);
      }
   }
}
//+------------------------------------------------------------------+
//| Expert timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(debug) Print("OnTimer()");
   //news_read();
}

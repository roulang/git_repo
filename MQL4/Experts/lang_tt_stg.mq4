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

//--- global
datetime    tg_st=D'06:15:00';         //start time
datetime    tg_ed=D'10:15:00';         //end time
int         i_lspt=300;                 //lose stop point
int         i_pspt=300;                 //profit stop point
int         i_cnt=3;

string   com="tt stg";    //only for GBPUSD 15M
int      mag=12345;
int      TimeOffset=SEC_H1*4.25;    //from 6:15 to 10:15,4.25H
int      n=0;
int      l_o=50; //price offset
bool     has_order=false;
int      order_tp=0;    //1:buy order, -1:sell order
int      time_ped=SEC_H1*1;  //1 hours
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

   LossStopPt=i_lspt;
   ProfitStopPt=i_pspt;
   double v=NormalizeDouble(getVolume(EquityPercent,i_lspt)/i_cnt,2);
   Vol=v;
   
   delAllObj();
   
   ea_init();
   
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

   int h=TimeHour(CurrentTimeStamp);
   int mi=TimeMinute(CurrentTimeStamp);
   datetime now=Time[bar_shift-1];

   if (has_order && order_tp!=0 && mi==0) {   //every hour to adjust lose stop
      //move lose stop
      if (movingStop2(NULL,order_tp,com,mag,bar_shift,i_lspt,0)) {
         Print("movingstop of buy order");
      }
   }

   if (h==10 && mi==30) {   //10:30 start,from 6:15 to 10:15,4.25H
      
      int b_ed=iBarShift(NULL,PERIOD_CURRENT,CurrentTimeStamp-TimeOffset);
      int b_st=1;
      int b_range=b_ed-b_st+1;
      Print("b_st=",b_st,",b_range=",b_range);
      int low=iLowest(NULL,PERIOD_CURRENT,MODE_LOW,b_range,b_st);
      int high=iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,b_range,b_st);
      double high_p=High[high];
      double low_p=Low[low];
      Print("ilow=",low,",ihigh=",high);
      Print("low=",low_p,",high=",high_p);
      
      //draw objects
      long current_chart_id=ChartID();
      string o=StringConcatenate("rect",n);
      n++;
      if (!ObjectCreate(current_chart_id,o,OBJ_RECTANGLE,0,Time[b_ed],low_p,Time[b_st],high_p)) {
         Print("Object Create Error: ", ErrorDescription(GetLastError()));
      }

      if (has_order) {
         OrderCloseA(NULL,0,com,mag);   //close all order
         has_order=false;
         order_tp=0;
      }

      bool isPd=isNewsPd(NULL,bar_shift-1);    //news zone control

      //open order
      if (!has_order && !isPd) {
         double closeprice_st=Close[b_st];
         double closeprice_ed=Close[b_ed];

         if (closeprice_st>closeprice_ed) {  //cur trend is up, set sell order
            Print("Open sell order");
            bool ret=false;
            for (int i=0;i<i_cnt;i++) {
               ProfitStopPt=i_pspt*(i+1);
               ret=OrderSell2(0,0,0,com,mag);
            }
            if (ret) {
               has_order=true;
               order_tp=-1;
               orderdt=now;
            }
         } else if (closeprice_st<closeprice_ed) { //cur trend is down, set buy order
            Print("Open buy order");
            bool ret=false;
            for (int i=0;i<i_cnt;i++) {
               ProfitStopPt=i_pspt*(i+1);
               ret=OrderBuy2(0,0,0,com,mag);
            }
            if (ret) {
               has_order=true;
               order_tp=1;
               orderdt=now;
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

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

int      Lspt=300;         //lose stop point
int      OC_range=300;    //open and close's range
string   com="jp stg";     //only for USDJPY 1D
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

   if (h==0 && mi==0) {   //00:00 start

      if (has_order) {
         OrderCloseA(NULL,0,com,mag);   //close all order
         has_order=false;
      }

      //open order
      if (!has_order) {   
         double high=High[bar_shift];
         double low=Low[bar_shift];
         double open=Open[bar_shift];
         double close=Close[bar_shift];
         double range=MathAbs(open-close)/Point;
         
         Print("low=",low,",high=",high,",open=",open,",close=",close,",oc_range=",range);
         
         if (range<OC_range) return;
         
         if (open>close) {  //cur trend is down, set sell order
            Print("Open sell order");
            double ls_price=high;
            double r_pt=(high-Bid)/Point;    //cal range from last high to Bid
            if (r_pt<Lspt) {
               ls_price=NormalizeDouble(Bid+Lspt*Point,Digits);   //when range<30pt
               r_pt=Lspt;
            }
            Print("range_pt=",r_pt);
            
            double ps_price=NormalizeDouble(Bid-r_pt/2*Point,Digits);
            bool ret=false;
            ret=OrderSell2(0,ls_price,ps_price,com,mag);
            if (ret) {
               has_order=true;
               orderdt=now;
            }
         } else if (open<close) { //cur trend is up, set buy order
            Print("Open buy order");

            double ls_price=low;
            double r_pt=(Ask-low)/Point;    //cal range from last low to Ask 
            if (r_pt<Lspt) {
               ls_price=NormalizeDouble(Ask-Lspt*Point,Digits);   //when range<30pt
               r_pt=Lspt;
            }
            Print("range_pt=",r_pt);
            
            double ps_price=NormalizeDouble(Ask+r_pt/2*Point,Digits);
            bool ret=false;
            ret=OrderBuy2(0,ls_price,ps_price,com,mag);
            if (ret) {
               has_order=true;
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
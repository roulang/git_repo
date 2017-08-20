//+------------------------------------------------------------------+
//|                                                  lang_newspd.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_stg_inc.mqh>

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 5
#property indicator_buffers 1
#property indicator_plots   1
//--- plot signal
#property indicator_label1  "signal"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double    signalBuffer[];

//--- input
input int i_timer_sec=SEC_H1;    //timer seconds
input int i_news_bef=15*60;      //news before 15min
input int i_news_aft=60*60;      //news after 1 hour
input bool i_update_news=true;   //news update control
input bool i_his_order_wrt=true; //history order write control

//global
bool      g_for_test=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   
//--- indicator buffers mapping
   SetIndexBuffer(0,signalBuffer);
   
   if (!g_for_test) {
      if (!timer_init(i_timer_sec)) return(INIT_FAILED);
   }
   
   news_read();
   
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if (i_debug) {
      Print("OnDeinit()");
   }
   
   //Print("OnDeinit(),release lock");
   releaseFileLock();
   
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   
   int limit=rates_total-prev_calculated;
   if (limit==0) return rates_total;
   if(prev_calculated==0) {
      limit=InitializeAll();
   }
   
   int st=limit;
   for(int i=st;i>=0;i--) {
      if (isNewsPd(NULL,i,i_news_bef,i_news_aft)) signalBuffer[i]=1;
      else signalBuffer[i]=0;
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int InitializeAll()
{
   printf("init");
   ArrayInitialize(signalBuffer,0.0);
//--- first counting position
   return(Bars-1);
}
//+------------------------------------------------------------------+
//| Expert timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(i_debug) Print("OnTimer()");
     
   if (!g_for_test) {
      if (i_update_news) news_read();
      if (i_his_order_wrt) {
         if (getFileLock()) {
            writeOrderHistoryToFile();
            releaseFileLock();
         }
      }
   }
}

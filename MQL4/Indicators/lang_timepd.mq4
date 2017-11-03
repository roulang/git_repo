//+------------------------------------------------------------------+
//|                                                  lang_timepd.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//time period
//jp=1, gbp=2, usd=4
//
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_inc.mqh>
#include <lang_ind_inc.mqh>

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 7
#property indicator_buffers 1
#property indicator_plots   1
//--- plot tm
#property indicator_label1  "tm"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double  tmBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,tmBuffer);
   
//---
   return(INIT_SUCCEEDED);
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
   if(prev_calculated==0) {
      limit=InitializeAll();
   }
   
   int st=limit;
   for(int i=st;i>=0;i--) {
      //if (i==st) printf("loop");
      //tmBuffer[i]=TimepdValue(i);
      tmBuffer[i]=TimepdValue(i);
      //if (isCurPd(NULL,i)) tmBuffer[i]=1;
      //else tmBuffer[i]=0;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
int InitializeAll()
{
   printf("init");
   ArrayInitialize(tmBuffer,0.0);
//--- first counting position
   return(Bars-1);
}

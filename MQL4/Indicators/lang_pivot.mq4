//+------------------------------------------------------------------+
//|                                                   lang_pivot.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_stg_inc.mqh>

#property indicator_chart_window
//#property indicator_separate_window
//#property indicator_minimum -5
//#property indicator_maximum 5
#property indicator_buffers 5
#property indicator_plots   5
//--- plot signal
#property indicator_label1  "low1"
//#property indicator_type1   DRAW_ARROW
//#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type1   DRAW_SECTION    //do not set 0 value
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot signal
#property indicator_label2  "high1"
//#property indicator_type2   DRAW_ARROW
//#property indicator_type2   DRAW_HISTOGRAM
#property indicator_type2   DRAW_SECTION    //do not set 0 value
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot signal
#property indicator_label3  "low2"
//#property indicator_type3   DRAW_ARROW
//#property indicator_type3   DRAW_HISTOGRAM
#property indicator_type3   DRAW_SECTION    //do not set 0 value
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_DASH
#property indicator_width3  1
//--- plot signal
#property indicator_label4  "high2"
//#property indicator_type4   DRAW_ARROW
//#property indicator_type4   DRAW_HISTOGRAM
#property indicator_type4   DRAW_SECTION    //do not set 0 value
#property indicator_color4  clrRed
#property indicator_style4  STYLE_DASH
#property indicator_width4  1
//--- plot signal
#property indicator_label5  "pivot"
//#property indicator_type5   DRAW_ARROW
//#property indicator_type5   DRAW_HISTOGRAM
#property indicator_type5   DRAW_SECTION    //do not set 0 value
#property indicator_color5  clrWhite
#property indicator_style5  STYLE_DASHDOT
#property indicator_width5  1

//--- indicator buffers
double         low_Buffer[];
double         high_Buffer[];
double         low2_Buffer[];
double         high2_Buffer[];
double         pivot_Buffer[];

//input

//global
int            g_last_shift=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping

   if (!i_for_test) {
      //if (!timer_init(i_timer_sec)) return(INIT_FAILED);
   }

//--- indicator buffers mapping
   SetIndexBuffer(0,low_Buffer);
   SetIndexBuffer(1,high_Buffer);
   SetIndexBuffer(2,low2_Buffer);
   SetIndexBuffer(3,high2_Buffer);
   SetIndexBuffer(4,pivot_Buffer);
      
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

   int uncal_bars=rates_total-prev_calculated;
   if (uncal_bars==0) return rates_total;
   //Print("0:uncal_bars=",uncal_bars);
   //return(rates_total);
   
   int limit=Bars-1;   
   if(prev_calculated==0) {
      InitializeAll();
      high_Buffer[limit]=high2_Buffer[limit]=High[limit];
      low_Buffer[limit]=low2_Buffer[limit]=Low[limit];
      double p=NormalizeDouble((high_Buffer[limit]+low_Buffer[limit]+Close[limit])/3,Digits);
      pivot_Buffer[limit]=p;
   }
   
   //1:
   int st=uncal_bars+1;
   if (st>limit) st=limit;
   if(i_debug) {
      Print("1:st=",st);
   }

   for(int i=st-1;i>0;i--) {

      if (i==st-1) {
         //break
         //Print("here to set breakpoint");
      }
      
      int larger_sht;
      int larger_pd=expandPeriod(PERIOD_CURRENT,i,larger_sht,-1,PERIOD_D1);
      larger_sht=larger_sht+1;
      if (g_last_shift !=0 && g_last_shift==larger_sht) {
         pivot_Buffer[i]=pivot_Buffer[i+1];
         high_Buffer[i]=high_Buffer[i+1];
         low_Buffer[i]=low_Buffer[i+1];
         high2_Buffer[i]=high2_Buffer[i+1];
         low2_Buffer[i]=low2_Buffer[i+1];
         continue;
      }
      double h=iHigh(NULL,larger_pd,larger_sht);
      double l=iLow(NULL,larger_pd,larger_sht);
      double c=iClose(NULL,larger_pd,larger_sht);
      double p=NormalizeDouble((h+l+c)/3,Digits);
      pivot_Buffer[i]=p;
      high_Buffer[i]=2*p-l;
      low_Buffer[i]=2*p-h;
      high2_Buffer[i]=p+(h-l);
      low2_Buffer[i]=p-(h-l);
      g_last_shift=larger_sht;
      
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int InitializeAll()
{

//--- first counting position
   return(Bars-1);
}
//+------------------------------------------------------------------+
//| Expert timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(i_debug) Print("OnTimer()");

}

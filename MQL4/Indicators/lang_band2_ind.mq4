//+------------------------------------------------------------------+
//|                                          lang_indicator_test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#include <lang_ind_inc.mqh>
#include <lang_stg_inc.mqh>

//#property indicator_chart_window
#property indicator_separate_window
#property indicator_minimum -2
#property indicator_maximum 2
#property indicator_buffers 4
#property indicator_plots   4
//--- plot signal
//#property indicator_label1  "signal"
//#property indicator_type1   DRAW_ARROW
#property indicator_label1  "high"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "mid"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "low"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "st"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrWhite
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- indicator buffers
//double         signalBuffer[];
double         highBuffer[];
double         midBuffer[];
double         lowBuffer[];
double         stBuffer[];

//input
//input int      i_mode=MODE_SIGNAL;     //0:Main,1:Signal
//input double   i_deviation=2;
//input int      i_range_ratio=1;
//input int      i_pd=10;
input double    i_gap_ratio=0.1;

//global
//int   g_ma_cross=0;
//int   g_fast_pd=12;
//int   g_slow_pd=26;
//int   g_singal_pd=9;
//int g_last_band_st=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   if (!i_for_test) {
      //if (!timer_init(i_timer_sec)) return(INIT_FAILED);
   }

//--- indicator buffers mapping
   //SetIndexBuffer(0,signalBuffer);
   SetIndexBuffer(0,highBuffer);
   SetIndexBuffer(1,midBuffer);
   SetIndexBuffer(2,lowBuffer);
   SetIndexBuffer(3,stBuffer);

   //SetIndexArrow(0,SYMBOL_ARROWUP);

   
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
   
   if(prev_calculated==0) {
      InitializeAll();
   }
   
   int limit=Bars-1;

   //1:skip last bar
   int st=uncal_bars+1;
   if (st>limit) st=limit;
   if(g_debug) {
      Print("1:st=",st);
   }
   int skip_first_bars=0;
   for(int i=st-skip_first_bars;i>=0;i--) {
      int band_bar_pos[5],bar_status;
      double d2_low,d2_high,d4_low,d4_high,ma,d2_gap,d4_gap;
      getBandStatus3(NULL,i,d2_low,d2_high,d4_low,d4_high,ma,d2_gap,d4_gap,band_bar_pos,bar_status,i_gap_ratio);
      highBuffer[i]=band_bar_pos[1];
      midBuffer[i]=band_bar_pos[2];
      lowBuffer[i]=band_bar_pos[3];
      stBuffer[i]=bar_status;
      
      //debug
      datetime t=Time[i];
      datetime t1=StringToTime("2018.04.9 08:00");
      if (t==t1) {
         Print("time=",t);
         Print("shift=",i);
         Print("highBuffer[i]=",highBuffer[i]);
         Print("midBuffer[i]=",midBuffer[i]);
         Print("lowBuffer[i]=",lowBuffer[i]);
         Print("stBuffer[i]=",stBuffer[i]);
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int InitializeAll()
{
   //ArrayInitialize(signalBuffer,0.0);
   ArrayInitialize(highBuffer,0.0);
   ArrayInitialize(midBuffer,0.0);
   ArrayInitialize(lowBuffer,0.0);
   ArrayInitialize(stBuffer,0.0);

//--- first counting position
   return(Bars-1);
}
//+------------------------------------------------------------------+
//| Expert timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(g_debug) Print("OnTimer()");

}

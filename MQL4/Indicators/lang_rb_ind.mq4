//+------------------------------------------------------------------+
//|                                                  lang_rb_ind.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_stg_inc.mqh>

//#property indicator_chart_window
#property indicator_separate_window
#property indicator_minimum -3
#property indicator_maximum 3
#property indicator_buffers 1
#property indicator_plots   1
//--- plot signal
#property indicator_label1  "signal"
//#property indicator_type1   DRAW_ARROW
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- indicator buffers
double         signalBuffer[];

//input
input int      i_range=20;
input int      i_thredhold_pt=0;
input int      i_expand=1;
input bool     i_sendmail=true;

//global
//double g_zigBuf[][3];
//double g_high_low[4][2];
//double g_pivotBuf[5];
//int    g_pivot_sht=0;
//int    g_touch_highlow[4];
//int    g_larger_shift=0;
//int    g_threhold_gap=50;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   if (!i_for_test) {
      //if (!timer_init(i_timer_sec)) return(INIT_FAILED);
      g_sendmail=i_sendmail;
   }
   
   //g_debug=true;
   
//--- indicator buffers mapping
   SetIndexBuffer(0,signalBuffer);
   
   //SetIndexArrow(0,SYMBOL_ARROWUP);

//   ArrayResize(g_zigBuf,i_range);
//   ArrayInitialize(g_zigBuf,0);
//   ArrayInitialize(g_pivotBuf,0);
//   ArrayInitialize(g_high_low,0);
   
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
   //double ls_price=0;
   double range_high,range_low;
   int range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt;
   int ret=0;
   string sym=Symbol();
   string ped=getPeriodTp(Period());
   string s=StringConcatenate("[",sym,"(",ped,")]");
   for(int i=st-1;i>0;i--) {
      //signalBuffer[i]=isBreak_Rebound_Open(i,i_thredhold_pt,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,ls_price);
      //signalBuffer[i]=isBreak_Rebound(i,i_thredhold_pt,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,g_larger_shift,g_touch_highlow,high_gap,low_gap,high_low_gap,i_expand,g_threhold_gap);
      ret=isBreak_Rebound2(i,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,i_range,i_thredhold_pt,i_expand,5,150,20);
      if (MathAbs(ret)>=1 && i==1) {   //sendmail in future
         //string t1=TimeToStr(Time[i],TIME_DATE);
         string t1=StringConcatenate(TimeMonth(Time[i]),"/",TimeDay(Time[i]));
         string t2=TimeToStr(Time[i],TIME_MINUTES);
         string t=StringConcatenate("[",t1," ",t2,"]");
         string mail_title=StringConcatenate(s," ",t," hit high low (",ret,")");
         mailNotice(mail_title,"");
      }
      if (MathAbs(ret)>1) {
         signalBuffer[i]=ret;
      }
      /*
      //debug
      datetime t=Time[i];
      datetime t1=StringToTime("2017.10.18 19:00");
      if (t==t1) {
         Print("time=",t);
         Print("shift=",i);
         Print("g_high_low=");
         PrintTwoDimArray(g_high_low);
         for (int j=0;j<ArraySize(g_touch_highlow);j++) {
            Print("g_touch_highlow[",j,"]=",g_touch_highlow[j]);
         }
      }
      */
   }

//--- return value of prev_calculated for next call
   return(rates_total);
   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int InitializeAll()
{
   ArrayInitialize(signalBuffer,0.0);

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

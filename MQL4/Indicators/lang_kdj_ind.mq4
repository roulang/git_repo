//+------------------------------------------------------------------+
//|                                                lang_kdj_ind.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ind_inc.mqh>
//#include <lang_stg_inc.mqh>

//#property indicator_chart_window
#property indicator_separate_window
#property indicator_minimum -4
#property indicator_maximum 4
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
input int      i_k_pd=5;
input int      i_d_pd=3;
input int      i_slow=3;
input int      i_high=80;
input int      i_low=20;
input bool     i_sendmail=False;

//global
int g_timer_sec;
double g_last_signal;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   if (!i_for_test) {
      g_timer_sec = PeriodSeconds()/5;
      if (!timer_init(g_timer_sec)) return(INIT_FAILED);
      if(g_debug) Print("set Timer at ", g_timer_sec);
   }

//--- indicator buffers mapping
   SetIndexBuffer(0,signalBuffer);
   
   //SetIndexArrow(0,SYMBOL_ARROWUP);
   
   g_sendmail=i_sendmail;
   g_last_signal=0;
   
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
   int skip_first_bars=2;
   int st=uncal_bars+skip_first_bars;
   if (st>limit) st=limit;
   if(g_debug) {
      Print("1:st=",st);
   }
   for(int i=st-skip_first_bars;i>0;i--) {
      signalBuffer[i]=getKDJStatus(PERIOD_CURRENT,i,i_k_pd,i_d_pd,i_slow,i_high,i_low);
      /*
      //debug
      if (signalBuffer[i]==2 || signalBuffer[i]==-2) {
         datetime t=Time[i];
         Print("time=",t);
         Print("shift=",i);
         Print("signalBuffer=",signalBuffer[i]);
      }
      */
      
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
   /*
   if(prev_calculated!=0) {
      if (MathAbs(signalBuffer[1])>=2) {
         Print("send notice mail");
         mailNotice_indicator("kdj",signalBuffer[1]);
      }
   }
   */

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
   if(g_debug) Print("OnTimer() at ", g_timer_sec);
   signalBuffer[0]=getKDJStatus(PERIOD_CURRENT,0,i_k_pd,i_d_pd,i_slow,i_high,i_low);
   ChartRedraw();
   if(g_last_signal!=signalBuffer[0]) {
      g_last_signal=signalBuffer[0];
      if (MathAbs(signalBuffer[0])>=2) {
         Print("send notice mail");
         mailNotice_indicator("kdj",signalBuffer[0]);
      }
   }
}

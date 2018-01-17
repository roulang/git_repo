//+------------------------------------------------------------------+
//|                                                  lang_th_ind.mq4 |
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
input int   i_type=0;
   
//global
int      g_ma_cross=0;    //1,fast ma up cross slow ma;-1,fast ma down cross slow ma
int      g_adx_status=0;  //1,above 40(default);-1,below 40(default)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   if (!i_for_test) {
      //if (!timer_init(i_timer_sec)) return(INIT_FAILED);
   }

//--- indicator buffers mapping
   SetIndexBuffer(0,signalBuffer);
   
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
   int skip_first_bars=2;
   int st=uncal_bars+skip_first_bars;
   if (st>limit) st=limit;
   if(g_debug) {
      Print("1:st=",st);
   }
   for(int i=st-skip_first_bars;i>0;i--) {
      //int touch_status[2];
      double ls_price=0;
      if (i_type==0) {
         signalBuffer[i]=isTrendStgOpen(i,g_ma_cross,ls_price);
      } else {
         //int ret=getMAStatus2(PERIOD_CURRENT,i,touch_status);
         //signalBuffer[i]=touch_status[1];
         //signalBuffer[i]=getADXStatus(PERIOD_CURRENT,i);
         signalBuffer[i]=isTrendStgClose(i,g_adx_status);
         //int ret=isTrendStgClose(i,g_adx_status);
         //signalBuffer[i]=g_adx_status;
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

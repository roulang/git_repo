//+------------------------------------------------------------------+
//|                                                  lang_zt_ind.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ind_inc.mqh>

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
input int i_deviation_st=0;     // Deviation(short),should set to equal to zigzag's deviation value
input int i_deviation_md=0;     // Deviation(mid),should set to equal to zigzag's deviation value
input int i_deviation_lg=0;     // Deviation(long),should set to equal to zigzag's deviation value
input int i_thredhold=0;         // breakthrough thredhold point


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
   int st=uncal_bars+1;
   if (st>limit) st=limit;
   if(g_debug) {
      Print("1:st=",st);
   }
   int lst_short_low_sht=0,lst_mid_low_sht=0,lst_short_high_sht=0,lst_mid_high_sht=0;
   for(int i=st-1;i>0;i--) {
      signalBuffer[i]=getZigTurn(i,lst_short_low_sht,lst_mid_low_sht,lst_short_high_sht,lst_mid_high_sht,i_deviation_st,i_deviation_md,i_deviation_lg,i_thredhold);
      if (MathAbs(signalBuffer[i])>1) {
         //Print(Time[i],",lst_stl_sht=",lst_short_low_sht,",lst_mdl_sht=",lst_mid_low_sht,",lst_sth_sht=",lst_short_high_sht,",lst_mdh_sht=",lst_mid_high_sht);
      }
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

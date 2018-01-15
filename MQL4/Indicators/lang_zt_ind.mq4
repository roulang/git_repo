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
input int      i_expand=0;          //0:current(not expand),1:expand one level,2:expand two level
input int      i_long=0;            //0:short vs mid,1:mid vs long

//global
int   g_deviation_st=0;     // Deviation(short),should set to equal to zigzag's deviation value
int   g_deviation_md=0;     // Deviation(mid),should set to equal to zigzag's deviation value
int   g_deviation_lg=0;     // Deviation(long),should set to equal to zigzag's deviation value
int   g_thredhold=0;        // breakthrough thredhold point

//int   g_larger_shift=0;

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
   int lst_small_low_sht=0,lst_big_low_sht=0,lst_small_high_sht=0,lst_big_high_sht=0;
   for(int i=st-1;i>0;i--) {
      int bar_shift=i;
      int pd=PERIOD_CURRENT;
      
      if          (i_expand==0) {                        //not expand
         bar_shift=i;
         pd=PERIOD_CURRENT;
         signalBuffer[i]=getZigTurn2(  pd,bar_shift,lst_small_low_sht,lst_big_low_sht,lst_small_high_sht,lst_big_high_sht,
                                       i_long,g_deviation_st,g_deviation_md,g_deviation_lg,g_thredhold);
                                       
      } else if   (i_expand==1) {  //expand to larger period
         pd=expandPeriod(PERIOD_CURRENT,i,bar_shift,0);
         signalBuffer[i]=getZigTurn2(  pd,bar_shift,lst_small_low_sht,lst_big_low_sht,lst_small_high_sht,lst_big_high_sht,
                                       i_long,g_deviation_st,g_deviation_md,g_deviation_lg,g_thredhold);

      } else if   (i_expand==2) {  //expand to larger period
         pd=expandPeriod(PERIOD_CURRENT,i,bar_shift,1);
         signalBuffer[i]=getZigTurn2(  pd,bar_shift,lst_small_low_sht,lst_big_low_sht,lst_small_high_sht,lst_big_high_sht,
                                       i_long,g_deviation_st,g_deviation_md,g_deviation_lg,g_thredhold);

      }
      
      /*
      //debug
      datetime t=Time[i];
      datetime t1=StringToTime("2018.01.15 09:15");
      string   sym="AUDUSD";
      if (t==t1 && StringCompare(sym,Symbol()==0)) {
         Print("time=",t);
         Print("shift=",i);
         Print("ret=",signalBuffer[i]);
      }
      */

      if (MathAbs(signalBuffer[i])>1) {
         //Print(Time[i],",lst_sml_sht=",lst_small_low_sht,",lst_bgl_sht=",lst_big_low_sht,",lst_smh_sht=",lst_small_high_sht,",lst_bgh_sht=",lst_big_high_sht);
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

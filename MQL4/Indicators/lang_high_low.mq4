//+------------------------------------------------------------------+
//|                                                lang_high_low.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <lang_stg_inc.mqh>

#property indicator_chart_window
//#property indicator_separate_window
//#property indicator_minimum -5
//#property indicator_maximum 5
#property indicator_buffers 8
#property indicator_plots   8
//--- plot signal
#property indicator_label1  "range_low"
//#property indicator_type1   DRAW_ARROW
//#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type1   DRAW_SECTION    //do not set 0 value
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot signal
#property indicator_label2  "range_high"
//#property indicator_type2   DRAW_ARROW
//#property indicator_type2   DRAW_HISTOGRAM
#property indicator_type2   DRAW_SECTION    //do not set 0 value
#property indicator_color2  clrLightPink
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot signal
#property indicator_label3  "range_low2"
//#property indicator_type3   DRAW_ARROW
//#property indicator_type3   DRAW_HISTOGRAM
#property indicator_type3   DRAW_SECTION    //do not set 0 value
#property indicator_color3  clrDeepSkyBlue
#property indicator_style3  STYLE_DASH
#property indicator_width3  1
//--- plot signal
#property indicator_label4  "range_high2"
//#property indicator_type4   DRAW_ARROW
//#property indicator_type4   DRAW_HISTOGRAM
#property indicator_type4   DRAW_SECTION    //do not set 0 value
#property indicator_color4  clrLightPink
#property indicator_style4  STYLE_DASH
#property indicator_width4  1
//--- plot range low shift
#property indicator_label5  "range_low_shift"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrBlack
//--- plot range high shift
#property indicator_label6  "range_high_shift"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrBlack
//--- plot range low2 shift
#property indicator_label7  "range_low2_shift"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrBlack
//--- plot range high2 shift
#property indicator_label8  "range_high_shift"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrBlack

//--- indicator buffers
double         range_low_Buffer[];
double         range_high_Buffer[];
double         range_low2_Buffer[];
double         range_high2_Buffer[];
double         range_low_sht_Buffer[];
double         range_high_sht_Buffer[];
double         range_low2_sht_Buffer[];
double         range_high2_sht_Buffer[];

//input
input int      i_range=10;
input int      i_long=1;

//global
double g_zigBuf[][3];
double g_high_low[4][2];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   if (!i_for_test) {
      //if (!timer_init(i_timer_sec)) return(INIT_FAILED);
   }

   ArrayResize(g_zigBuf,i_range);
   ArrayInitialize(g_zigBuf,0);
   ArrayInitialize(g_high_low,0);

//--- indicator buffers mapping
   SetIndexBuffer(0,range_low_Buffer);
   SetIndexBuffer(1,range_high_Buffer);
   SetIndexBuffer(2,range_low2_Buffer);
   SetIndexBuffer(3,range_high2_Buffer);
   SetIndexBuffer(4,range_low_sht_Buffer);
   SetIndexBuffer(5,range_high_sht_Buffer);
   SetIndexBuffer(6,range_low2_sht_Buffer);
   SetIndexBuffer(7,range_high2_sht_Buffer);
   
   //SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(4,SYMBOL_CHECKSIGN);
   SetIndexArrow(5,SYMBOL_CHECKSIGN);
   SetIndexArrow(6,SYMBOL_CHECKSIGN);
   SetIndexArrow(7,SYMBOL_CHECKSIGN);
   
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
   
   //1:
   int st=uncal_bars+1;
   if (st>limit) st=limit;
   if(i_debug) {
      Print("1:st=",st);
   }

   for(int i=st-1;i>0;i--) {
      //double range_up,range_dw,range_up2,range_dw2;
      //getLargerLastMidUpDw(PERIOD_CURRENT,i,range_up,range_dw);
      //getLastRange(PERIOD_CURRENT,i,range_up,range_dw,range_up2,range_dw2);
      //if (range_up>0) mid_up_Buffer[i]=range_up;
      //if (range_dw>0) mid_dw_Buffer[i]=range_dw;
      //if (range_up2>0) mid_up2_Buffer[i]=range_up2;
      //if (range_dw2>0) mid_dw2_Buffer[i]=range_dw2;

      double cur_price=Close[i];
      
      if (i==st-1) {
         //break
         //Print("here to set breakpoint");
      }
      if (High[i]<High[i+1] && Low[i]>Low[i+1]) {     //filter inner bar
         if (range_low_Buffer[i+1]!=MAX_INT) range_low_Buffer[i]=range_low_Buffer[i+1];
         if (range_high_Buffer[i+1]!=MAX_INT) range_high_Buffer[i]=range_high_Buffer[i+1];
         if (range_low2_Buffer[i+1]!=MAX_INT) range_low2_Buffer[i]=range_low2_Buffer[i+1];
         if (range_high2_Buffer[i+1]!=MAX_INT) range_high2_Buffer[i]=range_high2_Buffer[i+1];
         continue;
      }
      
      getNearestHighLowPrice4(cur_price,PERIOD_CURRENT,i,i_range,g_zigBuf,g_high_low,i_long);

      if (g_high_low[1][0]>0) {
         range_high_Buffer[i]=g_high_low[1][0];
         range_high_sht_Buffer[i]=g_high_low[1][1];
      } else {
         //Print("Time1[",i,"]=",Time[i]);
      }
      if (g_high_low[2][0]>0) {
         range_low_Buffer[i]=g_high_low[2][0];
         range_low_sht_Buffer[i]=g_high_low[2][1];
      } else {
         //Print("Time2[",i,"]=",Time[i]);
      }
      if (g_high_low[0][0]>0) {
         range_high2_Buffer[i]=g_high_low[0][0];
         range_high2_sht_Buffer[i]=g_high_low[0][1];
      } else {
         //Print("Time0[",i,"]=",Time[i]);
      }
      if (g_high_low[3][0]>0) {
         range_low2_Buffer[i]=g_high_low[3][0];
         range_low2_sht_Buffer[i]=g_high_low[3][1];
      } else {
         //Print("Time3[",i,"]=",Time[i]);
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
   ArrayInitialize(range_low_sht_Buffer,0.0);
   ArrayInitialize(range_high_sht_Buffer,0.0);
   ArrayInitialize(range_low2_sht_Buffer,0.0);
   ArrayInitialize(range_high2_sht_Buffer,0.0);

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

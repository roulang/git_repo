//+------------------------------------------------------------------+
//|                                                lang_high_low.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//use lang_zig_zag indicator
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <lang_ind_inc.mqh>

#property indicator_chart_window
//#property indicator_separate_window
//#property indicator_minimum -5
//#property indicator_maximum 5
#property indicator_buffers 11
#property indicator_plots   11
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
#property indicator_label8  "range_high2_shift"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrBlack
//--- plot high gap point
#property indicator_label9  "range_high_gap"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrBlack
//--- plot low gap point
#property indicator_label10  "range_low_gap"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrBlack
//--- plot high low gap point
#property indicator_label11  "range_high_low_gap"
#property indicator_type11   DRAW_ARROW
#property indicator_color11  clrBlack

//--- indicator buffers
double         range_low_Buffer[];
double         range_high_Buffer[];
double         range_low2_Buffer[];
double         range_high2_Buffer[];
double         range_low_sht_Buffer[];
double         range_high_sht_Buffer[];
double         range_low2_sht_Buffer[];
double         range_high2_sht_Buffer[];
double         range_high_gap_Buffer[];
double         range_low_gap_Buffer[];
double         range_high_low_gap_Buffer[];

//input
input int      i_range=20;
input int      i_long=1;
input int      i_thredhold_pt=0;
input int      i_expand=1;          //0:not expand,1:expand one level,2:expand two level
input int      i_add_pivot=1;       //0:not add pivot value,1:add pivot value

//global

double         g_zigBuf[][3];
double         g_high_low[4][2];
int            g_larger_shift=0;
double         g_pivotBuf[5];
int            g_pivot_sht=0;

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
   ArrayInitialize(g_pivotBuf,0);
   
//--- indicator buffers mapping
   SetIndexBuffer(0,range_low_Buffer);
   SetIndexBuffer(1,range_high_Buffer);
   SetIndexBuffer(2,range_low2_Buffer);
   SetIndexBuffer(3,range_high2_Buffer);
   SetIndexBuffer(4,range_low_sht_Buffer);
   SetIndexBuffer(5,range_high_sht_Buffer);
   SetIndexBuffer(6,range_low2_sht_Buffer);
   SetIndexBuffer(7,range_high2_sht_Buffer);
   SetIndexBuffer(8,range_high_gap_Buffer);
   SetIndexBuffer(9,range_low_gap_Buffer);
   SetIndexBuffer(10,range_high_low_gap_Buffer);
   
   //SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(4,SYMBOL_CHECKSIGN);
   SetIndexArrow(5,SYMBOL_CHECKSIGN);
   SetIndexArrow(6,SYMBOL_CHECKSIGN);
   SetIndexArrow(7,SYMBOL_CHECKSIGN);
   SetIndexArrow(8,SYMBOL_CHECKSIGN);
   SetIndexArrow(9,SYMBOL_CHECKSIGN);
   SetIndexArrow(10,SYMBOL_CHECKSIGN);
   
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
   if(g_debug) {
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
      int bar_status=0;
      if (Open[i]>Close[i]) {    //negative bar
         bar_status=1;
      }
      
      if (i==st-1) {
         //break
         //Print("here to set breakpoint");
      }
      
      if (High[i]<(High[i+1]+i_thredhold_pt*Point) && Low[i]>(Low[i+1]-i_thredhold_pt*Point)) {     //filter inner bar
         copyToNextValue(i);
         continue;
      }
      
      int larger_shift=0;
      int larger_pd=0;
      if (i_expand==0) {         //not expand
         //getNearestHighLowPrice(cur_price,PERIOD_CURRENT,i,i_range,g_zigBuf,g_high_low,i_long);
         //getNearestHighLowPrice2(cur_price,PERIOD_CURRENT,i,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,i_long,i_add_pivot);
         getNearestHighLowPrice3(cur_price,PERIOD_CURRENT,i,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,i_long,i_add_pivot,false,bar_status);
      } else if (i_expand==1 || i_expand==2) {  //expand to larger period
         larger_pd=expandPeriod(PERIOD_CURRENT,i,larger_shift,i_expand);
         if (g_larger_shift>0 && g_larger_shift==larger_shift) {     //
            //getNearestHighLowPrice(cur_price,larger_pd,g_larger_shift,i_range,g_zigBuf,g_high_low,i_long,true);
            //getNearestHighLowPrice2(cur_price,larger_pd,g_larger_shift,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,i_long,i_add_pivot,true);
            getNearestHighLowPrice3(cur_price,larger_pd,g_larger_shift,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,i_long,i_add_pivot,true,bar_status);
         } else {
            //getNearestHighLowPrice(cur_price,larger_pd,g_larger_shift,i_range,g_zigBuf,g_high_low,i_long);
            //getNearestHighLowPrice2(cur_price,larger_pd,g_larger_shift,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,i_long,i_add_pivot);
            getNearestHighLowPrice3(cur_price,larger_pd,g_larger_shift,i_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,i_long,i_add_pivot,false,bar_status);
            g_larger_shift=larger_shift;
         }
      }
      if (g_high_low[1][0]>0) {     //nearest high
         range_high_Buffer[i]=g_high_low[1][0];
         range_high_sht_Buffer[i]=g_high_low[1][1];
      } else {
         //Print("Time1[",i,"]=",Time[i]);
      }
      if (g_high_low[2][0]>0) {     //nearest low
         range_low_Buffer[i]=g_high_low[2][0];
         range_low_sht_Buffer[i]=g_high_low[2][1];
      } else {
         //Print("Time2[",i,"]=",Time[i]);
      }
      if (g_high_low[0][0]>0) {     //second nearest high
         range_high2_Buffer[i]=g_high_low[0][0];
         range_high2_sht_Buffer[i]=g_high_low[0][1];
      } else {
         //Print("Time0[",i,"]=",Time[i]);
      }
      if (g_high_low[3][0]>0) {     //second nearest low
         range_low2_Buffer[i]=g_high_low[3][0];
         range_low2_sht_Buffer[i]=g_high_low[3][1];
      } else {
         //Print("Time3[",i,"]=",Time[i]);
      }
      if (g_high_low[0][0]>0 && g_high_low[1][0]>0) {     //second nearest high>0 and nearest high>0
         range_high_gap_Buffer[i]=NormalizeDouble((g_high_low[0][0]-g_high_low[1][0])/Point,0);
      } else {
         range_high_gap_Buffer[i]=0;
      }
      if (g_high_low[2][0]>0 && g_high_low[3][0]>0) {     //nearest low>0 and second nearest low>0
         range_low_gap_Buffer[i]=NormalizeDouble((g_high_low[2][0]-g_high_low[3][0])/Point,0);
      } else {
         range_low_gap_Buffer[i]=0;
      }
      if (g_high_low[1][0]>0 && g_high_low[2][0]>0) {     //nearest high>0 and nearest low>0
         range_high_low_gap_Buffer[i]=NormalizeDouble((g_high_low[1][0]-g_high_low[2][0])/Point,0);
      } else {
         range_high_low_gap_Buffer[i]=0;
      }
      
      /*
      //debug
      datetime t=Time[i];
      datetime t1=StringToTime("2017.11.07 03:30");
      int      p=Period();
      int      p1=PERIOD_M15;
      if (t==t1 && p==p1) {
         Print("time=",t);
         Print("shift=",i);
         Print("larger_pd=",larger_pd);
         Print("larger_shift=",larger_shift);
         Print("g_larger_shift=",g_larger_shift);
         Print("cur_price=",cur_price);
         Print("g_high_low=");
         PrintTwoDimArray(g_high_low);
      }
      */
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void copyToNextValue(int arg_n)
{
   if (range_low_Buffer[arg_n+1]!=MAX_INT) {
      range_low_Buffer[arg_n]=range_low_Buffer[arg_n+1];
      if (range_low_sht_Buffer[arg_n+1]>0) {
         range_low_sht_Buffer[arg_n]=range_low_sht_Buffer[arg_n+1]+1;
      } else {
         range_low_sht_Buffer[arg_n]=range_low_sht_Buffer[arg_n+1]-1;
      }
   }
   if (range_high_Buffer[arg_n+1]!=MAX_INT) {
      range_high_Buffer[arg_n]=range_high_Buffer[arg_n+1];
      if (range_high_sht_Buffer[arg_n+1]>0) {
         range_high_sht_Buffer[arg_n]=range_high_sht_Buffer[arg_n+1]+1;
      } else {
         range_high_sht_Buffer[arg_n]=range_high_sht_Buffer[arg_n+1]-1;
      }
   }
   if (range_low2_Buffer[arg_n+1]!=MAX_INT) {
      range_low2_Buffer[arg_n]=range_low2_Buffer[arg_n+1];
      if (range_low2_sht_Buffer[arg_n+1]>0) {
         range_low2_sht_Buffer[arg_n]=range_low2_sht_Buffer[arg_n+1]+1;
      } else {
         range_low2_sht_Buffer[arg_n]=range_low2_sht_Buffer[arg_n+1]-1;
      }
   }
   if (range_high2_Buffer[arg_n+1]!=MAX_INT) {
      range_high2_Buffer[arg_n]=range_high2_Buffer[arg_n+1];
      if (range_high2_sht_Buffer[arg_n+1]>0) {
         range_high2_sht_Buffer[arg_n]=range_high2_sht_Buffer[arg_n+1]+1;
      } else {
         range_high2_sht_Buffer[arg_n]=range_high2_sht_Buffer[arg_n+1]-1;
      }
   }
}
//+------------------------------------------------------------------+
int InitializeAll()
{
   //ArrayInitialize(signalBuffer,0.0);
   ArrayInitialize(range_low_sht_Buffer,0.0);
   ArrayInitialize(range_high_sht_Buffer,0.0);
   ArrayInitialize(range_low2_sht_Buffer,0.0);
   ArrayInitialize(range_high2_sht_Buffer,0.0);
   ArrayInitialize(range_high_gap_Buffer,0.0);
   ArrayInitialize(range_low_gap_Buffer,0.0);
   ArrayInitialize(range_high_low_gap_Buffer,0.0);

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

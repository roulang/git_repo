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
#property indicator_width1  2

//--- indicator buffers
double         signalBuffer[];

//input
input int      i_avg=60;
input bool     i_draw_objs=True;
input bool     i_sendmail=False;

//global
int g_timer_sec;
int g_obj_cnt=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   if (!i_for_test) {
   /*
      g_timer_sec = PeriodSeconds()/5;
      if (!timer_init(g_timer_sec)) return(INIT_FAILED);
      if(g_debug) Print("set Timer at ", g_timer_sec);
   */
   }
   
   ObjectsDeleteAll(ChartID(), 0, OBJ_RECTANGLE);
   
//--- indicator buffers mapping
   SetIndexBuffer(0,signalBuffer);
   
   //SetIndexArrow(0,SYMBOL_ARROWUP);
   
   g_sendmail=i_sendmail;
   
//---
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){
   ObjectsDeleteAll(ChartID(), 0, OBJ_RECTANGLE);
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

   //1:skip last 2 bars
   int skip_first_bars=2;
   int st=uncal_bars+skip_first_bars;
   if (st>limit) st=limit;
   if(g_debug) {
      Print("1:st=",st);
   }
   for(int i=st-skip_first_bars;i>0;i--) {
      int sig=0;
      int val_i;
      double val_h=0,val_l=0;
      datetime tm1=0,tm2=0;
      int ret=getBarStatus_illya(PERIOD_CURRENT,i);
      
      if (MathAbs(ret)==1) {     //2K
         tm1=time[i+1];
         tm2=time[i];

         val_i=iHighest(NULL,0,MODE_HIGH,2,i);
         if(val_i!=-1) val_h=High[val_i];
         else PrintFormat("Error in call iHighest. Error code=%d",GetLastError());

         val_i=iLowest(NULL,0,MODE_LOW,2,i);
         if(val_i!=-1) val_l=Low[val_i];
         else PrintFormat("Error in call iLowest. Error code=%d",GetLastError());
      }
      if (MathAbs(ret)==2) {     //3K
         tm1=time[i+2];
         tm2=time[i];

         val_i=iHighest(NULL,0,MODE_HIGH,3,i);
         if(val_i!=-1) val_h=High[val_i];
         else PrintFormat("Error in call iHighest. Error code=%d",GetLastError());

         val_i=iLowest(NULL,0,MODE_LOW,3,i);
         if(val_i!=-1) val_l=Low[val_i];
         else PrintFormat("Error in call iLowest. Error code=%d",GetLastError());
      }

      double cur_ma=iMA(NULL,0,i_avg,0,MODE_SMA,PRICE_CLOSE,i);
      if (ret>0) {      //up
         if (close[i]>cur_ma) sig=2;
         else sig=1;
      }
      if (ret<0) {      //down
         if (close[i]<cur_ma) sig=-2;
         else sig=-1;
      }
      
      signalBuffer[i]=sig;
      
      if (i_draw_objs) {
         if (sig>0) {
            string nm = "up" + IntegerToString(g_obj_cnt);
            RectangleCreate(ChartID(),nm,0,tm1,val_h,tm2,val_l,clrGreen);
            g_obj_cnt += 1;
         } else
         if (sig<0) {
            string nm = "dw" + IntegerToString(g_obj_cnt);
            RectangleCreate(ChartID(),nm,0,tm1,val_h,tm2,val_l,clrRed);
            g_obj_cnt += 1;
         }
      }
      
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
   if(prev_calculated!=0) {
      if (MathAbs(signalBuffer[1])>=1) {
         Print("send notice mail");
         mailNotice_indicator("lang_illy_ind",signalBuffer[1]);
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
   /*
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
   */
}

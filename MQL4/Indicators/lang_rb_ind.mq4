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
//input int      i_range=20;
//input int      i_thredhold_pt=0;
//input int      i_expand=1;
input bool     i_sendmail=true;

//global
string   g_comment="3";
int      g_equity_percent=1;

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
   double price[4],ls_price[4],tp_price[4][2];
   int ls_price_pt[4],tp_price_pt[4][2];
   int high_low_touch_status=0;
   int ret=0;
   int ret2=0;
   for(int i=st-1;i>0;i--) {
      high_low_touch_status=0;
      /*
      int arg_shift,int &arg_touch_status,
      double &arg_price[],double &arg_ls_price[],double &arg_tp_price[][],
      int &arg_ls_price_pt[],int &arg_tp_price_pt[][],
      int arg_lspt=50,double arg_ls_ratio=0.6,
      int arg_length=20,int arg_th_pt=10,int arg_expand=1,int arg_long=1,
      int arg_oc_gap_pt=5,int arg_high_low_gap_pt=150,int arg_gap_pt2=20,
      double arg_atr_lvl_pt=5,int arg_atr_range=5
      */
      ret2=getHighLow_Value2(i,high_low_touch_status,price,ls_price,tp_price,ls_price_pt,tp_price_pt,
                           50,0.6,20,0,1,1,
                           5,150,20,5,5);
      ret=high_low_touch_status;
      if (MathAbs(ret)>=1 && i==1) {   //sendmail in future
         //mail
         //buy_break/buy_rebound/sell_break/sell_rebound
         string t_msg[8]={"buy_break","buy_break(2)","buy_rebound","buy_rebound(2)","sell_break","sell_break(2)","sell_rebound","sell_rebound(2)"};
         string t_msg2[8],t_comment[8];
         double t_price[8],t_tp_price[8],t_ls_price[8],t_lots[8];
         int    t_price_pt[8],t_tp_price_pt[8],t_ls_price_pt[8];
         
         int cnt=0;   
         for (int j=0;j<4;j++) {
            if (tp_price[j][0]>0) {
               t_msg2[cnt]=t_msg[j*2];
               t_price[cnt]=price[j];
               t_price_pt[cnt]=0;
               t_ls_price[cnt]=ls_price[j];
               t_ls_price_pt[cnt]=ls_price_pt[j];
               t_tp_price[cnt]=tp_price[j][0];
               t_tp_price_pt[cnt]=tp_price_pt[j][0];
               t_lots[cnt]=getVolume(g_equity_percent,MathAbs(t_ls_price_pt[cnt]));
               t_comment[cnt]=g_comment;
               
               cnt=cnt+1;
            }
            if (tp_price[j][1]>0) {
               t_msg2[cnt]=t_msg[j*2+1];
               t_price[cnt]=price[j];
               t_price_pt[cnt]=0;
               t_ls_price[cnt]=ls_price[j];
               t_ls_price_pt[cnt]=ls_price_pt[j];
               t_tp_price[cnt]=tp_price[j][1];
               t_tp_price_pt[cnt]=tp_price_pt[j][1];
               t_lots[cnt]=getVolume(g_equity_percent,MathAbs(t_ls_price_pt[cnt]));
               t_comment[cnt]=g_comment;
      
               cnt=cnt+1;
            }
         }
         
         string sym=Symbol();
         string ped=getPeriodTp(Period());
         string str=StringConcatenate("[",sym,"(",ped,")]");
      
         string t1=StringConcatenate(TimeMonth(Time[i]),"/",TimeDay(Time[i]));
         string t2=TimeToStr(Time[i],TIME_MINUTES);
         string t=StringConcatenate("[",t1," ",t2,"]");
         string mail_title=StringConcatenate(str," ",t," hit high low (",ret,"|",ret2,")");
      
         sendOrderMail(mail_title,cnt,t_msg2,t_price,t_price_pt,t_ls_price,t_ls_price_pt,t_tp_price,t_tp_price_pt,t_lots,t_comment);
      }
      signalBuffer[i]=ret;
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

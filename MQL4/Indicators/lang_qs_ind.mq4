//+------------------------------------------------------------------+
//|                                                  lang_qs_ind.mq4 |
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
#property indicator_minimum -2
#property indicator_maximum 2
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
input bool     i_sendmail=false;

//global

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
   int ret1=0;
   int ret2=0;
   string sym=Symbol();
   string ped=getPeriodTp(Period());
   string s=StringConcatenate("[",sym,"(",ped,")]");
   for(int i=st-1;i>0;i--) {
      ret1=isQuickShootClose(i);
      if (MathAbs(ret1)==1) {
         signalBuffer[i]=1*ret1;  //qs close signal(+1:close sell,-1:close buy
         /*
         if (i==1) {             //sendmail in future
            //string t1=TimeToStr(Time[i],TIME_DATE);
            string t1=StringConcatenate(TimeMonth(Time[i]),"/",TimeDay(Time[i]));
            string t2=TimeToStr(Time[i],TIME_MINUTES);
            string t=StringConcatenate("[",t1," ",t2,"]");
            string mail_title=StringConcatenate(s," ",t," quick shoot open(",ret1,")");
            mailNotice(mail_title,"");
         }
         */
         continue;
      }
      /*
      double price[2],ls_price[2];
      ret2=isQuickShootOpen(i,50,150,0.25,price,ls_price);
      if (MathAbs(ret2)==1) {
         string t1=StringConcatenate(TimeMonth(Time[i]),"/",TimeDay(Time[i]));
         string t2=TimeToStr(Time[i],TIME_MINUTES);
         string t=StringConcatenate("[",t1," ",t2,"]");

         signalBuffer[i]=2*ret2;  //qs open signal(+2:open buy,-2:open sell
         //Print(t,",ret2=",ret2);
         //Print("buy price=",price[0],",buy_ls_price=",ls_price[0]);
         //Print("sell price=",price[1],",sell_ls_price=",ls_price[1]);

         if (i==1) {             //sendmail in future
            string mail_title=StringConcatenate(s," ",t," quick shoot open(",ret2,")");
            mailNotice(mail_title,"");
         }
         continue;
      }
      */
      /*
      //debug
      datetime t=Time[i];
      datetime t1=StringToTime("2017.10.18 19:00");
      if (t==t1) {
         Print("time=",t);
         Print("shift=",i);
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

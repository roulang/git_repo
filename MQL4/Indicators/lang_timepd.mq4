//+------------------------------------------------------------------+
//|                                                  lang_timepd.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//time period
//jp=1, gbp=2, usd=4
//
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 7
#property indicator_buffers 1
#property indicator_plots   1
//--- plot tm
#property indicator_label1  "tm"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double  tmBuffer[];

//--- each time period
string u1="16:00";  //usa
string u2="00:00";  //usa
string a1="03:00";  //asia
string a2="11:00";  //asia
string g1="10:00";  //england
string g2="18:00";  //england

//

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,tmBuffer);
   
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
   int limit=rates_total-prev_calculated;
   if(prev_calculated==0) {
      limit=InitializeAll();
   }
   
   int st=limit;
   for(int i=st;i>=0;i--) {
      if (i==st) printf("loop");
      string t=TimeToStr(time[i],TIME_MINUTES);
      tmBuffer[i]=0;

      //asia
      if (StringCompare(t,a1,true)>=0 && StringCompare(t,a2,true)<0) {
         tmBuffer[i]+=1;
      }
      //euro
      if (StringCompare(t,g1,true)>=0 && StringCompare(t,g2,true)<0) {
         tmBuffer[i]+=2;
      }
      //ameri
      if (StringCompare(t,u1,true)>=0) {
         tmBuffer[i]+=4;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
int InitializeAll()
{
   printf("init");
   ArrayInitialize(tmBuffer,0.0);
//--- first counting position
   return(Bars-1);
}

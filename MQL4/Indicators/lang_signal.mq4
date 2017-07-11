//+------------------------------------------------------------------+
//|                                                  lang_signal.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//signal map:
//up break:     1
//down break:  -1
//
//
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum -8
#property indicator_maximum 8
#property indicator_buffers 1
#property indicator_plots   1
//--- plot signal
#property indicator_label1  "signal"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input double   refValue=0.0;
input int      barLen=0;
input int      barOffset=0;
//--- indicator buffers
double         signalBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,signalBuffer);
   
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
//--- break the refValue
   //up break:1
   if ((close[1]-open[1]>barLen*Point) && (close[1]-refValue>barOffset*Point)) {
      signalBuffer[0]=1;
   }
   
   //down break:-1
   if ((open[1]-close[1]>barLen*Point) && (refValue-close[1]>barOffset*Point)) {
      signalBuffer[0]=-1;
   }
  
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

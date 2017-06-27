//+------------------------------------------------------------------+
//|                                                  lang_zigzag.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
//#property indicator_plots   2
//--- plot up
#property indicator_label1  "up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot down
#property indicator_label2  "down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         upBuffer[];
double         downBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,upBuffer);
   SetIndexBuffer(1,downBuffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   //PlotIndexSetInteger(0,PLOT_ARROW,159);
   //PlotIndexSetInteger(1,PLOT_ARROW,159);
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   
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
   //upBuffer[1]=low[1]-30*Point;
   //downBuffer[1]=high[1]+30*Point;
   printf("OnCalculate()");
   
   if(prev_calculated==0) {
      InitializeAll();
   }
   
   int st=50;
   upBuffer[st]=low[st];
   downBuffer[st]=high[st];
   
   for(int i=st-1;i>0;i--) {
      if(high[i]>high[i+1]) {
         downBuffer[i+1]=0;
         downBuffer[i]=high[i]+30*Point;
      }
      if(low[i]<low[i+1]) {
         upBuffer[i+1]=0;
         upBuffer[i]=low[i]-30*Point;
      }      
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

int InitializeAll()
{
   ArrayInitialize(upBuffer,0.0);
   ArrayInitialize(downBuffer,0.0);
//--- first counting position
   return(Bars);
}

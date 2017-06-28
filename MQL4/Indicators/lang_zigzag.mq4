//+------------------------------------------------------------------+
//|                                                 lang_zigzag.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot up
#property indicator_label1  "up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSpringGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot down
#property indicator_label2  "down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot star1
#property indicator_label3  "star1"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot star2
#property indicator_label4  "star2"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- indicator buffers
double         upBuffer[];
double         downBuffer[];
double         star1Buffer[];
double         star2Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,upBuffer);
   SetIndexBuffer(1,downBuffer);
   SetIndexBuffer(2,star1Buffer);
   SetIndexBuffer(3,star2Buffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   //PlotIndexSetInteger(0,PLOT_ARROW,159);
   //PlotIndexSetInteger(1,PLOT_ARROW,159);
   //PlotIndexSetInteger(2,PLOT_ARROW,159);
   //PlotIndexSetInteger(3,PLOT_ARROW,159);
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   SetIndexArrow(2,SYMBOL_STOPSIGN);
   SetIndexArrow(3,SYMBOL_STOPSIGN);

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
      InitializeAll();
      limit=50;
      upBuffer[limit]=low[limit]-30*Point;
      downBuffer[limit]=high[limit]+30*Point;
   }
   
   int st=limit;

   //main loop
   for(int i=st-1;i>0;i--) {
      if (i==(st-1)) printf("loop");
      bool isHigh,isLow;
      isHigh=isLow=false;
      if(high[i]>high[i+1]) {
         downBuffer[i+1]=0;
         if(i>1) downBuffer[i]=high[i]+30*Point;
         isHigh=true;
      }
      if(low[i]<low[i+1]) {
         upBuffer[i+1]=0;
         if(i>1) upBuffer[i]=low[i]-30*Point;
         isLow=true;
      }
      if ((isHigh && isLow) || (!isHigh && !isLow)) {
      //if (isHigh && isLow) {
         star1Buffer[i]=high[i]+60*Point;
         star2Buffer[i]=low[i]-60*Point;
      }
      
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

int InitializeAll()
{
   printf("init");
   ArrayInitialize(upBuffer,0.0);
   ArrayInitialize(downBuffer,0.0);
   ArrayInitialize(star1Buffer,0.0);
   ArrayInitialize(star2Buffer,0.0);
//--- first counting position
   return(Bars);
}

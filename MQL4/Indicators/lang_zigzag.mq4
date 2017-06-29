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
#property indicator_buffers 7
#property indicator_plots   7

input int InpDeviation=5;  // Deviation
int innerCount=0;
int outterCount=0;
int totalCount=1;

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
//--- plot inner
#property indicator_label3  "inner"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot outter
#property indicator_label4  "outter"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot midup
#property indicator_label5  "midup"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrSpringGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot middown
#property indicator_label6  "down"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot zig
#property indicator_label7  "zig"
#property indicator_type7   DRAW_SECTION
#property indicator_color7  clrRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- indicator buffers
double         upBuffer[];
double         downBuffer[];
double         innerBuffer[];
double         outterBuffer[];
double         midupBuffer[];
double         middownBuffer[];
double         zigBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,upBuffer);
   SetIndexBuffer(1,downBuffer);
   SetIndexBuffer(2,innerBuffer);
   SetIndexBuffer(3,outterBuffer);
   SetIndexBuffer(4,midupBuffer);
   SetIndexBuffer(5,middownBuffer);
   SetIndexBuffer(6,zigBuffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   //PlotIndexSetInteger(0,PLOT_ARROW,159);
   //PlotIndexSetInteger(1,PLOT_ARROW,159);
   //PlotIndexSetInteger(2,PLOT_ARROW,159);
   //PlotIndexSetInteger(3,PLOT_ARROW,159);
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   SetIndexArrow(2,SYMBOL_STOPSIGN);
   SetIndexArrow(3,SYMBOL_CHECKSIGN);
   SetIndexArrow(4,SYMBOL_ARROWUP);
   SetIndexArrow(5,SYMBOL_ARROWDOWN);

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
   int last_up_i,last_down_i;
   last_up_i=last_down_i=0;
   if(prev_calculated==0) {
      limit=InitializeAll();
      //limit=500;
      totalCount=limit;
      upBuffer[limit]=low[limit]-30*Point;
      downBuffer[limit]=high[limit]+30*Point;
      last_up_i=last_down_i=limit;
   }
   
   int st=limit;
   
   //loop for search short up and short down
   for(int i=st-1;i>0;i--) {
      if (i==(st-1)) printf("loop");
      bool isHigh,isLow;
      isHigh=isLow=false;
      int k=i+1;
      while (k<=st) {
         if (innerBuffer[k]==0) {
            if (high[i]>high[k]) {
               //isHigh=true;
               downBuffer[k]=0;
               if (i>1) {
                  downBuffer[i]=high[i]+30*Point;
                  last_down_i=i;
               }
            }
            if (low[i]<low[k]) {
               //isLow=true;
               upBuffer[k]=0;
               if (i>1) {
                  upBuffer[i]=low[i]-30*Point;
                  last_up_i=i;
               }
            }
            break;
         }
         k++;
      }
      if (high[i]>high[i+1]) isHigh=true;
      if (low[i]<low[i+1]) isLow=true;
      if (isHigh && isLow) {
         outterBuffer[i]=high[i]+90*Point;
         outterCount++;
      }
      if (!isHigh && !isLow) {
         innerBuffer[i]=low[i]-90*Point;
         innerCount++;
      }
      
      if (i==1) {
         printf("inner=%d/%d=%2.1f%%",innerCount,totalCount,double(innerCount)/totalCount*100);
         printf("outter=%d/%d=%2.1f%%",outterCount,totalCount,double(outterCount)/totalCount*100);
      }
   
   }

   int high_i,low_i;
   high_i=low_i=0;
   
   //loop for search mid up and mid down
   for(int i=st;i>0;i--) {
      if (downBuffer[i]!=0) {
         if (high_i!=0) {
            if (downBuffer[i]>downBuffer[high_i]) {
               middownBuffer[high_i]=0;
               if (i!=last_down_i) middownBuffer[i]=high[i]+60*Point;
            }
         } else {
            middownBuffer[i]=high[i]+60*Point;
         }
         high_i=i;
      }
      
      if (upBuffer[i]!=0) {
         if (low_i!=0) {
            if (upBuffer[i]<upBuffer[low_i]) {
               midupBuffer[low_i]=0;
               if (i!=last_up_i) midupBuffer[i]=low[i]-60*Point;
            }
         } else {
            midupBuffer[i]=low[i]-60*Point;
         }
         low_i=i;
      }
   }
   
   int lookfor=0;
   //loop for build zigzag
   for(int i=st;i>0;i--) {
      switch(lookfor) {
         case 0:
            if (middownBuffer[i]!=0) {
               zigBuffer[i]=high[i];
               lookfor=-1;
               break;
            }
            if (midupBuffer[i]!=0) {
               zigBuffer[i]=low[i];
               lookfor=1;
               break;
            }
            break;
         case -1:
            if (midupBuffer[i]!=0) {
               zigBuffer[i]=low[i];
               lookfor=1;
            }
            break;
         case 1:
            if (middownBuffer[i]!=0) {
               zigBuffer[i]=high[i];
               lookfor=-1;
            }
            break;
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
   ArrayInitialize(innerBuffer,0.0);
   ArrayInitialize(outterBuffer,0.0);
   ArrayInitialize(midupBuffer,0.0);
   ArrayInitialize(middownBuffer,0.0);
//   ArrayInitialize(zigBuffer,0.0);
//--- first counting position
   return(Bars-1);
}

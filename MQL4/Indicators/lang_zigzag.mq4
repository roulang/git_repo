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
//#property indicator_minimum -10
//#property indicator_maximum 10
#property indicator_buffers 12
#property indicator_plots   8
//--- plot up
#property indicator_label1  "up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSpringGreen
//#property indicator_color1  clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot down
#property indicator_label2  "down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
//#property indicator_color2  clrBlack
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot inner
#property indicator_label3  "inner"
#property indicator_type3   DRAW_ARROW
//#property indicator_color3  clrYellow
#property indicator_color3  clrBlack
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot outter
#property indicator_label4  "outter"
#property indicator_type4   DRAW_ARROW
//#property indicator_color4  clrYellow
#property indicator_color4  clrBlack
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot midup
#property indicator_label5  "midup"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrSpringGreen
//#property indicator_color5  clrBlack
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot middown
#property indicator_label6  "middown"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
//#property indicator_color6  clrBlack
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot zig
#property indicator_label7  "zig"
#property indicator_type7   DRAW_SECTION    //do not set 0 value
#property indicator_color7  clrRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot last up idx
#property indicator_label8  "lastupi"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrBlack
//--- plot last dw idx
#property indicator_label9  "lastdwi"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrBlack
//--- plot last midup idx
#property indicator_label10  "lastmupi"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrBlack
//--- plot last dw idx
#property indicator_label11  "lastmdwi"
#property indicator_type11   DRAW_ARROW
#property indicator_color11  clrBlack
//--- plot last zig idx
#property indicator_label12  "lastzigi"
#property indicator_type12   DRAW_ARROW
#property indicator_color12  clrBlack
//--- plot last second zig idx
#property indicator_label13  "lastseczigi"
#property indicator_type13   DRAW_ARROW
#property indicator_color13  clrBlack

//--- indicator buffers
double         upBuffer[];
double         downBuffer[];
double         innerBuffer[];
double         outterBuffer[];
double         midupBuffer[];
double         middownBuffer[];
double         zigBuffer[];
double         lstUpIdxBuffer[];
double         lstDownIdxBuffer[];
double         lstMidUpIdxBuffer[];
double         lstMidDownIdxBuffer[];
double         lstZigIdxBuffer[];
double         lstZigSecIdxBuffer[];

//input
input bool i_debug = false;
input int i_deviation=100;  // Deviation
input int i_offset=60;

//global
int g_innerCount=0;
int g_outterCount=0;
int g_totalCount=0;
int g_lookfor=0;
datetime g_last_short_up_time;
datetime g_last_short_down_time;
datetime g_last_mid_up_time;
datetime g_last_mid_down_time;
datetime g_last_zig_time;

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
   SetIndexBuffer(7,lstUpIdxBuffer);
   SetIndexBuffer(8,lstDownIdxBuffer);
   SetIndexBuffer(9,lstMidUpIdxBuffer);
   SetIndexBuffer(10,lstMidDownIdxBuffer);
   SetIndexBuffer(11,lstZigIdxBuffer);
   SetIndexBuffer(12,lstZigSecIdxBuffer);
   
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   SetIndexArrow(2,SYMBOL_STOPSIGN);
   SetIndexArrow(3,SYMBOL_CHECKSIGN);
   SetIndexArrow(4,SYMBOL_ARROWUP);
   SetIndexArrow(5,SYMBOL_ARROWDOWN);
   SetIndexArrow(7,SYMBOL_CHECKSIGN);
   SetIndexArrow(8,SYMBOL_CHECKSIGN);
   SetIndexArrow(9,SYMBOL_CHECKSIGN);
   SetIndexArrow(10,SYMBOL_CHECKSIGN);
   SetIndexArrow(11,SYMBOL_CHECKSIGN);
   SetIndexArrow(12,SYMBOL_CHECKSIGN);
      
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

   int last_short_up_shift=0;
   int last_short_down_shift=0;
   int last_mid_up_shift=0;
   int last_mid_down_shift=0;
   int last_zig_shift=0;
   int limit=Bars-1;
   if(prev_calculated==0) {
      InitializeAll();
      g_totalCount=limit+1;
      upBuffer[limit]=low[limit]-i_offset*Point;
      downBuffer[limit]=high[limit]+i_offset*Point;
      last_short_up_shift=last_short_down_shift=limit;
      g_last_short_up_time=Time[last_short_up_shift];
      g_last_short_down_time=Time[last_short_down_shift];
      last_mid_up_shift=last_mid_down_shift=limit;
      g_last_mid_up_time=Time[last_mid_up_shift];
      g_last_mid_down_time=Time[last_mid_down_shift];
      last_zig_shift=limit;
      g_last_zig_time=Time[last_zig_shift];
   } else {
      last_short_up_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_short_up_time,true);
      last_short_down_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_short_down_time,true);
      if (last_short_up_shift==-1 || last_short_down_shift==-1) {
         Print("Error!!!");
         Print("last_short_up_shift=",last_short_up_shift);
         Print("last_short_down_shift=",last_short_down_shift);
         return rates_total;         
      }
      last_mid_up_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_mid_up_time,true);
      last_mid_down_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_mid_down_time,true);
      if (last_mid_up_shift==-1 || last_mid_down_shift==-1) {
         Print("Error!!!");
         Print("last_mid_up_shift=",last_mid_up_shift);
         Print("last_mid_down_shift=",last_mid_down_shift);
         return rates_total;         
      }
      last_zig_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_zig_time,true);
      if (last_zig_shift==-1) {
         Print("Error!!!");
         Print("last_zig_shift=",last_zig_shift);
         return rates_total;         
      }
   }
   
   //1.mark inner and outter bars, skip last bar
   int st=uncal_bars+1;
   if (st>limit) st=limit;
   if(i_debug) {
      Print("1:st=",st);
   }
   for(int i=st-1;i>0;i--) {
      bool isHigher,isLower;
      isHigher=isLower=false;
      if (high[i]>high[i+1]) isHigher=true;
      if (low[i]<low[i+1]) isLower=true;
      if (isHigher && isLower) {
         outterBuffer[i]=high[i]+(i_offset*3)*Point;
         innerBuffer[i]=0;
         g_outterCount++;
      } else if (!isHigher && !isLower) {
         innerBuffer[i]=low[i]-(i_offset*3)*Point;
         outterBuffer[i]=0;
         g_innerCount++;
      } else {
         outterBuffer[i]=0;
         innerBuffer[i]=0;
      }
      if (i==1) {
         //printf("inner=%d/%d=%2.1f%%",g_innerCount,g_totalCount,double(g_innerCount)/g_totalCount*100);
         //printf("outter=%d/%d=%2.1f%%",g_outterCount,g_totalCount,double(g_outterCount)/g_totalCount*100);
      }
   }

   //2. loop for search short down, skip last 2 bars
   st=last_short_down_shift;
   if(i_debug) {
      Print("2:st=",st);
   }
   int last_down_i=0;
   for(int i=st-1;i>1;i--) {
      //Print("i=",i);
      downBuffer[i]=0;
      if (innerBuffer[i]!=0) {
         //Print("i=",i,"innerBuffer[i]!=0");
         continue;
      }
      int k=i+1;
      while (k<=st) {
         //Print("k=",k);
         if (innerBuffer[k]==0) {
            //Print("k=",k,"innerBuffer[k]==0");
            if (high[i]>high[k]) {
               downBuffer[k]=0;
               downBuffer[i]=high[i]+i_offset*Point;
            }
            break;
         }
         k++;
      }
      if (downBuffer[i]==0) continue;
      k=i-1;
      while (k>0) {
         //Print("k=",k);
         if (innerBuffer[k]==0) {
            //Print("k=",k,"innerBuffer[k]==0");
            if (high[i]<high[k]) {
               downBuffer[i]=0;
            }
            break;
         }
         k--;
      }
      //if (k==0) Print("i=",i,",innerBuffer[i]=",innerBuffer[i],",downBuffer[i]=",downBuffer[i]);
      if (k==0 && innerBuffer[k+1]!=0) downBuffer[i]=0;
      if (downBuffer[i]>0) {
         last_down_i=i;
      }
   }

   //3. loop for search short up, skip last 2 bars
   st=last_short_up_shift;
   if(i_debug) {
      Print("3:st=",st);
   }
   int last_up_i=0;
   for(int i=st-1;i>1;i--) {
      upBuffer[i]=0;
      if (innerBuffer[i]!=0) {
         continue;
      }
      int k=i+1;
      while (k<=st) {
         if (innerBuffer[k]==0) {
            if (low[i]<low[k]) {
               upBuffer[k]=0;
               upBuffer[i]=low[i]-i_offset*Point;
            }
            break;
         }
         k++;
      }
      if (upBuffer[i]==0) continue;
      k=i-1;
      while (k>0) {
         if (innerBuffer[k]==0) {
            if (low[i]>low[k]) {
               upBuffer[i]=0;
            }
            break;
         }
         k--;
      }
      //if (k==0) Print("i=",i,",innerBuffer[i]=",innerBuffer[i],",upBuffer[i]=",upBuffer[i]);
      if (k==0 && innerBuffer[k+1]!=0) upBuffer[i]=0;
      if (upBuffer[i]>0) {
         last_up_i=i;
      }
   }

   //4.set for next onCalculate() to start process   
   if (last_down_i!=0) {
      last_short_down_shift=last_down_i;
      g_last_short_down_time=Time[last_short_down_shift];
   }
   if (last_up_i!=0) {
      last_short_up_shift=last_up_i;
      g_last_short_up_time=Time[last_short_up_shift];
   }

   if(i_debug) {
      Print("4:last_short_down_shift=",last_short_down_shift);
      Print("4:last_short_up_shift=",last_short_up_shift);
      Print("4:g_last_short_down_time=",g_last_short_down_time);
      Print("4:g_last_short_up_time=",g_last_short_up_time);
   }

   //5. loop for search mid down, skip last 2 bars
   st=last_mid_down_shift;
   if(i_debug) {
      Print("5:st=",st);
   }
   last_down_i=0;
   for(int i=st-1;i>1;i--) {
      middownBuffer[i]=0;
      if (downBuffer[i]!=0) {
         int k=i+1;
         while (k<=st) {
            if (downBuffer[k]!=0) {
               if (downBuffer[i]>(downBuffer[k]+i_deviation*Point)) {
                  middownBuffer[k]=0;
                  middownBuffer[i]=high[i]+(i_offset*2)*Point;
               }
               break;
            }
            k++;
         }
         if (middownBuffer[i]==0) continue;
         k=i-1;
         while (k>0) {
            if (downBuffer[k]!=0) {
               if (downBuffer[i]<(downBuffer[k]+i_deviation*Point)) {
                  middownBuffer[i]=0;
               }
               break;
            }
            k--;
         }
         if (i==last_short_down_shift) middownBuffer[i]=0;
         if (middownBuffer[i]>0) last_down_i=i;
      }
   }
   
   //6. loop for search mid up, skip last 2 bars
   st=last_mid_up_shift;
   if(i_debug) {
      Print("6:st=",st);
   }
   last_up_i=0;
   for(int i=st-1;i>1;i--) {
      midupBuffer[i]=0;
      if (upBuffer[i]!=0) {
         int k=i+1;
         while (k<=st) {
            if (upBuffer[k]!=0) {
               if (upBuffer[i]<(upBuffer[k]-i_deviation*Point)) {
                  midupBuffer[k]=0;
                  midupBuffer[i]=low[i]-(i_offset*2)*Point;
               }
               break;
            }
            k++;
         }
         if (midupBuffer[i]==0) continue;
         k=i-1;
         while (k>0) {
            if (upBuffer[k]!=0) {
               if (upBuffer[i]>(upBuffer[k]-i_deviation*Point)) {
                  midupBuffer[i]=0;
               }
               break;
            }
            k--;
         }
         if (i==last_short_up_shift) midupBuffer[i]=0;
         if (midupBuffer[i]>0) last_up_i=i;
      }
   }

   //7.set for last low up index buffer
   st=limit;
   //st=MathMax(last_mid_up_shift,last_mid_down_shift);
   if(i_debug) {
      Print("7:st=",st);
   }
   for(int i=st-1;i>0;i--) {
      lstUpIdxBuffer[i]=0;
      lstDownIdxBuffer[i]=0;
      lstMidUpIdxBuffer[i]=0;
      lstMidDownIdxBuffer[i]=0;
      int k=0;
      k=i+1;
      while (k<=st) {
         if (upBuffer[k]>0 && midupBuffer[k]==0) {
            lstUpIdxBuffer[i]=k-i;
            break;
         }
         k++;
      }
      k=i+1;
      while (k<=st) {
         if (downBuffer[k]>0 && middownBuffer[k]==0) {
            lstDownIdxBuffer[i]=k-i;
            break;
         }
         k++;
      }
      k=i+1;
      while (k<=st) {
         if (middownBuffer[k]>0) {
            lstMidDownIdxBuffer[i]=k-i;
            break;
         }
         k++;
      }
      k=i+1;
      while (k<=st) {
         if (midupBuffer[k]>0) {
            lstMidUpIdxBuffer[i]=k-i;
            break;
         }
         k++;
      }
   }
   
   //8.set for next onCalculate() to start process   
   if (last_down_i!=0) {
      last_mid_down_shift=last_down_i;
      g_last_mid_down_time=Time[last_mid_down_shift];
   }
   if (last_up_i!=0) {
      last_mid_up_shift=last_up_i;
      g_last_mid_up_time=Time[last_mid_up_shift];
   }

   if(i_debug) {
      Print("8:last_mid_down_shift=",last_mid_down_shift);
      Print("8:last_mid_up_shift=",last_mid_up_shift);
      Print("8:g_last_mid_down_time=",g_last_mid_down_time);
      Print("8:g_last_mid_up_time=",g_last_mid_up_time);
   }
   
   //9. loop for build zigzag, skip last 2 bars
   st=last_zig_shift;
   if(i_debug) {
      Print("9:st=",st);
   }
   int high_i,low_i;
   high_i=low_i=0;
   for(int i=st-1;i>1;i--) {
      //zigBuffer[i]=0;    //do not set 0 value
      switch(g_lookfor) {
         case 0:
            if (middownBuffer[i]!=0 && midupBuffer[i]==0) {
               zigBuffer[i]=high[i];
               g_lookfor=-1; //look for ziglow
               high_i=i;
               break;
            }
            if (midupBuffer[i]!=0 && middownBuffer[i]==0) {
               zigBuffer[i]=low[i];
               g_lookfor=1;  //look for zighigh
               low_i=i;
               break;
            }
            break;
         case -1: //look for ziglow
            if (middownBuffer[i]!=0 && midupBuffer[i]==0) {  //found middown
               //find lowest of shortlow
               int k=0;
               for (int j=high_i-1;j>i;j--) {
                  if (upBuffer[j]!=0) {
                     if (k==0) {
                        k=j;
                     } else {
                        if (low[j]<low[k]) {
                           k=j;
                        }
                     }
                  }
               }
               if (k!=0) {
                  zigBuffer[k]=low[k];
                  zigBuffer[i]=high[i];
                  g_lookfor=-1; //look for ziglow
                  high_i=i;
               }
               break;
            }
            if (midupBuffer[i]!=0 && middownBuffer[i]==0) {
               zigBuffer[i]=low[i];
               g_lookfor=1;  //look for zighigh
               low_i=i;
            }
            break;
         case 1:  //look for zighigh
            if (midupBuffer[i]!=0 && middownBuffer[i]==0) {  //found midup
               //find highest of shorthigh
               int k=0;
               for (int j=low_i-1;j>i;j--) {
                  if (downBuffer[j]!=0) {
                     if (k==0) {
                        k=j;
                     } else {
                        if (high[j]>high[k]) {
                           k=j;
                        }
                     }
                  }
               }
               if (k!=0) {
                  zigBuffer[k]=high[k];
                  zigBuffer[i]=low[i];
                  g_lookfor=1;  //look for zighigh
                  low_i=i;
               }
               break;
            }
            if (middownBuffer[i]!=0 && midupBuffer[i]==0) {
               zigBuffer[i]=high[i];
               g_lookfor=-1; //look for ziglow
               high_i=i;
            }
            break;
      }
   }

   //10.set for next onCalculate() to start process
   if (high_i!=0 || low_i!=0) {
      if (high_i!=0) last_zig_shift=high_i;
      else if (low_i!=0) last_zig_shift=low_i;
      else last_zig_shift=MathMin(high_i,low_i);
      g_last_zig_time=Time[last_zig_shift];
   }

   if(i_debug) {
      Print("10:last_zig_shift=",last_zig_shift);
      Print("10:g_last_zig_time=",g_last_zig_time);
      Print("10:g_lookfor=",g_lookfor);
   }

   
   /*
   lstUpIdxBuffer[0]=last_short_up_shift;
   lstDownIdxBuffer[0]=last_short_down_shift;
   lstMidUpIdxBuffer[0]=last_mid_up_shift;
   lstMidDownIdxBuffer[0]=last_mid_down_shift;
   */
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
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
   //ArrayInitialize(zigBuffer,0.0);      //do not set 0 value

//--- first counting position
   return(Bars-1);
}

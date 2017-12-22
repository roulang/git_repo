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
#property indicator_buffers 18
#property indicator_plots   18
//--- plot up
#property indicator_label1  "s_low"    //short low
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSpringGreen
//#property indicator_color1  clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot down
#property indicator_label2  "s_high"   //short high
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
//#property indicator_color2  clrBlack
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot inner
#property indicator_label3  "inner"    //inner
#property indicator_type3   DRAW_ARROW
//#property indicator_color3  clrYellow
#property indicator_color3  clrBlack
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot outter
#property indicator_label4  "outter"   //outter
#property indicator_type4   DRAW_ARROW
//#property indicator_color4  clrYellow
#property indicator_color4  clrBlack
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot midup
#property indicator_label5  "m_low"    //mid low
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrSpringGreen
//#property indicator_color5  clrBlack
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot middown
#property indicator_label6  "m_high"   //mid high
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
//#property indicator_color6  clrBlack
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot longup
#property indicator_label7  "l_low"    //long low
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrSpringGreen
//#property indicator_color7  clrBlack
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot longdown
#property indicator_label8  "l_high"   //long high
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrRed
//#property indicator_color8  clrBlack
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot last up idx
#property indicator_label9  "lstsl_sht"   //last short low shift
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrBlack
//--- plot last dw idx
#property indicator_label10  "lstsh_sht"  //last short high shift
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrBlack
//--- plot last midup idx
#property indicator_label11  "lstml_sht"  //last mid low shift
#property indicator_type11   DRAW_ARROW
#property indicator_color11  clrBlack
//--- plot last longdw idx
#property indicator_label12  "lstmh_sht"  //last mid high shift
#property indicator_type12   DRAW_ARROW
#property indicator_color12  clrBlack
//--- plot last longup idx
#property indicator_label13  "lstll_sht"  //last long low shift
#property indicator_type13   DRAW_ARROW
#property indicator_color13  clrBlack
//--- plot last longdw idx
#property indicator_label14  "lstlh_sht"  //last long high shift
#property indicator_type14   DRAW_ARROW
#property indicator_color14  clrBlack
//--- plot zig
#property indicator_label15  "zig"        //zigzag (link mid high low point)
#property indicator_type15   DRAW_SECTION    //do not set 0 value
#property indicator_color15  clrRed
#property indicator_style15  STYLE_SOLID
#property indicator_width15  1
//--- plot last zig idx
#property indicator_label16  "lstz_sht"   //last zig shift
#property indicator_type16   DRAW_ARROW
#property indicator_color16  clrBlack
//--- plot longzig
#property indicator_label17  "l_zig"      //last long zigzag (link long high low point)
#property indicator_type17   DRAW_SECTION    //do not set 0 value
#property indicator_color17  clrYellow
#property indicator_style17  STYLE_DASH
#property indicator_width17  1
//--- plot last longzig idx
#property indicator_label18  "lstlz_sht"  //last long zig shift
#property indicator_type18   DRAW_ARROW
#property indicator_color18  clrBlack

//--- indicator buffers
double         upBuffer[];
double         downBuffer[];
double         innerBuffer[];
double         outterBuffer[];
double         midupBuffer[];
double         middownBuffer[];
double         longupBuffer[];
double         longdownBuffer[];
double         lstUpIdxBuffer[];
double         lstDownIdxBuffer[];
double         lstMidUpIdxBuffer[];
double         lstMidDownIdxBuffer[];
double         lstLongUpIdxBuffer[];
double         lstLongDownIdxBuffer[];
double         zigBuffer[];
double         lstZigIdxBuffer[];
double         longzigBuffer[];
double         lstLongZigIdxBuffer[];

//input
input bool i_debug = false;
input int i_deviation_st=0;    // Deviation(short)
input int i_deviation_md=0;    // Deviation(middle)
input int i_deviation_lg=0;    // Deviation(long)
input int i_offset=1;

#define MAX_INT 2147483647

//global
int g_innerCount=0;
int g_outterCount=0;
int g_totalCount=0;
int g_lookfor=0;
int g_lookfor_long=0;
int g_zigCount=0;
int g_long_zigCount=0;
datetime g_last_short_up_time;
datetime g_last_short_down_time;
datetime g_last_mid_up_time;
datetime g_last_mid_down_time;
datetime g_last_long_up_time;
datetime g_last_long_down_time;
datetime g_last_zig_time;
datetime g_last_longzig_time;

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
   SetIndexBuffer(6,longupBuffer);
   SetIndexBuffer(7,longdownBuffer);
   SetIndexBuffer(8,lstUpIdxBuffer);
   SetIndexBuffer(9,lstDownIdxBuffer);
   SetIndexBuffer(10,lstMidUpIdxBuffer);
   SetIndexBuffer(11,lstMidDownIdxBuffer);
   SetIndexBuffer(12,lstLongUpIdxBuffer);
   SetIndexBuffer(13,lstLongDownIdxBuffer);
   SetIndexBuffer(14,zigBuffer);
   SetIndexBuffer(15,lstZigIdxBuffer);
   SetIndexBuffer(16,longzigBuffer);
   SetIndexBuffer(17,lstLongZigIdxBuffer);
   
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   SetIndexArrow(2,SYMBOL_STOPSIGN);
   SetIndexArrow(3,SYMBOL_CHECKSIGN);
   SetIndexArrow(4,SYMBOL_ARROWUP);
   SetIndexArrow(5,SYMBOL_ARROWDOWN);
   SetIndexArrow(6,SYMBOL_ARROWUP);
   SetIndexArrow(7,SYMBOL_ARROWDOWN);
   SetIndexArrow(8,SYMBOL_CHECKSIGN);
   SetIndexArrow(9,SYMBOL_CHECKSIGN);
   SetIndexArrow(10,SYMBOL_CHECKSIGN);
   SetIndexArrow(11,SYMBOL_CHECKSIGN);
   SetIndexArrow(12,SYMBOL_CHECKSIGN);
   SetIndexArrow(13,SYMBOL_CHECKSIGN);
   //skip section 14
   SetIndexArrow(15,SYMBOL_CHECKSIGN);
   //skip section 16 
   SetIndexArrow(17,SYMBOL_CHECKSIGN);
   
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
   int last_long_up_shift=0;
   int last_long_down_shift=0;
   int last_zig_shift=0;
   int last_longzig_shift=0;
   int limit=Bars-1;
   if(prev_calculated==0) {
      InitializeAll();
      g_totalCount=limit+1;
      upBuffer[limit]=low[limit]-i_offset*Point;
      downBuffer[limit]=high[limit]+i_offset*Point;
      midupBuffer[limit]=low[limit]-(i_offset*2)*Point;
      middownBuffer[limit]=high[limit]+(i_offset*2)*Point;;
      longupBuffer[limit]=low[limit]-(i_offset*3)*Point;
      longdownBuffer[limit]=high[limit]+(i_offset*3)*Point;;
      
      last_short_up_shift=last_short_down_shift=limit;
      g_last_short_up_time=Time[last_short_up_shift];
      g_last_short_down_time=Time[last_short_down_shift];
      
      last_mid_up_shift=last_mid_down_shift=limit;
      g_last_mid_up_time=Time[last_mid_up_shift];
      g_last_mid_down_time=Time[last_mid_down_shift];
      
      last_zig_shift=limit;
      g_last_zig_time=Time[last_zig_shift];

      last_long_up_shift=last_long_down_shift=limit;
      g_last_long_up_time=Time[last_long_up_shift];
      g_last_long_down_time=Time[last_long_down_shift];

      last_longzig_shift=limit;
      g_last_longzig_time=Time[last_longzig_shift];

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

      last_long_up_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_long_up_time,true);
      last_long_down_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_long_down_time,true);
      if (last_long_up_shift==-1 || last_long_down_shift==-1) {
         Print("Error!!!");
         Print("last_long_up_shift=",last_long_up_shift);
         Print("last_long_down_shift=",last_long_down_shift);
         return rates_total;         
      }

      last_longzig_shift=iBarShift(NULL,PERIOD_CURRENT,g_last_longzig_time,true);
      if (last_longzig_shift==-1) {
         Print("Error!!!");
         Print("last_longzig_shift=",last_longzig_shift);
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
         outterBuffer[i]=high[i]+(i_offset*4)*Point;
         innerBuffer[i]=0;
         g_outterCount++;
      } else if (!isHigher && !isLower) {
         innerBuffer[i]=low[i]-(i_offset*4)*Point;
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
            if (high[i]>(high[k]+i_deviation_st*Point)) {
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
            if (high[i]<(high[k]-i_deviation_st*Point)) {
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
   //2.1 set last second bar value to 0
   downBuffer[1]=0;

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
            if (low[i]<(low[k]-i_deviation_st*Point)) {
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
            if (low[i]>(low[k]+i_deviation_st*Point)) {
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

   //3.1 set last second bar value to 0
   upBuffer[1]=0;

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
               if (high[i]>(high[k]+i_deviation_md*Point)) {
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
               if (high[i]<(high[k]-i_deviation_md*Point)) {
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

   //5.1 set last second bar value to 0
   middownBuffer[1]=0;
   
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
               if (low[i]<(low[k]-i_deviation_md*Point)) {
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
               if (low[i]>(low[k]+i_deviation_md*Point)) {
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

   //6.1 set last second bar value to 0
   midupBuffer[1]=0;
   
   //7.set for next onCalculate() to start process   
   if (last_down_i!=0) {
      last_mid_down_shift=last_down_i;
      g_last_mid_down_time=Time[last_mid_down_shift];
   }
   if (last_up_i!=0) {
      last_mid_up_shift=last_up_i;
      g_last_mid_up_time=Time[last_mid_up_shift];
   }

   if(i_debug) {
      Print("7:last_mid_down_shift=",last_mid_down_shift);
      Print("7:last_mid_up_shift=",last_mid_up_shift);
      Print("7:g_last_mid_down_time=",g_last_mid_down_time);
      Print("7:g_last_mid_up_time=",g_last_mid_up_time);
   }

   //8. loop for search long down, skip last 2 bars
   st=last_long_down_shift;
   if(i_debug) {
      Print("8:st=",st);
   }
   last_down_i=0;
   for(int i=st-1;i>1;i--) {
      longdownBuffer[i]=0;
      if (middownBuffer[i]!=0) {
         int k=i+1;
         while (k<=st) {
            if (middownBuffer[k]!=0) {
               if (high[i]>(high[k]+i_deviation_lg*Point)) {
                  longdownBuffer[k]=0;
                  longdownBuffer[i]=high[i]+(i_offset*3)*Point;
               }
               break;
            }
            k++;
         }
         if (longdownBuffer[i]==0) continue;
         k=i-1;
         while (k>0) {
            if (middownBuffer[k]!=0) {
               if (high[i]<(high[k]-i_deviation_lg*Point)) {
                  longdownBuffer[i]=0;
               }
               break;
            }
            k--;
         }
         if (i==last_mid_down_shift) longdownBuffer[i]=0;
         if (longdownBuffer[i]>0) last_down_i=i;
      }
   }

   //8.1 set last second bar value to 0
   longdownBuffer[1]=0;

   //9. loop for search long up, skip last 2 bars
   st=last_long_up_shift;
   if(i_debug) {
      Print("9:st=",st);
   }
   last_up_i=0;
   for(int i=st-1;i>1;i--) {
      longupBuffer[i]=0;
      if (midupBuffer[i]!=0) {
         int k=i+1;
         while (k<=st) {
            if (midupBuffer[k]!=0) {
               if (low[i]<(low[k]-i_deviation_lg*Point)) {
                  longupBuffer[k]=0;
                  longupBuffer[i]=low[i]-(i_offset*3)*Point;
               }
               break;
            }
            k++;
         }
         if (longupBuffer[i]==0) continue;
         k=i-1;
         while (k>0) {
            if (midupBuffer[k]!=0) {
               if (low[i]>(low[k]+i_deviation_lg*Point)) {
                  longupBuffer[i]=0;
               }
               break;
            }
            k--;
         }
         if (i==last_mid_up_shift) longupBuffer[i]=0;
         if (longupBuffer[i]>0) last_up_i=i;
      }
   }

   //9.1 set last second bar value to 0
   longupBuffer[1]=0;

   //10.set for last down index buffer (use long value)
   //st=limit;
   st=last_long_down_shift;
   if(i_debug) {
      Print("10:st=",st);
   }
   for(int i=st-1;i>=0;i--) {
      lstDownIdxBuffer[i]=0;
      lstMidDownIdxBuffer[i]=0;
      lstLongDownIdxBuffer[i]=0;
      int k=0;
      k=i+1;
      while (k<=st) {
         //if (downBuffer[k]>0 && middownBuffer[k]==0) {
         if (downBuffer[k]>0) {
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
         if (longdownBuffer[k]>0) {
            lstLongDownIdxBuffer[i]=k-i;
            break;
         }
         k++;
      }
      if (i_debug) {
         if (lstDownIdxBuffer[i]==0|| lstMidDownIdxBuffer[i]==0 || lstLongDownIdxBuffer[i]==0) {
            Print("10:st=",st);
            Print("Time[",i,"]=",Time[i]);
         }
      }
   }

   //11.set for last up index buffer (use long value)
   //st=limit;
   st=last_long_up_shift;
   if(i_debug) {
      Print("11:st=",st);
   }
   for(int i=st-1;i>=0;i--) {
      lstUpIdxBuffer[i]=0;
      lstMidUpIdxBuffer[i]=0;
      lstLongUpIdxBuffer[i]=0;
      int k=0;
      k=i+1;
      while (k<=st) {
         //if (upBuffer[k]>0 && midupBuffer[k]==0) {
         if (upBuffer[k]>0) {
            lstUpIdxBuffer[i]=k-i;
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
      k=i+1;
      while (k<=st) {
         if (longupBuffer[k]>0) {
            lstLongUpIdxBuffer[i]=k-i;
            break;
         }
         k++;
      }
      if (i_debug) {
         if (lstUpIdxBuffer[i]==0|| lstMidUpIdxBuffer[i]==0 || lstLongUpIdxBuffer[i]==0) {
            Print("11:st=",st);
            Print("Time[",i,"]=",Time[i]);
         }
      }
   }
   
   //12.set for next onCalculate() to start process   
   if (last_down_i!=0) {
      last_long_down_shift=last_down_i;
      g_last_long_down_time=Time[last_long_down_shift];
   }
   if (last_up_i!=0) {
      last_long_up_shift=last_up_i;
      g_last_long_up_time=Time[last_long_up_shift];
   }

   if(i_debug) {
      Print("12:last_long_down_shift=",last_long_down_shift);
      Print("12:last_long_up_shift=",last_long_up_shift);
      Print("12:g_last_long_down_time=",g_last_long_down_time);
      Print("12:g_last_long_up_time=",g_last_long_up_time);
   }

   //13. loop for build zigzag, skip last 2 bars
   st=last_zig_shift;
   //Print("13:st=",st,",lookfor=",g_lookfor);
   if(i_debug) {
      Print("13:st=",st);
   }
   int high_i,low_i;
   high_i=low_i=0;
   for(int i=st-1;i>1;i--) {
      //zigBuffer[i]=0;    //do not set 0 value
      switch(g_lookfor) {
         case 0:
            if (middownBuffer[i]!=0 && midupBuffer[i]==0) {
               zigBuffer[i]=high[i];
               g_zigCount++;
               g_lookfor=-1; //look for ziglow
               high_i=i;
               break;
            }
            if (midupBuffer[i]!=0 && middownBuffer[i]==0) {
               zigBuffer[i]=low[i];
               g_zigCount++;
               g_lookfor=1;  //look for zighigh
               low_i=i;
               break;
            }
            break;
         case -1: //look for ziglow
            if (middownBuffer[i]!=0 && midupBuffer[i]==0) {  //found middown
               //find lowest of shortlow
               int k=0;
               int st2=high_i;
               if (st2==0) st2=last_zig_shift;
               for (int j=st2-1;j>i;j--) {
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
                  g_zigCount++;
                  g_zigCount++;
                  g_lookfor=-1; //look for ziglow
                  high_i=i;
               }
               break;
            }
            if (midupBuffer[i]!=0 && middownBuffer[i]==0) {
               zigBuffer[i]=low[i];
               g_zigCount++;
               g_lookfor=1;  //look for zighigh
               low_i=i;
            }
            break;
         case 1:  //look for zighigh
            if (midupBuffer[i]!=0 && middownBuffer[i]==0) {  //found midup
               //find highest of shorthigh
               int k=0;
               int st2=low_i;
               if (st2==0) st2=last_zig_shift;
               for (int j=st2-1;j>i;j--) {
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
                  g_zigCount++;
                  g_zigCount++;
                  g_lookfor=1;  //look for zighigh
                  low_i=i;
               }
               break;
            }
            if (middownBuffer[i]!=0 && midupBuffer[i]==0) {
               zigBuffer[i]=high[i];
               g_zigCount++;
               g_lookfor=-1; //look for ziglow
               high_i=i;
            }
            break;
      }
      /*
      if (i==2) {
         printf("zig_count=%d/%d=%2.1f%%",g_zigCount,g_totalCount,double(g_zigCount)/g_totalCount*100);
      }
      */
   }

   //14.set for last zig index buffer
   //st=limit;
   st=last_zig_shift;
   if(i_debug) {
      Print("14:st=",st);
   }
   for(int i=st-1;i>=0;i--) {
      lstZigIdxBuffer[i]=0;
      int k=0;
      k=i+1;
      while (k<=st) {
         //if ((downBuffer[k]!=0 || middownBuffer[k]!=0) && zigBuffer[k]>0) {   //high zig
         if (zigBuffer[k]==high[k]) {   //high zig
            lstZigIdxBuffer[i]=k-i;    //plus
            break;
         //} else if ((upBuffer[k]!=0 || midupBuffer[k]!=0) && zigBuffer[k]>0) { //low zig
         } else if (zigBuffer[k]==low[k]) { //low zig
            lstZigIdxBuffer[i]=i-k;    //minus
            break;
         }
         k++;
      }
   }
   
   //15.set for next onCalculate() to start process
   if (high_i!=0 || low_i!=0) {
      if (high_i!=0 && low_i==0) last_zig_shift=high_i;
      else if (low_i!=0 && high_i==0) last_zig_shift=low_i;
      else last_zig_shift=MathMin(high_i,low_i);
      g_last_zig_time=Time[last_zig_shift];
   }

   if(i_debug) {
      Print("15:last_zig_shift=",last_zig_shift);
      Print("15:g_last_zig_time=",g_last_zig_time);
      Print("15:g_lookfor=",g_lookfor);
   }

   //16. loop for build long zigzag, skip last 2 bars
   st=last_longzig_shift;
   //Print("16:st=",st,",lookfor_long=",g_lookfor_long);
   if(i_debug) {
      Print("16:st=",st);
   }
   high_i=low_i=0;
   for(int i=st-1;i>1;i--) {
      switch(g_lookfor_long) {
         case 0:
            if (longdownBuffer[i]!=0 && longupBuffer[i]==0) {
               longzigBuffer[i]=high[i];
               g_long_zigCount++;
               g_lookfor_long=-1; //look for long ziglow
               high_i=i;
               break;
            }
            if (longupBuffer[i]!=0 && longdownBuffer[i]==0) {
               longzigBuffer[i]=low[i];
               g_long_zigCount++;
               g_lookfor_long=1;  //look for long zighigh
               low_i=i;
               break;
            }
            break;
         case -1: //look for long ziglow
            if (longdownBuffer[i]!=0 && longupBuffer[i]==0) {  //found long down
               //find lowest of midlow
               int k=0;
               int st2=high_i;
               if (st2==0) st2=last_longzig_shift;
               for (int j=st2-1;j>i;j--) {
                  if (midupBuffer[j]!=0) {
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
                  longzigBuffer[k]=low[k];
                  longzigBuffer[i]=high[i];
                  g_long_zigCount++;
                  g_long_zigCount++;
                  g_lookfor_long=-1; //look for long ziglow
                  high_i=i;
               }
               break;
            }
            if (longupBuffer[i]!=0 && longdownBuffer[i]==0) {
               longzigBuffer[i]=low[i];
               g_long_zigCount++;
               g_lookfor_long=1;  //look for long zighigh
               low_i=i;
            }
            break;
         case 1:  //look for long zighigh
            if (longupBuffer[i]!=0 && longdownBuffer[i]==0) {  //found longup
               //find highest of midhigh
               int k=0;
               int st2=low_i;
               if (st2==0) st2=last_longzig_shift;
               for (int j=st2-1;j>i;j--) {
                  if (middownBuffer[j]!=0) {
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
                  longzigBuffer[k]=high[k];
                  longzigBuffer[i]=low[i];
                  g_long_zigCount++;
                  g_long_zigCount++;
                  g_lookfor_long=1;  //look for zighigh
                  low_i=i;
               }
               break;
            }
            if (longdownBuffer[i]!=0 && longupBuffer[i]==0) {
               longzigBuffer[i]=high[i];
               g_long_zigCount++;
               g_lookfor_long=-1; //look for ziglow
               high_i=i;
            }
            break;
      }
      /*
      if (i==2) {
         printf("long_zig_count=%d/%d=%2.1f%%",g_long_zigCount,g_totalCount,double(g_long_zigCount)/g_totalCount*100);
      }
      */
   }

   //17.set for last zig index buffer
   //st=limit;
   st=last_longzig_shift;
   if(i_debug) {
      Print("17:st=",st);
   }
   for(int i=st-1;i>=0;i--) {
      lstLongZigIdxBuffer[i]=0;
      int k=0;
      k=i+1;
      while (k<=st) {
         //if ((middownBuffer[k]!=0 || longdownBuffer[k]!=0) && longzigBuffer[k]>0) {   //high long zig
         if (longzigBuffer[k]==high[k]) {   //high long zig
            lstLongZigIdxBuffer[i]=k-i;    //plus
            break;
         //} else if ((midupBuffer[k]!=0 || longupBuffer[k]!=0) && longzigBuffer[k]>0) { //low long zig
         } else if (longzigBuffer[k]==low[k]) { //low long zig
            lstLongZigIdxBuffer[i]=i-k;    //minus
            break;
         }
         k++;
      }
   }
   
   //18.set for next onCalculate() to start process
   if (high_i!=0 || low_i!=0) {
      if (high_i!=0 && low_i==0) last_longzig_shift=high_i;
      else if (low_i!=0 && high_i==0) last_longzig_shift=low_i;
      else last_longzig_shift=MathMin(high_i,low_i);
      g_last_longzig_time=Time[last_longzig_shift];
   }

   if(i_debug) {
      Print("18:last_longzig_shift=",last_longzig_shift);
      Print("18:g_last_longzig_time=",g_last_longzig_time);
      Print("18:g_lookfor_long=",g_lookfor_long);
   }

   
   /*
   lstUpIdxBuffer[0]=last_short_up_shift;
   lstDownIdxBuffer[0]=last_short_down_shift;
   lstMidUpIdxBuffer[0]=last_mid_up_shift;
   lstMidDownIdxBuffer[0]=last_mid_down_shift;

   Print("limit=",limit,",Time[limit]",Time[limit],",upBuffer[limit]=",upBuffer[limit],",downBuffer[limit]=",downBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",innerBuffer[limit]=",innerBuffer[limit],",outterBuffer[limit]=",outterBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",midupBuffer[limit]=",midupBuffer[limit],",middownBuffer[limit]=",middownBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",longupBuffer[limit]=",longupBuffer[limit],",longdownBuffer[limit]=",longdownBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",lstUpIdxBuffer[limit]=",lstUpIdxBuffer[limit],",lstDownIdxBuffer[limit]=",lstDownIdxBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",lstMidUpIdxBuffer[limit]=",lstMidUpIdxBuffer[limit],",lstMidDownIdxBuffer[limit]=",lstMidDownIdxBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",lstLongUpIdxBuffer[limit]=",lstLongUpIdxBuffer[limit],",lstLongDownIdxBuffer[limit]=",lstLongDownIdxBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",zigBuffer[limit]=",zigBuffer[limit],",lstZigIdxBuffer[limit]=",lstZigIdxBuffer[limit]);
   Print("limit=",limit,",Time[limit]",Time[limit],",longzigBuffer[limit]=",longzigBuffer[limit],",lstLongZigIdxBuffer[limit]=",lstLongZigIdxBuffer[limit]);

   */
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int InitializeAll()
{
   if(i_debug) printf("init");
   ArrayInitialize(innerBuffer,0.0);
   ArrayInitialize(outterBuffer,0.0);
   ArrayInitialize(upBuffer,0.0);
   ArrayInitialize(downBuffer,0.0);
   ArrayInitialize(midupBuffer,0.0);
   ArrayInitialize(middownBuffer,0.0);
   ArrayInitialize(longupBuffer,0.0);
   ArrayInitialize(longdownBuffer,0.0);
   ArrayInitialize(lstUpIdxBuffer,0.0);
   ArrayInitialize(lstDownIdxBuffer,0.0);
   ArrayInitialize(lstMidUpIdxBuffer,0.0);
   ArrayInitialize(lstMidDownIdxBuffer,0.0);
   ArrayInitialize(lstLongUpIdxBuffer,0.0);
   ArrayInitialize(lstLongDownIdxBuffer,0.0);
   ArrayInitialize(lstZigIdxBuffer,0.0);
   ArrayInitialize(lstLongZigIdxBuffer,0.0);
   //ArrayInitialize(zigBuffer,0.0);      //do not set 0 value
   //ArrayInitialize(longzigBuffer,0.0);      //do not set 0 value

//--- first counting position
   return(Bars-1);
}

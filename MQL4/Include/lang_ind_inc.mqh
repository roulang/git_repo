//+------------------------------------------------------------------+
//|                                                 lang_ind_inc.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <lang_inc.mqh>

//+------------------------------------------------------------------+
// ind_init: indicator init
//+------------------------------------------------------------------+
void ind_init()
{
   CurrentTimeStamp = Time[0];
   getClientServerOffset();
}

//+------------------------------------------------------------------+
//| get Moving Average period
//| arg_timeperiod:M1,M5,M15,M30,H1,H4,D1,W1,WN1
//| arg_type:0,short;1,middle;2,long
//+------------------------------------------------------------------+
int getMAPeriod(int arg_timeperiod,int arg_type=0)
{
   int ret=0;
   if (arg_timeperiod==PERIOD_CURRENT) arg_timeperiod=Period();
   switch (arg_type) {
      case 0:     //short term
         switch (arg_timeperiod) {
            case PERIOD_M1: 
               ret=60;
               break;
            case PERIOD_M5:
               ret=60;
               break;
            case PERIOD_M15:
               ret=12;
               break;
            case PERIOD_M30:
               ret=12;
               break;
            case PERIOD_H1:
               ret=12;
               break;
            case PERIOD_H4:
               ret=12;
               break;
            case PERIOD_D1:
               ret=10;
               break;
            case PERIOD_W1:
               ret=12;
               break;
            case PERIOD_MN1:
               ret=12;
               break;
            default:
               Print("error on time period");
               break;
         }
         break;
      case 1:     //mid term
         switch (arg_timeperiod) {
            case PERIOD_M1: 
               ret=60;
               break;
            case PERIOD_M5:
               ret=12;
               break;
            case PERIOD_M15:
               ret=36;
               break;
            case PERIOD_M30:
               ret=36;
               break;
            case PERIOD_H1:
               ret=36;
               break;
            case PERIOD_H4:
               ret=36;
               break;
            case PERIOD_D1:
               ret=36;
               break;
            case PERIOD_W1:
               ret=36;
               break;
            case PERIOD_MN1:
               ret=36;
               break;
            default:
               Print("error on time period");
               break;
         }
         break;
      case 2:     //long term
         switch (arg_timeperiod) {
            case PERIOD_M1: 
               ret=60;
               break;
            case PERIOD_M5:
               ret=60;
               break;
            case PERIOD_M15:
               ret=60;
               break;
            case PERIOD_M30:
               ret=60;
               break;
            case PERIOD_H1:
               ret=60;
               break;
            case PERIOD_H4:
               ret=60;
               break;
            case PERIOD_D1:
               ret=60;
               break;
            case PERIOD_W1:
               ret=60;
               break;
            case PERIOD_MN1:
               ret=60;
               break;
            default:
               Print("error on time period");
               break;
         }
         break;
      default:
         Print("arg_type error");
         break;
   }
   
   return ret;
}

//+------------------------------------------------------------------+
//| Time Period function
//| arg_period: 
//| arg_type:0,short;1,middle;2,long;-1,specific period
//+------------------------------------------------------------------+
int expandPeriod(int arg_period,int arg_shift,int &arg_larger_shift,int arg_type=0,int arg_period2=0)
{
   int curPd;
   if (arg_period==PERIOD_CURRENT) {
      curPd=Period();
   } else {
      curPd=arg_period;
   }
   datetime cur_time=Time[arg_shift];
   /*
   int cur_d=TimeDayOfWeek(cur_time);
   int cur_h=TimeHour(cur_time);
   int cur_mi=TimeMinute(cur_time);   
   */
   int ret=0;
   if (arg_type==-1 && arg_period2>0) {
      //return specific shift
      arg_larger_shift=iBarShift(NULL,arg_period2,cur_time);
      ret=arg_period2;
      return ret;
   }
   switch (curPd) {
      case PERIOD_M1:
         switch (arg_type) {
            case 0:
               //return M5's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_M5,cur_time);
               ret=PERIOD_M5;
               break;
            case 1:
               //return H1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_H1,cur_time);
               ret=PERIOD_H1;
               break;
            case 2:
               //return D1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_D1,cur_time);
               ret=PERIOD_D1;
               break;
            default:
               //unknown
               break;
         }
         
         break;
      case PERIOD_M5:
         switch (arg_type) {
            case 0:
               //return M30's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_M30,cur_time);
               ret=PERIOD_M30;
               break;
            case 1:
               //return H1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_H1,cur_time);
               ret=PERIOD_H1;
               break;
            case 2:
               //return D1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_D1,cur_time);
               ret=PERIOD_D1;
               break;
            default:
               //unknown
               break;
         }
         break;
      case PERIOD_M15:
         switch (arg_type) {
            case 0:
               //return H1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_H1,cur_time);
               ret=PERIOD_H1;
               break;
            case 1:
               //return H4's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_H4,cur_time);
               ret=PERIOD_H4;
               break;
            case 2:
               //return D1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_D1,cur_time);
               ret=PERIOD_D1;
               break;
            default:
               //unknown
               break;
         }
         break;
      case PERIOD_M30:
         switch (arg_type) {
            case 0:
               //return H4's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_H4,cur_time);
               ret=PERIOD_H4;
               break;
            case 1:
               //return D1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_D1,cur_time);
               ret=PERIOD_D1;
               break;
            case 2:
               //return W1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_W1,cur_time);
               ret=PERIOD_W1;
               break;
            default:
               //unknown
               break;
         }
         break;
      case PERIOD_H1:
         switch (arg_type) {
            case 0:
               //return H4's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_H4,cur_time);
               ret=PERIOD_H4;
               break;
            case 1:
               //return D1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_D1,cur_time);
               ret=PERIOD_D1;
               break;
            case 2:
               //return W1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_W1,cur_time);
               ret=PERIOD_W1;
               break;
            default:
               //unknown
               break;
         }
         break;
      case PERIOD_H4:
         switch (arg_type) {
            case 0:
               //return D1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_D1,cur_time);
               ret=PERIOD_D1;
               break;
            case 1:
               //return W1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_W1,cur_time);
               ret=PERIOD_W1;
               break;
            case 2:
               //return MN1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_MN1,cur_time);
               ret=PERIOD_MN1;
               break;
            default:
               //unknown
               break;
         }
         break;
      case PERIOD_D1:
         switch (arg_type) {
            case 0:
               //return W1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_W1,cur_time);
               ret=PERIOD_W1;
               break;
            case 1:
               //return MN1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_MN1,cur_time);
               ret=PERIOD_MN1;
               break;
            case 2:
               //return MN1's shift
               arg_larger_shift=iBarShift(NULL,PERIOD_MN1,cur_time);
               ret=PERIOD_MN1;
               break;
            default:
               //unknown
               break;
         }
         break;
      default:
         //unknown
         break;
   }
   
   return ret;
}

int shrinkPeriod(int arg_larger_period,int arg_shift)
{
   datetime cur_time=Time[arg_shift];
   int larger_shift=iBarShift(NULL,arg_larger_period,cur_time);
   return larger_shift;
}

//+------------------------------------------------------------------+
//| get pivot value
//| date: 2017/10/10
//| arg_period: time period
//| arg_shift: bar shift
//| arg_pivot: pivot value(return)
//| arg_pivot: pivot value shift (last/new)
//+------------------------------------------------------------------+
void getPivotValue(int arg_period,int arg_shift,double &arg_pivot[],int &arg_larger_shift)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();
   int bar_shift=arg_shift;

   int larger_sht;
   int larger_pd=expandPeriod(arg_period,bar_shift,larger_sht,-1,PERIOD_D1);
   larger_sht=larger_sht+1;
   if (larger_sht==arg_larger_shift) return;
   
   double h=iHigh(NULL,larger_pd,larger_sht);
   double l=iLow(NULL,larger_pd,larger_sht);
   double c=iClose(NULL,larger_pd,larger_sht);
   double p=NormalizeDouble((h+l+c)/3,Digits);
   
   arg_pivot[0]=p;
   arg_pivot[1]=2*p-l;
   arg_pivot[2]=2*p-h;
   arg_pivot[3]=p+(h-l);
   arg_pivot[4]=p-(h-l);
   arg_larger_shift=larger_sht;
}

//+------------------------------------------------------------------+
//| get nearest high and low price (use lang_zig_zag & lang_pivot indicator)
//| arg_shift: bar shift
//| &arg_zig_buf[][]: to store high and low zig value.[0]:time,[1]:value,[2]:shift
//| &arg_pivot_buf[5]: to store pivot high and low value
//| &arg_high_low[][]: to store last two high and low zig value.four items,
//| 0:second nearest high price,1:nearest high price,2:nearest low price,3:second nearest low price
//| [0]:price,[1]:shift
//+------------------------------------------------------------------+
void getNearestHighLowPrice3(double arg_price,int arg_period,int arg_shift,int arg_length,
                              double &arg_zig_buf[][],double &arg_high_low[][],
                              double &arg_pivot_buf[],int &arg_pivot_shift,
                              int arg_long=0,int arg_add_pivot_value=0,bool arg_sort_only=false,
                              int arg_bar_stat=0,int arg_thred_pt=0)
{

   //PrintTwoDimArray(arg_zig_buf);

   //double cur_price=Close[arg_shift];
   double cur_price=arg_price;
   int bar_status=arg_bar_stat;     //1:for negative bar(open>close)

   int zig_shift_idx;
   int zig_value_idx;
   if (arg_long==0) {
      zig_value_idx=14;
      zig_shift_idx=15;
   } else {
      zig_value_idx=16;
      zig_shift_idx=17;
   }
   int zigShfit=0;
   int bar_shift=arg_shift;
   double zigPrice=0;
   datetime zigTime=0;
   double high_low[][2];   //[0]:price,[1]:shift
   if (arg_add_pivot_value==1) {
      ArrayResize(high_low,arg_length+5); //add pivot value
   } else {
      ArrayResize(high_low,arg_length);
   }
   //add zigzag value
   for (int i=0;i<arg_length;i++) {
      zigShfit=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,zig_shift_idx,bar_shift);
      if (zigShfit==0) break;
      bar_shift+=MathAbs(zigShfit);
      zigTime=Time[bar_shift];
      if (i==0) {
         datetime bufTime=(datetime)arg_zig_buf[0][0];
         if (zigTime==bufTime || arg_sort_only) {
            for (int j=0;j<arg_length;j++) {
               high_low[j][0]=arg_zig_buf[j][1];
               bufTime=(datetime)arg_zig_buf[j][0];
               high_low[j][1]=iBarShift(NULL,arg_period,bufTime,true);
            }
            break;
         }
      }
      zigPrice=iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,zig_value_idx,bar_shift);
      arg_zig_buf[i][0]=(double)zigTime;
      arg_zig_buf[i][1]=zigPrice;
      high_low[i][0]=zigPrice;
      if (zigShfit>0) {
         high_low[i][1]=bar_shift;
      } else {
         high_low[i][1]=-bar_shift;
      }
      arg_zig_buf[i][2]=high_low[i][1];
   }

   //PrintTwoDimArray(arg_zig_buf);
   
   //PrintTwoDimArray(high_low);
   
   //add pivot value
   if (arg_add_pivot_value==1) {
      getPivotValue(arg_period,arg_shift,arg_pivot_buf,arg_pivot_shift);

      high_low[arg_length][0]=arg_pivot_buf[0];    //pivot
      high_low[arg_length+1][0]=arg_pivot_buf[1];  //high
      high_low[arg_length+2][0]=arg_pivot_buf[2];  //low
      high_low[arg_length+3][0]=arg_pivot_buf[3];  //high2
      high_low[arg_length+4][0]=arg_pivot_buf[4];  //low2
   }

   
   ArraySort(high_low,WHOLE_ARRAY,0,MODE_DESCEND);
   
   /*
   //debug
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2017.10.25 16:58");
   if (t==t1) {
      Print("time=",t);
      Print("arg_price=",arg_price);
      Print("arg_period=",arg_period);
      Print("arg_shift=",arg_shift);
      Print("arg_length=",arg_length);
      Print("arg_long=",arg_long);
      Print("arg_add_pivot_value=",arg_add_pivot_value);
      Print("arg_sort_only=",arg_sort_only);
      PrintTwoDimArray(high_low);
   }
   */
   
   //clear values
   arg_high_low[0][0]=0;                  //second nearest high price
   arg_high_low[0][1]=0;                  //second nearest high price's shift
   arg_high_low[1][0]=0;                  //nearest high price
   arg_high_low[1][1]=0;                  //nearest high price's shift
   arg_high_low[2][0]=0;                  //nearest low price
   arg_high_low[2][1]=0;                  //nearest low price's shift
   arg_high_low[3][0]=0;                  //secondnearest low price
   arg_high_low[3][1]=0;                  //second nearest low price's shift

   int m=0;
   int s=ArrayRange(high_low,0);
   double offset=arg_thred_pt*Point;
   if (bar_status==0) {  //positive bar,open<close(cur)
      for (int i=s-1;i>=0;i--) {    //from low to high,ascend
         if (cur_price<=(high_low[i][0]+offset)) {
            break;
         }
         m++;
      }
      
      if (m<=s-2) {
         arg_high_low[0][0]=high_low[s-m-2][0];    //second nearest high price
         arg_high_low[0][1]=high_low[s-m-2][1];    //second nearest high price's shift
      }
      if (m<=s-1) {
         arg_high_low[1][0]=high_low[s-m-1][0];    //nearest high price
         arg_high_low[1][1]=high_low[s-m-1][1];    //nearest high price's shift
      }
      if (m>=1) {
         arg_high_low[2][0]=high_low[s-m][0];      //nearest low price
         arg_high_low[2][1]=high_low[s-m][1];      //nearest low price's shift
      }
      if (m>=2) {
         arg_high_low[3][0]=high_low[s-m+1][0];    //secondnearest low price
         arg_high_low[3][1]=high_low[s-m+1][1];    //second nearest low price's shift
      }
      
      /*
      if (m==0) {
         arg_high_low[0][0]=high_low[s-2][0];      //second nearest high price
         arg_high_low[0][1]=high_low[s-2][1];      //second nearest high price's shift
         arg_high_low[1][0]=high_low[s-1][0];      //nearest high price
         arg_high_low[1][1]=high_low[s-1][1];      //nearest high price's shift
      } else if (m==s) {
         arg_high_low[2][0]=high_low[0][0];        //nearest low price
         arg_high_low[2][1]=high_low[0][1];        //nearest low price's shift
         arg_high_low[3][0]=high_low[1][0];        //secondnearest low price
         arg_high_low[3][1]=high_low[1][1];        //second nearest low price's shift
      } else if (m==1) {
         arg_high_low[0][0]=high_low[s-3][0];      //second nearest high price
         arg_high_low[0][1]=high_low[s-3][1];      //second nearest high price's shift
         arg_high_low[1][0]=high_low[s-2][0];      //nearest high price
         arg_high_low[1][1]=high_low[s-2][1];      //nearest high price's shift
         arg_high_low[2][0]=high_low[s-1][0];      //nearest low price
         arg_high_low[2][1]=high_low[s-1][1];      //nearest low price's shift
      } else if (m==s-1) {
         arg_high_low[1][0]=high_low[0][0];        //nearest high price
         arg_high_low[1][1]=high_low[0][1];        //nearest high price's shift
         arg_high_low[2][0]=high_low[1][0];        //nearest low price
         arg_high_low[2][1]=high_low[1][1];        //nearest low price's shift
         arg_high_low[3][0]=high_low[2][0];        //secondnearest low price
         arg_high_low[3][1]=high_low[2][1];        //second nearest low price's shift
      } else {
         arg_high_low[0][0]=high_low[s-m-2][0];    //second nearest high price
         arg_high_low[0][1]=high_low[s-m-2][1];    //second nearest high price's shift
         arg_high_low[1][0]=high_low[s-m-1][0];    //nearest high price
         arg_high_low[1][1]=high_low[s-m-1][1];    //nearest high price's shift
         arg_high_low[2][0]=high_low[s-m][0];      //nearest low price
         arg_high_low[2][1]=high_low[s-m][1];      //nearest low price's shift
         arg_high_low[3][0]=high_low[s-m+1][0];    //secondnearest low price
         arg_high_low[3][1]=high_low[s-m+1][1];    //second nearest low price's shift
      }
      */
   } else {             //negative bar,open>close(cur)
      for (int i=0;i<s;i++) {    //from high to low,descend
         if (cur_price>=(high_low[i][0]-offset)) {
            break;
         }
         m++;
      }
      
      if (m>=2) {
         arg_high_low[0][0]=high_low[m-2][0];   //second nearest high price
         arg_high_low[0][1]=high_low[m-2][1];   //second nearest high price's shift
      }
      if (m>=1) {
         arg_high_low[1][0]=high_low[m-1][0];   //nearest high price
         arg_high_low[1][1]=high_low[m-1][1];   //nearest high price's shift
      }
      if (m<=s-1) {
         arg_high_low[2][0]=high_low[m][0];     //nearest low price
         arg_high_low[2][1]=high_low[m][1];     //nearest low price's shift
      }
      if (m<=s-2) {
         arg_high_low[3][0]=high_low[m+1][0];   //secondnearest low price
         arg_high_low[3][1]=high_low[m+1][1];   //second nearest low price's shift
      }
      
      /*
      if (m==0) {
         arg_high_low[2][0]=high_low[0][0];     //nearest low price
         arg_high_low[2][1]=high_low[0][1];     //nearest low price's shift
         arg_high_low[3][0]=high_low[1][0];     //secondnearest low price
         arg_high_low[3][1]=high_low[1][1];     //second nearest low price's shift
      } else if (m==s) {
         arg_high_low[0][0]=high_low[s-2][0];   //second nearest high price
         arg_high_low[0][1]=high_low[s-2][1];   //second nearest high price's shift
         arg_high_low[1][0]=high_low[s-1][0];   //nearest high price
         arg_high_low[1][1]=high_low[s-1][1];   //nearest high price's shift
      } else if (m==1) {
         arg_high_low[1][0]=high_low[0][0];     //nearest high price
         arg_high_low[1][1]=high_low[0][1];     //nearest high price's shift
         arg_high_low[2][0]=high_low[1][0];     //nearest low price
         arg_high_low[2][1]=high_low[1][1];     //nearest low price's shift
         arg_high_low[3][0]=high_low[2][0];     //secondnearest low price
         arg_high_low[3][1]=high_low[2][1];     //second nearest low price's shift
      } else if (m==s-1) {
         arg_high_low[0][0]=high_low[s-3][0];   //second nearest high price
         arg_high_low[0][1]=high_low[s-3][1];   //second nearest high price's shift
         arg_high_low[1][0]=high_low[s-2][0];   //nearest high price
         arg_high_low[1][1]=high_low[s-2][1];   //nearest high price's shift
         arg_high_low[2][0]=high_low[s-1][0];   //nearest low price
         arg_high_low[2][1]=high_low[s-1][1];   //nearest low price's shift
      } else {
         arg_high_low[0][0]=high_low[m-2][0];   //second nearest high price
         arg_high_low[0][1]=high_low[m-2][1];   //second nearest high price's shift
         arg_high_low[1][0]=high_low[m-1][0];   //nearest high price
         arg_high_low[1][1]=high_low[m-1][1];   //nearest high price's shift
         arg_high_low[2][0]=high_low[m][0];     //nearest low price
         arg_high_low[2][1]=high_low[m][1];     //nearest low price's shift
         arg_high_low[3][0]=high_low[m+1][0];   //secondnearest low price
         arg_high_low[3][1]=high_low[m+1][1];   //second nearest low price's shift
      }
      */
   }

}
//+------------------------------------------------------------------+
//| get nearest high and low price (use lang_zig_zag & lang_pivot indicator)
//| arg_shift: bar shift
//| &arg_zig_buf[][]: to store high and low zig value.[0]:time,[1]:value,[2]:shift
//| &arg_pivot_buf[5]: to store pivot high and low value
//| &arg_high_low[][]: to store last two high and low zig value.four items,
//| 0:third nearest high price,1:second nearest high price,2:nearest high price,
//| 3:nearest low price,4:second nearest low price,5:third nearest low price,
//| [0]:price,[1]:shift
//+------------------------------------------------------------------+
void getNearestHighLowPrice4(double arg_price,int arg_period,int arg_shift,int arg_length,
                              double &arg_zig_buf[][],double &arg_high_low[][],
                              double &arg_pivot_buf[],int &arg_pivot_shift,
                              int arg_long=0,int arg_add_pivot_value=0,bool arg_sort_only=false,
                              int arg_bar_stat=0,int arg_thred_pt=0)
{

   //PrintTwoDimArray(arg_zig_buf);

   //double cur_price=Close[arg_shift];
   double cur_price=arg_price;
   int bar_status=arg_bar_stat;     //1:for negative bar(open>close)

   int zig_shift_idx;
   int zig_value_idx;
   if (arg_long==0) {
      zig_value_idx=14;
      zig_shift_idx=15;
   } else {
      zig_value_idx=16;
      zig_shift_idx=17;
   }
   int zigShfit=0;
   int bar_shift=arg_shift;
   double zigPrice=0;
   datetime zigTime=0;
   double high_low[][2];   //[0]:price,[1]:shift
   if (arg_add_pivot_value==1) {
      ArrayResize(high_low,arg_length+5); //add pivot value
   } else {
      ArrayResize(high_low,arg_length);
   }
   //add zigzag value
   for (int i=0;i<arg_length;i++) {
      zigShfit=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,zig_shift_idx,bar_shift);
      if (zigShfit==0) break;
      bar_shift+=MathAbs(zigShfit);
      zigTime=Time[bar_shift];
      if (i==0) {
         datetime bufTime=(datetime)arg_zig_buf[0][0];
         if (zigTime==bufTime || arg_sort_only) {
            for (int j=0;j<arg_length;j++) {
               high_low[j][0]=arg_zig_buf[j][1];
               bufTime=(datetime)arg_zig_buf[j][0];
               high_low[j][1]=iBarShift(NULL,arg_period,bufTime,true);
            }
            break;
         }
      }
      zigPrice=iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,zig_value_idx,bar_shift);
      arg_zig_buf[i][0]=(double)zigTime;
      arg_zig_buf[i][1]=zigPrice;
      high_low[i][0]=zigPrice;
      if (zigShfit>0) {
         high_low[i][1]=bar_shift;
      } else {
         high_low[i][1]=-bar_shift;
      }
      arg_zig_buf[i][2]=high_low[i][1];
   }

   //PrintTwoDimArray(arg_zig_buf);
   
   //PrintTwoDimArray(high_low);
   
   //add pivot value
   if (arg_add_pivot_value==1) {
      getPivotValue(arg_period,arg_shift,arg_pivot_buf,arg_pivot_shift);

      high_low[arg_length][0]=arg_pivot_buf[0];    //pivot
      high_low[arg_length+1][0]=arg_pivot_buf[1];  //high
      high_low[arg_length+2][0]=arg_pivot_buf[2];  //low
      high_low[arg_length+3][0]=arg_pivot_buf[3];  //high2
      high_low[arg_length+4][0]=arg_pivot_buf[4];  //low2
   }

   
   ArraySort(high_low,WHOLE_ARRAY,0,MODE_DESCEND);
   
   /*
   //debug
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2017.10.25 16:58");
   if (t==t1) {
      Print("time=",t);
      Print("arg_price=",arg_price);
      Print("arg_period=",arg_period);
      Print("arg_shift=",arg_shift);
      Print("arg_length=",arg_length);
      Print("arg_long=",arg_long);
      Print("arg_add_pivot_value=",arg_add_pivot_value);
      Print("arg_sort_only=",arg_sort_only);
      PrintTwoDimArray(high_low);
   }
   */
   
   //clear values
   arg_high_low[0][0]=0;                  //third nearest high price
   arg_high_low[0][1]=0;                  //third nearest high price's shift
   arg_high_low[1][0]=0;                  //second nearest high price
   arg_high_low[1][1]=0;                  //second nearest high price's shift
   arg_high_low[2][0]=0;                  //nearest high price
   arg_high_low[2][1]=0;                  //nearest high price's shift
   arg_high_low[3][0]=0;                  //nearest low price
   arg_high_low[3][1]=0;                  //nearest low price's shift
   arg_high_low[4][0]=0;                  //second nearest low price
   arg_high_low[4][1]=0;                  //second nearest low price's shift
   arg_high_low[5][0]=0;                  //third nearest low price
   arg_high_low[5][1]=0;                  //third nearest low price's shift

   int m=0;
   int s=ArrayRange(high_low,0);
   double offset=arg_thred_pt*Point;
   if (bar_status==0) {  //positive bar,open<close(cur)
      for (int i=s-1;i>=0;i--) {    //from low to high,ascend
         if (cur_price<=(high_low[i][0]+offset)) {
            break;
         }
         m++;
      }
      
      if (m<=s-3) {
         arg_high_low[0][0]=high_low[s-m-3][0];    //third nearest high price
         arg_high_low[0][1]=high_low[s-m-3][1];    //third nearest high price's shift
      }
      if (m<=s-2) {
         arg_high_low[1][0]=high_low[s-m-2][0];    //second nearest high price
         arg_high_low[1][1]=high_low[s-m-2][1];    //second nearest high price's shift
      }
      if (m<=s-1) {
         arg_high_low[2][0]=high_low[s-m-1][0];    //nearest high price
         arg_high_low[2][1]=high_low[s-m-1][1];    //nearest high price's shift
      }
      if (m>=1) {
         arg_high_low[3][0]=high_low[s-m][0];      //nearest low price
         arg_high_low[3][1]=high_low[s-m][1];      //nearest low price's shift
      }
      if (m>=2) {
         arg_high_low[4][0]=high_low[s-m+1][0];    //second nearest low price
         arg_high_low[4][1]=high_low[s-m+1][1];    //second nearest low price's shift
      }
      if (m>=3) {
         arg_high_low[5][0]=high_low[s-m+2][0];    //third nearest low price
         arg_high_low[5][1]=high_low[s-m+2][1];    //third nearest low price's shift
      }
      
   } else {             //negative bar,open>close(cur)
      for (int i=0;i<s;i++) {    //from high to low,descend
         if (cur_price>=(high_low[i][0]-offset)) {
            break;
         }
         m++;
      }
      
      if (m>=3) {
         arg_high_low[0][0]=high_low[m-3][0];   //third nearest high price
         arg_high_low[0][1]=high_low[m-3][1];   //thirdd nearest high price's shift
      }
      if (m>=2) {
         arg_high_low[1][0]=high_low[m-2][0];   //second nearest high price
         arg_high_low[1][1]=high_low[m-2][1];   //second nearest high price's shift
      }
      if (m>=1) {
         arg_high_low[2][0]=high_low[m-1][0];   //nearest high price
         arg_high_low[2][1]=high_low[m-1][1];   //nearest high price's shift
      }
      if (m<=s-1) {
         arg_high_low[3][0]=high_low[m][0];     //nearest low price
         arg_high_low[3][1]=high_low[m][1];     //nearest low price's shift
      }
      if (m<=s-2) {
         arg_high_low[4][0]=high_low[m+1][0];   //second nearest low price
         arg_high_low[4][1]=high_low[m+1][1];   //second nearest low price's shift
      }
      if (m<=s-3) {
         arg_high_low[5][0]=high_low[m+2][0];   //third nearest low price
         arg_high_low[5][1]=high_low[m+2][1];   //third nearest low price's shift
      }
      
   }

}

//+------------------------------------------------------------------+
//| get touch high low status(use lang_zig_zag)
//| date: 2017/10/18
//| arg_shift: bar shift
//| arg_thpt:threahold point
//| arg_touch_status[4]:touch each range point:range_high(3/2/1),range_sub_high(3/2/1),range_sub_low(3/2/1),range_low(3/2/1)
//| plus for positive bar(include nutual bar),minus for nagative bar.
//| ->see below
//| <<range_high,range_sub_high>>
//|     (above) 0
//|  |  (high)  1
//| [ ] (open)  2
//| [ ] (close) 2
//|  |  (low)   3
//|     (below) 4
//| <<range_low,range_sub_low>>
//|     (above) 4
//|  |  (high)  3
//| [ ] (open)  2
//| [ ] (close) 2
//|  |  (low)   1
//|     (below) 0
//| return value: touch high,+1;touch low,-1;0:n/a
//+------------------------------------------------------------------+
int getHighLowTouchStatus(int arg_shift,int arg_thpt,int arg_lengh,double &arg_zig_buf[][],double &arg_high_low[][],
                           double &arg_pivot_buf[],int &arg_pivot_shift,int &arg_larger_shift,int &arg_touch_status[],
                           double &arg_high_gap,double &arg_low_gap,double &arg_high_low_gap,int arg_expand=0,
                           int arg_long=1,int arg_pivot=1)
{
   int bar_shift;
   bar_shift=arg_shift+1;
   ArrayInitialize(arg_touch_status,0);
   double last_close=Close[bar_shift];
   double last_open=Open[bar_shift];
   int bar_status=0;
   if (last_open>last_close) {    //negative bar
      bar_status=1;
   }
   double current_close=Close[arg_shift];
   double current_open=Open[arg_shift];
   double current_high=High[arg_shift];
   double current_low=Low[arg_shift];
   double current_gap=NormalizeDouble(current_high-current_low,Digits);
   int    current_bar_status=0;
   double current_sub_high=current_open;
   double current_sub_low=current_close;
   double current_sub_gap=NormalizeDouble(current_sub_high-current_sub_low,Digits);
   if (current_open<=current_close) {
      current_sub_high=current_close;
      current_sub_low=current_open;
      current_bar_status=1;
   } else {
      current_sub_high=current_open;
      current_sub_low=current_close;
      current_bar_status=-1;
   }
   
   if (arg_expand==0) {
      //getNearestHighLowPrice2(last_close,PERIOD_CURRENT,bar_shift,arg_lengh,arg_zig_buf,arg_high_low,arg_pivot_buf,arg_pivot_shift,arg_long,arg_pivot);
      getNearestHighLowPrice3(last_close,PERIOD_CURRENT,bar_shift,arg_lengh,arg_zig_buf,arg_high_low,arg_pivot_buf,arg_pivot_shift,arg_long,arg_pivot,false,bar_status);
   } else {
      int larger_pd,larger_shift;
      larger_pd=expandPeriod(PERIOD_CURRENT,bar_shift,larger_shift,arg_expand);
      if (arg_larger_shift>0 && arg_larger_shift==larger_shift) {     //
         //getNearestHighLowPrice2(last_close,larger_pd,larger_shift,arg_lengh,arg_zig_buf,arg_high_low,arg_pivot_buf,arg_pivot_shift,arg_long,arg_pivot,true);
         getNearestHighLowPrice3(last_close,larger_pd,larger_shift,arg_lengh,arg_zig_buf,arg_high_low,arg_pivot_buf,arg_pivot_shift,arg_long,arg_pivot,true,bar_status);
      } else {
         //getNearestHighLowPrice2(last_close,larger_pd,larger_shift,arg_lengh,arg_zig_buf,arg_high_low,arg_pivot_buf,arg_pivot_shift,arg_long,arg_pivot);
         getNearestHighLowPrice3(last_close,larger_pd,larger_shift,arg_lengh,arg_zig_buf,arg_high_low,arg_pivot_buf,arg_pivot_shift,arg_long,arg_pivot,false,bar_status);
         arg_larger_shift=larger_shift;
      }
   }
   
   //debug
   //Print("1.zigBuf=");
   //PrintTwoDimArray(arg_zig_buf);
   //Print("1.last_close=",last_close);
   //Print("1.high_low=");
   //PrintTwoDimArray(arg_high_low);
   
   double range_sub_high,range_sub_low;
   double range_high,range_low;
   range_sub_high=range_sub_low=range_high=range_low=0;
   double range_gap,range_sub_gap;
   range_gap=range_sub_gap=0;
   if (arg_high_low[1][0]>0) {       //nearest high
      range_sub_high=arg_high_low[1][0];
   }
   if (arg_high_low[2][0]>0) {       //nearest low
      range_sub_low=arg_high_low[2][0];
   }
   if (arg_high_low[0][0]>0) {       //second nearest high
      range_high=arg_high_low[0][0];
   }
   if (arg_high_low[3][0]>0) {       //second nearest low
      range_low=arg_high_low[3][0];
   }
   if (range_high>0 && range_low>0) {
      range_gap=NormalizeDouble(range_high-range_low,Digits);
   }
   if (range_sub_high>0 && range_sub_low>0) {
      range_sub_gap=NormalizeDouble(range_sub_high-range_sub_low,Digits);
   }

   if (range_sub_high>0 && range_high>0) {
      arg_high_gap=NormalizeDouble(range_high-range_sub_high,Digits);
   } else {
      arg_high_gap=-1;
   }
   if (range_sub_low>0 && range_low>0) {
      arg_low_gap=NormalizeDouble(range_sub_low-range_low,Digits);
   } else {
      arg_low_gap=-1;
   }
   if (range_sub_gap>0) {
      arg_high_low_gap=range_sub_gap;
   } else {
      arg_high_low_gap=-1;
   }
   
   /*
   //debug
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2017.11.03 07:30");
   if (t==t1) {
      Print("range_sub_gap=",range_sub_gap);
   }
   */
   
   if (range_sub_gap==0) return 0;
   
   double break_offset=arg_thpt*Point;
   double target_price;
   
   if (range_high>0) {
      target_price=range_high+break_offset;
      if (target_price>current_high) {
         if (arg_touch_status[0]==0) arg_touch_status[0]=0*current_bar_status;
      } else 
      if (target_price>current_sub_high) {
         if (arg_touch_status[0]==0) arg_touch_status[0]=1*current_bar_status;
      } else
      if (target_price>current_sub_low) {
         if (arg_touch_status[0]==0) arg_touch_status[0]=2*current_bar_status;
      } else
      if (target_price>current_low) {
         if (arg_touch_status[0]==0) arg_touch_status[0]=3*current_bar_status;
      } else
      //if (arg_touch_status[0]==0) arg_touch_status[0]=0*current_bar_status;
      if (arg_touch_status[0]==0) {
         arg_touch_status[0]=4*current_bar_status;
         datetime t=Time[arg_shift];
         //Print("1.touch=4,t=",t);
      }
   
      if (break_offset>0) {
         target_price=range_high-break_offset;
         /*
         if (target_price>current_high) {
            if (arg_touch_status[0]==0) arg_touch_status[0]=0*current_bar_status;
         } else
         if (target_price>current_sub_high) {
            if (arg_touch_status[0]==0) arg_touch_status[0]=1*current_bar_status;
         } else
         if (target_price>current_sub_low) {
            if (arg_touch_status[0]==0) arg_touch_status[0]=2*current_bar_status;
         } else
         if (target_price>current_low) {
            if (arg_touch_status[0]==0) arg_touch_status[0]=3*current_bar_status;
         } else
         //if (arg_touch_status[0]==0) arg_touch_status[0]=0*current_bar_status;
         if (arg_touch_status[0]==0) arg_touch_status[0]=4*current_bar_status;
         */
      }
   }
      
   if (range_sub_high>0) {
      target_price=range_sub_high+break_offset;
      if (target_price>current_high) {
         if (arg_touch_status[1]==0) arg_touch_status[1]=0*current_bar_status;
      } else
      if (target_price>current_sub_high) {
         if (arg_touch_status[1]==0) arg_touch_status[1]=1*current_bar_status;
      } else
      if (target_price>current_sub_low) {
         if (arg_touch_status[1]==0) arg_touch_status[1]=2*current_bar_status;
      } else
      if (target_price>current_low) {
         if (arg_touch_status[1]==0) arg_touch_status[1]=3*current_bar_status;
      } else
      //if (arg_touch_status[1]==0) arg_touch_status[1]=0*current_bar_status;
      if (arg_touch_status[1]==0) {
         arg_touch_status[1]=4*current_bar_status;
         datetime t=Time[arg_shift];
         //Print("2.touch=4,t=",t);
      }
      
      if (break_offset>0) {
         target_price=range_sub_high-break_offset;
         if (target_price>current_high) {
            if (arg_touch_status[1]==0) arg_touch_status[1]=0*current_bar_status;
         } else
         if (target_price>current_sub_high) {
            if (arg_touch_status[1]==0) arg_touch_status[1]=1*current_bar_status;   //set to 1
         } else
         if (target_price>current_sub_low) {
            if (arg_touch_status[1]==0) arg_touch_status[1]=1*current_bar_status;   //set to 1
         } else
         if (target_price>current_low) {
            if (arg_touch_status[1]==0) arg_touch_status[1]=1*current_bar_status;   //set to 1
         } else
         //if (arg_touch_status[1]==0) arg_touch_status[1]=0*current_bar_status;
         if (arg_touch_status[1]==0) arg_touch_status[1]=1*current_bar_status;      //set to 1
      }
   }
      
   if (range_sub_low>0) {
      target_price=range_sub_low-break_offset;
      if (target_price>current_high) {
         //if (arg_touch_status[2]==0) arg_touch_status[2]=0*current_bar_status;
         if (arg_touch_status[2]==0) {
            arg_touch_status[2]=4*current_bar_status;
            datetime t=Time[arg_shift];
            //Print("3.touch=4,t=",t);
         }
      } else
      if (target_price>current_sub_high) {
         if (arg_touch_status[2]==0) arg_touch_status[2]=3*current_bar_status;
      } else
      if (target_price>current_sub_low) {
         if (arg_touch_status[2]==0) arg_touch_status[2]=2*current_bar_status;
      } else
      if (target_price>current_low) {
         if (arg_touch_status[2]==0) arg_touch_status[2]=1*current_bar_status;
      } else
      if (arg_touch_status[2]==0) arg_touch_status[2]=0*current_bar_status;
      
      if (break_offset>0) {
         target_price=range_sub_low+break_offset;
         if (target_price>current_high) {
            //if (arg_touch_status[2]==0) arg_touch_status[2]=0*current_bar_status;
            if (arg_touch_status[2]==0) arg_touch_status[2]=1*current_bar_status;
         } else
         if (target_price>current_sub_high) {
            if (arg_touch_status[2]==0) arg_touch_status[2]=1*current_bar_status;   //set to 1
         } else
         if (target_price>current_sub_low) {
            if (arg_touch_status[2]==0) arg_touch_status[2]=1*current_bar_status;   //set to 1
         } else
         if (target_price>current_low) {
            if (arg_touch_status[2]==0) arg_touch_status[2]=1*current_bar_status;   //set to 1
         } else
         if (arg_touch_status[2]==0) arg_touch_status[2]=0*current_bar_status;
      }
   }
   
   if (range_low>0) {
      target_price=range_low-break_offset;
      if (target_price>current_high) {
         //if (arg_touch_status[3]==0) arg_touch_status[3]=0*current_bar_status;
         if (arg_touch_status[3]==0) {
            arg_touch_status[3]=4*current_bar_status;
            datetime t=Time[arg_shift];
            //Print("4.touch=4,t=",t);
         }
      } else
      if (target_price>current_sub_high) {
         if (arg_touch_status[3]==0) arg_touch_status[3]=3*current_bar_status;
      } else
      if (target_price>current_sub_low) {
         if (arg_touch_status[3]==0) arg_touch_status[3]=2*current_bar_status;
      } else
      if (target_price>current_low) {
         if (arg_touch_status[3]==0) arg_touch_status[3]=1*current_bar_status;
      } else
      if (arg_touch_status[3]==0) arg_touch_status[3]=0*current_bar_status;
      
      if (break_offset>0) {
         target_price=range_low+break_offset;
         /*
         if (target_price>current_high) {
            //if (arg_touch_status[3]==0) arg_touch_status[3]=0*current_bar_status;
            if (arg_touch_status[3]==0) arg_touch_status[3]=4*current_bar_status;
         } else
         if (target_price>current_sub_high) {
            if (arg_touch_status[3]==0) arg_touch_status[3]=3*current_bar_status;
         } else
         if (target_price>current_sub_low) {
            if (arg_touch_status[3]==0) arg_touch_status[3]=2*current_bar_status;
         } else
         if (target_price>current_low) {
            if (arg_touch_status[3]==0) arg_touch_status[3]=1*current_bar_status;
         } else
         if (arg_touch_status[3]==0) arg_touch_status[3]=0*current_bar_status;
         */
      }
   }
      
   if (MathAbs(arg_touch_status[1])>0 && MathAbs(arg_touch_status[2])>0) return 0;
   if (MathAbs(arg_touch_status[1])>0) {   //hit high
      return 1;
   }
   if (MathAbs(arg_touch_status[2])>0) {   //hit low
      return -1;
   }
   return 0;
}

//+------------------------------------------------------------------+
//| Get MA status (base on 3 continous values)
//| date: 2017/10/20
//| arg_period: time period
//| arg_shift: bar shift
//| return value: short>mid,same direction,up,5;
//|               short>mid,different direction(short down,mid up),4;
//|               short>mid,different direction(short up,mid down),3;
//|               short>mid,same direction(short down,mid down),2;
//|               short>mid,no direction(short down,mid down),1;
//| return value: short<mid,same direction,down,-5;
//|               short<mid,different direction(short up,mid down),-4;
//|               short<mid,different direction(short down,mid up),-3;
//|               short<mid,same direction(short up,mid up),-2;
//|               short<mid,no direction(short down,mid down),-1;
//|               n/a:0
//| return value: short break mid,up(within last 2 bars):+10  
//|               short break mid,down(within last 2 bars):-10  
//+------------------------------------------------------------------+
int getMAStatus(int arg_period,int arg_shift,double &arg_short_value)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();

   int short_tm=getMAPeriod(arg_period,0);  //short
   if (short_tm==0) {
      return 0;
   }
   int middle_tm=getMAPeriod(arg_period,1);  //middle
   if (middle_tm==0) {
      return 0;
   }

   double current_short_ma=iMA(NULL,PERIOD_CURRENT,short_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift);
   arg_short_value=current_short_ma;
   double current_high,current_low;
   if (Open[arg_shift]>Close[arg_shift]) {
      current_high=Open[arg_shift];
      current_low=Close[arg_shift];
   } else {
      current_high=Close[arg_shift];
      current_low=Open[arg_shift];
   }
   
   if (current_short_ma<=current_high && current_short_ma>=current_low)    //filter current bar's body through short ma
      return 0;
   
   double last_short_ma=iMA(NULL,PERIOD_CURRENT,short_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift+1);
   double last_high,last_low;
   if (Open[arg_shift+1]>Close[arg_shift+1]) {
      last_high=Open[arg_shift+1];
      last_low=Close[arg_shift+1];
   } else {
      last_high=Close[arg_shift+1];
      last_low=Open[arg_shift+1];
   }
   
   /*
   if (last_short_ma<=last_high && last_short_ma>=last_low)                //filter last bar's body through short ma
      return 0;
   */
   
   double last_short_ma2=iMA(NULL,PERIOD_CURRENT,short_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift+2);
   double current_middle_ma=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift);
   double last_middle_ma=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift+1);
   double last_middle_ma2=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift+2);
   
   /*
   //filter
   if (current_short_ma<=current_high && current_short_ma>=current_low) {        //current bar's body through short ma
      if (current_middle_ma<=current_high && current_middle_ma>=current_low) {   //current bar's body through middle ma
         return 0;
      }
   }
   */
   
   int ret=0;
   int short_direction=0;
   int middle_direction=0;
   if (last_short_ma2<last_short_ma && last_short_ma<current_short_ma) short_direction=1;          //short is up
   if (last_short_ma2>last_short_ma && last_short_ma>current_short_ma) short_direction=-1;         //short is down
   if (last_middle_ma2<last_middle_ma && last_middle_ma<current_middle_ma) middle_direction=1;     //middle is up
   if (last_middle_ma2>last_middle_ma && last_middle_ma>current_middle_ma) middle_direction=-1;    //middle is down
   int break_status=0;
   
   if          (current_short_ma>current_middle_ma && last_short_ma<last_middle_ma) {  //short break mid(last), up
      break_status=10;
   } else if   (current_short_ma>current_middle_ma && last_short_ma>last_middle_ma 
               && last_short_ma2<last_middle_ma2) {                                    //short break mid(last2), up
      break_status=10;
   } else if   (current_short_ma<current_middle_ma && last_short_ma>last_middle_ma) {  //short break mid(last), down
      break_status=-10;
   } else if   (current_short_ma<current_middle_ma && last_short_ma<last_middle_ma 
               && last_short_ma2>last_middle_ma2) {                                    //short break mid(last2), down
      break_status=-10;
   }
      
   if (current_short_ma>current_middle_ma) {             //short>mid

      if (short_direction==1 && middle_direction==1)     //short mid in same direction up
         return (break_status+5);

      if (short_direction==-1 && middle_direction==-1)   //short mid in same direction down
         return (break_status+2);

      if (short_direction==-1 && middle_direction==1)   //short is down, mid is up
         return (break_status+4);

      if (short_direction==1 && middle_direction==-1)   //short is up, mid is down
         return (break_status+3);

      return (break_status+1);
   }
   if (current_short_ma<current_middle_ma) {    //short<mid
      if (short_direction==1 && middle_direction==1)     //short mid in same direction up
         return (break_status-2);

      if (short_direction==-1 && middle_direction==-1)   //short mid in same direction down
         return (break_status-5);

      if (short_direction==-1 && middle_direction==1)   //short is down, mid is up
         return (break_status-3);

      if (short_direction==1 && middle_direction==-1)   //short is up, mid is down
         return (break_status-4);

      return (break_status-1);
   }
   
   return 0;
}
//+------------------------------------------------------------------+
//| Get MA status (base on 3 continous values)
//| date: 2017/10/20
//| arg_period: time period
//| arg_shift: bar shift
//| arg_touch_status[2]:touch each ma line:short_ma(3/2/1),middle_ma(3/2/1)
//| plus for positive bar(include nutual bar),minus for nagative bar.
//| ->see below
//| <<ma line>>
//|     (above) 0
//|  |  (high)  1
//| [ ] (open)  2
//| [ ] (close) 2
//|  |  (low)   3
//|     (below) 4
//| return value: short>mid,same direction,up,5;
//|               short>mid,different direction(short down,mid up),4;
//|               short>mid,different direction(short up,mid down),3;
//|               short>mid,same direction(short down,mid down),2;
//|               short>mid,no direction,1;
//| return value: short<mid,same direction,down,-5;
//|               short<mid,different direction(short up,mid down),-4;
//|               short<mid,different direction(short down,mid up),-3;
//|               short<mid,same direction(short up,mid up),-2;
//|               short<mid,no direction,-1;
//|               n/a:0
//| return value: short break mid,up(within last 2 bars):+10  
//|               short break mid,down(within last 2 bars):-10  
//+------------------------------------------------------------------+
int getMAStatus2(int arg_period,int arg_shift,int &arg_touch_status[],double &arg_short_ma,double &arg_mid_ma)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();

   int short_tm=getMAPeriod(arg_period,0);  //short
   if (short_tm==0) {
      return 0;
   }
   int middle_tm=getMAPeriod(arg_period,1);  //middle
   if (middle_tm==0) {
      return 0;
   }

   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   int sec_lst_bar_shift=arg_shift+2;

   double current_short_ma=iMA(NULL,arg_period,short_tm,0,MODE_EMA,PRICE_CLOSE,cur_bar_shift);

   double current_bar_high,current_bar_low;
   if (Open[cur_bar_shift]>Close[cur_bar_shift]) {
      current_bar_high=Open[cur_bar_shift];
      current_bar_low=Close[cur_bar_shift];
   } else {
      current_bar_high=Close[cur_bar_shift];
      current_bar_low=Open[cur_bar_shift];
   }
   
   /*
   if (current_short_ma<=current_bar_high && current_short_ma>=current_bar_low)    //filter current bar's body through short ma
      return 0;
   */
   
   double last_short_ma=iMA(NULL,arg_period,short_tm,0,MODE_EMA,PRICE_CLOSE,lst_bar_shift);
   double last_bar_high,last_bar_low;
   if (Open[lst_bar_shift]>Close[lst_bar_shift]) {
      last_bar_high=Open[lst_bar_shift];
      last_bar_low=Close[lst_bar_shift];
   } else {
      last_bar_high=Close[lst_bar_shift];
      last_bar_low=Open[lst_bar_shift];
   }
   
   /*
   if (last_short_ma<=last_bar_high && last_short_ma>=last_bar_low)                //filter last bar's body through short ma
      return 0;
   */
   
   double last_short_ma2=iMA(NULL,PERIOD_CURRENT,short_tm,0,MODE_EMA,PRICE_CLOSE,sec_lst_bar_shift);
   double current_middle_ma=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,cur_bar_shift);
   double last_middle_ma=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,lst_bar_shift);
   double last_middle_ma2=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,sec_lst_bar_shift);
   
   /*
   //filter
   if (current_short_ma<=current_bar_high && current_short_ma>=current_bar_low) {        //current bar's body through short ma
      if (current_middle_ma<=current_bar_high && current_middle_ma>=current_bar_low) {   //current bar's body through middle ma
         return 0;
      }
   }
   */
   
   int short_direction=0;
   int middle_direction=0;
   if (last_short_ma2<last_short_ma && last_short_ma<current_short_ma) short_direction=1;          //short is up
   if (last_short_ma2>last_short_ma && last_short_ma>current_short_ma) short_direction=-1;         //short is down
   if (last_middle_ma2<last_middle_ma && last_middle_ma<current_middle_ma) middle_direction=1;     //middle is up
   if (last_middle_ma2>last_middle_ma && last_middle_ma>current_middle_ma) middle_direction=-1;    //middle is down
   
   int break_status=0;
   
   if          (current_short_ma>current_middle_ma && last_short_ma<last_middle_ma) {  //short break mid(last), up
      break_status=10;
   } else if   (current_short_ma>current_middle_ma && last_short_ma>last_middle_ma 
               && last_short_ma2<last_middle_ma2) {                                    //short break mid(last2), up
      break_status=10;
   } else if   (current_short_ma<current_middle_ma && last_short_ma>last_middle_ma) {  //short break mid(last), down
      break_status=-10;
   } else if   (current_short_ma<current_middle_ma && last_short_ma<last_middle_ma 
               && last_short_ma2>last_middle_ma2) {                                    //short break mid(last2), down
      break_status=-10;
   }
   
   int ret=0;
   
   if (current_short_ma>current_middle_ma) {             //short>mid

      if (short_direction==1 && middle_direction==1)     //short mid in same direction up
         ret=break_status+5;

      else 
      if (short_direction==-1 && middle_direction==-1)   //short mid in same direction down
         ret=break_status+2;

      else
      if (short_direction==-1 && middle_direction==1)   //short is down, mid is up
         ret=break_status+4;

      else
      if (short_direction==1 && middle_direction==-1)   //short is up, mid is down
         ret=break_status+3;
      
      else
         ret=break_status+1;
   }
   
   if (current_short_ma<current_middle_ma) {             //short<mid
      if (short_direction==1 && middle_direction==1)     //short mid in same direction up
         ret=break_status-2;

      else
      if (short_direction==-1 && middle_direction==-1)   //short mid in same direction down
         ret=break_status-5;

      else
      if (short_direction==-1 && middle_direction==1)    //short is down, mid is up
         ret=break_status-3;

      else
      if (short_direction==1 && middle_direction==-1)    //short is up, mid is down
         ret=break_status-4;

      else
         ret=break_status-1;
   }

   arg_short_ma=current_short_ma;
   arg_mid_ma=current_middle_ma;
   
   //get touch status
   double current_close=Close[cur_bar_shift];
   double current_open=Open[cur_bar_shift];
   double current_high=High[cur_bar_shift];
   double current_low=Low[cur_bar_shift];
   double current_gap=NormalizeDouble(current_high-current_low,Digits);
   
   int    current_bar_status=0;
   double current_sub_high=current_open;
   double current_sub_low=current_close;
   double current_sub_gap=NormalizeDouble(current_sub_high-current_sub_low,Digits);
   if (current_open<=current_close) {
      current_sub_high=current_close;
      current_sub_low=current_open;
      current_bar_status=1;
   } else {
      current_sub_high=current_open;
      current_sub_low=current_close;
      current_bar_status=-1;
   }
   
   double target_price;
   ArrayInitialize(arg_touch_status,0);

   target_price=current_short_ma;
   if (target_price>current_high) {
      if (arg_touch_status[0]==0) arg_touch_status[0]=0*current_bar_status;
   } else 
   if (target_price>current_sub_high) {
      if (arg_touch_status[0]==0) arg_touch_status[0]=1*current_bar_status;
   } else
   if (target_price>current_sub_low) {
      if (arg_touch_status[0]==0) arg_touch_status[0]=2*current_bar_status;
   } else
   if (target_price>current_low) {
      if (arg_touch_status[0]==0) arg_touch_status[0]=3*current_bar_status;
   } else
   if (arg_touch_status[0]==0) {
      arg_touch_status[0]=4*current_bar_status;
      datetime t=Time[arg_shift];
      //Print("1.touch=4,t=",t);
   }

   target_price=current_middle_ma;
   if (target_price>current_high) {
      if (arg_touch_status[1]==0) arg_touch_status[1]=0*current_bar_status;
   } else 
   if (target_price>current_sub_high) {
      if (arg_touch_status[1]==0) arg_touch_status[1]=1*current_bar_status;
   } else
   if (target_price>current_sub_low) {
      if (arg_touch_status[1]==0) arg_touch_status[1]=2*current_bar_status;
   } else
   if (target_price>current_low) {
      if (arg_touch_status[1]==0) arg_touch_status[1]=3*current_bar_status;
   } else
   if (arg_touch_status[1]==0) {
      arg_touch_status[1]=4*current_bar_status;
      datetime t=Time[arg_shift];
      //Print("1.touch=4,t=",t);
   }
   
   return ret;
}
//+------------------------------------------------------------------+
//| Get ADX status (base on 3 continous values)
//| date: 2017/11/23
//| arg_period: time period
//| arg_shift: bar shift
//| arg_adx_level: 1:adx>=arg_thrd
//| return value: 
//|   2,adx is top(pdi>mdi);-2,adx is top(pdi<mdi);
//|   1,pdi_mdi_gap is top(pdi>mdi);-1,pdi_mdi_gap is top(pdi<mdi);
//|   3,2+1
//|   0,N/A
//+------------------------------------------------------------------+
int getADXStatus(int arg_period,int arg_shift,int &arg_adx_level,int arg_thrd=40)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();
   
   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   int sec_lst_bar_shift=arg_shift+2;
   
   double cur_adx=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MAIN,cur_bar_shift);
   double cur_adx_pdi=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_PLUSDI,cur_bar_shift);
   double cur_adx_mdi=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MINUSDI,cur_bar_shift);
   double lst_adx=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MAIN,lst_bar_shift);
   double lst_adx_pdi=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_PLUSDI,lst_bar_shift);
   double lst_adx_mdi=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MINUSDI,lst_bar_shift);
   double sec_lst_adx=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MAIN,sec_lst_bar_shift);
   double sec_lst_adx_pdi=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_PLUSDI,sec_lst_bar_shift);
   double sec_lst_adx_mdi=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MINUSDI,sec_lst_bar_shift);
   
   double cur_pdi_mdi_gap=cur_adx_pdi-cur_adx_mdi;
   double lst_pdi_mdi_gap=lst_adx_pdi-lst_adx_mdi;
   double sec_lst_pdi_mdi_gap=sec_lst_adx_pdi-sec_lst_adx_mdi;

   double cur_adx_pdi_gap=cur_adx-cur_adx_pdi;
   double lst_adx_pdi_gap=lst_adx-lst_adx_pdi;
   double sec_lst_adx_pdi_gap=sec_lst_adx-sec_lst_adx_pdi;
   double cur_adx_mdi_gap=cur_adx-cur_adx_mdi;
   double lst_adx_mdi_gap=lst_adx-lst_adx_mdi;
   double sec_lst_adx_mdi_gap=sec_lst_adx-sec_lst_adx_mdi;
   
   if (cur_adx>=arg_thrd) {
      arg_adx_level=1;
   } else {
      arg_adx_level=0;
   }
   
   int adx_dir=0;
   if (cur_pdi_mdi_gap>0 && lst_pdi_mdi_gap>0 && sec_lst_pdi_mdi_gap>0) {
      adx_dir=1;
   }
   if (cur_pdi_mdi_gap<0 && lst_pdi_mdi_gap<0 && sec_lst_pdi_mdi_gap<0) {
      adx_dir=-1;
   }
   
   if (adx_dir==0) {    //no direction
      return 0;
   }

   int adx_top=0;
   if (sec_lst_adx<=lst_adx && lst_adx>=cur_adx) {
      if (lst_adx>=arg_thrd) {
         adx_top=1;
      }
   }
   
   int pdi_top=0;
   int mdi_top=0;
   int adx_gap_top=0;
   if          (adx_dir==1) {    //pdi>mdi
      if (sec_lst_adx_pdi<=lst_adx_pdi && lst_adx_pdi>=cur_adx_pdi) {
         pdi_top=1;
      }
      if (sec_lst_adx_mdi>=lst_adx_mdi && lst_adx_mdi<=cur_adx_mdi) {
         mdi_top=1;
      }
      if (sec_lst_adx_pdi_gap>0 && lst_adx_pdi_gap>0 && cur_adx_pdi_gap>0) {
         if (sec_lst_adx_pdi_gap>=lst_adx_pdi_gap && lst_adx_pdi_gap<=cur_adx_pdi_gap) {
            adx_gap_top=1;
         }
      }
   } else if   (adx_dir==-1) {    //pdi<mdi
      if (sec_lst_adx_pdi>=lst_adx_pdi && lst_adx_pdi<=cur_adx_pdi) {
         pdi_top=1;
      }
      if (sec_lst_adx_mdi<=lst_adx_mdi && lst_adx_mdi>=cur_adx_mdi) {
         mdi_top=1;
      }
      if (sec_lst_adx_mdi_gap>0 && lst_adx_mdi_gap>0 && cur_adx_mdi_gap>0) {
         if (sec_lst_adx_mdi_gap>=lst_adx_mdi_gap && lst_adx_mdi_gap<=cur_adx_mdi_gap) {
            adx_gap_top=1;
         }
      }
   }
   
   int pdi_mdi_top=0;
   if (pdi_top==1 && mdi_top==1) {
      if (lst_adx>=arg_thrd || cur_adx>=arg_thrd) {
         pdi_mdi_top=1;
      }
   }
      
   int ret=0;
   
   //ret=(adx_top+pdi_mdi_top)*adx_dir;
   ret=(adx_top*2+adx_gap_top)*adx_dir;
   
   return ret;
}

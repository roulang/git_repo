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
   int larger_pd;
   if (arg_period==PERIOD_D1) {
      larger_pd=PERIOD_D1;
      larger_sht=arg_shift;
   } else {
      larger_pd=expandPeriod(arg_period,bar_shift,larger_sht,-1,PERIOD_D1);
      larger_sht=larger_sht+1;
      if (larger_sht==arg_larger_shift) return;
   }
   
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
int getMAStatus2( int arg_period,int arg_shift,int &arg_touch_status[],double &arg_short_ma,double &arg_mid_ma,
                  int arg_short_ma_ped=0,int arg_mid_ma_ped=0)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();

   int short_tm=0;      //short ma period
   if (arg_short_ma_ped==0) {
      short_tm=getMAPeriod(arg_period,0);
   } else {
      short_tm=arg_short_ma_ped;
   }
   if (short_tm==0) {
      return 0;
   }
   
   int middle_tm=0;     //middle ma period
   if (arg_mid_ma_ped==0) {
      middle_tm=getMAPeriod(arg_period,1);
   } else {
      middle_tm=arg_mid_ma_ped;
   }
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
//+------------------------------------------------------------------+
//| Zigzag Turn
//| arg_shift: series
//| arg_deviation: used by zigzag indicator
//| arg_lsp: lose stop price
//| arg_tpp: take profit price
//| arg_thpt: threhold point
//| arg_lst_stupi: last short up shift
//| arg_lst_mdupi: last middle up shift
//| arg_lst_stdwi: last short down shift
//| arg_lst_mddwi: last middle down shift
//| return value: -1,turn down;1:turn up;0:n/a
//+------------------------------------------------------------------+
int getZigTurn(int arg_period,int arg_shift,int &arg_lst_stupi,int &arg_lst_mdupi,int &arg_lst_stdwi,int &arg_lst_mddwi,int arg_deviation_st=0,int arg_deviation_md=0,int arg_deviation_lg=0,int arg_thpt=0)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();

   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;

   //int tm=getMAPeriod(PERIOD_CURRENT);
   //Print("tm=",tm);
   //if (tm==0) {
   //   return 0;
   //}
   //double ma=iMA(NULL,PERIOD_CURRENT,tm,0,MODE_EMA,PRICE_CLOSE,cur_bar_shift);
   
   //filter ma across
   //if ((Open[cur_bar_shift]>ma && Close[cur_bar_shift]<ma) || (Open[cur_bar_shift]<ma && Close[cur_bar_shift]>ma))
   //   return 0;
   
   arg_lst_stupi=arg_lst_mdupi=arg_lst_stdwi=arg_lst_mddwi=0;

   int up_idx=8;
   int dw_idx=9;
   int midup_idx=10;
   int middw_idx=11;
   int lgup_idx=12;
   int lgdw_idx=13;
   int zig_idx=15;
   
   int high_shift=0;
   int low_shift=0;
   double high_p=0;
   double low_p=0;
   
   int shortLowShift=0;
   int shortHighShift=0;
   int midLowShift=0;
   int midHighShift=0;
   int shortLowShift2=0;
   int shortHighShift2=0;
   shortLowShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,up_idx,cur_bar_shift);
   shortHighShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,dw_idx,cur_bar_shift);
   midLowShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,midup_idx,cur_bar_shift);
   midHighShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,middw_idx,cur_bar_shift);

   if (shortHighShift>0 && midHighShift>0 && shortHighShift==midHighShift) {
      return 0;
   }
   if (shortLowShift>0 && midLowShift>0 && shortLowShift==midLowShift) {
      return 0;
   }

   bool upSign=false;
   bool upSign_fst=false;
   //
   if (shortLowShift>0 && midLowShift>0 && shortLowShift<midLowShift) {
      double shortLow_low=iLow(NULL,arg_period,cur_bar_shift+shortLowShift);
      double midLow_low=iLow(NULL,arg_period,cur_bar_shift+midLowShift);
      //if (Low[cur_bar_shift+shortLowShift]>Low[cur_bar_shift+midLowShift]) {
      if (shortLow_low>midLow_low) {
         high_shift=iHighest(NULL,arg_period,MODE_HIGH,midLowShift-shortLowShift-1,cur_bar_shift+shortLowShift+1);
         //high_p=iHigh(NULL,PERIOD_CURRENT,high_shift);
         //high_p=High[high_shift];
         high_p=iHigh(NULL,arg_period,high_shift);
         upSign=true;
      }
      shortLowShift2=shortLowShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,up_idx,cur_bar_shift+shortLowShift);
   }
   if (upSign && shortLowShift2>=midLowShift) upSign_fst=true;  //start turn up
   else upSign_fst=false;

   bool downSign=false;
   bool downSign_fst=false;
   //
   if (shortHighShift>0 && midHighShift>0 && shortHighShift<midHighShift) {
      double shortHigh_high=iHigh(NULL,arg_period,cur_bar_shift+shortHighShift);
      double midHigh_high=iHigh(NULL,arg_period,cur_bar_shift+midHighShift);
      //if (High[cur_bar_shift+shortHighShift]<High[cur_bar_shift+midHighShift]) {
      if (shortHigh_high<midHigh_high) {
         low_shift=iLowest(NULL,arg_period,MODE_LOW,midHighShift-shortHighShift-1,cur_bar_shift+shortHighShift+1);
         //low_p=iLow(NULL,PERIOD_CURRENT,low_shift);
         //low_p=Low[low_shift];
         low_p=iLow(NULL,arg_period,low_shift);
         downSign=true;
      }
      shortHighShift2=shortHighShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,dw_idx,cur_bar_shift+shortHighShift);
   }
   
   if (downSign && shortHighShift2>=midHighShift) downSign_fst=true;   //start turn down
   else downSign_fst=false;
   
   if (upSign && downSign) {
      //if       (shortLowShift<shortHighShift && midLowShift<midHighShift) {
      if       (midLowShift<midHighShift) {
         downSign=false;
      //} else if  (shortHighShift<shortLowShift && midHighShift<midLowShift) {
      } else if  (midHighShift<midLowShift) {
         upSign=false;
      } else {
         return 0;
      }
   }
   
   if (g_debug) {
      Print("period=",arg_period);
      Print("upSign=",upSign,",downSign=",downSign);
      Print("shortLowShift=",shortLowShift);
      Print("midLowShift=",midLowShift);
      Print("shortLowShift2=",shortLowShift2);
      Print("shortHighShift=",shortHighShift);
      Print("midHighShift=",midHighShift);
      Print("shortHighShift2=",shortHighShift2);
      Print("high_shift=",high_shift,",low_shift=",low_shift);
      Print("high_p=",high_p,",low_p=",low_p);
   }

   arg_lst_stupi=shortLowShift;
   arg_lst_mdupi=midLowShift;
   arg_lst_stdwi=shortHighShift;
   arg_lst_mddwi=midHighShift;
   int bar_status=0;
   double cur_open_price=iOpen(NULL,arg_period,cur_bar_shift);
   double cur_close_price=iClose(NULL,arg_period,cur_bar_shift);
   //if (Open[cur_bar_shift]>Close[cur_bar_shift]) bar_status=-1;      //negative bar
   //if (Open[cur_bar_shift]<Close[cur_bar_shift]) bar_status=1;       //positive bar
   if (cur_open_price>cur_close_price) bar_status=-1;      //negative bar
   if (cur_open_price<cur_close_price) bar_status=1;       //positive bar
   if (upSign && !downSign) {
      if (upSign_fst) {
         //if (bar_status==1 && Close[cur_bar_shift]>(high_p+arg_thpt*Point)) {    //positive bar and go beyond high_p
         if (bar_status==1 && cur_close_price>(high_p+arg_thpt*Point)) {    //positive bar and go beyond high_p
            if (g_debug) {
               Print("upSign=True and go beyond high_p");
               Print("period=",arg_period);
               datetime tm=iTime(NULL,arg_period,cur_bar_shift);
               //Print(Time[cur_bar_shift],",high_shift=",high_shift-cur_bar_shift,",high_p=",high_p);
               Print(tm,",high_shift=",high_shift-cur_bar_shift,",high_p=",high_p);
               Print("cur_bar_shift=",cur_bar_shift);
               Print("shortLowShift=",shortLowShift);
               Print("midLowShift=",midLowShift);
               Print("shortLowShift2=",shortLowShift2);
               Print("shortHighShift=",shortHighShift);
               Print("midHighShift=",midHighShift);
               Print("shortHighShift2=",shortHighShift2);
            }
            //add ma check
            //if (Open[cur_bar_shift]>=ma && Close[cur_bar_shift]>=ma) {
            //   return 4;
            //} else {
               return 3;
            //}
         } else {
            return 2;
         }
      } else {
         return 1;
      }
   }
   
   if (downSign && !upSign) {
      if (downSign_fst) {
         //if (bar_status==-1 && Close[cur_bar_shift]<(low_p-arg_thpt*Point)) {    //negative bar and go below low_p 
         if (bar_status==-1 && cur_close_price<(low_p-arg_thpt*Point)) {    //negative bar and go below low_p 
            if (g_debug) {
               Print("downSign=True and go below low_p");
               Print("period=",arg_period);
               datetime tm=iTime(NULL,arg_period,cur_bar_shift);
               //Print(Time[cur_bar_shift],",low_shift=",low_shift-cur_bar_shift,",low_p=",low_p);
               Print(tm,",low_shift=",low_shift-cur_bar_shift,",low_p=",low_p);
               Print("cur_bar_shift=",cur_bar_shift);
               Print("shortLowShift=",shortLowShift);
               Print("midLowShift=",midLowShift);
               Print("shortLowShift2=",shortLowShift2);
               Print("shortHighShift=",shortHighShift);
               Print("midHighShift=",midHighShift);
               Print("shortHighShift2=",shortHighShift2);
            }
            //add ma check
            //if (Open[cur_bar_shift]<=ma && Close[cur_bar_shift]<=ma) {
            //   return -4;
            //} else {
               return -3;
            //}
         } else {
               return -2;
         }
      } else {
         return -1;
      }
   }
   
   return 0;
   
}
//+------------------------------------------------------------------+
//| Zigzag Turn
//| arg_period: period
//| arg_shift: series
//| arg_lst_small_upi: last short up shift
//| arg_lst_big_upi: last middle up shift
//| arg_lst_small_dwi: last short down shift
//| arg_lst_big_dwi: last middle down shift
//| arg_long: 0,for short and mid;1,for mid and long
//| return value: -1,turn down;1:turn up;0:n/a
//+------------------------------------------------------------------+
int getZigTurn2(  int arg_period,int arg_shift,int &arg_lst_small_upi,int &arg_lst_big_upi,int &arg_lst_small_dwi,int &arg_lst_big_dwi,
                  int arg_long=0,int arg_deviation_st=0,int arg_deviation_md=0,int arg_deviation_lg=0,int arg_thpt=0)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();

   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   
   arg_lst_small_upi=arg_lst_big_upi=arg_lst_small_dwi=arg_lst_big_dwi=0;

   int up_idx=8;
   int dw_idx=9;
   int midup_idx=10;
   int middw_idx=11;
   int longup_idx=12;
   int longdw_idx=13;
   
   int high_shift=0;
   int low_shift=0;
   double high_p=0;
   double low_p=0;
   
   int smallLowShift=0,smallHighShift=0;
   int bigLowShift=0,bigHighShift=0;
   int smallLowShift2=0,smallHighShift2=0;
   
   int shortLowShift=0,shortHighShift=0;
   int midLowShift=0,midHighShift=0;
   int shortLowShift2=0,shortHighShift2=0;
   int longLowShift=0,longHighShift=0;
   int midLowShift2=0,midHighShift2=0;

   shortLowShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,up_idx,cur_bar_shift);
   shortHighShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,dw_idx,cur_bar_shift);
   midLowShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,midup_idx,cur_bar_shift);
   midHighShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,middw_idx,cur_bar_shift);
   longLowShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,longup_idx,cur_bar_shift);
   longHighShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,longdw_idx,cur_bar_shift);
   if (shortLowShift>0) {
      shortLowShift2=shortLowShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,up_idx,cur_bar_shift+shortLowShift);
   }
   if (shortHighShift>0) {
      shortHighShift2=shortHighShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,dw_idx,cur_bar_shift+shortHighShift);
   }
   if (midLowShift>0) {
      midLowShift2=midLowShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,midup_idx,cur_bar_shift+midLowShift);
   }
   if (midHighShift>0) {
      midHighShift2=midHighShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,middw_idx,cur_bar_shift+midHighShift);
   }
   
   if (arg_long==0) {
      smallLowShift=shortLowShift;
      smallHighShift=shortHighShift;
      bigLowShift=midLowShift;
      bigHighShift=midHighShift;
      smallLowShift2=shortLowShift2;
      smallHighShift2=shortHighShift2;
   } else {
      smallLowShift=midLowShift;
      smallHighShift=midHighShift;
      bigLowShift=longLowShift;
      bigHighShift=longHighShift;
      smallLowShift2=midLowShift2;
      smallHighShift2=midHighShift2;
   }
   
   if (smallHighShift>0 && bigHighShift>0 && smallHighShift==bigHighShift) {
      return 0;
   }
   if (smallLowShift>0 && bigLowShift>0 && smallLowShift==bigLowShift) {
      return 0;
   }

   bool upSign=false;
   bool upSign_fst=false;
   //
   if (smallLowShift>0 && bigLowShift>0 && smallLowShift<bigLowShift) {
      double smallLow_low=iLow(NULL,arg_period,cur_bar_shift+smallLowShift);
      double bigLow_low=iLow(NULL,arg_period,cur_bar_shift+bigLowShift);
      if (smallLow_low>bigLow_low) {
         high_shift=iHighest(NULL,arg_period,MODE_HIGH,bigLowShift-smallLowShift-1,cur_bar_shift+smallLowShift+1);
         high_p=iHigh(NULL,arg_period,high_shift);
         upSign=true;
      }
   }
   if (upSign && smallLowShift2>=bigLowShift) upSign_fst=true;  //start turn up
   else upSign_fst=false;

   bool downSign=false;
   bool downSign_fst=false;
   //
   if (smallHighShift>0 && bigHighShift>0 && smallHighShift<bigHighShift) {
      double smallHigh_high=iHigh(NULL,arg_period,cur_bar_shift+smallHighShift);
      double bigHigh_high=iHigh(NULL,arg_period,cur_bar_shift+bigHighShift);
      if (smallHigh_high<bigHigh_high) {
         low_shift=iLowest(NULL,arg_period,MODE_LOW,bigHighShift-smallHighShift-1,cur_bar_shift+smallHighShift+1);
         low_p=iLow(NULL,arg_period,low_shift);
         downSign=true;
      }
   }
   
   if (downSign && smallHighShift2>=bigHighShift) downSign_fst=true;   //start turn down
   else downSign_fst=false;
   
   if (upSign && downSign) {
      if          (bigLowShift<bigHighShift) {
         downSign=false;
      } else if   (bigHighShift<bigLowShift) {
         upSign=false;
      } else {
         return 0;
      }
   }
   
   if (g_debug) {
      Print("period=",arg_period,",long=",arg_long);
      Print("upSign=",upSign,",downSign=",downSign);
      Print("smallLowShift=",smallLowShift);
      Print("bigLowShift=",bigLowShift);
      Print("smallLowShift2=",smallLowShift2);
      Print("smallHighShift=",smallHighShift);
      Print("bigHighShift=",bigHighShift);
      Print("smallHighShift2=",smallHighShift2);
      Print("high_shift=",high_shift,",low_shift=",low_shift);
      Print("high_p=",high_p,",low_p=",low_p);
   }

   arg_lst_small_upi=smallLowShift;
   arg_lst_big_upi=bigLowShift;
   arg_lst_small_dwi=smallHighShift;
   arg_lst_big_dwi=bigHighShift;
   
   int bar_status=0;
   double cur_open_price=iOpen(NULL,arg_period,cur_bar_shift);
   double cur_close_price=iClose(NULL,arg_period,cur_bar_shift);
   if (cur_open_price>cur_close_price) bar_status=-1;      //negative bar
   if (cur_open_price<cur_close_price) bar_status=1;       //positive bar
   if (upSign && !downSign) {
      if (upSign_fst) {
         if (bar_status==1 && cur_close_price>(high_p+arg_thpt*Point)) {    //positive bar and go beyond high_p
            if (g_debug) {
               Print("upSign=True and go beyond high_p");
               Print("period=",arg_period,",long=",arg_long);
               datetime tm=iTime(NULL,arg_period,cur_bar_shift);
               Print(tm,",high_shift=",high_shift-cur_bar_shift,",high_p=",high_p);
               Print("cur_bar_shift=",cur_bar_shift);
               Print("smallLowShift=",smallLowShift);
               Print("bigLowShift=",bigLowShift);
               Print("smallLowShift2=",smallLowShift2);
               Print("smallHighShift=",smallHighShift);
               Print("bigHighShift=",bigHighShift);
               Print("smallHighShift2=",smallHighShift2);
            }
            return 3;
         } else {
            return 2;
         }
      } else {
         return 1;
      }
   }
   
   if (downSign && !upSign) {
      if (downSign_fst) {
         if (bar_status==-1 && cur_close_price<(low_p-arg_thpt*Point)) {    //negative bar and go below low_p 
            if (g_debug) {
               Print("downSign=True and go below low_p");
               Print("period=",arg_period,",long=",arg_long);
               datetime tm=iTime(NULL,arg_period,cur_bar_shift);
               Print(tm,",low_shift=",low_shift-cur_bar_shift,",low_p=",low_p);
               Print("cur_bar_shift=",cur_bar_shift);
               Print("smallLowShift=",smallLowShift);
               Print("bigLowShift=",bigLowShift);
               Print("smallLowShift2=",smallLowShift2);
               Print("smallHighShift=",smallHighShift);
               Print("bigHighShift=",bigHighShift);
               Print("smallHighShift2=",smallHighShift2);
            }
            return -3;
         } else {
            return -2;
         }
      } else {
         return -1;
      }
   }
   
   return 0;
   
}
//+------------------------------------------------------------------+
//| Get MACD status (base on 3 continous values)
//| date: 2018/02/18
//| arg_period: time period
//| arg_shift: bar shift
//| return value: 
//|   +1,keep plus;
//|   -1,keep minus;
//|   +2,keep plus(max);
//|   -2,keep minus(min);
//|   +10,break to plus;
//|   -10,break to minus;
//|   0,N/A;
//+------------------------------------------------------------------+
int getMACDStatus(int arg_period,int arg_shift,int arg_slow_pd=26,int arg_fast_pd=12,int arg_signal_pd=9,int arg_mode=MODE_SIGNAL,double arg_deviation=2,int arg_range_ratio=1)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();
   
   string ind_name="lang_macd";
   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   int sec_lst_bar_shift=arg_shift+2;
   int macd_main_idx=0;
   int macd_signal_idx=1;
   
   int macd_idx=macd_signal_idx;
   if (arg_mode==MODE_MAIN) macd_idx=macd_main_idx;
   
   double cur_macd=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_idx,cur_bar_shift);
   double lst_macd=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_idx,lst_bar_shift);
   double sec_lst_macd=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_idx,sec_lst_bar_shift);

   int ret=0;
   
   if (cur_macd>0 && lst_macd<=0) {    //break to plus
      ret+=10;
   }

   if (cur_macd<0 && lst_macd>=0) {    //break to minux
      ret-=10;
   }

   if (cur_macd>0) {                   //keep plus
      ret+=1;
   }

   if (cur_macd<0) {                   //keep minus
      ret+=-1;
   }

   if (cur_macd>0 && sec_lst_macd<lst_macd && lst_macd>cur_macd) {      //keep plus(max)
      ret+=2;
   }
   if (cur_macd<0 && sec_lst_macd>lst_macd && lst_macd<cur_macd) {      //keep minus(max)
      ret+=-2;
   }
   
   return ret;  
}
//+------------------------------------------------------------------+
//| Get MACD status (base on 3 continous values)
//| date: 2018/02/5
//| arg_period: time period
//| arg_shift: bar shift
//| return value: fast>slow,same direction,up,5;
//|               fast>slow,different direction(fast down,slow up),4;
//|               fast>slow,different direction(fast up,slow down),3;
//|               fast>slow,same direction(fast down,slow down),2;
//|               fast>slow,no direction,1;
//| return value: fast<slow,same direction,down,-5;
//|               fast<slow,different direction(fast up,slow down),-4;
//|               fast<slow,different direction(fast down,slow up),-3;
//|               fast<slow,same direction(fast up,slow up),-2;
//|               fast<slow,no direction,-1;
//|               n/a:0
//| return value: fast is above slow range upper:+10  
//|               fast is below slow ramnge lower:-10  
//+------------------------------------------------------------------+
int getMACDStatus2(int arg_period,int arg_shift,int arg_slow_pd=26,int arg_fast_pd=12,int arg_signal_pd=9,double arg_deviation=2,int arg_range_ratio=1)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();
   
   string ind_name="lang_macd";
   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   int sec_lst_bar_shift=arg_shift+2;
   int macd_main_idx=0;
   int macd_signal_idx=1;
   int macd_signalB_up_idx=2;
   int macd_signalB_low_idx=3;
   int macd_signalR_up_idx=5;
   int macd_signalR_low_idx=6;
   
   double cur_macd_fast=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_main_idx,cur_bar_shift);
   double cur_macd_slow=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_signal_idx,cur_bar_shift);
   double lst_macd_fast=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_main_idx,lst_bar_shift);
   double lst_macd_slow=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_signal_idx,lst_bar_shift);
   double sec_lst_macd_fast=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_main_idx,sec_lst_bar_shift);
   double sec_lst_macd_slow=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_signal_idx,sec_lst_bar_shift);

   double cur_macd_up=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_signalR_up_idx,cur_bar_shift);
   double cur_macd_low=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_signalR_low_idx,cur_bar_shift);
   double lst_macd_up=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_signalR_up_idx,lst_bar_shift);
   double lst_macd_low=iCustom(NULL,arg_period,ind_name,arg_fast_pd,arg_slow_pd,arg_signal_pd,0,arg_deviation,arg_range_ratio,macd_signalR_low_idx,lst_bar_shift);
   
   
   int fast_direction=0;
   if (sec_lst_macd_fast<lst_macd_fast && lst_macd_fast<cur_macd_fast) fast_direction=1;           //fast is up
   if (sec_lst_macd_fast>lst_macd_fast && lst_macd_fast>cur_macd_fast) fast_direction=-1;          //fast is down

   int slow_direction=0;
   if (sec_lst_macd_slow<lst_macd_slow && lst_macd_slow<cur_macd_slow) slow_direction=1;           //slow is up
   if (sec_lst_macd_slow>lst_macd_slow && lst_macd_slow>cur_macd_slow) slow_direction=-1;          //middle is down
   
   int break_status=0;

   if (cur_macd_fast>cur_macd_up) {   //above signal upper
      break_status=10;
   }
   if (cur_macd_fast<cur_macd_low) {  //below signal lower
      break_status=-10;
   }
   
   int ret=0;
   
   if (cur_macd_fast>cur_macd_slow) {                 //fast>slow

      if (fast_direction==1 && slow_direction==1)     //fast slow in same direction up
         ret=break_status+5;

      else 
      if (fast_direction==-1 && slow_direction==-1)   //fast slow in same direction down
         ret=break_status+2;

      else
      if (fast_direction==-1 && slow_direction==1)    //fast is down, slow is up
         ret=break_status+4;

      else
      if (fast_direction==1 && slow_direction==-1)    //fast is up, slow is down
         ret=break_status+3;
      
      else
         ret=break_status+1;
   }
   
   if (cur_macd_fast<cur_macd_slow) {                 //fast<slow
      if (fast_direction==1 && slow_direction==1)     //fast slow in same direction up
         ret=break_status-2;

      else
      if (fast_direction==-1 && slow_direction==-1)   //fast slow in same direction down
         ret=break_status-5;

      else
      if (fast_direction==-1 && slow_direction==1)    //fast is down, slow is up
         ret=break_status-3;

      else
      if (fast_direction==1 && slow_direction==-1)    //fast is up, slow is down
         ret=break_status-4;

      else
         ret=break_status-1;
   }
   
   return ret;
}
//+------------------------------------------------------------------+
//| Get Band status (base on 3 continous values)
//| date: 2018/02/5
//| arg_period: time period
//| arg_shift: bar shift
//| return value: 
//| return value: 1,touch high;2,break high
//| return value: -1,touch low;-2,break low
//+------------------------------------------------------------------+
int getBandStatus(int arg_period,int arg_shift,int arg_pd=12,int arg_deviation=2)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();
   
   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   int sec_lst_bar_shift=arg_shift+2;

   double cur_band_low=iBands(NULL,arg_period,arg_pd,arg_deviation,0,PRICE_CLOSE,MODE_LOWER,cur_bar_shift);
   double cur_band_high=iBands(NULL,arg_period,arg_pd,arg_deviation,0,PRICE_CLOSE,MODE_UPPER,cur_bar_shift);
   double lst_band_low=iBands(NULL,arg_period,arg_pd,arg_deviation,0,PRICE_CLOSE,MODE_LOWER,lst_bar_shift);
   double lst_band_high=iBands(NULL,arg_period,arg_pd,arg_deviation,0,PRICE_CLOSE,MODE_UPPER,lst_bar_shift);
   double sec_lst_band_low=iBands(NULL,arg_period,arg_pd,arg_deviation,0,PRICE_CLOSE,MODE_LOWER,sec_lst_bar_shift);
   double sec_lst_band_high=iBands(NULL,arg_period,arg_pd,arg_deviation,0,PRICE_CLOSE,MODE_UPPER,sec_lst_bar_shift);
   
   double cur_high=High[cur_bar_shift];
   double cur_low=Low[cur_bar_shift];
   double cur_close=Close[cur_bar_shift];
   double lst_high=High[lst_bar_shift];
   double lst_low=Low[lst_bar_shift];
   double lst_close=Close[lst_bar_shift];
   double sec_lst_high=High[sec_lst_bar_shift];
   double sec_lst_low=Low[sec_lst_bar_shift];
   double sec_lst_close=Close[sec_lst_bar_shift];
   int touch_high=0,touch_low=0;
   int break_high=0,break_low=0;
   
   if (cur_high>=cur_band_high || lst_high>=lst_band_high || sec_lst_high>=sec_lst_band_high) touch_high=1;
   if (cur_close>=cur_band_high || lst_close>=lst_band_high || sec_lst_close>=sec_lst_band_high) break_high=1;
   if (cur_low<=cur_band_low || lst_low<=lst_band_low || sec_lst_low<=sec_lst_band_low) touch_low=1;
   if (cur_close<=cur_band_low || lst_close<=lst_band_low || sec_lst_close<=sec_lst_band_low) break_low=1;
   
   if (break_high==1 && break_low==0) return 2;
   if (break_low==1 && break_high==0) return -2;
   if (touch_high==1 && touch_low==0) return 1;
   if (touch_low==1 && touch_high==0) return -1;
   
   return 0;
}
//+------------------------------------------------------------------+
//| Get Bar status
//| date: 2018/02/19
//| arg_period: time period
//| arg_shift: bar shift
//| arg_thpt: thredhold point
//| return value:
//| return value: 1,positive bar;-1,negative bar
//+------------------------------------------------------------------+
int getBarStatus(int arg_period,int arg_shift,int arg_thpt=0)
{
   if (arg_period==PERIOD_CURRENT) arg_period=Period();
   
   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   int sec_lst_bar_shift=arg_shift+2;
   
   double cur_open=iOpen(NULL,arg_period,cur_bar_shift);
   double cur_close=iClose(NULL,arg_period,cur_bar_shift);
   double gap=arg_thpt*Point;
   
   if (cur_close>(cur_open+gap)) {
      return 1;
   }
   if (cur_close<(cur_open-gap)) {
      return -1;
   }
   
   return 0;
}
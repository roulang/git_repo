//+------------------------------------------------------------------+
//|                                                  lang_rb_ind.mq4 |
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
#property indicator_minimum -4
#property indicator_maximum 4
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
input int      i_range=20;
input int      i_thredhold_pt=0;
input int      i_expand=1;
input bool     i_sendmail=true;

//global
int      g_ls_pt=50;
string   g_comment="3";
int      g_equity_percent=1;

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
   //double ls_price=0;
   double range_high,range_low;
   double range_high2,range_low2;
   int range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt;
   int range_high2_gap_pt,range_low2_gap_pt;
   int high_low_touch_status=0;
   int ret=0;
   int ret2=0;
   string sym=Symbol();
   string ped=getPeriodTp(Period());
   string str=StringConcatenate("[",sym,"(",ped,")]");
   for(int i=st-1;i>0;i--) {
      high_low_touch_status=0;
      ret2=isBreak_Rebound3(i,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,
                           range_high2,range_low2,range_high2_gap_pt,range_low2_gap_pt,high_low_touch_status,
                           i_range,i_thredhold_pt,i_expand,5,150,20);
      ret=high_low_touch_status;
      if (MathAbs(ret)>=1 && i==1) {   //sendmail in future
         //string t1=TimeToStr(Time[i],TIME_DATE);
         string t1=StringConcatenate(TimeMonth(Time[i]),"/",TimeDay(Time[i]));
         string t2=TimeToStr(Time[i],TIME_MINUTES);
         string t=StringConcatenate("[",t1," ",t2,"]");
         string mail_title=StringConcatenate(str," ",t," hit high low (",ret,"|",ret2,")");
         string mail_body="";

         //order parameters
         double higher_price=range_high+range_high_gap_pt*Point();
         double higher2_price=range_high2+range_high2_gap_pt*Point();
         double high_price=range_high;
         double low_price=range_low;
         double lower_price=range_low-range_low_gap_pt*Point();
         double lower2_price=range_low2-range_low2_gap_pt*Point();
         double last_bar_high=High[i-1];
         double last_bar_low=Low[i-1];
         
         double ask_price=Ask;
         double bid_price=Bid;
         double ab_gap=NormalizeDouble(Ask-Bid,Digits);
         double break_ls_ratio=0.6;
         
         if (ret>0) {      //up
            double price=ask_price;
            double ls_tgt_price=last_bar_low;
            double ls_tgt_price2=NormalizeDouble(high_price-range_high_low_gap_pt*break_ls_ratio*Point,Digits);   //break up stop lose point
            double ls_price=ls_tgt_price-g_ls_pt*Point;
            double ls_price2=ls_tgt_price2;
            double ls_gap=NormalizeDouble(price-ls_price,Digits);
            double ls_gap2=NormalizeDouble(price-ls_price2,Digits);
            double tp_price11=price+ls_gap;
            double tp_price12=price+2*ls_gap;
            double tp_price21=price+ls_gap2;
            double tp_price22=price+2*ls_gap2;
            int tp_gap11_pt=(int)NormalizeDouble(ls_gap/Point,0);
            int tp_gap12_pt=(int)NormalizeDouble(2*ls_gap/Point,0);
            int tp_gap21_pt=(int)NormalizeDouble(ls_gap2/Point,0);
            int tp_gap22_pt=(int)NormalizeDouble(2*ls_gap2/Point,0);
            int ls_gap_pt=tp_gap11_pt;
            int ls_gap2_pt=tp_gap21_pt;
            double risk_vol = getVolume(g_equity_percent,ls_gap_pt);            
            double risk_vol2 = getVolume(g_equity_percent,ls_gap2_pt);            
            
            string str_fmt=StringFormat("buy price=%%.%df(ask)\r\n",Digits);
            string temp_string=StringFormat(str_fmt,price);
            StringAdd(mail_body,temp_string);

            string tp_price11_str="";
            string tp_price12_str="";
            string tp_price21_str="";
            string tp_price22_str="";
            if (tp_price11>higher_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price11_str=StringFormat(str_fmt,tp_price11);
            } else if (tp_price11>high_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price11_str=StringFormat(str_fmt,tp_price11);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price11_str=StringFormat(str_fmt,tp_price11);
            }
            if (tp_price12>higher_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price12_str=StringFormat(str_fmt,tp_price12);
            } else if (tp_price12>high_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price12_str=StringFormat(str_fmt,tp_price12);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price12_str=StringFormat(str_fmt,tp_price12);
            }
            if (tp_price21>higher_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price21_str=StringFormat(str_fmt,tp_price21);
            } else if (tp_price21>high_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price21_str=StringFormat(str_fmt,tp_price21);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price21_str=StringFormat(str_fmt,tp_price21);
            }
            if (tp_price22>higher_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price22_str=StringFormat(str_fmt,tp_price22);
            } else if (tp_price22>high_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price22_str=StringFormat(str_fmt,tp_price22);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price22_str=StringFormat(str_fmt,tp_price22);
            }

            str_fmt=StringFormat("%%.%df(-%%d)|%%s(+%%d)|%%.2f|\"%%s\"\r\n",Digits);

            //rebound
            temp_string="---rebound---\r\n";
            StringAdd(mail_body,temp_string);

            temp_string=StringFormat(str_fmt,ls_price,ls_gap_pt,tp_price11_str,tp_gap11_pt,risk_vol,g_comment);
            StringAdd(mail_body,temp_string);
            temp_string=StringFormat(str_fmt,ls_price,ls_gap_pt,tp_price12_str,tp_gap12_pt,risk_vol,g_comment);
            StringAdd(mail_body,temp_string);
            
            //break
            temp_string="---break---\r\n";
            StringAdd(mail_body,temp_string);

            temp_string=StringFormat(str_fmt,ls_price2,tp_gap21_pt,tp_price21_str,tp_gap21_pt,risk_vol2,g_comment);
            StringAdd(mail_body,temp_string);
            temp_string=StringFormat(str_fmt,ls_price2,tp_gap22_pt,tp_price22_str,tp_gap22_pt,risk_vol2,g_comment);
            StringAdd(mail_body,temp_string);
         }
         if (ret<0) {      //down
            double price=bid_price;
            double ls_tgt_price=last_bar_high;
            double ls_tgt_price2=NormalizeDouble(low_price+range_high_low_gap_pt*break_ls_ratio*Point,Digits);      //break down stop lose point
            double ls_price=ls_tgt_price+g_ls_pt*Point;
            double ls_price2=ls_tgt_price2;
            double ls_gap=NormalizeDouble(ls_price-price,Digits);
            double ls_gap2=NormalizeDouble(ls_price2-price,Digits);
            double tp_price11=price-ls_gap;
            double tp_price12=price-2*ls_gap;
            double tp_price21=price-ls_gap2;
            double tp_price22=price-2*ls_gap2;
            int tp_gap11_pt=(int)NormalizeDouble(ls_gap/Point,0);
            int tp_gap12_pt=(int)NormalizeDouble(2*ls_gap/Point,0);
            int tp_gap21_pt=(int)NormalizeDouble(ls_gap2/Point,0);
            int tp_gap22_pt=(int)NormalizeDouble(2*ls_gap2/Point,0);
            int ls_gap_pt=tp_gap11_pt;
            int ls_gap2_pt=tp_gap21_pt;
            double risk_vol = getVolume(g_equity_percent,ls_gap_pt);            
            double risk_vol2 = getVolume(g_equity_percent,ls_gap2_pt);                 

            string str_fmt=StringFormat("sell price=%%.%df(bid)\r\n",Digits);
            string temp_string=StringFormat(str_fmt,price);
            StringAdd(mail_body,temp_string);

            string tp_price11_str="";
            string tp_price12_str="";
            string tp_price21_str="";
            string tp_price22_str="";
            if (tp_price11<lower_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price11_str=StringFormat(str_fmt,tp_price11);
            } else if (tp_price11<low_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price11_str=StringFormat(str_fmt,tp_price11);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price11_str=StringFormat(str_fmt,tp_price11);
            }
            if (tp_price12<lower_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price12_str=StringFormat(str_fmt,tp_price12);
            } else if (tp_price12<low_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price12_str=StringFormat(str_fmt,tp_price12);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price12_str=StringFormat(str_fmt,tp_price12);
            }
            if (tp_price21<lower_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price21_str=StringFormat(str_fmt,tp_price21);
            } else if (tp_price21<low_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price21_str=StringFormat(str_fmt,tp_price21);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price21_str=StringFormat(str_fmt,tp_price21);
            }
            if (tp_price22<lower_price) {
               str_fmt=StringFormat("{%%.%df}",Digits);
               tp_price22_str=StringFormat(str_fmt,tp_price22);
            } else if (tp_price22<low_price) {
               str_fmt=StringFormat("[%%.%df]",Digits);
               tp_price22_str=StringFormat(str_fmt,tp_price22);
            } else {
               str_fmt=StringFormat("%%.%df",Digits);
               tp_price22_str=StringFormat(str_fmt,tp_price22);
            }

            str_fmt=StringFormat("%%.%df(-%%d)|%%s(+%%d)|%%.2f|\"%%s\"\r\n",Digits);

            //rebound
            temp_string="---rebound---\r\n";
            StringAdd(mail_body,temp_string);

            temp_string=StringFormat(str_fmt,ls_price,ls_gap_pt,tp_price11_str,tp_gap11_pt,risk_vol,g_comment);
            StringAdd(mail_body,temp_string);
            temp_string=StringFormat(str_fmt,ls_price,ls_gap_pt,tp_price12_str,tp_gap12_pt,risk_vol,g_comment);
            StringAdd(mail_body,temp_string);
            
            //break
            temp_string="---break---\r\n";
            StringAdd(mail_body,temp_string);

            temp_string=StringFormat(str_fmt,ls_price2,ls_gap2_pt,tp_price21_str,tp_gap21_pt,risk_vol2,g_comment);
            StringAdd(mail_body,temp_string);
            temp_string=StringFormat(str_fmt,ls_price2,ls_gap2_pt,tp_price22_str,tp_gap22_pt,risk_vol2,g_comment);
            StringAdd(mail_body,temp_string);
         }

         mailNotice(mail_title,mail_body);
      }
      if (MathAbs(ret)>1) {
         signalBuffer[i]=ret;
      }
      /*
      //debug
      datetime t=Time[i];
      datetime t1=StringToTime("2017.10.18 19:00");
      if (t==t1) {
         Print("time=",t);
         Print("shift=",i);
         Print("g_high_low=");
         PrintTwoDimArray(g_high_low);
         for (int j=0;j<ArraySize(g_touch_highlow);j++) {
            Print("g_touch_highlow[",j,"]=",g_touch_highlow[j]);
         }
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

//+------------------------------------------------------------------+
//|                                                 lang_ea_test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ea_inc.mqh>

//--- input
input bool     i_news_skip=true;       // news zone skip
input int      i_news_bef=SEC_H1/4;    // news before 1/4 hour
input int      i_news_aft=SEC_H1;      // news after 1 hour
input bool     i_zone_control=false;   // time zone control
input int      i_zone_bef=SEC_H1/2;    // time zone before
input int      i_zone_aft=0;           // time zone after
input int      i_oc_gap_pt=5;
input int      i_high_low_gap_pt=150;
input int      i_gap2_pt=20;
input bool     i_atr_control=true;
input bool     i_ma_control=true;
input int      i_tp_cnt=1;             //one|two|three times tp
input bool     i_manual=false;

//--- global
int      g_magic=3;        //rebound
int      g_magic2=4;        //break
datetime g_orderdt;

int      g_expand=1;
int      g_long=1;
int      g_range=20;
double   g_break_ls_ratio=0.6;
int      g_atr_lvl_pt=5;
int      g_atr_range=5;
int      g_short_ma_ped=12;
int      g_mid_ma_ped=36;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   g_debug=false;
   
   if (g_debug) {
      Print("OnInit()");
   }
   
   ea_init();
   
   if (!i_for_test) {
      if (!timer_init(SEC_H1)) return(INIT_FAILED);
   }
   
   news_read();

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if (g_debug) {
      Print("OnDeinit()");
   }
   
   if (!i_for_test) {
      timer_deinit();
   }

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   if (isNewBar()==0) return;
   
   int cur_bar_shift=0;
   int last_bar_shift=1;
   datetime now=Time[cur_bar_shift];
   bool has_order=true;
   
   //check if exists any order
   if (FindOrderA(NULL,1,g_magic) || FindOrderA(NULL,1,g_magic2)) {  //found buy order
      if (ifClose(cur_bar_shift)) {
         Print("closed buy order");
         if (!FindOrderA(NULL,0,g_magic) && !FindOrderA(NULL,0,g_magic2)) {
            has_order=false;
         }
      }
      
      //move lose stop
      if (movingStop3(NULL,g_magic,last_bar_shift)) {
         Print("movingstop of buy order");
      }
      
   } else if(FindOrderA(NULL,-1,g_magic) || FindOrderA(NULL,-1,g_magic2)) {  //found sell order
      if (ifClose(cur_bar_shift)) {
         Print("closed sell order");
         if (!FindOrderA(NULL,0,g_magic) && !FindOrderA(NULL,0,g_magic2)) {
            has_order=false;
         }
      }
      
      //move lose stop
      if (movingStop3(NULL,g_magic,last_bar_shift)) {
         Print("movingstop of sell order");
      }
      
   } else {    //not found buy and sell order
      has_order=false;
   }
   
   //news time skip control
   bool newsPd=isNewsPd(NULL,cur_bar_shift,i_news_bef,i_news_aft);
   if (i_news_skip && newsPd) {     //in news time
      if (has_order) {
         Print("new time skip control:news time start, close all order");
         OrderCloseA(NULL,0,g_magic);   //close all order
         OrderCloseA(NULL,0,g_magic2);   //close all order
         if (!FindOrderA(NULL,0,g_magic) && !FindOrderA(NULL,0,g_magic2)) {
            has_order=false;
         }
      } else {
         Print("news time skip control:news time start, do not take action");
      }
      return;
   }
   
   double price[4],ls_price[4],tp_price[4][2];
   int ls_price_pt[4],tp_price_pt[4][2];
   int high_low_touch_status=0;
   int touch_status=0;
   int sign;
   //sign=isBreak_Rebound2(last_bar_shift,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,touch_status,i_range,i_thredhold_pt,i_expand,5,150,20);
   /*
   sign=isBreak_Rebound3(last_bar_shift,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,
                        range_high2,range_low2,range_high2_gap_pt,range_low2_gap_pt,touch_status,
                        i_range,i_thredhold_pt,i_expand,5,150,20);
   */
   /*
   int arg_shift,int &arg_touch_status,
   double &arg_price[],double &arg_ls_price[],double &arg_tp_price[][],
   int &arg_ls_price_pt[],int &arg_tp_price_pt[][],
   int arg_lspt=50,double arg_ls_ratio=0.6,
   int arg_length=20,int arg_th_pt=0,int arg_expand=1,int arg_long=1,
   int arg_oc_gap_pt=5,int arg_high_low_gap_pt=150,int arg_gap_pt2=20,
   int arg_atr_lvl_pt=5,int arg_atr_range=5
   int arg_short_ma_ped=12,int arg_mid_ma_ped=36
   bool arg_atr_control=true,bool arg_ma_control=true
   */
   sign=getHighLow_Value3( last_bar_shift,touch_status,price,ls_price,tp_price,ls_price_pt,tp_price_pt,
                           i_ls_pt,g_break_ls_ratio,g_range,0,g_expand,g_long,
                           i_oc_gap_pt,i_high_low_gap_pt,i_gap2_pt,
                           g_atr_lvl_pt,g_atr_range,
                           g_short_ma_ped,g_mid_ma_ped,
                           i_atr_control,i_ma_control);
   
   if (touch_status>=3 && has_order) {    //break up,have order
      //close opposit order
      //if (OrderCloseA(NULL,-1,g_magic)>0 || OrderCloseA(NULL,-1,g_magic2)>0) {  //close sell order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell rebound order
         Print("close opposit(sell) order");
         has_order=false;
      }
   }

   if (touch_status<=-3 && has_order) {   //break down,have order
      //close opposit order
      //if (OrderCloseA(NULL,1,g_magic)>0 || OrderCloseA(NULL,1,g_magic2)>0) {  //close buy order
      if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy rebound order
         Print("close opposit(buy) order");
         has_order=false;
      }
   }
   
   //active time zone control
   bool curPd=isCurPd(NULL,cur_bar_shift,i_zone_bef,i_zone_aft);
   if (MathAbs(sign)==3 && i_zone_control && !curPd) {      //break
      Print("timezone control:avoid to break in non-active time.");
      return;
   }
   /*
   if (MathAbs(sign)==2 && i_time_control && curPd) {       //rebound
      Print("news time skip control:not active time.");
      return;
   }
   */
   
   //open order
   //buy_break/buy_rebound/sell_break/sell_rebound
   int buy_break_idx=0;
   int buy_rebound_idx=1;
   int sell_break_idx=2;
   int sell_rebound_idx=3;
   int idx=-1;
   
   if (!has_order) {
      switch(sign) {
         case 2:        //rebound(up)
            idx=buy_rebound_idx;
            break;
         case -2:       //rebound(down)
            idx=sell_rebound_idx;
            break;
         case 3:        //break(up)
            idx=buy_break_idx;
            break;
         case -3:       //break(down)
            idx=sell_break_idx;
            break;
         case 4:        //break(up) second
            idx=buy_break_idx;
            break;
         case -4:       //break(down) second
            idx=sell_break_idx;
            break;
         default:
            break;
      }
      
      if (idx>=0 && !g_debug && !i_manual) {
         double t_price=price[idx];
         double t_ls_price=ls_price[idx];
         double t_ls_gap=MathAbs(ls_price_pt[idx]);
         double t_tp_price=tp_price[idx][0];
         double t_tp_price2=tp_price[idx][1];
         int t_tp_gap_pt=MathAbs(tp_price_pt[idx][0]);
         int t_tp_gap2_pt=MathAbs(tp_price_pt[idx][1]);
         int t_magic=0;

         Print("Time=",Time[cur_bar_shift]);
         Print("price=",t_price,",ls_price=",t_ls_price,",ls_gap=",t_ls_gap);
         Print("tp_price=",t_tp_price,",tp_price2=",t_tp_price2,",tp_gap_pt=",t_tp_gap_pt,",tp_gap2_pt=",t_tp_gap2_pt);
   
         bool ret,ret2;
         ret=ret2=false;
         if (idx==buy_rebound_idx || idx==buy_break_idx) {
            if (idx==buy_rebound_idx && (t_tp_price>0 || t_tp_price2>0)) {
               Print("ready to turn up.create buy order.");
               t_magic=g_magic;  //rebound
            }
            if (idx==buy_break_idx && (t_tp_price>0 || t_tp_price2>0)) {
               Print("ready to break up.create buy order.");
               t_magic=g_magic2;  //break
            }
            if (i_tp_cnt==1) {
               if (t_tp_price>0) {
                  ret=OrderBuy2(0,t_ls_price,t_tp_price,t_magic);
               }
            }
            if (i_tp_cnt==2) {
               if (t_tp_price2>0) {
                  ret2=OrderBuy2(0,t_ls_price,t_tp_price2,t_magic);
               }
            }
            if (i_tp_cnt==3) {
               if (t_tp_price>0) {
                  ret=OrderBuy2(0,t_ls_price,t_tp_price,t_magic);
               }
               if (t_tp_price2>0) {
                  ret2=OrderBuy2(0,t_ls_price,t_tp_price2,t_magic);
               }
            }
         } else 
         if (idx==sell_rebound_idx || idx==sell_break_idx) {
            if (idx==sell_rebound_idx && (t_tp_price>0 || t_tp_price2>0)) {
               Print("ready to turn down.create sell order.");
               t_magic=g_magic;  //rebound
            }
            if (idx==sell_break_idx && (t_tp_price>0 || t_tp_price2>0)) {
               Print("ready to break down.create sell order.");
               t_magic=g_magic2;  //rebound
            }
            if (i_tp_cnt==1) {
               if (t_tp_price>0) {
                  ret=OrderSell2(0,t_ls_price,t_tp_price,t_magic);
               }
            }
            if (i_tp_cnt==2) {
               if (t_tp_price2>0) {
                  ret2=OrderSell2(0,t_ls_price,t_tp_price2,t_magic);
               }
            }
            if (i_tp_cnt==3) {
               if (t_tp_price>0) {
                  ret=OrderSell2(0,t_ls_price,t_tp_price,t_magic);
               }
               if (t_tp_price2>0) {
                  ret2=OrderSell2(0,t_ls_price,t_tp_price2,t_magic);
               }
            }
         }
         if (ret || ret2) {
            //has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }
}
bool ifClose(int arg_shift)
{
   if(isEndOfWeek(arg_shift)) {
      Print("market close,close all buy/sell order");
      if (OrderCloseA(NULL,0,g_magic)>0 && OrderCloseA(NULL,0,g_magic2)>0) return true;
   }

   return false;
}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (g_debug) {
      Print("OnTimer()");
   }

   if (!i_for_test) {
      news_read();
   }
}

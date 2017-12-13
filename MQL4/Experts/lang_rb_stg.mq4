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

//--- global
int      g_magic=3;        //rebound and break
//bool     g_has_order=false;
datetime g_orderdt;

//--------------------------------

//input
input int      i_range=20;
input int      i_thredhold_pt=0;
input int      i_expand=1;
input bool     i_manual=false;

//global
int      g_tp_offset=10;

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
   if (FindOrderA(NULL,1,g_magic)) {  //found buy order
      if (ifClose(cur_bar_shift)) {
         Print("closed buy order");
         if (!FindOrderA(NULL,0,g_magic)) {
            has_order=false;
         }
      }
      /*
      //move lose stop
      if (movingStop3(NULL,g_magic,last_bar_shift)) {
         Print("movingstop of buy order");
      }
      */
   } else if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
      if (ifClose(cur_bar_shift)) {
         Print("closed buy order");
         if (!FindOrderA(NULL,0,g_magic)) {
            has_order=false;
         }
      }
      /*
      //move lose stop
      if (movingStop3(NULL,g_magic,last_bar_shift)) {
         Print("movingstop of buy order");
      }
      */
   } else {    //not found buy and sell order
      has_order=false;
   }
   
   //news time skip control
   bool newsPd=isNewsPd(NULL,cur_bar_shift,i_news_bef,i_news_aft);
   if (i_news_skip && newsPd) {     //in news time
      if (has_order) {
         Print("new time skip control:news time start, close all order");
         OrderCloseA(NULL,0,g_magic);   //close all order
         if (!FindOrderA(NULL,0,g_magic)) {
            has_order=false;
         }
      } else {
         Print("new time skip control:news time start, do not take action");
      }
      return;
   }
   
   //double high_gap,low_gap,high_low_gap;
   double range_high,range_low;
   double range_high2,range_low2;
   int range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt;
   int range_high2_gap_pt,range_low2_gap_pt;
   int touch_status=0;
   int sign;
   //sign=isBreak_Rebound2(last_bar_shift,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,touch_status,i_range,i_thredhold_pt,i_expand,5,150,20);
   sign=isBreak_Rebound3(last_bar_shift,range_high,range_low,range_high_low_gap_pt,range_high_gap_pt,range_low_gap_pt,
                        range_high2,range_low2,range_high2_gap_pt,range_low2_gap_pt,touch_status,
                        i_range,i_thredhold_pt,i_expand,5,150,20);
   
   if (touch_status>=3 && has_order) {    //break up,have order
      //close opposit order
      if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
         Print("close opposit(sell) order");
         has_order=false;
      }
   }

   if (touch_status<=-3 && has_order) {   //break down,have order
      //close opposit order
      if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
         Print("close opposit(buy) order");
         has_order=false;
      }
   }
   
   //active time zone control
   bool curPd=isCurPd(NULL,cur_bar_shift,i_zone_bef,i_zone_aft);
   if (MathAbs(sign)==3 && i_time_control && !curPd) {      //break
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
   double higher_price=range_high+range_high_gap_pt*Point();
   double higher2_price=range_high2+range_high2_gap_pt*Point();
   double high_price=range_high;
   double low_price=range_low;
   double lower_price=range_low-range_low_gap_pt*Point();
   double lower2_price=range_low2-range_low2_gap_pt*Point();
   double last_bar_high=High[last_bar_shift];
   double last_bar_low=Low[last_bar_shift];
   
   double ask_price=Ask;
   double bid_price=Bid;
   double ab_gap=NormalizeDouble(Ask-Bid,Digits);
   //double min_tp_pt=2*i_SL;
   //double min_tp2_pt=4*i_SL;
   double break_ls_ratio=0.6;

   //rebound(up)
   if (sign==2 && !has_order) {
      Print("ready to turn up.create buy order.");
      double price=ask_price;
      double ls_tgt_price=last_bar_low;
      double ls_price=ls_tgt_price-i_SL*Point;
      double ls_gap=NormalizeDouble(price-ls_price,Digits);
      double tp_price=price+ls_gap;
      double tp_price2=price+2*ls_gap;
      int tp_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);
      int tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("high_price=",high_price,",low_price=",low_price,",higher_price=",higher_price,",lower_price=",lower_price,",range_high_low_gap_pt=",range_high_low_gap_pt);
      Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap=",ab_gap);
      Print("price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print("tp_price=",tp_price,",tp_price2=",tp_price2,",tp_gap_pt=",tp_gap_pt,",tp_gap2_pt=",tp_gap2_pt);

      if (tp_price>high_price) {
         /*
         tp_price=high_price-g_tp_offset*Point;
         tp_gap_pt=(int)NormalizeDouble((tp_price-price)/Point,0);
         if (tp_gap_pt<min_tp_pt) {
            Print("tp_gap is too small(<",min_tp_pt,"pt)");
            tp_price=0;
         }
         */
         Print("tp_price(",tp_price,") is higher than high_price(",high_price,")");
         tp_price=0;
         tp_price2=0;
      } else if (tp_price2>high_price) {
         /*
         tp_price2=high_price-g_tp_offset*Point;
         tp_gap2_pt=(int)NormalizeDouble((tp_price2-price)/Point,0);
         if (tp_gap2_pt<min_tp2_pt) {
            Print("tp_gap2 is too small(<",min_tp2_pt,"pt)");
            tp_price2=0;
         }
         */
         Print("tp_price2(",tp_price2,") is higher than high_price(",high_price,")");
         tp_price2=0;
      }
      
      if (!g_debug && !i_manual) {
         bool ret,ret2;
         ret=ret2=0;
         if (tp_price>0) {
            ret=OrderBuy2(0,ls_price,tp_price,g_magic);
         }
         if (tp_price2>0) {
            ret2=OrderBuy2(0,ls_price,tp_price2,g_magic);
         }
         if (ret || ret2) {
            //has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }
   
   //rebound(down)
   if (sign==-2 && !has_order) {
      Print("ready to turn down.create sell order.");
      double price=bid_price;
      double ls_tgt_price=last_bar_high;
      double ls_price=ls_tgt_price+i_SL*Point;
      double ls_gap=NormalizeDouble(ls_price-price,Digits);
      double tp_price=price-ls_gap;
      double tp_price2=price-2*ls_gap;
      int tp_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);
      int tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("high_price=",high_price,",low_price=",low_price,",higher_price=",higher_price,",lower_price=",lower_price,",range_high_low_gap_pt=",range_high_low_gap_pt);
      Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap=",ab_gap);
      Print("price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print("tp_price=",tp_price,",tp_price2=",tp_price2,",tp_gap_pt=",tp_gap_pt,",tp_gap2_pt=",tp_gap2_pt);

      if (tp_price<low_price) {
         /*
         tp_price=low_price+g_tp_offset*Point;
         tp_gap_pt=(int)NormalizeDouble((price-tp_price)/Point,0);
         if (tp_gap_pt<min_tp_pt) {
            Print("tp_gap is too small(<",min_tp_pt,"pt)");
            tp_price=0;
         }
         */
         Print("tp_price(",tp_price,") is lower than low_price(",low_price,")");
         tp_price=0;
         tp_price2=0;
      } else if (tp_price2<low_price) {
         /*
         tp_price2=low_price+g_tp_offset*Point;
         tp_gap2_pt=(int)NormalizeDouble((price-tp_price2)/Point,0);
         if (tp_gap2_pt<min_tp2_pt) {
            Print("tp_gap2 is too small(<",min_tp2_pt,"pt)");
            tp_price2=0;
         }
         */
         Print("tp_price2(",tp_price2,") is lower than low_price(",low_price,")");
         tp_price2=0;
      }
      
      if (!g_debug && !i_manual) {
         bool ret,ret2;
         ret=ret2=0;
         if (tp_price>0) {
            ret=OrderSell2(0,ls_price,tp_price,g_magic);
         }
         if (tp_price2>0) {
            ret2=OrderSell2(0,ls_price,tp_price2,g_magic);
         }
         if (ret || ret2) {
            //has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }
   
   //break(up)
   if (sign==3 && !has_order) {
      Print("ready to break up.create buy order.");
      double price=ask_price;
      double ls_tgt_price=NormalizeDouble(high_price-range_high_low_gap_pt*break_ls_ratio*Point,Digits);      //break up stop lose point
      double ls_price=ls_tgt_price;
      double ls_gap=NormalizeDouble(price-ls_price,Digits);
      double tp_price=price+ls_gap;
      double tp_price2=price+2*ls_gap;
      int tp_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);
      int tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("high_price=",high_price,",low_price=",low_price,",higher_price=",higher_price,",lower_price=",lower_price,",range_high_low_gap_pt=",range_high_low_gap_pt);
      Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap=",ab_gap);
      Print("price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print("tp_price=",tp_price,",tp_price2=",tp_price2,",tp_gap_pt=",tp_gap_pt,",tp_gap2_pt=",tp_gap2_pt);

      if (tp_price>higher_price) {
         /*
         Print("adjust tp_price to higher_price");
         tp_price=higher_price-g_tp_offset*Point;
         tp_gap_pt=(int)NormalizeDouble((tp_price-price)/Point,0);
         if (tp_gap_pt<min_tp_pt) {
            Print("tp_gap is too small(<",min_tp_pt,"pt)");
            tp_price=0;
         }
         */
         Print("tp_price(",tp_price,") is higher than higher_price(",higher_price,")");
         tp_price=0;
         tp_price2=0;
      } else if (tp_price2>higher_price) {
         /*
         Print("adjust tp_price2 to higher_price");
         tp_price2=higher_price-g_tp_offset*Point;
         tp_gap2_pt=(int)NormalizeDouble((tp_price2-price)/Point,0);
         if (tp_gap2_pt<min_tp2_pt) {
            Print("tp_gap2 is too small(<",min_tp2_pt,"pt)");
            tp_price2=0;
         }
         */
         Print("tp_price2(",tp_price2,") is higher than higher_price(",higher_price,")");
         tp_price2=0;
      }
      
      if (!g_debug && !i_manual) {
         bool ret,ret2;
         ret=ret2=0;
         if (tp_price>0) {
            ret=OrderBuy2(0,ls_price,tp_price,g_magic);
         }
         if (tp_price2>0) {
            ret2=OrderBuy2(0,ls_price,tp_price2,g_magic);
         }
         if (ret || ret2) {
            //has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }

   //break(up/second)
   if (sign==4 && !has_order) {
      Print("ready to break up(second).create buy order.");
      double price=ask_price;
      double ls_tgt_price=NormalizeDouble(high_price-range_high_low_gap_pt*break_ls_ratio*Point,Digits);      //break up stop lose point
      double ls_price=ls_tgt_price;
      double ls_gap=NormalizeDouble(price-ls_price,Digits);
      double tp_price=price+ls_gap;
      double tp_price2=price+2*ls_gap;
      int tp_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);
      int tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("high_price=",high_price,",low_price=",low_price,",higher_price=",higher_price,",lower_price=",lower_price,",range_high_low_gap_pt=",range_high_low_gap_pt);
      Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap=",ab_gap);
      Print("price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print("tp_price=",tp_price,",tp_price2=",tp_price2,",tp_gap_pt=",tp_gap_pt,",tp_gap2_pt=",tp_gap2_pt);

      if (tp_price>higher2_price) {
         /*
         Print("adjust tp_price to higher_price");
         tp_price=higher_price-g_tp_offset*Point;
         tp_gap_pt=(int)NormalizeDouble((tp_price-price)/Point,0);
         if (tp_gap_pt<min_tp_pt) {
            Print("tp_gap is too small(<",min_tp_pt,"pt)");
            tp_price=0;
         }
         */
         Print("tp_price(",tp_price,") is higher than higher2_price(",higher2_price,")");
         tp_price=0;
         tp_price2=0;
      } else if (tp_price2>higher2_price) {
         /*
         Print("adjust tp_price2 to higher_price");
         tp_price2=higher_price-g_tp_offset*Point;
         tp_gap2_pt=(int)NormalizeDouble((tp_price2-price)/Point,0);
         if (tp_gap2_pt<min_tp2_pt) {
            Print("tp_gap2 is too small(<",min_tp2_pt,"pt)");
            tp_price2=0;
         }
         */
         Print("tp_price2(",tp_price2,") is higher than higher2_price(",higher2_price,")");
         tp_price2=0;
      }
      
      if (!g_debug && !i_manual) {
         bool ret,ret2;
         ret=ret2=0;
         if (tp_price>0) {
            ret=OrderBuy2(0,ls_price,tp_price,g_magic);
         }
         if (tp_price2>0) {
            ret2=OrderBuy2(0,ls_price,tp_price2,g_magic);
         }
         if (ret || ret2) {
            //has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }

   //break(down)
   if (sign==-3 && !has_order) {
      Print("ready to break down.create sell order.");
      double price=bid_price;
      double ls_tgt_price=NormalizeDouble(low_price+range_high_low_gap_pt*break_ls_ratio*Point,Digits);      //break down stop lose point
      double ls_price=ls_tgt_price;
      double ls_gap=NormalizeDouble(ls_price-price,Digits);
      double tp_price=price-ls_gap;
      double tp_price2=price-2*ls_gap;
      int tp_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);
      int tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("high_price=",high_price,",low_price=",low_price,",higher_price=",higher_price,",lower_price=",lower_price,",range_high_low_gap_pt=",range_high_low_gap_pt);
      Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap=",ab_gap);
      Print("price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print("tp_price=",tp_price,",tp_price2=",tp_price2,",tp_gap_pt=",tp_gap_pt,",tp_gap2_pt=",tp_gap2_pt);

      if (tp_price<lower_price) {
         /*
         Print("adjust tp_price to lower_price");
         tp_price=lower_price+g_tp_offset*Point;
         tp_gap_pt=(int)NormalizeDouble((price-tp_price)/Point,0);
         if (tp_gap_pt<min_tp_pt) {
            Print("tp_gap is too small(<",min_tp_pt,"pt)");
            tp_price=0;
         }
         */
         Print("tp_price(",tp_price,") is lower than lower_price(",lower_price,")");
         tp_price=0;
         tp_price2=0;
      } else if (tp_price2<lower_price) {
         /*
         Print("adjust tp_price2 to lower_price");
         tp_price2=lower_price+g_tp_offset*Point;
         tp_gap2_pt=(int)NormalizeDouble((price-tp_price2)/Point,0);
         if (tp_gap2_pt<min_tp2_pt) {
            Print("tp_gap2 is too small(<",min_tp2_pt,"pt)");
            tp_price2=0;
         }
         */
         Print("tp_price2(",tp_price2,") is lower than lower_price(",lower_price,")");
         tp_price2=0;
      }
      
      if (!g_debug && !i_manual) {
         bool ret,ret2;
         ret=ret2=0;
         if (tp_price>0) {
            ret=OrderSell2(0,ls_price,tp_price,g_magic);
         }
         if (tp_price2>0) {
            ret2=OrderSell2(0,ls_price,tp_price2,g_magic);
         }
         if (ret || ret2) {
            //has_order=true;
            g_orderdt=now;
            return;
         }
      }
   }
   
   //break(down/second)
   if (sign==-4 && !has_order) {
      Print("ready to break down(second).create sell order.");
      double price=bid_price;
      double ls_tgt_price=NormalizeDouble(low_price+range_high_low_gap_pt*break_ls_ratio*Point,Digits);      //break down stop lose point
      double ls_price=ls_tgt_price;
      double ls_gap=NormalizeDouble(ls_price-price,Digits);
      double tp_price=price-ls_gap;
      double tp_price2=price-2*ls_gap;
      int tp_gap_pt=(int)NormalizeDouble(ls_gap/Point,0);
      int tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);

      Print("Time=",Time[cur_bar_shift]);
      Print("high_price=",high_price,",low_price=",low_price,",higher_price=",higher_price,",lower_price=",lower_price,",range_high_low_gap_pt=",range_high_low_gap_pt);
      Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap=",ab_gap);
      Print("price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print("tp_price=",tp_price,",tp_price2=",tp_price2,",tp_gap_pt=",tp_gap_pt,",tp_gap2_pt=",tp_gap2_pt);

      if (tp_price<lower2_price) {
         /*
         Print("adjust tp_price to lower_price");
         tp_price=lower_price+g_tp_offset*Point;
         tp_gap_pt=(int)NormalizeDouble((price-tp_price)/Point,0);
         if (tp_gap_pt<min_tp_pt) {
            Print("tp_gap is too small(<",min_tp_pt,"pt)");
            tp_price=0;
         }
         */
         Print("tp_price(",tp_price,") is lower than lower2_price(",lower2_price,")");
         tp_price=0;
         tp_price2=0;
      } else if (tp_price2<lower2_price) {
         /*
         Print("adjust tp_price2 to lower_price");
         tp_price2=lower_price+g_tp_offset*Point;
         tp_gap2_pt=(int)NormalizeDouble((price-tp_price2)/Point,0);
         if (tp_gap2_pt<min_tp2_pt) {
            Print("tp_gap2 is too small(<",min_tp2_pt,"pt)");
            tp_price2=0;
         }
         */
         Print("tp_price2(",tp_price2,") is lower than lower2_price(",lower2_price,")");
         tp_price2=0;
      }
      
      if (!g_debug && !i_manual) {
         bool ret,ret2;
         ret=ret2=0;
         if (tp_price>0) {
            ret=OrderSell2(0,ls_price,tp_price,g_magic);
         }
         if (tp_price2>0) {
            ret2=OrderSell2(0,ls_price,tp_price2,g_magic);
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
      if (OrderCloseA(NULL,0,g_magic)>0) return true;
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

//+------------------------------------------------------------------+
//|                                                 lang_th2_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_ea_inc.mqh>

//--------------------------------

//--- input
input int      i_order_cnt=3;
input int      i_mvst_ofst_pt=100;
input bool     i_debug=true;

//--- global
int      g_magic=8;        //trend by
//datetime g_orderdt;
//int      g_com=0;    //1:buy,2:sell,0:N/A

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
   g_magic+=Period();
   
   if (!i_for_test) {
      //if (!timer_init(SEC_H1)) return(INIT_FAILED);
      //news_impact();
   }
   
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

   /*
   if (!i_for_test) {
      timer_deinit();
   }
   */
   
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
   int weekday=TimeDayOfWeek(now);

   if (ifClose(cur_bar_shift)) {
      Print("closed all order");
      return;
   }

   bool has_order=true;
      
   double ls_tgt_price;
   //| return value: +3,open buy(up);-3,open sell (dw)
   //|               +2,keep buy(up);-2,keep sell (dw);
   //|               +1,turn up;-1,turn dw;
   //|               0,N/A
   double sign=isTrendStgOpen8(last_bar_shift,ls_tgt_price);

   //debug
   /*
   if (i_debug) {
      datetime t=Time[last_bar_shift];
      Print("time=",t,",signal=",sign);
   }
   */
   
   if (sign>=2) {
      //close sell order
      if(FindOrderA(NULL,-1,g_magic)) {  //found sell order
         if (OrderCloseA(NULL,-1,g_magic)>0) {  //close sell order
            Print("signal>1,close sell order");
         }
      }
   }
   if (sign<=-2) {
      //close buy order
      if(FindOrderA(NULL,1,g_magic)) {  //found buy order
         if (OrderCloseA(NULL,1,g_magic)>0) {  //close buy order
            Print("signal<-1,close buy order");
         }
      }
   }
   
   int buy_order_cnt,sell_order_cnt;
   buy_order_cnt=sell_order_cnt=0;
   double order_pft=0;

   if (MathAbs(sign)>=2) {
      if (!FindOrderCnt(NULL,g_magic,buy_order_cnt,sell_order_cnt,order_pft)) {
         has_order=false;
      } else {
         if (sign>0) {
            //moving stop (buy)
            if (movingStop4(NULL,1,g_magic,ls_tgt_price,i_mvst_ofst_pt)) {
               Print("moving stop!");
            }
         } else {
            //moving stop (sell)
            if (movingStop4(NULL,-1,g_magic,ls_tgt_price,i_mvst_ofst_pt)) {
               Print("moving stop!");
            }
         }
      }

      if (i_debug) {
         datetime t=Time[last_bar_shift];
         Print("time=",t,",b_cnt=",buy_order_cnt,",s_cnt=",sell_order_cnt,",profit=",order_pft);
      }
      
      if (sign==2 || has_order) {    //open buy order
         if (buy_order_cnt<i_order_cnt && order_pft>=0) {
            if (OrderBuy2(0,ls_tgt_price,-1,g_magic)) {
               Print("buy order opened for ",buy_order_cnt);
            }
         }
      }
      if (sign==-2 || has_order) {   //open sell order
         if (sell_order_cnt<i_order_cnt && order_pft>=0) {
            if (OrderSell2(0,ls_tgt_price,-1,g_magic)) {
               Print("sell order opened for ",sell_order_cnt);
            }
         }
      }
   }
   
}
bool ifClose(int arg_shift)
{
   /*
   if(isEndOfWeek(arg_shift)) {
      Print("market close,close all buy/sell order");
      if (OrderCloseA(NULL,0,g_magic)>0) return true;
   }
   */   
   
   return false;
}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (g_debug) {
      Print("OnTimer()");
   }

   if (!i_for_test) {
      //g_com=file_read();
      //news_impact();
   }
}

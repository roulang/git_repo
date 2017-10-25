//+------------------------------------------------------------------+
//|                                                lang_news_stg.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_stg_inc.mqh>

//--- input
input int      i_SL=100;         //take lose point
input int      i_rate_SL=100;    //take lose point(rate control)
input int      i_OPT=150;        //oo offset
input bool     i_skiptd=false;   //skip trend control
input bool     i_rate_ctl=false; //rate control(not do OO,avoid slippage)

//--- global
//string   com="event stg";
int      mag=1;         //event magic
int      time_ped=900;  //15 minutes
bool     has_order=false;
datetime orderdt;

//global
double g_zigBuf[][3];
double g_high_low[4][2];
double g_pivotBuf[5];
int    g_pivot_sht=0;
int    g_touch_highlow[4];

double g_zigBuf2[][3];
double g_high_low2[4][2];
double g_pivotBuf2[5];
int    g_pivot_sht2=0;
int    g_touch_highlow2[4];

int    g_larger_shift=0;
int    g_range=20;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if (i_debug) {
      Print("OnInit()");
   }
   ea_init();
   
   //Print("has_order=",has_order);
   
   if (!i_for_test) {
      if (!timer_init()) return(INIT_FAILED);
   }
   
   news_read();

   ArrayResize(g_zigBuf,g_range);
   ArrayInitialize(g_zigBuf,0);
   ArrayInitialize(g_pivotBuf,0);
   ArrayInitialize(g_high_low,0);

   ArrayResize(g_zigBuf2,g_range);
   ArrayInitialize(g_zigBuf2,0);
   ArrayInitialize(g_pivotBuf2,0);
   ArrayInitialize(g_high_low2,0);

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (i_debug) {
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
   int bar_shift=isNewBar();
   if (bar_shift==0) {
      return;
   }

   datetime now=Time[bar_shift-1];
   
   int isPd3=isNewsPd3(NULL,bar_shift-1);    //news zone control
   if (isPd3>0 && !has_order) {
      double s_price[2],ls_price[2],tp_price[2];
      calculatePrice(bar_shift,s_price,ls_price,tp_price);
      if (!i_rate_ctl) {
         if (s_price[0]>0) {
            //Print("Open buy stop order,",now);
            if (OrderBuy2(s_price[0],ls_price[0],tp_price[0],mag)) {
               has_order=true;
               orderdt=now;
            }
         }
         if (s_price[1]>0) {
            //Print("Open sell stop order,",now);
            if (OrderSell2(s_price[1],ls_price[1],tp_price[1],mag)) {
               has_order=true;
               orderdt=now;
            }
         }
         return;
      } else {
         if (isPd3==1) {            //not rate change news
            if (s_price[0]>0) {
               //Print("Open buy stop order,",now);
               if (OrderBuy2(s_price[0],ls_price[0],tp_price[0],mag)) {
                  has_order=true;
                  orderdt=now;
               }
            }
            if (s_price[1]>0) {
               //Print("Open sell stop order,",now);
               if (OrderSell2(s_price[1],ls_price[1],tp_price[1],mag)) {
                  has_order=true;
                  orderdt=now;
               }
            }
            return;
         } else if (isPd3==2) {     //is rate change news
            if (s_price[0]>0) {
               //Print("Open buy stop order,",now);
               if (OrderBuy2(s_price[0],ls_price[0],tp_price[0],mag)) {
                  has_order=true;
                  orderdt=now;
               }
            }
            if (s_price[1]>0) {
               //Print("Open sell stop order,",now);
               if (OrderSell2(s_price[1],ls_price[1],tp_price[1],mag)) {
                  has_order=true;
                  orderdt=now;
               }
            }
            return;
         }
      }
   }

   if (has_order) {
      if       (FindOrderA(NULL,1,mag)) {  //found buy order
         //Print("found buy order,close sellstop order");
         OrderCloseA(NULL,-2,mag);   //close sellstop order
         
         /*
         //move lose stop, set no risk
         if (movingStop2(NULL,1,mag,bar_shift,i_SL,0)) {
            Print("movingstop of buy order");
         }
         
         if (ifClose(bar_shift)) {
            Print("closed buy order");
            if (!FindOrderA(NULL,0,mag)) {
               has_order=false;
            }
         }
         */
      } else if(FindOrderA(NULL,-1,mag)) {  //found sell order
         //Print("found sell order,close buystop order");
         OrderCloseA(NULL,2,mag);    //close buystop order
         
         /*
         //move lose stop, set no risk
         if (movingStop2(NULL,-1,mag,bar_shift,i_SL,0)) {
            Print("movingstop of sell order");
         }

         if (ifClose(bar_shift)) {
            Print("closed sell order");
            if (!FindOrderA(NULL,0,mag)) {
               has_order=false;
            }
         }
         */
      } else {    //not found buy and sell order
         //Print("not found buy and sell order");
         if ((now-orderdt)>time_ped) {  //timeover
            Print("over time, close buy stop and sell stop order");
            OrderCloseA(NULL,-2,mag);   //close sellstop order
            OrderCloseA(NULL,2,mag);    //close buystop order
            if (!FindOrderA(NULL,0,mag)) {
               has_order=false;
            }
         }
      }
   }
   
   //Print("has_order=",has_order);
   
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   if(i_debug) Print("OnTimer()");
   if (!i_for_test) {
      news_read();
   }
}
//+------------------------------------------------------------------+
bool ifClose(int shift)
{
   bool ret=false;
   
   int op1=ShotShootStgValue(shift+1);   //par and avg control
   int op2=ShotShootStgValue(shift);     //par and avg control
   int td=0;
   if (!i_skiptd) td=TrendStgValue2(shift);          //trend control
   
   if ((op1<0 && op2<0)||td==3) {  // close buy signal
      printf("close buy order");
      if (OrderCloseA(NULL,1,mag)>0) return true;
   }

   if ((op1>0 && op2>0)||td==-3) {  // close sell signal
      printf("close sell order");
      if (OrderCloseA(NULL,-1,mag)>0) return true;
   }
   
   return false;
}
//+------------------------------------------------------------------+
void calculatePrice(int arg_shift,double &arg_sus_price[],double &arg_ls_price[],double &arg_tp_price[],
                     int arg_offset1=100,int arg_offset2=50,int arg_offset3=20) 
{

   //get not expanded high low values
   int expand=0;
   double range_high_gap,range_low_gap,range_high_low_gap;
   int ret=getHighLowTouchStatus(arg_shift,0,g_range,g_zigBuf,g_high_low,g_pivotBuf,g_pivot_sht,
                                 g_larger_shift,g_touch_highlow,range_high_gap,range_low_gap,range_high_low_gap,
                                 expand,1,1);
   double range_high=g_high_low[0][0];
   double range_sub_high=g_high_low[1][0];
   double range_sub_low=g_high_low[2][0];
   double range_low=g_high_low[3][0];
   
   //get expanded high low values
   expand=1;
   double range_high_gap2,range_low_gap2,range_high_low_gap2;
   int ret2=getHighLowTouchStatus(arg_shift,0,g_range,g_zigBuf2,g_high_low2,g_pivotBuf2,g_pivot_sht2,
                                 g_larger_shift,g_touch_highlow2,range_high_gap2,range_low_gap2,range_high_low_gap2,
                                 expand,1,1);
   double range_high2=g_high_low2[0][0];
   double range_sub_high2=g_high_low2[1][0];
   double range_sub_low2=g_high_low2[2][0];
   double range_low2=g_high_low2[3][0];
   
   double ask_price=Ask;
   double bid_price=Bid;
   double ab_gap=Ask-Bid;
   
   //-------------------------------
   //buy stop price
   arg_sus_price[0]=0;
   if (range_sub_high>0 && (range_sub_high-ask_price)>arg_offset1*Point) {    //range_sub_high is high enough(>ask+100pt)
      if (range_high>0 && range_high_gap<arg_offset2*Point) {     //range_high and range_sub_high are too narrow(<50pt)
         arg_sus_price[0]=range_high+arg_offset3*Point;           //choose range_high(+20pt above)
      } else {
         arg_sus_price[0]=range_sub_high+arg_offset3*Point;       //choose range_sub_high(+20pt above)
      }
   }
   if (arg_sus_price[0]==0 && range_high>0 && (range_high-ask_price)>arg_offset1*Point) {    //range_high is high enough(>ask 100pt)
      arg_sus_price[0]=range_high+arg_offset3*Point;              //choose range_high(+20pt above)
   }
   if (arg_sus_price[0]==0) {                                     //range_high and range_sub_high are not high enough(<ask+100pt)
      //arg_sus_price[0]=ask_price+(arg_offset1+arg_offset3)*Point; //set to (ask+120pt)
   }
   //buy lose stop price
   arg_ls_price[0]=0;
   if (arg_sus_price[0]>0) {
      arg_ls_price[0]=arg_sus_price[0]-arg_offset1*Point;         //set to (price-100pt)
   }
   //buy take profit price
   arg_tp_price[0]=0;
   if (arg_sus_price[0]>0) {
      if (range_sub_high2>0 && (range_sub_high2-arg_sus_price[0])>2*arg_offset1*Point) {  //range_sub_high2 is high enough(>price+200pt)
         arg_tp_price[0]=range_sub_high2-arg_offset3*Point;       //choose range_sub_high2(-20pt below)
      }
      if (arg_tp_price[0]>0 && arg_tp_price[0]==0 && range_high2>0 && (range_high2-arg_sus_price[0])>2*arg_offset1*Point) {  //range_high2 is high enough(>price+200pt)
         arg_tp_price[0]=range_high2-arg_offset3*Point;           //choose range_high2(-20pt below)
      }
      if (arg_tp_price[0]>0 && arg_tp_price[0]==0) {              //range_high2 and range_sub_high2 are not high enough(<price+200pt)
         arg_tp_price[0]=arg_sus_price[0]+2*arg_offset1*Point;    //set to (price+200pt)
      }
   }
   
   //-------------------------------
   //sell stop price
   arg_sus_price[1]=0;
   if (range_sub_low>0 && (bid_price-range_sub_low)>arg_offset1*Point) {   //range_sub_low is low enough(<bid-100pt)
      if (range_low>0 && range_low_gap<arg_offset2*Point) {       //range_low and range_sub_low are too narrow(<50pt)
         arg_sus_price[1]=range_low-arg_offset3*Point;            //choose range_low(-20pt below)
      } else {
         arg_sus_price[1]=range_sub_low-arg_offset3*Point;        //choose range_sub_low(-20pt below)
      }
   }
   if (arg_sus_price[1]==0 && range_low>0 && (bid_price-range_low)>arg_offset1*Point) {   //range_low is low enough(<bid-100pt)
      arg_sus_price[1]=range_low-arg_offset3*Point;               //choose range_low(-20pt below)
   }
   if (arg_sus_price[1]==0) {             //range_low and range_sub_low are not low enough(>bid-100pt)
      //arg_sus_price[1]=bid_price-(arg_offset1+arg_offset3)*Point; //set to (bid-120pt)
   }
   //sell lose stop price
   arg_ls_price[1]=0;
   if (arg_sus_price[1]>0) {
      arg_ls_price[1]=arg_sus_price[1]+arg_offset1*Point;         //set to (price+100pt)
   }
   //sell take profit price
   arg_tp_price[1]=0;
   if (arg_sus_price[1]>0) {
      if (range_sub_low2>0 && (arg_sus_price[1]-range_sub_low2)>2*arg_offset1*Point) { //range_sub_low2 is low enough(<price-200pt)
         arg_tp_price[1]=range_sub_low2+arg_offset3*Point;        //choose range_sub_low2(+20pt above)
      }
      if (arg_tp_price[1]>0 && arg_tp_price[1]==0 && range_low2>0 && (arg_sus_price[1]-range_low2)>2*arg_offset1*Point) { //range_low2 is low enough(<price-200pt)
         arg_tp_price[1]=range_low2+arg_offset3*Point;            //choose range_low2(+20pt above)
      }
      if (arg_tp_price[1]>0 && arg_tp_price[1]==0) {    //range_low2 and range_sub_low2 are not low enough(>price-200pt)
         arg_tp_price[1]=arg_sus_price[1]-2*arg_offset1*Point;    //set to (price-200pt)
      }
   }
   
}
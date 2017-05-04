//+------------------------------------------------------------------+
//|                                                         lang.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <stderror.mqh> 
#include <stdlib.mqh> 

extern int EquityPercent = 1;
extern int LossStopPt = 100;
extern int ProfitStopPt = 200;
extern double Volume = 0.1;
extern bool debug = true;

//+------------------------------------------------------------------+
// OrderBuy
// ls_value: Loss Stop Value
// ps_value: Profit Stop Value
// ep: equity percent. ex,1=1%,2=2%
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
int OrderBuy(double ls_value, double ps_value, int ep, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double price = Ask;
   double gap = NormalizeDouble((price - Bid) / pt, 0);

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (ls_value == 0) {
      ls_price = NormalizeDouble(price - LossStopPt * pt, Digits);
	  ls_pt = LossStopPt;
   } else {
      ls_price = ls_value;
      ls_pt = NormalizeDouble((price - ls_price) / pt, 0);
   }
   if (ps_value == 0) {
      ps_price = NormalizeDouble(price + ProfitStopPt * pt, Digits);
	  ps_pt = ProfitStopPt;
   } else {
      ps_price = ps_value;
      ps_pt = NormalizeDouble((ps_price - price) / pt, 0);
   }

   double risk_vol = getVolume(EquityPercent, ls_pt);
   if (risk_vol > Volume) risk_vol = Volume;
   
   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.5f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!debug) {
      ret = OrderSend(Symbol(), OP_BUY, risk_vol, price, 0, ls_price, ps_price, comment, magic, 0, Green);
   }
   
   if (ret != 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   return ret;
}

//+------------------------------------------------------------------+
// OrderSell
// volume: Volume
// ls_point: Loss Stop Point
// ps_point: Profit Stop Point
// ep: equity percent. ex,1=1%,2=2%
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
int OrderSell(double ls_value, double ps_value, int ep, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double price = Bid;
   double gap = NormalizeDouble((Ask - price) / pt, 0);

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (ls_value == 0) {
      ls_price = NormalizeDouble(price + LossStopPt * pt, Digits);
	  ls_pt = LossStopPt;
   } else {
      ls_price = ls_value;
      ls_pt = NormalizeDouble((ls_price - price) / pt, 0);
   }
   if (ps_value == 0) {
      ps_price = NormalizeDouble(price - ProfitStopPt * pt, Digits);
	  ps_pt = ProfitStopPt;
   } else {
      ps_price = ps_value;
      ps_pt = NormalizeDouble((price- ps_price) / pt, 0);
   }

   double risk_vol = getVolume(ep, ls_pt);
   if (risk_vol > Volume) risk_vol = Volume;

   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.5f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!debug) {
      ret = OrderSend(Symbol(), OP_SELL, risk_vol, price, 0, ls_price, ps_price, comment, magic, 0, Red);
   }
   
   if (ret != 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   return ret;

}

//+------------------------------------------------------------------+
// getVolume
// ep: equity percent. ex,1=1%,2=2%
// ls_point: Loss Stop Point
//+------------------------------------------------------------------+
double getVolume(int ep, doube ls_point)
{
   double risk_amount = AccountEquity() * ep / 100;
   double tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);
   double volume = risk_amount / (ls_point * tick_value);
   volume = NormalizeDouble(volume, 2);
   
   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("risk amount=%.5f", risk_amount);
      printf("tick value=%.5f", tick_value);
      printf("volume=%.5f", volume);
      Print("debug>>>>");
   }
   //debug>>>>
   return volume;
   
}

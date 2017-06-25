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
extern int OOPt = 100;
extern double Vol = 0.1;
extern bool debug = false;

//+------------------------------------------------------------------+
// OrderBuy
// p: Price
// ls_value: Loss Stop Value
// ps_value: Profit Stop Value
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
int OrderBuy(double p, double ls_value, double ps_value, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price = Ask;
   int cmd = OP_BUY;
   if (p != 0) {
	   if (p > price) {
		   cmd = OP_BUYSTOP;
	   } else {
		   cmd = OP_BUYLIMIT;
	   }
      price = p + g;
   }

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
   } else if (ps_value == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = ps_value;
      ps_pt = NormalizeDouble((ps_price - price) / pt, 0);
   }

   double risk_vol = getVolume(EquityPercent, ls_pt);
   if (risk_vol > Vol) risk_vol = Vol;
   
   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, 0, ls_price, ps_price, comment, magic, 0, Green);
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
// p: Price
// ls_point: Loss Stop Point
// ps_point: Profit Stop Point
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
int OrderSell(double p, double ls_value, double ps_value, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price = Bid;
   int cmd = OP_SELL;
   if (p != 0) {
	   if (p > price) {
		   cmd = OP_SELLLIMIT;
	   } else {
		   cmd = OP_SELLSTOP;
	   }
      price = p;
   }

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (ls_value == 0) {
      ls_price = NormalizeDouble(price + LossStopPt * pt, Digits);
	   ls_pt = LossStopPt;
   } else {
      ls_price = ls_value + g;
      ls_pt = NormalizeDouble((ls_price - price) / pt, 0);
   }
   
   if (ps_value == 0) {
      ps_price = NormalizeDouble(price - ProfitStopPt * pt, Digits);
	   ps_pt = ProfitStopPt;
   } else if (ps_value == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = ps_value + g;
      ps_pt = NormalizeDouble((price- ps_price) / pt, 0);
   }

   double risk_vol = getVolume(EquityPercent, ls_pt);
   if (risk_vol > Vol) risk_vol = Vol;

   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, 0, ls_price, ps_price, comment, magic, 0, Red);
   }
   
   if (ret != 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   return ret;

}

//+------------------------------------------------------------------+
// OrderOO
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
int OrderOO(string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price1 = Bid;
   price1 = NormalizeDouble(price1 - OOPt * pt, Digits);
   double price2 = Ask;
   price2 = NormalizeDouble(price2 + OOPt * pt, Digits);
   int cmd1 = OP_SELLSTOP;
   int cmd2 = OP_BUYSTOP;

   double ls_pt;
   double ps_pt;
   ls_pt = LossStopPt;
   ps_pt = ProfitStopPt;
   double ls_price1;
   double ps_price1;
   ls_price1 = NormalizeDouble(price1 + LossStopPt * pt, Digits);
   ps_price1 = NormalizeDouble(price1 - ProfitStopPt * pt, Digits);

   double ls_price2;
   double ps_price2;
   ls_price2 = NormalizeDouble(price2 - LossStopPt * pt, Digits);
   ps_price2 = NormalizeDouble(price2 + ProfitStopPt * pt, Digits);

   double risk_vol = getVolume(EquityPercent, ls_pt);
   if (risk_vol > Vol) risk_vol = Vol;

   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("command1=%d", cmd1);
      printf("command2=%d", cmd2);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price1=%.5f", price1);
      printf("price2=%.5f", price2);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop point=%.5f", ps_pt);
      printf("loss stop price1=%.5f", ls_price1);
      printf("profit stop price1=%.5f", ps_price1);
      printf("loss stop price2=%.5f", ls_price2);
      printf("profit stop price2=%.5f", ps_price2);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   if (!debug) {
      ret = OrderSend(Symbol(), cmd1, risk_vol, price1, 0, ls_price1, ps_price1, comment, magic, 0, Red);
   }
   
   if (ret != 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   if (!debug) {
      ret = OrderSend(Symbol(), cmd2, risk_vol, price2, 0, ls_price2, ps_price2, comment, magic, 0, Green);
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
double getVolume(int ep, double ls_point)
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

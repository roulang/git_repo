//+------------------------------------------------------------------+
//|                                                         lang.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include <stderror.mqh> 
#include <stdlib.mqh> 

extern bool debug;

//+------------------------------------------------------------------+
// OrderBuy
// volume: Volume
// ps_point: Profit Stop Point
// ls_point: Loss Stop Point
// ep: equity percent. ex,1=1%,2=2%
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
int OrderBuy(double volume, int ps_point, int ls_point, int ep, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double price = Ask;
   double ps_price = NormalizeDouble(price + ps_point*pt, Digits);
   double ls_price = NormalizeDouble(price - ls_point*pt, Digits);
   double rv = getVolume(ep,ls_point);

   if (rv < volume) volume = rv;
   
   if (!debug) {
      ret = OrderSend(Symbol(), OP_BUY, volume, price, 0, ls_price, ps_price, comment, magic, 0, Green);
   }
   
   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("vol=%.5f", volume);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop=%.5f", ls_price);
      printf("profit stop=%.5f", ps_price);
      Print("debug>>>>");
   }
   //debug>>>>

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
// ps_point: Profit Stop Point
// ls_point: Loss Stop Point
// ep: equity percent. ex,1=1%,2=2%
// comment: Comment
// magic: Magic
//+------------------------------------------------------------------+
int OrderSell(double volume, int ps_point, int ls_point, int ep, string comment, int magic)
{
   int ret = 0;
   double pt = Point;
   double price = Bid;
   double ps_price = NormalizeDouble(price - ps_point*pt, Digits);
   double ls_price = NormalizeDouble(price + ls_point*pt, Digits);
   double rv = getVolume(ep, ls_point);

   if (rv < volume) volume = rv;

   if (!debug) {
      ret = OrderSend(Symbol(), OP_SELL, volume, price, 0, ls_price, ps_price, comment, magic, 0, Red);
   }
   
   //<<<<debug
   if (debug) {
      Print("<<<<debug");
      printf("vol=%.5f", volume);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop=%.5f", ls_price);
      printf("profit stop=%.5f", ps_price);
      Print("debug>>>>");
   }
   //debug>>>>
   
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
double getVolume(int ep, int ls_point)
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

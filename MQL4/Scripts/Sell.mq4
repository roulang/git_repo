//+------------------------------------------------------------------+
//|                                                       Buy+-5.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <stderror.mqh> 
#include <stdlib.mqh> 
void OnStart()
  {
  int s = 10;
  int p = 20;
  double v = 1;
  double tp = NormalizeDouble(Ask - p*Point, Digits);
  double sl = NormalizeDouble(Ask + s*Point, Digits);
//--- sell order
   if (OrderSend(Symbol(), OP_SELL, v, Bid, 0, sl, tp, "sell", 12345, 0, Red) != 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   
  }
//+------------------------------------------------------------------+

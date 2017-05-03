//+------------------------------------------------------------------+
//|                                                         Buy2.mq4 |
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
#include <lang_inc.mqh> 

extern int StopLoss = 100;
extern int StopProfit = 200;
extern int EquityPercent = 1;
extern double Vol = 0.1;
void OnStart()
{
//---
   debug = true;
   if (OrderSell(Vol, StopProfit, StopLoss, EquityPercent, "sell", 12345) != 0)
   {
      printf("sell error");
   }
}
//+------------------------------------------------------------------+

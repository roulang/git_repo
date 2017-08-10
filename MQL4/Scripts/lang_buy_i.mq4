//+------------------------------------------------------------------+
//|                                                         Buy2.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_inc.mqh> 

extern double Price = 0;
extern double LossStopPrice = 0;
//-1 is no set
extern double ProfitStopPrice = 0;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   debug = false;
   if (OrderBuy2(Price, LossStopPrice, ProfitStopPrice, "buy", 12345) != 0)
   {
      printf("buy error");
   }
}
//+------------------------------------------------------------------+


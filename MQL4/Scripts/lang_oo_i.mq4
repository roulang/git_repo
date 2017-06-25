//+------------------------------------------------------------------+
//|                                                    lang_oo_i.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_inc.mqh> 

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   debug = false;
   if (OrderOO("oo", 12345) != 0)
   {
      printf("sell error");
   }
  }
//+------------------------------------------------------------------+

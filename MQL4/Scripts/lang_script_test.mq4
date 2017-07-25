//+------------------------------------------------------------------+
//|                                                    lang_test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_inc.mqh>
#include <lang_stg_inc.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   debug=true;
   printf("test");
   int ret=0;
   if (isCurPd(NULL,0)) ret=1;
   printf("ret is %d",ret);   
}
//+------------------------------------------------------------------+

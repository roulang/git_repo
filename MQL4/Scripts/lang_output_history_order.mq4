//+------------------------------------------------------------------+
//|                                    lang_output_history_order.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_stg_inc.mqh>

#property script_show_inputs
//--- input parameters
input bool     i_write_all=false;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   if (getFileLock()) {
      if (i_write_all)
         writeOrderHistoryToFile(1);
      else
         writeOrderHistoryToFile();

      releaseFileLock();
   }

}
//+------------------------------------------------------------------+

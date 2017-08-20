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
   
   //test mail
   //mailNoticeOrderOpen(12345,Symbol(),2,0.1,1.4545,1.4500,1.4678,"some stg",12345);
   //return;
   
   Print("test");
   
   if (getFileLock()) {
      writeOrderHistoryToFile();
      releaseFileLock();
   }
   
}


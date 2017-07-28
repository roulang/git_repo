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

//local
NewsImpact events[];

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   debug=true;
   printf("test");
   
   int cnt=0;
   int h=FileOpen(filen,FILE_READ|FILE_CSV,',');
   if(h!=INVALID_HANDLE) {
      //read record count
      while(!FileIsEnding(h)) {
         string s;
         s=FileReadString(h);
         if(debug) Print(s);
         s=FileReadString(h);
         if(debug) Print(s);
         s=FileReadString(h);
         if(debug) Print(s);
         cnt++;
      }
      
      ArrayResize(events,cnt);
      cnt=0;
      //move to file's head
      if (FileSeek(h,0,SEEK_SET)) {
         while(!FileIsEnding(h)) {
            events[cnt].n=FileReadNumber(h);
            events[cnt].cur=FileReadString(h);
            events[cnt].dt=FileReadDatetime(h);
            cnt++;
         }
      }
      
      FileClose(h);
   } else {
      Print("Operation FileOpen failed, error: ",GetLastError());
   }
   
}
//+------------------------------------------------------------------+

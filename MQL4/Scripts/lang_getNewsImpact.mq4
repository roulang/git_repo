//+------------------------------------------------------------------+
//|                                           lang_getNewsImpact.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs
//
#include <stderror.mqh>
#include <stdlib.mqh>
//
#define SEC_H1 3600 //Seconds in an hour
#define SEC_D1 86400 //Seconds in a day
//--- input parameters
input datetime refDate=D'2017.07.07 20:30:00';
input int dtOffset=-5*SEC_H1;
input int period=1*SEC_H1;
//
//double olValue[8][2];
//string cur[8] = {"EURUSD","USDJPY","AUDUSD","NZDUSD","USDCAD","GBPUSD","USDCHF","XAUUSD"};
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   datetime dt=refDate+dtOffset;
   int openSft,closeSft;
   openSft=closeSft=0;
   double openVal,closeVal;
   openVal=closeVal=0;
   
//   for (int i=0;i<8;i++) {
   int sft=0;
   double val=0;

   //sft=iBarShift(cur[i],PERIOD_M15,dt,true);
   sft=iBarShift(NULL,PERIOD_CURRENT,dt,true);
   if (sft>0) {
      //val=iOpen(cur[i],PERIOD_M15,sft);
      val=iOpen(NULL,PERIOD_CURRENT,sft);
      if (val==0) {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
      openVal=val;
   } else {
      openVal=0;
   }
   openSft=sft;

   //sft=iBarShift(cur[i],PERIOD_M15,dt+period,true); 
   sft=iBarShift(NULL,PERIOD_CURRENT,dt+period,true); 
   if (sft>0) {
      //val=iClose(cur[i],PERIOD_M15,sft+1);
      val=iClose(NULL,PERIOD_CURRENT,sft+1);
      if (val==0) {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
      closeVal=val;
   } else {
      closeVal=0;
   }
   closeSft=sft+1;
   
   //printf("%s open shift is %d, close shift is %d",cur[i],openSft,closeSft);
   //printf("%s open is %.5f, close is %.5f",cur[i],openVal,closeVal);
   printf("%s open shift is %d, close shift is %d",Symbol(),openSft,closeSft);
   printf("%s open is %.5f, close is %.5f",Symbol(),openVal,closeVal);
//   }
}
//+------------------------------------------------------------------+

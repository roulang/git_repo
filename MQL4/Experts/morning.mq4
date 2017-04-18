//+------------------------------------------------------------------+
//|                                                      morning.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <stderror.mqh> 
#include <stdlib.mqh> 

extern int lmt = 10;
extern double v = 0.1;
extern int pd = PERIOD_D1;

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   datetime t = TimeCurrent();
   int h = TimeHour(t);
   int m = TimeMinute(t);
   printf("h=" + h);
   printf("m=" + m);
   if (m == 0)
   {
      double tp = iHigh(NULL, pd, 1);
      double lw = iLow(NULL, pd, 1);
      double op = iOpen(NULL, pd, 1);
      double cl = iClose(NULL, pd, 1);
      double s = NormalizeDouble((op - cl), Digits) / Point;
      double s2 = NormalizeDouble((tp - lw), Digits);
      double s3 = NormalizeDouble(s2 / 2, Digits);
      printf("tp=" + tp);
      printf("lw=" + lw);
      printf("op=" + op);
      printf("cl=" + cl);
      printf("s=" + s);
      printf("s2=" + s2);
      printf("s3=" + s3);
      
      if (MathAbs(s) > lmt)
      {
         if (s > 0) 
         {
            double ps = NormalizeDouble(Ask + s3, Digits);
            double ls = NormalizeDouble(Ask - s2, Digits);
            if (OrderSend(NULL, OP_BUY, v, Ask, 0, ls, ps, "buy", 12345, 0, Red) != 0)
            {
               int check=GetLastError(); 
               if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
            }
         } else 
         {
            double ps = NormalizeDouble(Bid - s3, Digits);
            double ls = NormalizeDouble(Bid + s2, Digits);
            if (OrderSend(NULL, OP_SELL, v, Bid, 0, ls, ps, "sell", 12345, 0, Red) != 0)
            {
               int check=GetLastError(); 
               if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
            }
         }
      }
   }
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+

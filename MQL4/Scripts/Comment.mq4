//+------------------------------------------------------------------+
//|                                                      Comment.mq4 |
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
//---
   int pd = 12;
   datetime t=D'2017.04.17 00:00'; 
   int ed = iBarShift(NULL, PERIOD_M15, t);
   int st = ed - pd + 1;
   int tp = iHighest(NULL, PERIOD_M15, MODE_HIGH, pd, st);
   int lw = iLowest(NULL, PERIOD_M15, MODE_LOW, pd, st);
   printf("ed=" + ed);
   printf("st=" + st);
   printf("tp=" + tp);
   printf("lw=" + lw);

   if (ObjectFind("Rec 1") == 0)
   {
      ObjectDelete(0, "Rec 1");
   }
   if (! ObjectCreate("Rec 1", OBJ_RECTANGLE, 0, Time[st], High[tp], Time[ed], Low[lw]))
   {
      int check=GetLastError();
      if(check != ERR_NO_ERROR) Print("Object not created. Error: ", ErrorDescription(check));
   }
   
   ObjectSet("Rec 1", OBJPROP_COLOR, clrRed);
   ObjectSet("Rec 1", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("Rec 1", OBJPROP_BACK, false);
   
   /*
   if (ObjectFind("VLine 1") == 0)
   {
      ObjectDelete(0, "VLine 1");
   }
   if (! ObjectCreate("VLine 1", OBJ_VLINE, 0, Time[i], Open[i]))
   {
      int check=GetLastError();
      if(check != ERR_NO_ERROR) Print("Object not created. Error: ", ErrorDescription(check));
   }
   
   ObjectSet("VLine 1", OBJPROP_COLOR, clrLawnGreen);
   ObjectSet("VLine 1", OBJPROP_STYLE, STYLE_DASHDOT);

   if (ObjectFind("Text 1") == 0)
   {
      ObjectDelete(0, "Text 1");
   }
   if (! ObjectCreate("Text 1", OBJ_TEXT, 0, Time[i], Low[i]))
   {
      int check=GetLastError();
      if(check != ERR_NO_ERROR) Print("Object not created. Error: ", ErrorDescription(check));
   }
   ObjectSetText("Text 1", "Day Open", 10, NULL, clrRed);

   if (ObjectFind("VLine 2") == 0)
   {
      ObjectDelete(0, "VLine 2");
   }
   if (! ObjectCreate("VLine 2", OBJ_VLINE, 0, Time[j], Open[j]))
   {
      int check=GetLastError();
      if(check != ERR_NO_ERROR) Print("Object not created. Error: ", ErrorDescription(check));
   }
   
   ObjectSet("VLine 2", OBJPROP_COLOR, clrLawnGreen);
   ObjectSet("VLine 2", OBJPROP_STYLE, STYLE_DASHDOT);

   if (ObjectFind("Text 2") == 0)
   {
      ObjectDelete(0, "Text 2");
   }
   if (! ObjectCreate("Text 2", OBJ_TEXT, 0, Time[j], Low[j]))
   {
      int check=GetLastError();
      if(check != ERR_NO_ERROR) Print("Object not created. Error: ", ErrorDescription(check));
   }
   ObjectSetText("Text 2", "Day Open 3 hours", 10, NULL, clrRed);
   
   if (ObjectFind("HLine 1") == 0)
   {
      ObjectDelete(0, "HLine 1");
   }
   if (! ObjectCreate("HLine 1", OBJ_HLINE, 0, Time[k], High[k]))
   {
      int check=GetLastError();
      if(check != ERR_NO_ERROR) Print("Object not created. Error: ", ErrorDescription(check));
   }
   
   ObjectSet("HLine 1", OBJPROP_COLOR, clrLawnGreen);
   ObjectSet("HLine 1", OBJPROP_STYLE, STYLE_DASHDOT);
   
   if (ObjectFind("HLine 2") == 0)
   {
      ObjectDelete(0, "HLine 2");
   }
   if (! ObjectCreate("HLine 2", OBJ_HLINE, 0, Time[l], Low[l]))
   {
      int check=GetLastError();
      if(check != ERR_NO_ERROR) Print("Object not created. Error: ", ErrorDescription(check));
   }
   
   ObjectSet("HLine 2", OBJPROP_COLOR, clrLawnGreen);
   ObjectSet("HLine 2", OBJPROP_STYLE, STYLE_DASHDOT);
   */
  }
//+------------------------------------------------------------------+

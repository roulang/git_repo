//+------------------------------------------------------------------+
//|                                                 lang_ea_test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_inc.mqh>
#include <lang_stg_inc.mqh>

//--- input parameters
input datetime   tg_st=D'00:00:00';        //start time
input datetime   tg_ed=D'03:00:00';        //end time

//--- local
string   com="fish stg";   //only for GBPJPY 5M
int      mag=12345;
int      TimeOffset=SEC_H1*3;
int      n=0;
int      l_o=50; //price offset
bool     has_order=false;
int      time_ped=SEC_H1*1;  //20 hours
datetime orderdt;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   debug=false;
   if (debug) {
      Print("OnInit()");
   }
   
   Vol=1;
   
   delAllObj();
   
   ea_init();
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if (debug) {
      Print("OnDeinit()");
   }
   
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   int bar_shift=isNewBar();
   if (bar_shift==0) return;

   datetime now=Time[bar_shift-1];

   if (has_order) {
       if       (FindOrderA(NULL,1,com,mag)) {  //found buy order
         //Print("found buy order,close sellstop order");
         //OrderCloseA(NULL,-2,com,mag);   //close sellstop order

      } else if(FindOrderA(NULL,-1,com,mag)) {  //found sell order
         //Print("found sell order,close buystop order");
         //OrderCloseA(NULL,2,com,mag);    //close buystop order
      
      } else {
         if ((now-orderdt)>time_ped) {  //timeover
            Print("over time, close buy stop and sell stop order");
            OrderCloseA(NULL,-2,com,mag);   //close sellstop order
            OrderCloseA(NULL,2,com,mag);    //close buystop order
            if (!FindOrderA(NULL,0,com,mag)) {
               has_order=false;
            }
         }
      }
   }
   
   int h=TimeHour(CurrentTimeStamp);
   int mi=TimeMinute(CurrentTimeStamp);

   if (h==3 && mi==0) {   //03:00 start
      
      int b_ed=iBarShift(NULL,PERIOD_CURRENT,CurrentTimeStamp-TimeOffset);
      int b_st=1;
      int b_range=b_ed-b_st+1;
      Print("b_st=",b_st,",b_range=",b_range);
      int low=iLowest(NULL,PERIOD_CURRENT,MODE_LOW,b_range,b_st);
      int high=iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,b_range,b_st);
      double high_p=High[high];
      double low_p=Low[low];
      Print("ilow=",low,",ihigh=",high);
      Print("low=",low_p,",high=",high_p);
      
      //create objects
      long current_chart_id=ChartID();
      string o=StringConcatenate("rect",n);
      n++;
      if (!ObjectCreate(current_chart_id,o,OBJ_RECTANGLE,0,Time[b_ed],low_p,Time[b_st],high_p)) {
         Print("Object Create Error: ", ErrorDescription(GetLastError()));
      }
      
      if (!has_order) {   
         if (high_p<Ask || ((high_p-Ask)/Point)<l_o) high_p=NormalizeDouble(Ask+l_o*Point,Digits);
         if (Bid<low_p || ((Bid-low_p)/Point)<l_o) low_p=NormalizeDouble(Bid-l_o*Point,Digits);
         double g=high_p-low_p;
         
         Print("Open oo order");
         if (OrderOO2(com,mag,low_p,high_p,high_p,low_p-2*g,low_p,high_p+2*g)) {
         //if (OrderOO2(com,mag,low_p,high_p,high_p,low_p-g,low_p,high_p+g)) {
            has_order=true;
            orderdt=now;
         }
      }
      
   }

}
//+------------------------------------------------------------------+
void OnTimer()
{
   if (debug) {
      Print("OnTimer()");
   }
}

//+------------------------------------------------------------------+
//|                                                  lang_newspd.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <lang_stg_inc.mqh>

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 5
#property indicator_buffers 1
#property indicator_plots   1
//--- plot signal
#property indicator_label1  "signal"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double    signalBuffer[];

//--- input
input int i_timer_sec=SEC_H1;       //timer seconds
input int i_news_bef=15*60;         //news before 15min
input int i_news_aft=60*60;         //news after 1 hour
input bool i_update_news=true;      //news update control
input bool i_his_order_wrt=false;   //history order write control

//global
bool      g_for_test=false;
int       g_obj_cnt=0;
string    g_obj_name="vline";
int       g_obj_cnt2=0;
string    g_obj_name2="txt";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   
//--- indicator buffers mapping
   SetIndexBuffer(0,signalBuffer);
   
   if (!g_for_test) {
      if (!timer_init(i_timer_sec)) return(INIT_FAILED);
   }
   
   news_read();
   
   DelObjects();
   
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if (i_debug) {
      Print("OnDeinit()");
   }

   DelObjects();
   
   //Print("OnDeinit(),release lock");
   releaseFileLock();
   
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   
   int limit=rates_total-prev_calculated;
   if (limit==0) return rates_total;
   if(prev_calculated==0) {
      limit=InitializeAll();
   }
   
   int st=limit;
   for(int i=st-1;i>=0;i--) {
      if (isNewsPd(NULL,i,i_news_bef,i_news_aft)) signalBuffer[i]=1;
      else signalBuffer[i]=0;
      DrawObjects(i);
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int InitializeAll()
{
   printf("init");
   ArrayInitialize(signalBuffer,0.0);
//--- first counting position
   return(Bars-1);
}
//+------------------------------------------------------------------+
//| Expert timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(i_debug) Print("OnTimer()");
     
   if (!g_for_test) {
      if (i_update_news) news_read();
      if (i_his_order_wrt) {
         if (getFileLock()) {
            writeOrderHistoryToFile();
            releaseFileLock();
         }
      }
   }
}

void DrawObjects(int arg_shift)
{
   string cur=Symbol();
   int pd=TimepdValue(arg_shift);
   int pd2=TimepdValue(arg_shift+1);
   if (pd==0 && pd2==0) return;

   long current_chart_id=ChartID();
   int widx=WindowFind("lang_newspd");
   
   DrawTimeZone(current_chart_id,widx,pd,pd2,AMA_PD,arg_shift);
   if          (StringCompare(cur,EURUSD)==0) {
      DrawTimeZone(current_chart_id,widx,pd,pd2,EUR_PD,arg_shift);
   } else if   (StringCompare(cur,USDJPY)==0) {
      DrawTimeZone(current_chart_id,widx,pd,pd2,ASIA_PD,arg_shift);
   } else if   (StringCompare(cur,AUDUSD)==0) {
      DrawTimeZone(current_chart_id,widx,pd,pd2,ASIA_PD,arg_shift);
   } else if   (StringCompare(cur,NZDUSD)==0) {
      DrawTimeZone(current_chart_id,widx,pd,pd2,ASIA_PD,arg_shift);
   } else if   (StringCompare(cur,USDCAD)==0) {
   } else if   (StringCompare(cur,GBPUSD)==0) {
      DrawTimeZone(current_chart_id,widx,pd,pd2,EUR_PD,arg_shift);
   } else if   (StringCompare(cur,USDCHF)==0) {
      DrawTimeZone(current_chart_id,widx,pd,pd2,EUR_PD,arg_shift);
   } else if   (StringCompare(cur,XAUUSD)==0) {
   }   
   
   
   /*
   //usa zone
   int pd3=pd & AMA_PD;
   int pd4=pd2 & AMA_PD;
   
   if (pd3!=0 && pd4==0) {  //start
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(current_chart_id,widx,obj_name,arg_shift,clrChocolate,STYLE_SOLID);

      g_obj_cnt2++;
      string obj_name2=StringConcatenate(g_obj_name2,g_obj_cnt2);
      DrawText(current_chart_id,widx,obj_name2,"USA",arg_shift,clrChocolate);
      
   } else if (pd3==0 && pd4!=0) {                //end
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(current_chart_id,widx,obj_name,arg_shift+1,clrChocolate,STYLE_DASH);
   }

   //eur zone
   pd3=pd & EUR_PD;
   pd4=pd2 & EUR_PD;
   if (pd3!=0 && pd4==0) {  //start
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(current_chart_id,widx,obj_name,arg_shift,clrCornflowerBlue,STYLE_SOLID);

      g_obj_cnt2++;
      string obj_name2=StringConcatenate(g_obj_name2,g_obj_cnt2);
      DrawText(current_chart_id,widx,obj_name2,"EUR",arg_shift,clrCornflowerBlue);
      
   } else if (pd3==0 && pd4!=0) {                //end
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(current_chart_id,widx,obj_name,arg_shift+1,clrCornflowerBlue,STYLE_DASH);
   }

   //asia zone
   pd3=pd & ASIA_PD;
   pd4=pd2 & ASIA_PD;
   if (pd3!=0 && pd4==0) {  //start
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(current_chart_id,widx,obj_name,arg_shift,clrIvory,STYLE_SOLID);

      g_obj_cnt2++;
      string obj_name2=StringConcatenate(g_obj_name2,g_obj_cnt2);
      DrawText(current_chart_id,widx,obj_name2,"ASIA",arg_shift,clrIvory);
      
   } else if (pd3==0 && pd4!=0) {                //end
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(current_chart_id,widx,obj_name,arg_shift+1,clrIvory,STYLE_DASH);
   }
   */
}
//+------------------------------------------------------------------+
//| Draw timezone function
//| arg_type:ASIA_PD,AMA_PD,EUR_PD
//+------------------------------------------------------------------+
void DrawTimeZone(long arg_chart_id,int arg_window,int arg_pd,int arg_pd2,int arg_type,int arg_shift)
{
   int pd3=arg_pd & arg_type;
   int pd4=arg_pd2 & arg_type;
   string text="";
   int c=0;
   if       (arg_type==AMA_PD) {
      text="USA";
      c=clrChocolate;
   } else if  (arg_type==EUR_PD) {
      text="EUR";
      c=clrCornflowerBlue;
   } else if  (arg_type==ASIA_PD) {
      text="ASIA";
      c=clrIvory;
   } else return;
   
   if (pd3!=0 && pd4==0) {          //start
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(arg_chart_id,arg_window,obj_name,arg_shift,c,STYLE_SOLID);

      g_obj_cnt2++;
      string obj_name2=StringConcatenate(g_obj_name2,g_obj_cnt2);
      DrawText(arg_chart_id,arg_window,obj_name2,text,arg_shift,c);
      
   } else if (pd3==0 && pd4!=0) {   //end
      g_obj_cnt++;
      string obj_name=StringConcatenate(g_obj_name,g_obj_cnt);
      //Print(Time[arg_shift],",pd=",pd,",pd2=",pd2,",pd3=",pd3,",pd4=",pd4);
      DrawLine(arg_chart_id,arg_window,obj_name,arg_shift+1,c,STYLE_DASH);
   }
}
void DelObjects()
{
   int obj_total=ObjectsTotal(); 
   for(int i=obj_total-1;i>=0;i--) { 
      string name=ObjectName(i); 
      PrintFormat("object %d: %s",i,name);
      if (StringFind(name,g_obj_name)>=0) {
         ObjectDelete(name);
      }
      if (StringFind(name,g_obj_name2)>=0) {
         ObjectDelete(name);
      }
   }
}

void DrawLine(long arg_chart_id, int arg_window, string arg_obj_name, int arg_shift, int arg_color, int arg_style)
{
   if (!ObjectCreate(arg_chart_id,arg_obj_name,OBJ_VLINE,arg_window,Time[arg_shift],0)) {
      Print("Object Create Error: ", ErrorDescription(GetLastError()));
   }
   //--- set line color
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_COLOR,arg_color);
   //--- set line display style
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_STYLE,arg_style);
   //--- set line width
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_WIDTH,1);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_BACK,true);
}

void DrawText(long arg_chart_id, int arg_window, string arg_obj_name, string arg_text, int arg_shift, int arg_color)
{
   if(!ObjectCreate(arg_chart_id,arg_obj_name,OBJ_TEXT,arg_window,Time[arg_shift],2)) {
      Print("Object Create Error: ", ErrorDescription(GetLastError()));
   }
   //--- set the text
   ObjectSetString(arg_chart_id,arg_obj_name,OBJPROP_TEXT,arg_text);
   //--- set text font
   //ObjectSetString(arg_chart_id,arg_obj_name,OBJPROP_FONT,font);
   //--- set font size
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_FONTSIZE,6);
   //--- set the slope angle of the text
   //ObjectSetDouble(arg_chart_id,arg_obj_name,OBJPROP_ANGLE,angle);
   //--- set anchor type
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   //--- set color
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_COLOR,arg_color);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(arg_chart_id,arg_obj_name,OBJPROP_BACK,true);
}

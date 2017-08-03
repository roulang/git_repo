//+------------------------------------------------------------------+
//|                                                 lang_stg_inc.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <lang_inc.mqh>

//input
input int      Adx_lev=40; //adx level

//each time period
string u1="16:00";  //usa
string u2="00:00";  //usa
string a1="03:00";  //asia
string a2="11:00";  //asia
string g1="10:00";  //england
string g2="18:00";  //england
static int ASIA_PD = 1;
static int AMA_PD = 4;
static int EUR_PD = 2;

//news
NewsImpact news[];
string filen="news.csv";

int news_bef=SEC_H1*0.25;     //15 mins before news
int news_aft=SEC_H1*0.25;     //15 mins after news
int TimeZoneOffset=SEC_H1*5;
int TimerSecond=SEC_H1*1;

//adx
double adx_thred=0.5;

//atr
double atr_lvl=0.0002;

//+------------------------------------------------------------------+
//| Shot shoot strategy
//+------------------------------------------------------------------+
int ShotShootStgValue(int shift)
{
   int ma_pos=0;  //2 for price above SMA(60),-2 for price below SMA(60)
   int sar_pos=0; //2 for price above SAR(0.02,0.2),-2 for price below SAR(0.02,0.2)
   int ma_break=0;//-1 for SMA(60) from down to up the price,1 for SMA(60) from up to down the price
   int sar_break=0;//-1 for SAR(0.02,0.2) from down to up the price,1 for SAR(0.02,0.2) from up to down the price
   int ret=0;
   
   double ma1=iMA(NULL,PERIOD_CURRENT,60,0,MODE_SMA,PRICE_CLOSE,shift+1);
   double ma2=iMA(NULL,PERIOD_CURRENT,60,0,MODE_SMA,PRICE_CLOSE,shift);
   //if (open[i]>ma2 && close[i]>ma2) { //price is above sma(60)
   if (Close[shift]>ma2) { //price is above sma(60)
      ma_pos=2;
   //} else if (open[i]<ma2 && close[i]<ma2) { //price is under sma(60)
   } else if (Close[shift]<ma2) { //price is under sma(60)
      ma_pos=-2;
   }
   if (ma1<Close[shift+1] && ma2>Close[shift]) { //prev MA is under price and cur MA is above price
      ma_break=-1;
   } else if (ma1>Close[shift+1] && ma2<Close[shift]) { //prev MA is above price and cur MA is under price
      ma_break=1;
   }
   
   double sar1=iSAR(NULL,PERIOD_CURRENT,0.02,0.2,shift+1);
   double sar2=iSAR(NULL,PERIOD_CURRENT,0.02,0.2,shift);
   if (Close[shift]>sar2) { //price is above sar
      sar_pos=2;
   } else if (Close[shift]<sar2) { //price is under sar
      sar_pos=-2;
   }
   if (sar1<Close[shift+1] && sar2>Close[shift]) { //prev SAR is under price and cur SAR is above price
      sar_break=-1;
   } else if (sar1>Close[shift+1] && sar2<Close[shift]) { //prev SAR is above price and cur SAR is under price
      sar_break=1;
   }
   
   ret=sar_pos+ma_pos+sar_break+ma_break;
   return ret;
}

//+------------------------------------------------------------------+
//| Trend strategy
//+------------------------------------------------------------------+
int TrendStgValue(int shift)
{
   int ret=0;
   //double adx1=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,shift+1);
   //double adx1_pdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_PLUSDI,shift+1);
   //double adx1_mdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MINUSDI,shift+1);
   double adx2=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,shift);
   double adx2_pdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_PLUSDI,shift);
   double adx2_mdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MINUSDI,shift);
   
   int adx_lv=0;
   if (adx2>=Adx_lev) {
      adx_lv=1;
   }
   
   int adx_dir=0;
   if (adx2_pdi>adx2_mdi) {
      adx_dir=1;
   }
   if (adx2_pdi<adx2_mdi) {
      adx_dir=-1;
   }
   
   int pdi_break=0;
   if (adx2_pdi>adx2 && adx_dir==1) {
      pdi_break=2;
   }
   
   int mdi_break=0;
   if (adx2_mdi>adx2 && adx_dir==-1) {
      mdi_break=2;
   }
   
   ret=(adx_lv+pdi_break+mdi_break)*adx_dir;
   
   return ret;
}

//+------------------------------------------------------------------+
//| Trend strategy
//+------------------------------------------------------------------+
int TrendStgValue2(int shift)
{
   int ret=0;
   double adx1=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,shift+2);
   double adx1_pdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_PLUSDI,shift+2);
   double adx1_mdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MINUSDI,shift+2);
   double adx2=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,shift+1);
   double adx2_pdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_PLUSDI,shift+1);
   double adx2_mdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MINUSDI,shift+1);
   double adx3=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,shift);
   double adx3_pdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_PLUSDI,shift);
   double adx3_mdi=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MINUSDI,shift);
   
   double pdi_offset1=MathAbs(adx1_pdi-adx1_mdi);
   double pdi_offset2=MathAbs(adx2_pdi-adx2_mdi);
   double pdi_offset3=MathAbs(adx3_pdi-adx3_mdi);

   int adx_dir=0;
   if (adx2_pdi>adx2_mdi) {
      adx_dir=1;
   }
   if (adx2_pdi<adx2_mdi) {
      adx_dir=-1;
   }

   int pdi_top=0;
   int mdi_top=0;
   if (adx_dir==1) {
      if (adx1_pdi<=(adx2_pdi-adx_thred) && adx2_pdi>=(adx3_pdi+adx_thred)) {
         pdi_top=1;
      }
      if (adx1_mdi>=(adx2_mdi+adx_thred) && adx2_mdi<=(adx3_mdi-adx_thred)) {
         mdi_top=1;
      }
   }

   if (adx_dir==-1) {
      if (adx1_pdi>=(adx2_pdi+adx_thred) && adx2_pdi<=(adx3_pdi-adx_thred)) {
         pdi_top=1;
      }
      if (adx1_mdi<=(adx2_mdi-adx_thred) && adx2_mdi>=(adx3_mdi+adx_thred)) {
         mdi_top=1;
      }
   }
   
   int pdi_mdi_top=0;
   if (pdi_offset1<=pdi_offset2 && pdi_offset2>=pdi_offset3) {
      pdi_mdi_top=1;
   }   
      
   ret=(pdi_top+mdi_top+pdi_mdi_top)*adx_dir;
   
   return ret;
}

//+------------------------------------------------------------------+
//| Time strategy
//| ret/ASIA_PD==1:asia
//| ret/AMA_PD==1:america
//| ret/EUR_PD==1:europa
//+------------------------------------------------------------------+
int TimepdValue(int shift)
{
   int ret=0;

   string t=TimeToStr(Time[shift],TIME_MINUTES);

   //asia
   if (StringCompare(t,a1,true)>=0 && StringCompare(t,a2,true)<0) {
      ret+=ASIA_PD;
   }
   //euro
   if (StringCompare(t,g1,true)>=0 && StringCompare(t,g2,true)<0) {
      ret+=EUR_PD;
   }
   //america
   if (StringCompare(t,u1,true)>=0) {
      ret+=AMA_PD;
   }
   
   return ret;
}
//+------------------------------------------------------------------+
//| Time function
//+------------------------------------------------------------------+
bool isCurPd(string symbol,int shift)
{
   bool ret=false;
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   int pd=TimepdValue(shift);
   
   if (debug) {
      printf("symbo=%s,pd=%d",cur,pd);
   }
   int pd2=(pd/AMA_PD)%2;
   if (pd2==1) return true;
    
   if          (StringCompare(cur,EURUSD)==0) {
      pd2=(pd/EUR_PD)%2;
      if (debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==1) return true;
   } else if   (StringCompare(cur,USDJPY)==0) {
      pd2=(pd/ASIA_PD)%2;
      if (debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==1) return true;
   } else if   (StringCompare(cur,AUDUSD)==0) {
      pd2=(pd/ASIA_PD)%2;
      if (debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==1) return true;
   } else if   (StringCompare(cur,NZDUSD)==0) {
      pd2=(pd/ASIA_PD)%2;
      if (debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==1) return true;
   } else if   (StringCompare(cur,USDCAD)==0) {
   } else if   (StringCompare(cur,GBPUSD)==0) {
      pd2=(pd/EUR_PD)%2;
      if (debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==1) return true;
   } else if   (StringCompare(cur,USDCHF)==0) {
      pd2=(pd/EUR_PD)%2;
      if (debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==1) return true;
   } else if   (StringCompare(cur,XAUUSD)==0) {
   }   
   return false;
}
//+------------------------------------------------------------------+
//| Time strategy
//+------------------------------------------------------------------+
int ATRValue(int shift)
{
   int ret=0;
   double atr=iATR(NULL,PERIOD_CURRENT,10,shift);
   
   if (atr>atr_lvl) ret=1;

   return ret;
}

int news_read()
{
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
      
      ArrayResize(news,cnt);
      cnt=0;
      //move to file's head
      if (FileSeek(h,0,SEEK_SET)) {
         while(!FileIsEnding(h)) {
            news[cnt].n=FileReadNumber(h);
            if(debug) Print(news[cnt].n);
            news[cnt].cur=FileReadString(h);
            if(debug) Print(news[cnt].cur);
            news[cnt].dt=FileReadDatetime(h)-TimeZoneOffset;
            if(debug) Print(news[cnt].dt);
            cnt++;
         }
      }
      
      FileClose(h);
   } else {
      Print("Operation FileOpen failed, error: ",ErrorDescription(GetLastError()));
      FileClose(h);
   }

   return cnt;
}

//+------------------------------------------------------------------+
//| Timer function
//| argSec: timer seconds
//+------------------------------------------------------------------+
bool timer_init(int argSec=0)
{
   if(debug) Print("timer_init");
   if (argSec==0) argSec=TimerSecond;
   bool ret=EventSetTimer(argSec);
   return(ret);  
}

//+------------------------------------------------------------------+
//| Timer function
//+------------------------------------------------------------------+
void timer_deinit()
{
   if(debug) Print("timer_deinit");
   //relase timer
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Time of news function
//+------------------------------------------------------------------+
bool isNewsPd(string symbol,int shift)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;
   
   for (int i=0;i<ArraySize(news);i++) {
      if (StringFind(cur,news[i].cur)>=0) {
         datetime t=Time[shift];
         datetime t2=news[i].dt;
         if (t>=(t2-news_bef) && t<(t2+news_aft)) return true;
      }
   }
   
   return false;
}
//+------------------------------------------------------------------+
//| Time of news function
//+------------------------------------------------------------------+
bool isNewsPd2(string symbol,int shift)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;
   
   for (int i=0;i<ArraySize(news);i++) {
      if (StringFind(cur,news[i].cur)>=0) {
         datetime t=Time[shift];
         datetime t2=news[i].dt;
         if (t>=(t2-60) && t<t2) return true;
      }
   }
   
   return false;
}

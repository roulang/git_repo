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
NewsImpact news[7];
input int news_bef=300;        //5 mins before news
input int news_aft=SEC_H1*1;   //60 mins before news

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

int news_init()
{
   news[0].cur=EURUSD;
   news[0].dt=D'2017.07.17 12:00:00';
   news[1].cur=EURUSD;
   news[1].dt=D'2017.07.17 15:30:00';
   news[2].cur=EURUSD;
   news[2].dt=D'2017.07.18 12:00:00';
   news[3].cur=EURUSD;
   news[3].dt=D'2017.07.18 15:30:00';
   news[4].cur=EURUSD;
   news[4].dt=D'2017.07.19 15:30:00';
   news[5].cur=EURUSD;
   news[5].dt=D'2017.07.20 14:45:00';
   news[6].cur=EURUSD;
   news[6].dt=D'2017.07.20 15:30:00';
   
   return 1;
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
      if (StringCompare(news[i].cur,cur)==0) {
         datetime t=Time[shift];
         datetime t2=news[i].dt;
         if (t>=(t2-news_bef) && t<(t2+news_aft)) return true;
      }
   }
   
   return false;
}
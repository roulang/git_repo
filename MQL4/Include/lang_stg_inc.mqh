//+------------------------------------------------------------------+
//|                                                 lang_stg_inc.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <lang_inc.mqh>

//global
int    g_adx_level=40; //adx level

//each time period
const string u1="16:00";  //usa
const string u2="00:00";  //usa
const string a1="03:00";  //asia
const string a2="11:00";  //asia
const string g1="10:00";  //england
const string g2="18:00";  //england
const  int ASIA_PD = 1;
const  int AMA_PD = 4;
const  int EUR_PD = 2;

//adx
double adx_thred=0.5;

//atr
double atr_lvl=0.0002;

//+------------------------------------------------------------------+
//| Shot shoot strategy
//+------------------------------------------------------------------+
int ShotShootStgValue(int shift)
{
   int tm=getMAPeriod(PERIOD_CURRENT);
   //Print("tm=",tm);
   if (tm==0) {
      return 0;
   }

   int ma_pos=0;  //2 for price above SMA(60),-2 for price below SMA(60)
   int sar_pos=0; //2 for price above SAR(0.02,0.2),-2 for price below SAR(0.02,0.2)
   int ma_break=0;//-1 for SMA(60) from down to up the price,1 for SMA(60) from up to down the price
   int sar_break=0;//-1 for SAR(0.02,0.2) from down to up the price,1 for SAR(0.02,0.2) from up to down the price
   int ret=0;
   double ma1=iMA(NULL,PERIOD_CURRENT,tm,0,MODE_SMA,PRICE_CLOSE,shift+1);
   double ma2=iMA(NULL,PERIOD_CURRENT,tm,0,MODE_SMA,PRICE_CLOSE,shift);
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
   if (adx2>=g_adx_level) {
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
/*
//+------------------------------------------------------------------+
//| Time strategy
//| ret^ASIA_PD==1:asia
//| ret^AMA_PD==4:america
//| ret^EUR_PD==2:europa
//+------------------------------------------------------------------+
int TimepdValue(int arg_shift)
{
   int ret=0;

   string t=TimeToStr(Time[arg_shift],TIME_MINUTES);

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
*/
//+------------------------------------------------------------------+
//| Time function
//+------------------------------------------------------------------+
bool isCurPd(string arg_symbol,int arg_shift,int arg_bef=0,int arg_aft=0)
{
   bool ret=false;
   string cur;
   if (arg_symbol==NULL) cur=Symbol();
   else cur=arg_symbol;

   int pd=TimepdValue2(arg_shift,arg_bef,arg_aft);
   
   if (i_debug) {
      printf("symbo=%s,pd=%d",cur,pd);
   }
   int pd2=pd & AMA_PD;
   if (pd2==AMA_PD) return true;
    
   if          (StringFind(cur,EURUSD)>=0) {
      pd2=pd & EUR_PD;
      if (i_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==EUR_PD) return true;
   } else if   (StringFind(cur,USDJPY)>=0) {
      pd2= pd & ASIA_PD;
      if (i_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==ASIA_PD) return true;
   } else if   (StringFind(cur,AUDUSD)>=0) {
      pd2= pd & ASIA_PD;
      if (i_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==ASIA_PD) return true;
   } else if   (StringFind(cur,NZDUSD)>=0) {
      pd2= pd & ASIA_PD;
      if (i_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==ASIA_PD) return true;
   } else if   (StringFind(cur,USDCAD)>=0) {
   } else if   (StringFind(cur,GBPUSD)>=0) {
      pd2=pd & EUR_PD;
      if (i_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==EUR_PD) return true;
   } else if   (StringFind(cur,USDCHF)>=0) {
      pd2=pd & EUR_PD;
      if (i_debug) {
         printf("pd2=%d",pd2);
      }
      if (pd2==EUR_PD) return true;
   } else if   (StringFind(cur,XAUUSD)>=0 || StringFind(cur,GOLD)>=0) {
   }
   return false;
}
//+------------------------------------------------------------------+
//| Time strategy
//| ret^ASIA_PD==1:asia
//| ret^AMA_PD==4:america
//| ret^EUR_PD==2:europa
//+------------------------------------------------------------------+
int TimepdValue2(int arg_shift,int arg_bef=0,int arg_aft=0)
{
   int ret=0;
   string t=TimeToStr(Time[arg_shift],TIME_MINUTES);

   if (arg_bef==0 && arg_aft==0) {
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
      
   datetime tm0=Time[arg_shift];
   //datetime tm1=Time[arg_shift]+arg_bef;
   datetime tm2=Time[arg_shift]-arg_aft;
   int d0=TimeDay(tm0);
   //int d1=TimeDay(tm1);
   int d2=TimeDay(tm2);

   datetime t0,t1,t2;
   if (d0!=d2) {
      t0=StringToTime(StringConcatenate("2010.10.11 ",t));
   } else {
      t0=StringToTime(StringConcatenate("2010.10.10 ",t));
   }
   
   //asia
   t1=StringToTime(StringConcatenate("2010.10.10 ",a1))-arg_bef;
   t2=StringToTime(StringConcatenate("2010.10.10 ",a2))+arg_aft;
   if (t0>=t1 && t0<t2) {
      //Print("t0=",t0,",t1=",t1,",t2=",t2);
      ret+=ASIA_PD;
   }
   //euro
   t1=StringToTime(StringConcatenate("2010.10.10 ",g1))-arg_bef;
   t2=StringToTime(StringConcatenate("2010.10.10 ",g2))+arg_aft;
   if (t0>=t1 && t0<t2) {
      //Print("t0=",t0,",t1=",t1,",t2=",t2);
      ret+=EUR_PD;
   }
   
   //america
   t1=StringToTime(StringConcatenate("2010.10.10 ",u1))-arg_bef;
   t2=StringToTime(StringConcatenate("2010.10.11 ",u2))+arg_aft;
   if (t0>=t1 && t0<t2) {
      //Print("t0=",t0,",t1=",t1,",t2=",t2);
      ret+=AMA_PD;
   }
   
   return ret;
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

//+------------------------------------------------------------------+
//| Zigzag strategy
//| arg_shift: series
//| arg_deviation: used by zigzag indicator
//| arg_lsp: lose stop price
//| arg_tpp: take profit price
//| arg_thpt: threhold point
//| arg_lst_stupi: last short up shift
//| arg_lst_mdupi: last middle up shift
//| arg_lst_stdwi: last short down shift
//| arg_lst_mddwi: last middle down shift
//| return value: -1,turn down;1:turn up;0:n/a
//+------------------------------------------------------------------+
int getZigTurn(int arg_shift,int arg_deviation_st,int arg_deviation_md,int arg_deviation_lg,int arg_thpt,int &arg_lst_stupi,int &arg_lst_mdupi,int &arg_lst_stdwi,int &arg_lst_mddwi)
{
   int tm=getMAPeriod(PERIOD_CURRENT);
   //Print("tm=",tm);
   if (tm==0) {
      return 0;
   }
   double ma=iMA(NULL,PERIOD_CURRENT,tm,0,MODE_SMA,PRICE_CLOSE,arg_shift);
   
   //filter ma across
   if ((Open[arg_shift]>ma && Close[arg_shift]<ma) || (Open[arg_shift]<ma && Close[arg_shift]>ma))
      return 0;
   
   arg_lst_stupi=arg_lst_mdupi=arg_lst_stdwi=arg_lst_mddwi=0;

   int up_idx=8;
   int dw_idx=9;
   int midup_idx=10;
   int middw_idx=11;
   int zig_idx=15;
   
   int high_shift=0;
   int low_shift=0;
   double high_p=0;
   double low_p=0;
   
   int shortUpShift=0;
   int shortDownShift=0;
   int midUpShift=0;
   int midDownShift=0;
   int shortUpShift2=0;
   int shortDownShift2=0;
   shortUpShift=(int)iCustom(NULL,PERIOD_CURRENT,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,up_idx,arg_shift);
   shortDownShift=(int)iCustom(NULL,PERIOD_CURRENT,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,dw_idx,arg_shift);
   midUpShift=(int)iCustom(NULL,PERIOD_CURRENT,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,midup_idx,arg_shift);
   midDownShift=(int)iCustom(NULL,PERIOD_CURRENT,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,middw_idx,arg_shift);

   bool upSign=false;
   //
   if (shortUpShift>0 && midUpShift>0 && shortUpShift<midUpShift) {
      if (Low[arg_shift+shortUpShift]>Low[arg_shift+midUpShift]) {
         high_shift=iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,midUpShift-shortUpShift-1,arg_shift+shortUpShift+1);
         //high_p=iHigh(NULL,PERIOD_CURRENT,high_shift);
         high_p=High[high_shift];
         upSign=true;
      }
      shortUpShift2=shortUpShift+(int)iCustom(NULL,PERIOD_CURRENT,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,up_idx,arg_shift+shortUpShift);
   }

   bool downSign=false;
   if (shortDownShift>0&& midDownShift>0 && shortDownShift<midDownShift) {
      if (High[arg_shift+shortDownShift]<High[arg_shift+midDownShift]) {
         low_shift=iLowest(NULL,PERIOD_CURRENT,MODE_LOW,midDownShift-shortDownShift-1,arg_shift+shortDownShift+1);
         //low_p=iLow(NULL,PERIOD_CURRENT,low_shift);
         low_p=Low[low_shift];
         downSign=true;
      }
      shortDownShift2=shortDownShift+(int)iCustom(NULL,PERIOD_CURRENT,"lang_zigzag",false,arg_deviation_st,arg_deviation_md,arg_deviation_lg,0,dw_idx,arg_shift+shortDownShift);
   }
   
   if (upSign && shortUpShift2>midUpShift) upSign=true;  //start turn up
   else upSign=false;

   if (downSign && shortDownShift2>midDownShift) downSign=true;   //start turn down
   else downSign=false;
   
   if (upSign && downSign) {
      if (shortUpShift<shortDownShift && midUpShift>midDownShift) downSign=false;
      if (shortDownShift<shortUpShift && midDownShift>midUpShift) upSign=false;
   }
   
   if (i_debug) {
      //Print("shortUpShift=",shortUpShift);
      //Print("midUpShift=",midUpShift);
      //Print("shortUpShift2=",shortUpShift2);
      //Print("shortDownShift=",shortDownShift);
      //Print("midDownShift=",midDownShift);
      //Print("shortDownShift2=",shortDownShift2);
   }

   arg_lst_stupi=shortUpShift;
   arg_lst_mdupi=midUpShift;
   arg_lst_stdwi=shortDownShift;
   arg_lst_mddwi=midDownShift;
   
   if (upSign && !downSign) {
      if (Open[arg_shift]<Close[arg_shift] && Close[arg_shift]>(high_p+arg_thpt*Point)) {
         if (i_debug) {
               Print("arg_shift=",arg_shift);
               Print("shortUpShift=",shortUpShift);
               Print("midUpShift=",midUpShift);
               Print("shortUpShift2=",shortUpShift2);
               Print("shortDownShift=",shortDownShift);
               Print("midDownShift=",midDownShift);
               Print("shortDownShift2=",shortDownShift2);
               Print(Time[arg_shift],",high_shift*=",high_shift-arg_shift,",high_p=",high_p);
         }
         //add ma check
         if (Open[arg_shift]>=ma && Close[arg_shift]>=ma) {
            return 3; 
         } else {
            return 2;
         }
      } else {
         return 1;
      }
   }
   
   if (downSign && !upSign) {
      if (Open[arg_shift]>Close[arg_shift] && Close[arg_shift]<(low_p-arg_thpt*Point)) {
         if (i_debug) {
            Print("arg_shift=",arg_shift);
            Print("shortUpShift=",shortUpShift);
            Print("midUpShift=",midUpShift);
            Print("shortUpShift2=",shortUpShift2);
            Print("shortDownShift=",shortDownShift);
            Print("midDownShift=",midDownShift);
            Print("shortDownShift2=",shortDownShift2);
            Print(Time[arg_shift],",low_shift*=",low_shift-arg_shift,",low_p=",low_p);
         }
         //add ma check
         if (Open[arg_shift]<=ma && Close[arg_shift]<=ma) {
            return -3;
         } else {
            return -2;
         }
      } else {
         return -1;
      }
   }
   
   return 0;
   
}

//+------------------------------------------------------------------+
//| get Moving Average period
//| arg_timeperiod:M1,M5,M15,M30,H1,H4,D1,W1,WN1
//| arg_type:0,short;1,middle;2,long
//+------------------------------------------------------------------+
int getMAPeriod(int arg_timeperiod,int arg_type=0)
{
   int ret=0;
   if (arg_timeperiod==PERIOD_CURRENT) arg_timeperiod=Period();
   switch (arg_type) {
      case 0:
         switch (arg_timeperiod) {
            case PERIOD_M1: 
               ret=60;
               break;
            case PERIOD_M5:
               ret=60;
               break;
            case PERIOD_M15:
               ret=12;
               break;
            case PERIOD_M30:
               ret=12;
               break;
            case PERIOD_H1:
               ret=12;
               break;
            case PERIOD_H4:
               ret=12;
               break;
            case PERIOD_D1:
               ret=10;
               break;
            case PERIOD_W1:
               ret=12;
               break;
            case PERIOD_MN1:
               ret=12;
               break;
            default:
               Print("error on time period");
               break;
         }
         break;
      case 1:
         switch (arg_timeperiod) {
            case PERIOD_M1: 
               ret=60;
               break;
            case PERIOD_M5:
               ret=12;
               break;
            case PERIOD_M15:
               ret=12;
               break;
            case PERIOD_M30:
               ret=12;
               break;
            case PERIOD_H1:
               ret=36;
               break;
            case PERIOD_H4:
               ret=12;
               break;
            case PERIOD_D1:
               ret=10;
               break;
            case PERIOD_W1:
               ret=12;
               break;
            case PERIOD_MN1:
               ret=12;
               break;
            default:
               Print("error on time period");
               break;
         }
         break;
      case 2:
         switch (arg_timeperiod) {
            case PERIOD_M1: 
               ret=60;
               break;
            case PERIOD_M5:
               ret=12;
               break;
            case PERIOD_M15:
               ret=12;
               break;
            case PERIOD_M30:
               ret=12;
               break;
            case PERIOD_H1:
               ret=60;
               break;
            case PERIOD_H4:
               ret=12;
               break;
            case PERIOD_D1:
               ret=10;
               break;
            case PERIOD_W1:
               ret=12;
               break;
            case PERIOD_MN1:
               ret=12;
               break;
            default:
               Print("error on time period");
               break;
         }
         break;
      default:
         Print("arg_type error");
         break;
   }
   
   return ret;
}
void getLargerLastMidUpDw(int arg_period,int arg_shift,double &arg_midup,double &arg_middw)
{
   int up_idx=8;
   int dw_idx=9;
   int midup_idx=10;
   int middw_idx=11;
   int lgup_idx=12;
   int lgdw_idx=13;
   int zig_idx=15;
   
   int midUpShift,midDwShift;
   int larger_shift,larger_pd;
   larger_pd=getLargerPeriod(arg_period,arg_shift,larger_shift);
   midUpShift=(int)iCustom(NULL,larger_pd,"lang_zigzag",false,0,0,0,0,midup_idx,larger_shift);
   midDwShift=(int)iCustom(NULL,larger_pd,"lang_zigzag",false,0,0,0,0,middw_idx,larger_shift);
   arg_midup=iLow(NULL,larger_pd,midUpShift+larger_shift);
   arg_middw=iHigh(NULL,larger_pd,midDwShift+larger_shift);
   
}
void getLastRange(int arg_period,int arg_shift,double &arg_low,double &arg_high,double &arg_low2,double &arg_high2)
{
   int up_idx=8;
   int dw_idx=9;
   int midup_idx=10;
   int middw_idx=11;
   int lgup_idx=12;
   int lgdw_idx=13;
   int bar_shift=arg_shift;
   
   int midUpShift,midDwShift,lgUpShift,lgDwShift;
   midUpShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,midup_idx,bar_shift);
   midDwShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,middw_idx,bar_shift);
   lgUpShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,lgup_idx,bar_shift);
   lgDwShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,lgdw_idx,bar_shift);
   //Print("midUpShift=",midUpShift,",midDwShift=",midDwShift,",lgUpShift=",lgUpShift,",lgDwShift=",lgDwShift);
   
   double midUpPrice,midDwPrice,lgUpPrice,lgDwPrice;
   midUpPrice=iLow(NULL,arg_period,midUpShift+bar_shift);
   midDwPrice=iHigh(NULL,arg_period,midDwShift+bar_shift);
   lgUpPrice=iLow(NULL,arg_period,lgUpShift+bar_shift);
   lgDwPrice=iHigh(NULL,arg_period,lgDwShift+bar_shift);

   double p[8];
   p[0]=midUpPrice;
   p[1]=midDwPrice;
   p[2]=lgUpPrice;
   p[3]=lgDwPrice;
   //Print("p[0]=",p[0],",p[1]=",p[1],",p[2]=",p[2],",p[3]=",p[3]);

   /*
   //larger pd
   int larger_shift,larger_pd;
   larger_pd=getLargerPeriod(arg_period,bar_shift,larger_shift);

   midUpShift=(int)iCustom(NULL,larger_pd,"lang_zigzag",false,0,0,0,0,midup_idx,larger_shift);
   midDwShift=(int)iCustom(NULL,larger_pd,"lang_zigzag",false,0,0,0,0,middw_idx,larger_shift);
   lgUpShift=(int)iCustom(NULL,larger_pd,"lang_zigzag",false,0,0,0,0,lgup_idx,larger_shift);
   lgDwShift=(int)iCustom(NULL,larger_pd,"lang_zigzag",false,0,0,0,0,lgdw_idx,larger_shift);
   //Print("midUpShift=",midUpShift,",midDwShift=",midDwShift,",lgUpShift=",lgUpShift,",lgDwShift=",lgDwShift);

   midUpPrice=iLow(NULL,larger_pd,midUpShift+larger_shift);
   midDwPrice=iHigh(NULL,larger_pd,midDwShift+larger_shift);
   lgUpPrice=iLow(NULL,larger_pd,lgUpShift+larger_shift);
   lgDwPrice=iHigh(NULL,larger_pd,lgDwShift+larger_shift);
   p[4]=midUpPrice;
   p[5]=midDwPrice;
   p[6]=lgUpPrice;
   p[7]=lgDwPrice;
   //Print("p[4]=",p[5],",p[6]=",p[7],",p[4]=",p[5],",p[6]=",p[7]);   
   */
   
   int midUpShift2,midDwShift2,lgUpShift2,lgDwShift2;
   midUpShift2=midUpShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,middw_idx,bar_shift+midUpShift);   
   midDwShift2=midDwShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,middw_idx,bar_shift+midDwShift);
   lgUpShift2=lgUpShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,lgup_idx,bar_shift+lgUpShift);
   lgDwShift2=lgDwShift+(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,lgdw_idx,bar_shift+lgDwShift);

   double midUpPrice2,midDwPrice2,lgUpPrice2,lgDwPrice2;
   midUpPrice2=iLow(NULL,arg_period,midUpShift2+bar_shift);
   midDwPrice2=iHigh(NULL,arg_period,midDwShift2+bar_shift);
   lgUpPrice2=iLow(NULL,arg_period,lgUpShift2+bar_shift);
   lgDwPrice2=iHigh(NULL,arg_period,lgDwShift2+bar_shift);

   p[4]=midUpPrice2;
   p[5]=midDwPrice2;
   p[6]=lgUpPrice2;
   p[7]=lgDwPrice2;
   //Print("p[4]=",p[5],",p[6]=",p[7],",p[4]=",p[5],",p[6]=",p[7]);   
   
   ArraySort(p);
   //Print("p[0]=",p[0],",p[1]=",p[1],",p[2]=",p[2],",p[3]=",p[3]);
   //Print("p[0]=",p[0],",p[1]=",p[1],",p[2]=",p[2],",p[3]=",p[3],"p[4]=",p[4],",p[5]=",p[5],",p[6]=",p[6],",p[7]=",p[7]);
   
   double cur_price=Close[arg_shift];  //not bar_shift
   int    high_i=-1;
   int    low_i=-1;
   //double high_p=0;
   //double low_p=0;
   for (int i=0;i<8;i++) {
      if (cur_price>p[i]) {
         //low_p=p[i];
         low_i=i;
      }
      if (cur_price<p[i]) {
         //high_p=p[i];
         high_i=i;
         break;
      }
   }
   
   //Print("cur_price=",cur_price,",high_p=",high_p,",low_p=",low_p);
   if (low_i>=0) {
      arg_low=p[low_i];
      if (low_i>0) {
         arg_low2=p[low_i-1];
      } else {
         arg_low2=0;
      }
   } else {
      arg_low=0;
      arg_low2=0;
   }
   if (high_i>=0) {
      arg_high=p[high_i];
      if (high_i<7) {
         arg_high2=p[high_i+1];
      } else {
         arg_high2=0;
      }
      
   } else {
      arg_high=0;
      arg_high2=0;
   }
      
}
//+------------------------------------------------------------------+
//| get nearest high and low price (use zigzag middle point)
//| arg_shift: bar shift
//| arg_direction: 1:search for high,-1:search for low,0:both
//| &arg_shift_high: taget high value bar index (minus for low,plus for high)
//| &arg_shift_low: taget low value bar index (minus for high,plus for low)
//+------------------------------------------------------------------+
void getNearestHighLowPrice(double arg_price,int arg_period,int arg_shift,int arg_depth,double &arg_price_high,
                            double &arg_price_low,int &arg_shift_high,int &arg_shift_low,int arg_direction=0)
{
   //double cur_price=Close[arg_shift];
   double cur_price=arg_price;

   int midup_idx=10;
   int middw_idx=11;
   int midUpShift=0;
   int midDwShift=0;
   int bar_shift1,bar_shift2;
   bar_shift1=bar_shift2=arg_shift;
   double midUpPrice,midDwPrice;
   
   double high_price=0;
   double low_price=0;
   for (int i=0;i<arg_depth;i++) {
      midUpShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,midup_idx,bar_shift1);
      midDwShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,middw_idx,bar_shift2);
      bar_shift1+=midUpShift;
      bar_shift2+=midDwShift;
      midUpPrice=iLow(NULL,arg_period,bar_shift1);
      midDwPrice=iHigh(NULL,arg_period,bar_shift2);

      if (midUpPrice>cur_price && midDwPrice>cur_price && high_price==0) {
         if (midUpPrice<=midDwPrice) {
            arg_shift_high=-bar_shift1;
            high_price=midUpPrice;
         } else {
            arg_shift_high=bar_shift2;
            high_price=midDwPrice;
         }
      }
      if (midUpPrice<cur_price && midDwPrice<cur_price && low_price==0) {
         if (midUpPrice>=midDwPrice) {
            arg_shift_low=bar_shift1;
            low_price=midUpPrice;
         } else {
            arg_shift_low=-bar_shift2;
            low_price=midDwPrice;
         }
      }
      
      if (midUpPrice>cur_price && midDwPrice<cur_price) {
         if (high_price==0) {
            arg_shift_high=-bar_shift1;
            high_price=midUpPrice;
         }
         if (low_price==0) {
            arg_shift_low=-bar_shift2;
            low_price=midDwPrice;
         }
      }
      if (midUpPrice<cur_price && midDwPrice>cur_price) {
         if (high_price==0) {
            arg_shift_high=bar_shift2;
            high_price=midDwPrice;
         }
         if (low_price==0) {
            arg_shift_low=bar_shift1;
            low_price=midUpPrice;
         }
      }
      if (high_price!=0 && arg_direction==1) break;
      if (low_price!=0 && arg_direction==-1) break;
      if (high_price!=0 && low_price!=0 && arg_direction==0) break;
   }
   
   arg_price_high=high_price;
   arg_price_low=low_price;
   if (high_price==0) arg_shift_high=0;
   if (low_price==0) arg_shift_low=0;
}
//+------------------------------------------------------------------+
//| get nearest high and low price (use zigzag middle point)
//| arg_shift: bar shift
//| arg_direction: 1:search for high,-1:search for low,0:both
//| &arg_shift_high: taget high value bar index (minus for low,plus for high)
//| &arg_shift_low: taget low value bar index (minus for high,plus for low)
//+------------------------------------------------------------------+
int getNearestHighLowPrice2(double arg_price,int arg_period,int arg_shift,int arg_length,double &arg_price_high,
                            double &arg_price_low,int &arg_shift_high,int &arg_shift_low,int arg_max_depth,
                            int arg_direction=0,int arg_depth=0)
{
   //double cur_price=Close[arg_shift];
   double cur_price=arg_price;

   int depth=arg_depth+1;
   
   int midup_idx=10;
   int middw_idx=11;
   int midUpShift=0;
   int midDwShift=0;
   int bar_shift1,bar_shift2;
   bar_shift1=bar_shift2=arg_shift;
   double midUpPrice,midDwPrice;
   
   double high_price=0;
   double low_price=0;
   for (int i=0;i<arg_length;i++) {
      midUpShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,midup_idx,bar_shift1);
      midDwShift=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,middw_idx,bar_shift2);
      bar_shift1+=midUpShift;
      bar_shift2+=midDwShift;
      midUpPrice=iLow(NULL,arg_period,bar_shift1);
      midDwPrice=iHigh(NULL,arg_period,bar_shift2);

      if (midUpPrice>cur_price && midDwPrice>cur_price && high_price==0) {
         if (midUpPrice<=midDwPrice) {
            arg_shift_high=-bar_shift1;
            high_price=midUpPrice;
         } else {
            arg_shift_high=bar_shift2;
            high_price=midDwPrice;
         }
      }
      if (midUpPrice<cur_price && midDwPrice<cur_price && low_price==0) {
         if (midUpPrice>=midDwPrice) {
            arg_shift_low=bar_shift1;
            low_price=midUpPrice;
         } else {
            arg_shift_low=-bar_shift2;
            low_price=midDwPrice;
         }
      }
      
      if (midUpPrice>cur_price && midDwPrice<cur_price) {
         if (high_price==0) {
            arg_shift_high=-bar_shift1;
            high_price=midUpPrice;
         }
         if (low_price==0) {
            arg_shift_low=-bar_shift2;
            low_price=midDwPrice;
         }
      }
      if (midUpPrice<cur_price && midDwPrice>cur_price) {
         if (high_price==0) {
            arg_shift_high=bar_shift2;
            high_price=midDwPrice;
         }
         if (low_price==0) {
            arg_shift_low=bar_shift1;
            low_price=midUpPrice;
         }
      }
      if (high_price!=0 && arg_direction==1) break;
      if (low_price!=0 && arg_direction==-1) break;
      if (high_price!=0 && low_price!=0 && arg_direction==0) break;
   }

   if (high_price==0) {
      arg_shift_high=0;
      if (arg_direction!=-1)
         Print("Time(high)[",arg_shift,"]=",Time[arg_shift],",period=",arg_period,",depth=",arg_depth);
      if (depth<arg_max_depth && arg_direction!=-1) {
         int larger_pd,larger_shift;
         larger_pd=getLargerPeriod(arg_period,arg_shift,larger_shift);
         if (larger_pd!=0) {
            double range_high,range_low;
            int shift_high,shift_low;
            depth=getNearestHighLowPrice2(arg_price,larger_pd,larger_shift,arg_length,range_high,range_low,shift_high,shift_low,arg_max_depth,1,depth);
            Print("Time2(high)[",shift_high,"]=",iTime(NULL,larger_pd,MathAbs(shift_high)),",range_high=",range_high,",period=",larger_pd);
            if (range_high>0) high_price=range_high;
         }
      }
   }
   if (low_price==0) {
      arg_shift_low=0;
      if (arg_direction!=1)
         Print("Time(low)[",arg_shift,"]=",Time[arg_shift],",period=",arg_period,",depth=",arg_depth);
      if (depth<arg_max_depth && arg_direction!=1) {
         int larger_pd,larger_shift;
         larger_pd=getLargerPeriod(arg_period,arg_shift,larger_shift);
         if (larger_pd!=0) {
            double range_high,range_low;
            int shift_high,shift_low;
            depth=getNearestHighLowPrice2(arg_price,larger_pd,larger_shift,arg_length,range_high,range_low,shift_high,shift_low,arg_max_depth,-1,depth);
            Print("Time2(low)[",shift_low,"]=",iTime(NULL,larger_pd,MathAbs(shift_low)),",range_low=",range_low,",period=",larger_pd);
            if (range_low>0) low_price=range_low;
         }
      }
   }

   arg_price_high=high_price;
   arg_price_low=low_price;
   
   return depth;
}
//+------------------------------------------------------------------+
//| get nearest high and low price (use zigzag middle point)
//| arg_shift: bar shift
//| arg_direction: 1:search for high,-1:search for low,0:both
//| &arg_shift_high: taget high value bar index (minus for low,plus for high)
//| &arg_shift_low: taget low value bar index (minus for high,plus for low)
//+------------------------------------------------------------------+
void getNearestHighLowPrice3(double arg_price,int arg_period,int arg_shift,int arg_length,double &arg_price_high,
                            double &arg_price_low,int &arg_shift_high,int &arg_shift_low,int arg_direction=0,
                            int arg_long=0)
{
   //double cur_price=Close[arg_shift];
   double cur_price=arg_price;

   int up_idx,dw_idx;
   int upShfit=0;
   int dwShfit=0;
   if (arg_long==0) {
      up_idx=10;
      dw_idx=11;
   } else {
      up_idx=12;
      dw_idx=13;
   }
   int bar_shift_up,bar_shift_dw;
   bar_shift_up=bar_shift_dw=arg_shift;
   double upPrice,dwPrice;
   
   double high_price=0;
   double low_price=0;
   for (int i=0;i<arg_length;i++) {
      upShfit=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,up_idx,bar_shift_up);
      dwShfit=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,dw_idx,bar_shift_dw);
      bar_shift_up+=upShfit;
      bar_shift_dw+=dwShfit;
      upPrice=iLow(NULL,arg_period,bar_shift_up);
      dwPrice=iHigh(NULL,arg_period,bar_shift_dw);

      if (upPrice>cur_price && dwPrice>cur_price && high_price==0) {
         if (upPrice<=dwPrice) {
            arg_shift_high=-bar_shift_up;
            high_price=upPrice;
         } else {
            arg_shift_high=bar_shift_dw;
            high_price=dwPrice;
         }
      }
      if (upPrice<cur_price && dwPrice<cur_price && low_price==0) {
         if (upPrice>=dwPrice) {
            arg_shift_low=bar_shift_up;
            low_price=upPrice;
         } else {
            arg_shift_low=-bar_shift_dw;
            low_price=dwPrice;
         }
      }
      
      if (upPrice>cur_price && dwPrice<cur_price) {
         if (high_price==0) {
            arg_shift_high=-bar_shift_up;
            high_price=upPrice;
         }
         if (low_price==0) {
            arg_shift_low=-bar_shift_dw;
            low_price=dwPrice;
         }
      }
      if (upPrice<cur_price && dwPrice>cur_price) {
         if (high_price==0) {
            arg_shift_high=bar_shift_dw;
            high_price=dwPrice;
         }
         if (low_price==0) {
            arg_shift_low=bar_shift_up;
            low_price=upPrice;
         }
      }
      if (high_price!=0 && arg_direction==1) break;
      if (low_price!=0 && arg_direction==-1) break;
      if (high_price!=0 && low_price!=0 && arg_direction==0) break;
   }
   
   arg_price_high=high_price;
   arg_price_low=low_price;
   if (high_price==0) arg_shift_high=0;
   if (low_price==0) arg_shift_low=0;
}
//+------------------------------------------------------------------+
//| get nearest high and low price (use zigzag middle point)
//| arg_shift: bar shift
//| &arg_zig_buf[][]: to store high and low zig value.[0]:time,[1]:value,[2]:shift
//| &arg_high_low[][]: to store last two high and low zig value.four items,
//| 0:second nearest high price,1:nearest high price,2:nearest low price,3:second nearest low price
//| [0]:price,[1]:shift
//+------------------------------------------------------------------+
void getNearestHighLowPrice4 (double arg_price,int arg_period,int arg_shift,int arg_length,
                              double &arg_zig_buf[][],double &arg_high_low[][],
                              int arg_long=0)
{

   //PrintTwoDimArray(arg_zig_buf);

   //double cur_price=Close[arg_shift];
   double cur_price=arg_price;

   int zig_shift_idx;
   int zig_value_idx;
   if (arg_long==0) {
      zig_value_idx=14;
      zig_shift_idx=15;
   } else {
      zig_value_idx=16;
      zig_shift_idx=17;
   }
   int zigShfit=0;
   int bar_shift=arg_shift;
   double zigPrice=0;
   datetime zigTime=0;
   double high_low[][2];   //[0]:price,[1]:shift
   ArrayResize(high_low,arg_length);
   for (int i=0;i<arg_length;i++) {
      zigShfit=(int)iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,zig_shift_idx,bar_shift);
      if (zigShfit==0) break;
      bar_shift+=MathAbs(zigShfit);
      zigTime=Time[bar_shift];
      if (i==0) {
         datetime bufTime=(datetime)arg_zig_buf[0][0];
         if (zigTime==bufTime) {
            for (int j=0;j<arg_length;j++) {
               high_low[j][0]=arg_zig_buf[j][1];
               bufTime=(datetime)arg_zig_buf[j][0];
               high_low[j][1]=iBarShift(NULL,arg_period,bufTime,true);
            }
            break;
         }
      }
      zigPrice=iCustom(NULL,arg_period,"lang_zigzag",false,0,0,0,0,zig_value_idx,bar_shift);
      arg_zig_buf[i][0]=(double)zigTime;
      arg_zig_buf[i][1]=zigPrice;
      high_low[i][0]=zigPrice;
      if (zigShfit>0) {
         high_low[i][1]=bar_shift;
      } else {
         high_low[i][1]=-bar_shift;
      }
      arg_zig_buf[i][2]=high_low[i][1];
   }

   //PrintTwoDimArray(arg_zig_buf);
   
   //PrintTwoDimArray(high_low);
   
   ArraySort(high_low,WHOLE_ARRAY,0,MODE_DESCEND);

   //PrintTwoDimArray(high_low);

   int n=ArrayBsearch(high_low,cur_price,WHOLE_ARRAY,0,MODE_DESCEND);

   /* --memo
   double a[10][2]={{0.5,1},{0.2,2},{0.4,3},{0.7,4},{0.9,5},{1.0,6},{0.51,7},{1.1,8},{0.1,9},{0.05,10}};
   ArraySort(a,WHOLE_ARRAY,0,MODE_DESCEND);
   //(1.1|1.0|0.9|0.7|0.51|0.5|0.4|0.2|0.1|0.05)
   PrintTwoDimArray(a);
   //Print("0.51 is in a[",ArrayBsearch(a,0.51,WHOLE_ARRAY,0,MODE_DESCEND),"]");   //return 4 
   //Print("0.52 is in a[",ArrayBsearch(a,0.52,WHOLE_ARRAY,0,MODE_DESCEND),"]");   //return 3
   //Print("0.69 is in a[",ArrayBsearch(a,0.69,WHOLE_ARRAY,0,MODE_DESCEND),"]");   //return 3
   //Print("1.2 is in a[",ArrayBsearch(a,1.2,WHOLE_ARRAY,0,MODE_DESCEND),"]");     //return 0
   //Print("1.05 is in a[",ArrayBsearch(a,1.05,WHOLE_ARRAY,0,MODE_DESCEND),"]");   //return 0
   //Print("0.04 is in a[",ArrayBsearch(a,0.04,WHOLE_ARRAY,0,MODE_DESCEND),"]");   //return 9
   //Print("0.06 is in a[",ArrayBsearch(a,0.06,WHOLE_ARRAY,0,MODE_DESCEND),"]");   //return 8
   */
   
   if (n==0) {
      if (high_low[0][0]<cur_price) {
         arg_high_low[0][0]=0;                  //second nearest high price
         arg_high_low[0][1]=0;                  //second nearest high price's shift
         arg_high_low[1][0]=0;                  //nearest high price
         arg_high_low[1][1]=0;                  //nearest high price's shift
         if (high_low[0][0]>0) {
            arg_high_low[2][0]=high_low[0][0];  //nearest low price
            arg_high_low[2][1]=high_low[0][1];  //nearest low price's shift
         } else {
            arg_high_low[2][0]=0;
            arg_high_low[2][1]=0;
         }
         if (high_low[1][0]>0) {
            arg_high_low[3][0]=high_low[1][0];  //second nearest low price
            arg_high_low[3][1]=high_low[1][1];  //second nearest low price's shift
         } else {
            arg_high_low[3][0]=0;
            arg_high_low[3][1]=0;
         }
      } else {
         arg_high_low[0][0]=0;                  //second nearest high price
         arg_high_low[0][1]=0;                  //second nearest high price's shift
         if (high_low[0][0]>0) {
            arg_high_low[1][0]=high_low[0][0];  //nearest high price
            arg_high_low[1][1]=high_low[0][1];  //nearest high price's shift
         } else {
            arg_high_low[1][0]=0;
            arg_high_low[1][1]=0;
         }
         if (high_low[1][0]>0) {
            arg_high_low[2][0]=high_low[1][0];  //nearest low price
            arg_high_low[2][1]=high_low[1][1];  //nearest low price's shift
         } else {
            arg_high_low[2][0]=0;
            arg_high_low[2][1]=0;
         }
         if (high_low[2][0]>0) {
            arg_high_low[3][0]=high_low[2][0];  //second nearest low price
            arg_high_low[3][1]=high_low[2][1];  //second nearest low price's shift
         } else {
            arg_high_low[3][0]=0;
            arg_high_low[3][1]=0;
         }
      }
      return;
   }
   
   //n>0
   int st=n-1;
   for (int i=0;i<4;i++) {
      if (st<arg_length && high_low[st][0]>0) {
         arg_high_low[i][0]=high_low[st][0];
         arg_high_low[i][1]=high_low[st][1];
      } else {
         arg_high_low[i][0]=0;
         arg_high_low[i][1]=0;
      }
      st++;
   }

}
//+------------------------------------------------------------------+
//| Trend strategy Open (use ma)
//| date: 2017/08/31
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: -1,sell(open);1:buy(open);0:n/a
//+------------------------------------------------------------------+
int isTrendStgOpen(int arg_shift,double &arg_ls_price)
{
   int short_tm=getMAPeriod(PERIOD_CURRENT,0);  //short
   if (short_tm==0) {
      return 0;
   }
   int middle_tm=getMAPeriod(PERIOD_CURRENT,1);  //middle
   //Print("tm=",tm);
   if (middle_tm==0) {
      return 0;
   }
   double short_ma1=iMA(NULL,PERIOD_CURRENT,short_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift);
   double short_ma2=iMA(NULL,PERIOD_CURRENT,short_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift+1);
   double middle_ma1=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift);
   double middle_ma2=iMA(NULL,PERIOD_CURRENT,middle_tm,0,MODE_EMA,PRICE_CLOSE,arg_shift+1);
   if (short_ma1>middle_ma1 && short_ma2<middle_ma2) {   //EMA12>EMA36,for up trend
      if (Close[arg_shift]>Open[arg_shift] && Close[arg_shift]>short_ma1) {   //break EMA12
         arg_ls_price=NormalizeDouble(middle_ma1,Digits);
         return 1;
      }
      return 0;
   }
   if (short_ma1<middle_ma1 && short_ma2>middle_ma2) {   //EMA12<EMA36,for down trend
      if (Close[arg_shift]<Open[arg_shift] && Close[arg_shift]<short_ma1) {   //break EMA12
         arg_ls_price=NormalizeDouble(middle_ma1,Digits);
         return -1;
      }
      return 0;
   }

   return 0;
}
//+------------------------------------------------------------------+
//| Trend strategy Close (use adx)
//| date: 2017/08/31
//| return value: 2:close(all);1:close(sell);-1:close(buy);0:n/a
//+------------------------------------------------------------------+
int isTrendStgClose(int arg_shift,int arg_period=PERIOD_CURRENT)
{
   double adx1=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MAIN,arg_shift);
   double adx2=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MAIN,arg_shift+1);
   double adx3=iADX(NULL,arg_period,14,PRICE_CLOSE,MODE_MAIN,arg_shift+2);
   if (adx1<g_adx_level && (adx2>g_adx_level || adx3>g_adx_level)) return 1;
   return 0;
}
//+------------------------------------------------------------------+
//| Break and Bounce Open (use zigzag)
//| date: 2017/09/11
//| arg_shift: bar shift
//| arg_thpt:threahold point
//| return value: +2,up break;-2,down break;+1,bounce up;-1,bounce down;0:n/a
//+------------------------------------------------------------------+
int isBreak_Bounce_Open(int arg_shift,int arg_thpt)
{
   double range_low,range_high,range_low2,range_high2;
   getLastRange(PERIOD_CURRENT,arg_shift,range_low,range_high,range_low2,range_high2);
   //Print("range_low=",range_low,",range_high=",range_high,",range_low2=",range_low2,",range_high2=",range_high2);
   
   double break_offset=arg_thpt*Point;
   
   if (High[arg_shift]>range_high) {   //break up
      if (Close[arg_shift]>(range_high+break_offset)) {  //up break
         Print("Close=",Close[arg_shift],",high=",range_high+break_offset);
         return 2;
      }
      if (Close[arg_shift]<(range_high)) return -1;      //bounce down
   }
   if (Close[arg_shift]<range_low) {   //break down
      if (Close[arg_shift]<(range_low-break_offset)) {   //down break
         Print("Close=",Close[arg_shift],",low=",range_low-break_offset);
         return -2;
      }
      if (Close[arg_shift]>(range_low)) return 1;        //bounce up
   }
   return 0;
}
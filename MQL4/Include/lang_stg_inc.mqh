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
//+------------------------------------------------------------------+
//| Trend strategy Open/Close
//| date: 2017/08/31
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: -1,sell(open);1:buy(open);1:close;0:n/a
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
//| Trend strategy Close
//| date: 2017/08/31
//| return value: 1:close;0:n/a
//+------------------------------------------------------------------+
int isTrendStgClose(int arg_shift)
{
   double adx1=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,arg_shift);
   double adx2=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,arg_shift+1);
   double adx3=iADX(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,MODE_MAIN,arg_shift+1);
   if (adx1<g_adx_level && (adx2>g_adx_level || adx3>g_adx_level)) return 1;
   return 0;
}
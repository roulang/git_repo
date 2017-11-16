//+------------------------------------------------------------------+
//|                                                 lang_stg_inc.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <lang_ind_inc.mqh>

//global
int    g_adx_level=40; //adx level

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
   
   if (g_debug) {
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
         if (g_debug) {
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
         if (g_debug) {
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
//| Hit point break or rebound
//| date: 2017/10/19
//| arg_shift: bar shift
//| arg_thpt:threahold point
//| return value: break(up),+2;break(down),-2;rebound(up),1;rebound(down),-1;0:n/a
//+------------------------------------------------------------------+
int isBreak_Rebound(int arg_shift,int arg_thpt,int arg_lengh,double &arg_zig_buf[][],double &arg_high_low[][],
                                 double &arg_pivot_buf[],int &arg_pivot_shift,int &arg_larger_shift,int &arg_touch_status[],
                                 double &arg_high_gap,double &arg_low_gap,double &arg_high_low_gap,
                                 int arg_expand=0,int arg_thpt2=0,int arg_long=1,int arg_pivot=1)
{
   int ret=0;
   ret=getHighLowTouchStatus(arg_shift,arg_thpt,arg_lengh,arg_zig_buf,arg_high_low,arg_pivot_buf,arg_pivot_shift,
                                 arg_larger_shift,arg_touch_status,arg_high_gap,arg_low_gap,arg_high_low_gap,
                                 arg_expand,arg_long,arg_pivot);
   
   if (ret==0) return 0;
   
   int touch_high,touch_sub_high,touch_low,touch_sub_low,bar_status;
   touch_high=touch_sub_high=touch_low=touch_sub_low=bar_status=0;
   if (ret>0) {   //hit high
      touch_sub_high=MathAbs(arg_touch_status[1]);
      if (arg_touch_status[1]>0) bar_status=1;
      else bar_status=-1;
   }
   if (ret<0) {   //hit low
      touch_sub_low=MathAbs(arg_touch_status[2]);
      if (arg_touch_status[2]>0) bar_status=1;
      else bar_status=-1;
   }
   touch_high=MathAbs(arg_touch_status[0]);
   touch_low=MathAbs(arg_touch_status[3]);
   
   int ma_status=getMAStatus(PERIOD_CURRENT,arg_shift);
   if (ma_status==0) return 0;
   
   double threhold_gap=arg_thpt2*Point;
   
   if(arg_high_low_gap<=(2*threhold_gap)) return 0;   //filter too small high_low_gap
   
   if (touch_sub_high>0 && touch_high>0) {   //hit sub_high and high both
      return 2;   //break(up)
   }
   if (touch_sub_low>0 && touch_low>0) {     //hit sub_low and low both
      return -2;   //break(down)
   }
   if (touch_sub_high>1 && bar_status>0 && arg_high_gap>threhold_gap) {   //hit sub_high only,body touch sub_high,positive bar
      return 2;   //break(up)
   }
   if (touch_sub_low>1 && bar_status<0 && arg_low_gap>threhold_gap) {    //hit sub_low only,body touch sub_low,negative bar
      return -2;  //break(down)
   }
   if (touch_sub_high==1) {   //hit sub_high only
      return -1;  //rebound(down)
   }
   if (touch_sub_low==1) {    //hit sub_low only
      return 1;  //rebound(up)
   }
   
   //unknown
   return 0;
}

//+------------------------------------------------------------------+
//| Hit point break or rebound (use high_low_touch indicator)
//| date: 2017/11/6
//| arg_shift: bar shift
//| arg_thpt:threahold point
//| return value: touch(high),+1;touch(down),-1;break(up),+2;break(down),-2;rebound(up),1;rebound(down),-1;0:n/a
//+------------------------------------------------------------------+
int isBreak_Rebound2(int arg_shift,double &arg_last_range_high,double &arg_last_range_low,
                     int &arg_last_range_high_low_gap_pt,int &arg_last_range_high_gap_pt,int &arg_last_range_low_gap_pt,
                     int arg_length=20,int arg_th_pt=10,int arg_expand=1,int arg_oc_gap_pt=10,
                     int arg_high_low_gap_pt=200,int arg_high_gap_pt2=50)
{
   string t1=TimeToStr(Time[arg_shift],TIME_DATE);
   string t2=TimeToStr(Time[arg_shift],TIME_MINUTES);
   string t=StringConcatenate("[",t1," ",t2,"]");

   double oc_gap=Open[arg_shift]-Close[arg_shift];
   int oc_gap_pt=(int)NormalizeDouble(MathAbs(oc_gap)/Point,0);
   
   if (g_debug) {
      Print("oc_gap_pt=",oc_gap_pt);
   }
   
   int bar_status=0;
   if (oc_gap>0) bar_status=1;   //1 for negative bar(open>close)
   
   int touch_idx=0;
   int cur_high_low_touch=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,1,arg_length,arg_th_pt,arg_expand,touch_idx,arg_shift);       //nearest
   int cur_high_low_touch2=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,0,arg_length,arg_th_pt,arg_expand,touch_idx,arg_shift);      //second nearest
   int last_bar_shift=arg_shift+1;
   int lst_high_low_touch=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,1,arg_length,arg_th_pt,arg_expand,touch_idx,last_bar_shift);  //nearest
   int lst_high_low_touch2=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,0,arg_length,arg_th_pt,arg_expand,touch_idx,last_bar_shift); //second nearest
   
   if (g_debug) {
      Print("cur_high_low_touch=",cur_high_low_touch,",cur_high_low_touch2=",cur_high_low_touch2);
      Print("lst_high_low_touch=",lst_high_low_touch,",lst_high_low_touch2=",lst_high_low_touch2);
   }
      
   int low_idx=0;
   int high_idx=1;
   int low2_idx=2;
   int high2_idx=3;
   int high_gap_idx=8;
   int low_gap_idx=9;
   int high_low_gap_idx=10;

   double last_range_high=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_idx,last_bar_shift);
   double last_range_high2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high2_idx,last_bar_shift);
   double last_range_low=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_idx,last_bar_shift);
   double last_range_low2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low2_idx,last_bar_shift);
   int last_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_gap_idx,last_bar_shift);
   int last_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_gap_idx,last_bar_shift);
   int last_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_low_gap_idx,last_bar_shift);

   double cur_range_high=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_idx,arg_shift);
   double cur_range_high2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high2_idx,arg_shift);
   double cur_range_low=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_idx,arg_shift);
   double cur_range_low2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low2_idx,arg_shift);
   int cur_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_gap_idx,arg_shift);
   int cur_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_gap_idx,arg_shift);
   int cur_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_low_gap_idx,arg_shift);

   int high_low_change=0;
   if (cur_range_high!=last_range_high || cur_range_low!=last_range_low) {
      if (cur_range_high>last_range_high && cur_range_low>=last_range_low) {
         high_low_change=1;   //range up
      }
      if (cur_range_low<last_range_low && cur_range_high<=last_range_high) {
         high_low_change=-1;   //range down
      }
   }
   int high_low_change2=0;
   if (cur_range_high2!=last_range_high2 || cur_range_low2!=last_range_low2) {
      if (cur_range_high2>last_range_high2 && cur_range_low2>=last_range_low2) {
         high_low_change2=1;   //range up
      }
      if (cur_range_low2<last_range_low2 && cur_range_high2<=last_range_high2) {
         high_low_change2=-1;   //range down
      }
   }

   if (g_debug) {
      Print("cur_range_high=",cur_range_high,",cur_range_high2=",cur_range_high2);
      Print("cur_range_low=",cur_range_low,",cur_range_low2=",cur_range_low2);
      Print("cur_high_gap_pt=",cur_high_gap_pt,",cur_low_gap_pt=",cur_low_gap_pt,",cur_high_low_gap_pt=",cur_high_low_gap_pt);
      Print("last_range_high=",last_range_high,",last_range_high2=",last_range_high2);
      Print("last_range_low=",last_range_low,",last_range_low2=",last_range_low2);
      Print("last_high_gap_pt=",last_high_gap_pt,",last_low_gap_pt=",last_low_gap_pt,",last_high_low_gap_pt=",last_high_low_gap_pt);
      Print("high_low_change=",high_low_change,",high_low_change2=",high_low_change2);
   }

   if (high_low_change==0 && lst_high_low_touch==0 && cur_high_low_touch==0) {   //no signal
      Print(t,"no signal");
      return 0;
   }
   
   if (cur_high_low_gap_pt<arg_high_low_gap_pt) {     //high low gap is too narrow
      Print(t,"high low gap is too narrow(<",arg_high_low_gap_pt,")");
      return 0;
   }
   
   int ret=0;
   
   if (ret==0) {
      //break(up)
      if (high_low_change==1 && lst_high_low_touch>=0 && cur_high_low_touch>1) {     //high_low_change up
         if (bar_status==0) {       //positive bar
            if (g_debug) Print(t,"high_low_change up,positive bar,+3");
            ret=3;
         }
      }
      //break(down)
      if (high_low_change==-1 && lst_high_low_touch<=0 && cur_high_low_touch<-1) {    //high_low_change down
         if (bar_status==1) {       //negative bar
            if (g_debug) Print(t,"high_low_change down,negative bar,-3");
            ret=-3;
         }
      }
   }
   
   if (ret==0) {
      //rebound(down)
      if (high_low_change==0 && lst_high_low_touch==0 && cur_high_low_touch==1) {     //hit high,turn down,nagetive bar
         if (g_debug) Print(t,"hit high,turn down,nagetive bar,-2");
         ret=-2;
      }
      /*
      if (high_low_change==0 && lst_high_low_touch==1 && cur_high_low_touch==0) {     //hit high,turn down,more strong
         Print(t,"hit high,turn down,more strong,-2");
         ret=-2;
      }
      */
   }

   if (ret==0) {
      //rebound(up)
      if (high_low_change==0 && lst_high_low_touch==0 && cur_high_low_touch==-1) {    //hit low,turn up,positive bar
         if (g_debug) Print(t,"hit low,turn up,positive bar,+2");
         ret=2;
      }
      /*
      if (high_low_change==0 && lst_high_low_touch==-1 && cur_high_low_touch==0) {    //hit low,turn up,more strong
         Print(t,"hit low,turn up,more strong,+2");
         ret=2;
      }
      */
   }
      
   if (ret==0) {
      //break(up)
      if (cur_high_low_touch>1 && lst_high_low_touch>=0 && bar_status==0) {      //break high,positive bar,up
         if (cur_high_low_touch2>1) {  //break second high
            if (g_debug) Print(t,"break high,positive bar,break second high,+3");
            ret=3;
         } else 
         if (last_high_gap_pt>=arg_high_gap_pt2) {
            if (g_debug) Print(t,"break high,positive bar,+3");
            ret=3;
         } else {
            Print(t,"break high,positive bar,but high_gap is too narrow");
         }
      }
      /*
      if (lst_high_low_touch>1 && cur_high_low_touch>1 && bar_status==0) {      //break high(two bars),positive bar,up
         if (last_high_gap_pt>=arg_high_gap_pt2) {
            Print(t,"break high(two bars),positive bar,+3");
            ret=3;
         } else {
            Print(t,"break high(two bars),positive bar,but high_gap is too narrow");
         }
         if (cur_high_low_touch2>1) {  //break second high
            Print(t,"break high(two bars),positive bar,break second high,+3");
            ret=3;
         }
      }
      */
   }
   
   if (ret==0) {
      //break(down)
      if (cur_high_low_touch<-1 && lst_high_low_touch<=0 && bar_status==1) {     //break low,negative bar,down
         if (cur_high_low_touch2<-1) {  //break second low
            if (g_debug) Print(t,"break low,negative bar,break second low,-3");
            ret=-3;
         } else 
         if (last_high_gap_pt>=arg_high_gap_pt2) {
            if (g_debug) Print(t,"break low,negative bar,-3");
            ret=-3;
         } else {
            Print(t,"break low,negative bar,but low_gap is too narrow");
         }
      }
      /*
      if (lst_high_low_touch<-1 && cur_high_low_touch<-1 && bar_status==0) {      //break low(two bars),negative bar,down
         if (last_high_gap_pt>=arg_high_gap_pt2) {
            Print(t,"break low(two bars),negative bar,-3");
            ret=-3;
         } else {
            Print(t,"break low(two bars),negative bar,but low_gap is too narrow");
         }
         if (cur_high_low_touch2<-1) {  //break second low
            Print(t,"break low(two bars),negative bar,break second low,-3");
            ret=-3;
         }
      }
      */
   }

   //add ma condition
   int cur_ma_status=getMAStatus(PERIOD_CURRENT,arg_shift);
   /*  
   if (cur_ma_status==0) {    //ma status is 0
      Print(t,"ma status is 0,0");
      return 0;
   }
   */
   if (ret==3) {     //break up
      if (cur_ma_status<=0) {    //ma is down
         Print(t,"break up,but ma is down,0");
         ret=0;
      }
   }
   if (ret==-3) {    //break down
      if (cur_ma_status>=0) {    //ma is up
         Print(t,"break down,but ma is up,0");
         ret=0;
      }
   }

   if (MathAbs(ret)==3) {     //break up or break down
      if (oc_gap_pt<=arg_oc_gap_pt) {  //open close gap is too narrow
         Print(t,"open close gap is too narrow(<=",arg_oc_gap_pt,"pt)");
         ret=0;
      }
   }
   
   if (ret==0) {     //final
      if (cur_high_low_touch>0) {   //only touch high(can notify by email)
         Print(t,"final,only touch high,+1");
         ret=1;
      }
      if (cur_high_low_touch<0) {   //only touch low(can notify by email)
         Print(t,"final,only touch low,-1");
         ret=-1;
      }
   }
   
   arg_last_range_high=last_range_high;
   arg_last_range_low=last_range_low;
   arg_last_range_high_low_gap_pt=last_high_low_gap_pt;
   arg_last_range_high_gap_pt=last_high_gap_pt;
   arg_last_range_low_gap_pt=last_low_gap_pt;
   
   return ret;
}
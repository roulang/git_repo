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

//+------------------------------------------------------------------+
// getVolume: get risk volume
// ep: equity percent. ex,1=1%,2=2% (0 for not set, use )
// ls_point: Loss Stop Point
//+------------------------------------------------------------------+
double getVolume(int ep, double ls_point)
{
   double risk_amount = AccountEquity() * ep / 100;
   double tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);
   if (tick_value == 0) return 1;
   double volume = risk_amount / (ls_point * tick_value);
   volume = NormalizeDouble(volume, 2);
   
   //<<<<debug
   if (g_debug) {
      Print("<<<<debug");
      printf("risk amount=%.5f", risk_amount);
      printf("tick value=%.5f", tick_value);
      printf("volume=%.5f", volume);
      Print("debug>>>>");
   }
   //debug>>>>
   return volume;
   
}

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
int getAtrValue(int arg_shift,double arg_lvl=0.0005,int arg_range=10)
{
   int ret=0;
   double atr=iATR(NULL,PERIOD_CURRENT,arg_range,arg_shift);
   
   if (atr>arg_lvl) ret=1;

   return ret;
}

//+------------------------------------------------------------------+
//| Trend strategy Open (use ma)
//| date: 2017/12/19
//| arg_shift: bar shift
//| arg_last_cross: 1,fast ma up cross slow ma;-1,fast ma down cross slow ma
//| &arg_ls_price: lose stop price(for return)
//| return value: -2,sell(open);2,buy(open);-1,fast ma down cross slow ma;1,fast ma up cross slow ma;0:n/a
//+------------------------------------------------------------------+
int isTrendStgOpen(int arg_shift,int &arg_last_cross,double &arg_ls_price)
{
   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   
   int cur_touch_status[2];
   double cur_short_ma,cur_middle_ma;
   int cur_ret=getMAStatus2(PERIOD_CURRENT,cur_bar_shift,cur_touch_status,cur_short_ma,cur_middle_ma);

   int lst_touch_status[2];
   double lst_short_ma,lst_middle_ma;
   int lst_ret=getMAStatus2(PERIOD_CURRENT,lst_bar_shift,lst_touch_status,lst_short_ma,lst_middle_ma);

   arg_ls_price=cur_middle_ma;
   
//| ret
//| return value: short>mid,same direction,up,5;
//|               short>mid,different direction(short down,mid up),4;
//|               short>mid,different direction(short up,mid down),3;
//|               short>mid,same direction(short down,mid down),2;
//|               short>mid,no direction(short down,mid down),1;
//| return value: short<mid,same direction,down,-5;
//|               short<mid,different direction(short up,mid down),-4;
//|               short<mid,different direction(short down,mid up),-3;
//|               short<mid,same direction(short up,mid up),-2;
//|               short<mid,no direction(short down,mid down),-1;
//|               n/a:0
//| return value: short break mid,up(within last 2 bars):+10
//|               short break mid,down(within last 2 bars):-10

   /*
   if (arg_last_cross==0 && arg_last_ma_cross_shift>0) {   //search the last cross bar shift and ma touch count
      if (cur_ret>=10 || cur_ret<=-10) {
         arg_last_ma_cross_shift=cur_bar_shift;
         arg_last_ma_touch_cnt=0;
      } else if (cur_ret!=0) {
         for (int i=1;i<100;i++) {
            int bar_shift=cur_bar_shift+i;
            int bar_shift2=bar_shift+1;
            int touch_status[2];
            double short_ma,middle_ma;
            int ret=getMAStatus2(PERIOD_CURRENT,bar_shift,touch_status,short_ma,middle_ma);
            int touch_status2[2];
            double short_ma2,middle_ma2;
            int ret2=getMAStatus2(PERIOD_CURRENT,bar_shift2,touch_status2,short_ma2,middle_ma2);

            int short_ma_touch=touch_status[0];
            int middle_ma_touch=touch_status[1];
            int short_ma_touch2=touch_status2[0];
            int middle_ma_touch2=touch_status2[1];

            if ((cur_ret>0 && ret>=10) || (cur_ret<0 && ret<=-10)) {
               arg_last_ma_cross_shift=bar_shift;
               break;
            }
            
            if (cur_ret>0 && (ret==4 || ret==5)) {    //short ma is above mid ma,mid ma is up
               if (short_ma_touch==3) {               //current bar is positive and under touch short ma
                  if (MathAbs(short_ma_touch2)>=3) {  //last bar is above or under touch short ma
                     arg_last_ma_touch_cnt+=1;
                  }
               }
            }
            if (cur_ret<0 && (ret==-4 || ret==-5)) {  //short ma is below mid ma,mid ma is down
               if (short_ma_touch==-1) {              //current bar is negative and high touch short ma
                  if (MathAbs(short_ma_touch2)<=1) {  //last bar is below or high touch short ma
                     arg_last_ma_touch_cnt+=1;
                  }
               }
            }
         }
      }
   }
   */
   
   if (cur_ret>=10 && arg_last_cross!=1) {   //short ma up cross mid ma
      arg_last_cross=1;
      return 1;
   }
   if (cur_ret<=-10 && arg_last_cross!=-1) {   //short ma down cross mid ma
      arg_last_cross=-1;
      return -1;
   }

   int ret=0;   
   
//| touch status
//| ->see below
//| <<ma line>>
//|     (above) 0
//|  |  (high)  1
//| [ ] (open)  2
//| [ ] (close) 2
//|  |  (low)   3
//|     (below) 4

   int cur_short_ma_touch=cur_touch_status[0];
   int cur_middle_ma_touch=cur_touch_status[1];
   int lst_short_ma_touch=lst_touch_status[0];
   int lst_middle_ma_touch=lst_touch_status[1];

   if (arg_last_cross==1) {                        //fast ma up cross slow ma
      //if (cur_ret==4 || cur_ret==5) {              //short ma is above mid ma,mid ma is up
      if (cur_ret==5) {                            //short ma is above mid ma,short/mid ma is up
         if (cur_short_ma_touch==3) {              //current bar is positive and under touch short ma
            if (MathAbs(lst_short_ma_touch)>=3) {  //last bar is above or under touch short ma
               ret=2;
            }
         }
      }
   }
   if (arg_last_cross==-1) {                       //fast ma down cross slow ma
      //if (cur_ret==-4 || cur_ret==-5) {            //short ma is below mid ma,mid ma is down
      if (cur_ret==-5) {                           //short ma is below mid ma,short/mid ma is down
         if (cur_short_ma_touch==-1) {             //current bar is negative and high touch short ma
            if (MathAbs(lst_short_ma_touch)<=1) {  //last bar is below or high touch short ma
               ret=-2;
            }
         }
      }
   }
   /*
   if (MathAbs(arg_last_cross)==1) {               //has crossed
      if (MathAbs(cur_middle_ma_touch)==2) {       //current bar is crossing middle ma
         arg_last_cross=0;
         return 1;                                 //close all
      }
   }
   */

   //add zigturn
   int lst_short_low_sht=0,lst_mid_low_sht=0,lst_short_high_sht=0,lst_mid_high_sht=0;
   int cur_pd=PERIOD_CURRENT;
   int zt1=getZigTurn2(cur_pd,cur_bar_shift,lst_short_low_sht,lst_mid_low_sht,lst_short_high_sht,lst_mid_high_sht);
   int exp_bar_shift;
   int exp_pd=expandPeriod(PERIOD_CURRENT,cur_bar_shift,exp_bar_shift,0);
   int zt2=getZigTurn2(exp_pd,exp_bar_shift,lst_short_low_sht,lst_mid_low_sht,lst_short_high_sht,lst_mid_high_sht);

   if (MathAbs(ret)==2) {
      if (ret>0 && zt1>=0 && zt2>=1) ret += 1;
      if (ret<0 && zt1<=0 && zt2<=-1) ret -= 1;
   }

   return ret;
}

//+------------------------------------------------------------------+
//| Trend strategy Close (use adx)
//| date: 2017/12/26
//| arg_last_adx_status: 1,above 40(default);-1,below 40(default);0,N/A
//| return value: 1:close(buy/sell)
//+------------------------------------------------------------------+
int isTrendStgClose(int arg_shift,int &arg_last_adx_status,int arg_period=PERIOD_CURRENT)
{

   int cur_bar_shift=arg_shift;

   int ret=0;
   int adx_level=0;
   int adx_cross=0;  //1 for up cross,-1 for down cross
   
   int adx_status=getADXStatus(arg_period,cur_bar_shift,adx_level);
   if (adx_level==0) {     //adx is below 40
      if (arg_last_adx_status==0) {
         arg_last_adx_status=-1;
      } else {
         if (arg_last_adx_status==1) {   //down cross 40(default)
            adx_cross=-1;
            arg_last_adx_status=-1;
         }
      }
   }
   if (adx_level==1) {     //adx is above 40
      if (arg_last_adx_status==0) {
         arg_last_adx_status=1;
      } else {
         if (arg_last_adx_status==-1) {   //up cross 40(default)
            adx_cross=1;
            arg_last_adx_status=1;
         }
      }
   }
   
   //if (adx_status>=2) ret=1;     //adx is top in up trend, close buy
   //if (adx_status<=-2) ret=-1;   //adx is top in down trend, close sell
   //if (adx_cross==-1 && adx_status>0) ret=1; //adx is down cross 40 in the up trend, close buy
   //if (adx_cross==-1 && adx_status<0) ret=-1; //adx is down cross 40 in the down trend, close sell
   if (adx_cross==-1) ret=1;

   if (ret==0) {
      int cur_touch_status[2];
      double cur_short_ma,cur_middle_ma;
      int cur_ret=getMAStatus2(PERIOD_CURRENT,cur_bar_shift,cur_touch_status,cur_short_ma,cur_middle_ma);
      int cur_short_ma_touch=cur_touch_status[0];
      int cur_middle_ma_touch=cur_touch_status[1];

      //| return value: short>mid,same direction,up,5;
      //|               short>mid,different direction(short down,mid up),4;
      //|               short>mid,different direction(short up,mid down),3;
      //|               short>mid,same direction(short down,mid down),2;
      //|               short>mid,no direction(short down,mid down),1;
      //| return value: short<mid,same direction,down,-5;
      //|               short<mid,different direction(short up,mid down),-4;
      //|               short<mid,different direction(short down,mid up),-3;
      //|               short<mid,same direction(short up,mid up),-2;
      //|               short<mid,no direction(short down,mid down),-1;
      //|               n/a:0
      //| return value: short break mid,up(within last 2 bars):+10
      //|               short break mid,down(within last 2 bars):-10

      //| touch status
      //| ->see below
      //| <<ma line>>
      //|     (above) 0
      //|  |  (high)  1
      //| [ ] (open)  2
      //| [ ] (close) 2
      //|  |  (low)   3
      //|     (below) 4
      //| plus for positive bar(include nutual bar),minus for nagative bar.
      if (MathAbs(cur_middle_ma_touch)==2) {
         ret=-1;
      }
   }
      
   return ret;
}

//+------------------------------------------------------------------+
//| Hit point break (use high_low_touch indicator)
//| date: 2017/11/22
//| arg_shift: bar shift
//| arg_thpt:threahold point
//| return value: break(high),+1;break(low),-1;0:n/a
//+------------------------------------------------------------------+
int isBreak(int arg_shift,double &arg_last_range_high,double &arg_last_range_low,
            int &arg_last_range_high_low_gap_pt,int &arg_last_range_high_gap_pt,int &arg_last_range_low_gap_pt,
            int arg_length=20,int arg_th_pt=10,int arg_expand=1,int arg_oc_gap_pt=10,
            int arg_high_low_gap_pt=200,int arg_gap_pt2=50)
{
   string t1=TimeToStr(Time[arg_shift],TIME_DATE);
   string t2=TimeToStr(Time[arg_shift],TIME_MINUTES);
   string t=StringConcatenate("[",t1," ",t2,"]");
   
   int cur_bar_shift=arg_shift;
   int last_bar_shift=arg_shift+1;
   
   double oc_gap=Open[cur_bar_shift]-Close[cur_bar_shift];
   int oc_gap_pt=(int)NormalizeDouble(MathAbs(oc_gap)/Point,0);
   
   if (g_debug) {
      Print("oc_gap_pt=",oc_gap_pt);
   }
   
   int cur_bar_status=0;
   if (oc_gap>0) cur_bar_status=1;   //1 for negative bar(open>close)
   
   int touch_idx=0;
   int cur_high_low_touch=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,1,arg_length,arg_th_pt,arg_expand,touch_idx,cur_bar_shift);       //nearest
   int cur_high_low_touch2=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,0,arg_length,arg_th_pt,arg_expand,touch_idx,cur_bar_shift);      //second nearest
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

   double cur_range_high=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_idx,cur_bar_shift);
   double cur_range_high2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high2_idx,cur_bar_shift);
   double cur_range_low=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_idx,cur_bar_shift);
   double cur_range_low2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low2_idx,cur_bar_shift);
   int cur_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_gap_idx,cur_bar_shift);
   int cur_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_gap_idx,cur_bar_shift);
   int cur_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_low_gap_idx,cur_bar_shift);

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
      Print(t,"high low gap is too narrow(<",arg_high_low_gap_pt,"pt)");
      return 0;
   }
   
   int ret=0;

   if (ret==0) {
      //break(up)
      if (high_low_change==1 && cur_high_low_touch>=-1 && cur_bar_status==0) {      //high_low_change up,positive bar
         if (cur_high_low_touch2>1) {  //break second high
            if (g_debug) Print(t,"high_low_change up,positive bar,break second high,+1");
            ret=1;
         } else 
         if (last_high_gap_pt>=arg_gap_pt2) {
            if (g_debug) Print(t,"high_low_change up,positive bar,+1");
            ret=1;
         } else {
            Print(t,"high_low_change up,positive bar,but last high_gap is too narrow(<",arg_gap_pt2,"pt)");
         }
      }
      //break(down)
      if (high_low_change==-1 && cur_high_low_touch<=1 && cur_bar_status==1) {     //high_low_change down,negative bar
         if (cur_high_low_touch2<-1) {  //break second low
            if (g_debug) Print(t,"high_low_change down,negative bar,break second low,-1");
            ret=-1;
         } else 
         if (last_low_gap_pt>=arg_gap_pt2) {
            if (g_debug) Print(t,"high_low_change down,negative bar,-1");
            ret=-1;
         } else {
            Print(t,"high_low_change down,negative bar,but last low_gap is too narrow(<",arg_gap_pt2,"pt)");
         }
      }
   }
   if (ret==0) {
      //break(up)
      if (high_low_change==0 && lst_high_low_touch>=0 && cur_high_low_touch>1 && cur_bar_status==0) { //break high,positive bar,up
         if (cur_high_low_touch2>1) {  //break second high
            if (g_debug) Print(t,"break high,positive bar,break second high,+1");
            ret=1;
         } else 
         if (cur_high_gap_pt>=arg_gap_pt2) {
            if (g_debug) Print(t,"break high,positive bar,+1");
            ret=1;
         } else {
            Print(t,"break high,positive bar,but cur high gap is too narrow(<",arg_gap_pt2,"pt)");
         }
      }
      //break(down)
      if (high_low_change==0 && lst_high_low_touch<=0 && cur_high_low_touch<-1 && cur_bar_status==1) {    //break low,negative bar,down
         if (cur_high_low_touch2<-1) {  //break second low
            if (g_debug) Print(t,"break low,negative bar,break second low,-1");
            ret=-1;
         } else
         if (cur_low_gap_pt>=arg_gap_pt2) {
            if (g_debug) Print(t,"break low,negative bar,-1");
            ret=-1;
         } else {
            Print(t,"break low,negative bar,but cur low gap is too narrow(<",arg_gap_pt2,"pt)");
         }
      }
   }
   
   //sma(M1:60) position
   int ma_pos=0;  //1 for price above SMA(M1:60),-1 for price below SMA(60)
   int tm=getMAPeriod(PERIOD_CURRENT);
   //Print("tm=",tm);
   if (tm==0) {
      return 0;
   }

   double ma1=iMA(NULL,PERIOD_CURRENT,tm,0,MODE_SMA,PRICE_CLOSE,cur_bar_shift);
   if (Close[cur_bar_shift]>ma1) { //price is above sma(60)
      ma_pos=1;
   //} else if (open[i]<ma2 && close[i]<ma2) { //price is under sma(60)
   } else if (Close[cur_bar_shift]<ma1) { //price is under sma(60)
      ma_pos=-1;
   }
   
   //sar position
   int sar_pos=0; //1 for price above SAR(0.02,0.2),-1 for price below SAR(0.02,0.2)
   double sar1=iSAR(NULL,PERIOD_CURRENT,0.02,0.2,cur_bar_shift);
   if (Close[cur_bar_shift]>sar1) { //price is above sar
      sar_pos=1;
   } else if (Close[cur_bar_shift]<sar1) { //price is under sar
      sar_pos=-1;
   }
   
   //final
   if (ret==3) {     //break up
      if (ma_pos!=1 || sar_pos!=1) {    //sma and sar is ng
         Print(t,"break up,but sma or sar is not supported,0");
         ret=0;
      }
   }
   if (ret==-3) {    //break down
      if (ma_pos!=-1 || sar_pos!=-1) {    //sma and sar is ng
         Print(t,"break down,but sma or sar is not supported,0");
         ret=0;
      }
   }
   
   return ret;
}
//+------------------------------------------------------------------+
//| get high low target price(use high_low2 indicator)
//| event stg's buy/sell stop price
//| date: 2017/11/16
//| arg_shift: bar shift
//| arg_thpt:threahold point(minimum high low offset)
//| arg_offpt:offset point(high low break offset)
//| return value: arg_price[2](buy/sell),arg_ls_price[2](buy/sell),arg_tp_price[2](buy/sell)
//+------------------------------------------------------------------+
void getHighLow_Value(int arg_shift,int arg_expand,int arg_range,int arg_long,int arg_thpt,int arg_thpt2,int arg_offpt,int arg_maxls_pt,
                     double &arg_price[],double &arg_ls_price[])
{
   string t1=TimeToStr(Time[arg_shift],TIME_DATE);
   string t2=TimeToStr(Time[arg_shift],TIME_MINUTES);
   string t=StringConcatenate("[",t1," ",t2,"]");

   int cur_bar_shift=arg_shift;
   int last_bar_shift=arg_shift+1;
   
   string ind_name="lang_high_low2";
   int low_idx=0;
   int high_idx=1;
   int low2_idx=2;
   int high2_idx=3;
   int low3_idx=4;
   int high3_idx=5;
   int high_gap_idx=12;
   int low_gap_idx=13;
   int high_low_gap_idx=14;
   int high2_gap_idx=15;
   int low2_gap_idx=16;
   
   double ask_price=Ask;
   double bid_price=Bid;
   int ab_gap_pt=(int)NormalizeDouble((ask_price-bid_price)/Point,0);
   //for test
   if (g_debug) {
      bid_price=Open[cur_bar_shift];
      ask_price=bid_price+ab_gap_pt*Point;
   }
   int exp=arg_expand;
   int range=arg_range;
   int lng=arg_long;
   double cur_range_high=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_idx,cur_bar_shift);
   double cur_range_high2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_idx,cur_bar_shift);
   double cur_range_high3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high3_idx,cur_bar_shift);
   double cur_range_low=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_idx,cur_bar_shift);
   double cur_range_low2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_idx,cur_bar_shift);
   double cur_range_low3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low3_idx,cur_bar_shift);
   int cur_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_gap_idx,cur_bar_shift);
   int cur_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_gap_idx,cur_bar_shift);
   int cur_high2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_gap_idx,cur_bar_shift);
   int cur_low2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_gap_idx,cur_bar_shift);
   int cur_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_low_gap_idx,cur_bar_shift);
   
   Print("cur_range_high=",cur_range_high,",cur_range_low=",cur_range_low);
   Print("cur_range_high2=",cur_range_high2,",cur_range_low2=",cur_range_low2);
   Print("cur_range_high3=",cur_range_high3,",cur_range_low3=",cur_range_low3);
   Print("cur_high_low_gap_pt=",cur_high_low_gap_pt);
   Print("cur_high_gap_pt=",cur_high_gap_pt,",cur_low_gap_pt=",cur_low_gap_pt);
   Print("cur_high2_gap_pt=",cur_high2_gap_pt,",cur_low2_gap_pt=",cur_low2_gap_pt);

   double range_high[3],range_low[3];
   range_high[0]=cur_range_high;
   range_high[1]=cur_range_high2;
   range_high[2]=cur_range_high3;
   range_low[0]=cur_range_low;
   range_low[1]=cur_range_low2;
   range_low[2]=cur_range_low3;
   
   double tgt_price;
   
   double buy_stop_price=0;
   tgt_price=ask_price;
   for (int i=0;i<3;i++) {
      int gap_pt=(int)NormalizeDouble((range_high[i]-tgt_price)/Point,0);
      if (gap_pt<arg_thpt) {
         if (g_debug) Print("ask_price=",tgt_price,",range high(",range_high[i],") is not high enough(gap<",arg_thpt,"pt)");
      } else {
         if    (i==0 && cur_high_gap_pt<arg_thpt2) {
            if (g_debug) Print("ask_price=",tgt_price,",cur_high_gap_pt(",cur_high_gap_pt,") is two narrow(gap<",arg_thpt2,"pt)");
         } else if (i==1 && cur_high2_gap_pt<arg_thpt2) {
            if (g_debug) Print("ask_price=",tgt_price,",cur_high2_gap_pt(",cur_high2_gap_pt,") is two narrow(gap<",arg_thpt2,"pt)");
         } else {
            buy_stop_price=range_high[i]+arg_offpt*Point;
            buy_stop_price=NormalizeDouble(buy_stop_price,Digits);
            if (g_debug) Print("ask_price=",tgt_price,",buy_stop_price=",buy_stop_price);
            break;
         }
      }
   }
   
   /*
   double buy_stop_tp_price=0;
   if (buy_stop_price>0) {
      tgt_price=buy_stop_price;
      for (int i=0;i<3;i++) {
         int gap_pt=(int)NormalizeDouble((range_high[i]-tgt_price)/Point,0);
         if (gap_pt<arg_thpt) {
            if (g_debug) Print("buy_stop_price=",tgt_price,",range high(",range_high[i],") is not high enough(gap<",arg_thpt,"pt)");
         } else {
            buy_stop_tp_price=range_high[i]-arg_offpt*Point;
            if (g_debug) Print("buy_stop_price=",tgt_price,",buy_stop_tp_price=",buy_stop_tp_price);
            break;
         }
      }
   }
   */
   
   double buy_stop_ls_price=0;
   if (buy_stop_price>0) {
      tgt_price=bid_price;
      for (int i=0;i<3;i++) {
         int gap_pt=(int)NormalizeDouble((tgt_price-range_low[i])/Point,0);
         if (gap_pt<arg_thpt) {
            if (g_debug) Print("bid_price=",tgt_price,",range low(",range_low[i],") is not low enough(gap<",arg_thpt,"pt)");
         } else {
            buy_stop_ls_price=range_low[i]-arg_offpt*Point;
            buy_stop_ls_price=NormalizeDouble(buy_stop_ls_price,Digits);
            if (g_debug) Print("bid_price=",tgt_price,",buy_stop_ls_price=",buy_stop_ls_price);
            break;
         }
      }
   }

   double sell_stop_price=0;
   tgt_price=bid_price;
   for (int i=0;i<3;i++) {
      int gap_pt=(int)NormalizeDouble((tgt_price-range_low[i])/Point,0);
      if (gap_pt<arg_thpt) {
         if (g_debug) Print("bid_price=",tgt_price,",range low(",range_low[i],") is not low enough(gap<",arg_thpt,"pt)");
      } else {
         if    (i==0 && cur_low_gap_pt<arg_thpt2) {
            if (g_debug) Print("bid_price=",tgt_price,",cur_low_gap_pt(",cur_low_gap_pt,") is two narrow(gap<",arg_thpt2,"pt)");
         } else if (i==1 && cur_low2_gap_pt<arg_thpt2) {
            if (g_debug) Print("bid_price=",tgt_price,",cur_low2_gap_pt(",cur_low2_gap_pt,") is two narrow(gap<",arg_thpt2,"pt)");
         } else {
            sell_stop_price=range_low[i]-arg_offpt*Point;
            sell_stop_price=NormalizeDouble(sell_stop_price,Digits);
            if (g_debug) Print("bid_price=",tgt_price,",sell_stop_price=",sell_stop_price);
            break;
         }
      }
   }
   
   /*
   double sell_stop_tp_price=0;
   if (sell_stop_price>0) {
      tgt_price=sell_stop_price;
      for (int i=0;i<3;i++) {
         int gap_pt=(int)NormalizeDouble((tgt_price-range_low[i])/Point,0);
         if (gap_pt<arg_thpt) {
            if (g_debug) Print("sell_stop_price=",tgt_price,",range low(",range_low[i],") is not low enough(gap<",arg_thpt,"pt)");
         } else {
            sell_stop_tp_price=range_low[i]+arg_offpt*Point;
            if (g_debug) Print("sell_stop_price=",tgt_price,",sell_stop_tp_price=",buy_stop_tp_price);
            break;
         }
      }
   }
   */
   
   double sell_stop_ls_price=0;
   if (sell_stop_price>0) {
      tgt_price=ask_price;
      for (int i=0;i<3;i++) {
         int gap_pt=(int)NormalizeDouble((range_high[i]-tgt_price)/Point,0);
         if (gap_pt<arg_thpt) {
            if (g_debug) Print("ask_price=",tgt_price,",range high(",range_high[i],") is not high enough(gap<",arg_thpt,"pt)");
         } else {
            sell_stop_ls_price=range_high[i]+arg_offpt*Point;
            sell_stop_ls_price=NormalizeDouble(sell_stop_ls_price,Digits);
            if (g_debug) Print("ask_price=",tgt_price,",sell_stop_ls_price=",sell_stop_ls_price);
            break;
         }
      }
   }

   Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap_pt=",ab_gap_pt);
   //int buy_stop_gap_pt,buy_stop_ls_gap_pt,buy_stop_tp_gap_pt;
   int buy_stop_gap_pt,buy_stop_ls_gap_pt;
   //buy_stop_gap_pt=buy_stop_ls_gap_pt=buy_stop_tp_gap_pt=0;
   buy_stop_gap_pt=buy_stop_ls_gap_pt=0;
   if (buy_stop_price>0) buy_stop_gap_pt=(int)NormalizeDouble((buy_stop_price-ask_price)/Point,0);
   //if (buy_stop_tp_price>0) buy_stop_tp_gap_pt=(int)NormalizeDouble((buy_stop_tp_price-buy_stop_price)/Point,0);
   if (buy_stop_ls_price>0) buy_stop_ls_gap_pt=(int)NormalizeDouble((buy_stop_price-buy_stop_ls_price)/Point,0);
   //Print("buy_stop_price=",buy_stop_price,"(",buy_stop_gap_pt,"),buy_stop_tp_price=",buy_stop_tp_price,"(",buy_stop_tp_gap_pt,"),buy_stop_ls_price=",buy_stop_ls_price,"(",buy_stop_ls_gap_pt,")");
   Print("buy_stop_price=",buy_stop_price,"(",buy_stop_gap_pt,"),buy_stop_ls_price=",buy_stop_ls_price,"(",buy_stop_ls_gap_pt,")");
   //int sell_stop_gap_pt,sell_stop_ls_gap_pt,sell_stop_tp_gap_pt;
   int sell_stop_gap_pt,sell_stop_ls_gap_pt;
   //sell_stop_gap_pt=sell_stop_ls_gap_pt=sell_stop_tp_gap_pt=0;
   sell_stop_gap_pt=sell_stop_ls_gap_pt=0;
   if (sell_stop_price>0) sell_stop_gap_pt=(int)NormalizeDouble((bid_price-sell_stop_price)/Point,0);
   //if (sell_stop_tp_price>0) sell_stop_tp_gap_pt=(int)NormalizeDouble((sell_stop_price-sell_stop_tp_price)/Point,0);
   if (sell_stop_ls_price>0) sell_stop_ls_gap_pt=(int)NormalizeDouble((sell_stop_ls_price-sell_stop_price)/Point,0);
   //Print("sell_stop_price=",sell_stop_price,"(",sell_stop_gap_pt,"),sell_stop_tp_price=",sell_stop_tp_price,"(",sell_stop_tp_gap_pt,"),sell_stop_ls_price=",sell_stop_ls_price,"(",sell_stop_ls_gap_pt,")");
   Print("sell_stop_price=",sell_stop_price,"(",sell_stop_gap_pt,"),sell_stop_ls_price=",sell_stop_ls_price,"(",sell_stop_ls_gap_pt,")");

   if (buy_stop_ls_gap_pt>arg_maxls_pt) {
      Print("buy_stop_ls_gap_pt is too big(>",arg_maxls_pt,")");
      buy_stop_ls_price=NormalizeDouble(buy_stop_price-arg_maxls_pt*Point(),Digits);
   }
   if (sell_stop_ls_gap_pt>arg_maxls_pt) {
      Print("sell_stop_ls_gap_pt is too big(>",arg_maxls_pt,")");
      sell_stop_ls_price=NormalizeDouble(sell_stop_price+arg_maxls_pt*Point(),Digits);
   }
   
   arg_price[0]=buy_stop_price;
   //arg_tp_price[0]=buy_stop_tp_price;
   arg_ls_price[0]=buy_stop_ls_price;
   arg_price[1]=sell_stop_price;
   //arg_tp_price[1]=sell_stop_tp_price;
   arg_ls_price[1]=sell_stop_ls_price;
   
}

//+------------------------------------------------------------------+
//| get high low target price(use high_low2 indicator)
//| rb stg's buy/sell price
//| date: 2017/12/18
//| arg_shift: bar shift
//| arg_ls_pt:ls point
//| arg_ls_ratio:
//| return value: (buy_break/buy_rebound/sell_break/sell_rebound)
//|               arg_price[4],arg_ls_price[4],arg_tp_price[4][2]
//|               arg_ls_price_pt[4],arg_tp_price_pt[4][2]
//+------------------------------------------------------------------+
int getHighLow_Value3( int arg_shift,int &arg_touch_status,
                        double &arg_price[],double &arg_ls_price[],double &arg_tp_price[][],
                        int &arg_ls_price_pt[],int &arg_tp_price_pt[][],double &arg_lvl_price[],
                        int arg_lspt=50,double arg_ls_ratio=0.6,
                        int arg_length=20,int arg_th_pt=0,int arg_expand=1,int arg_long=1,
                        int arg_oc_gap_pt=5,int arg_high_low_gap_pt=150,int arg_gap_pt2=20,
                        int arg_atr_lvl_pt=5,int arg_atr_range=5,
                        int arg_short_ma_ped=12,int arg_mid_ma_ped=36,
                        bool arg_atr_control=true,bool arg_ma_control=true,bool arg_zt_control=true
                      )
{

   //clear
   ArrayInitialize(arg_price,0);
   ArrayInitialize(arg_ls_price,0);
   ArrayInitialize(arg_ls_price_pt,0);
   ArrayInitialize(arg_tp_price,0);
   ArrayInitialize(arg_tp_price_pt,0);
   ArrayInitialize(arg_lvl_price,0);

   //--------------------
   //get high low value
   //--------------------

   string t1=TimeToStr(Time[arg_shift],TIME_DATE);
   string t2=TimeToStr(Time[arg_shift],TIME_MINUTES);
   string t=StringConcatenate("[",t1," ",t2,"]");

   int cur_bar_shift=arg_shift;
   int last_bar_shift=arg_shift+1;
   int sec_last_bar_shift=arg_shift+2;

   double cur_oc_gap=Open[cur_bar_shift]-Close[cur_bar_shift];
   int cur_oc_gap_pt=(int)NormalizeDouble(MathAbs(cur_oc_gap)/Point,0);
   double lst_oc_gap=Open[last_bar_shift]-Close[last_bar_shift];
   int lst_oc_gap_pt=(int)NormalizeDouble(MathAbs(lst_oc_gap)/Point,0);
   
   if (g_debug) {
      Print(t,"cur_oc_gap_pt=",cur_oc_gap_pt,",lst_oc_gap_pt=",lst_oc_gap_pt);
   }
   
   int cur_bar_status=0;
   if (cur_oc_gap>0) cur_bar_status=1;   //1 for negative bar(open>close)
   int lst_bar_status=0;
   if (lst_oc_gap>0) lst_bar_status=1;   //1 for negative bar(open>close)
   
   int touch_idx=0;
   int cur_high_low_touch=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,1,arg_length,arg_th_pt,arg_expand,touch_idx,cur_bar_shift);       //nearest
   int cur_high_low_touch2=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,0,arg_length,arg_th_pt,arg_expand,touch_idx,cur_bar_shift);      //second nearest
   int lst_high_low_touch=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,1,arg_length,arg_th_pt,arg_expand,touch_idx,last_bar_shift);      //nearest
   int lst_high_low_touch2=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,0,arg_length,arg_th_pt,arg_expand,touch_idx,last_bar_shift);     //second nearest
   int sec_lst_high_low_touch=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,1,arg_length,arg_th_pt,arg_expand,touch_idx,sec_last_bar_shift);  //nearest
   int sec_lst_high_low_touch2=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low_touch",false,0,arg_length,arg_th_pt,arg_expand,touch_idx,sec_last_bar_shift); //second nearest
   
   if (g_debug) {
      Print(t,"cur_high_low_touch=",cur_high_low_touch,",cur_high_low_touch2=",cur_high_low_touch2);
      Print(t,"lst_high_low_touch=",lst_high_low_touch,",lst_high_low_touch2=",lst_high_low_touch2);
      Print(t,"sec_lst_high_low_touch=",sec_lst_high_low_touch,",sec_lst_high_low_touch2=",sec_lst_high_low_touch2);
   }
      
   string ind_name="lang_high_low2";
   int low_idx=0;
   int high_idx=1;
   int low2_idx=2;
   int high2_idx=3;
   int low3_idx=4;
   int high3_idx=5;
   int high_gap_idx=12;
   int low_gap_idx=13;
   int high_low_gap_idx=14;
   int high2_gap_idx=15;
   int low2_gap_idx=16;
   int exp=1;
   int range=20;
   int lng=1;

   double cur_range_high=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_idx,cur_bar_shift);
   double cur_range_high2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_idx,cur_bar_shift);
   double cur_range_high3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high3_idx,cur_bar_shift);
   double cur_range_low=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_idx,cur_bar_shift);
   double cur_range_low2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_idx,cur_bar_shift);
   double cur_range_low3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low3_idx,cur_bar_shift);
   int cur_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_gap_idx,cur_bar_shift);
   int cur_high2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_gap_idx,cur_bar_shift);
   int cur_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_gap_idx,cur_bar_shift);
   int cur_low2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_gap_idx,cur_bar_shift);
   int cur_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_low_gap_idx,cur_bar_shift);

   double last_range_high=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_idx,last_bar_shift);
   double last_range_high2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_idx,last_bar_shift);
   double last_range_high3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high3_idx,last_bar_shift);
   double last_range_low=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_idx,last_bar_shift);
   double last_range_low2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_idx,last_bar_shift);
   double last_range_low3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low3_idx,last_bar_shift);
   int last_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_gap_idx,last_bar_shift);
   int last_high2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_gap_idx,last_bar_shift);
   int last_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_gap_idx,last_bar_shift);
   int last_low2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_gap_idx,last_bar_shift);
   int last_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_low_gap_idx,last_bar_shift);
  
   double sec_last_range_high=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_idx,sec_last_bar_shift);
   double sec_last_range_high2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_idx,sec_last_bar_shift);
   double sec_last_range_high3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high3_idx,sec_last_bar_shift);
   double sec_last_range_low=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_idx,sec_last_bar_shift);
   double sec_last_range_low2=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_idx,sec_last_bar_shift);
   double sec_last_range_low3=iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low3_idx,sec_last_bar_shift);
   int sec_last_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_gap_idx,sec_last_bar_shift);
   int sec_last_high2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high2_gap_idx,sec_last_bar_shift);
   int sec_last_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low_gap_idx,sec_last_bar_shift);
   int sec_last_low2_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,low2_gap_idx,sec_last_bar_shift);
   int sec_last_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,ind_name,false,range,lng,0,exp,1,high_low_gap_idx,sec_last_bar_shift);

   int cur_high_low_change=0;
   if (cur_range_high!=last_range_high || cur_range_low!=last_range_low) {
      if (cur_range_high>last_range_high && cur_range_low>=last_range_low) {
         cur_high_low_change=1;   //range up
      }
      if (cur_range_low<last_range_low && cur_range_high<=last_range_high) {
         cur_high_low_change=-1;   //range down
      }
   }
   int cur_high_low_change2=0;
   if (cur_range_high2!=last_range_high2 || cur_range_low2!=last_range_low2) {
      if (cur_range_high2>last_range_high2 && cur_range_low2>=last_range_low2) {
         cur_high_low_change2=1;   //range up
      }
      if (cur_range_low2<last_range_low2 && cur_range_high2<=last_range_high2) {
         cur_high_low_change2=-1;   //range down
      }
   }

   int lst_high_low_change=0;
   if (last_range_high!=sec_last_range_high || last_range_low!=sec_last_range_low) {
      if (last_range_high>sec_last_range_high && last_range_low>=sec_last_range_low) {
         lst_high_low_change=1;   //range up
      }
      if (last_range_low<sec_last_range_low && last_range_high<=sec_last_range_high) {
         lst_high_low_change=-1;   //range down
      }
   }
   int lst_high_low_change2=0;
   if (last_range_high2!=sec_last_range_high2 || last_range_low2!=sec_last_range_low2) {
      if (last_range_high2>sec_last_range_high2 && last_range_low2>=sec_last_range_low2) {
         lst_high_low_change2=1;   //range up
      }
      if (last_range_low2<sec_last_range_low2 && last_range_high2<=sec_last_range_high2) {
         lst_high_low_change2=-1;   //range down
      }
   }

   if (g_debug) {
      Print(t,"cur_range_high=",cur_range_high,",cur_range_high2=",cur_range_high2,",cur_range_high3=",cur_range_high3);
      Print(t,"cur_range_low=",cur_range_low,",cur_range_low2=",cur_range_low2,",cur_range_low3=",cur_range_low3);
      Print(t,"cur_high_gap_pt=",cur_high_gap_pt,",cur_low_gap_pt=",cur_low_gap_pt,",cur_high_low_gap_pt=",cur_high_low_gap_pt);
      Print(t,"cur_high2_gap_pt=",cur_high2_gap_pt,",cur_low2_gap_pt=",cur_low2_gap_pt);
      Print(t,"last_range_high=",last_range_high,",last_range_high2=",last_range_high2,",last_range_high3=",last_range_high3);
      Print(t,"last_range_low=",last_range_low,",last_range_low2=",last_range_low2,",last_range_low3=",last_range_low3);
      Print(t,"last_high_gap_pt=",last_high_gap_pt,",last_low_gap_pt=",last_low_gap_pt,",last_high_low_gap_pt=",last_high_low_gap_pt);
      Print(t,"last_high2_gap_pt=",last_high2_gap_pt,",last_low2_gap_pt=",last_low2_gap_pt);
      Print(t,"cur_high_low_change=",cur_high_low_change,",cur_high_low_change2=",cur_high_low_change2);
      Print(t,"lst_high_low_change=",lst_high_low_change,",lst_high_low_change2=",lst_high_low_change2);
   }
   
   /*
   arg_last_range_high=last_range_high;
   arg_last_range_high2=last_range_high2;
   arg_last_range_low=last_range_low;
   arg_last_range_low2=last_range_low2;
   arg_last_range_high_low_gap_pt=last_high_low_gap_pt;
   arg_last_range_high_gap_pt=last_high_gap_pt;
   arg_last_range_low_gap_pt=last_low_gap_pt;
   arg_last_range_high2_gap_pt=last_high2_gap_pt;
   arg_last_range_low2_gap_pt=last_low2_gap_pt;   
   */
   
   if (lst_high_low_change==0 && cur_high_low_change==0 && lst_high_low_touch==0 && cur_high_low_touch==0) {   //no signal
      if (g_debug) Print(t,"no signal");
      return 0;
   }
   
   /*
   if (cur_high_low_gap_pt<arg_high_low_gap_pt) {     //high low gap is too narrow
      Print(t,"high low gap is too narrow(<",arg_high_low_gap_pt,")");
      return 0;
   }
   */
   
   int ret=0;
   
   //| high low touch
   //| <<range_high,range_sub_high>>
   //|     (above) 0
   //|  |  (high)  1
   //| [ ] (open)  2
   //| [ ] (close) 2
   //|  |  (low)   3
   //|     (below) 4
   //| <<range_low,range_sub_low>>
   //|     (above) -4
   //|  |  (high)  -3
   //| [ ] (open)  -2
   //| [ ] (close) -2
   //|  |  (low)   -1
   //|     (below) 0
   //| plus for touch high;minus for touch low
   if (ret==0) {
      //break(up)
      if (  lst_high_low_change==0 && cur_high_low_change==1 && 
            (cur_high_low_touch==-1 || cur_high_low_touch==0) && 
            cur_bar_status==0) {          //high_low_change up,positive bar

         if (lst_high_low_touch2>=2) {    //break second high
            if (g_debug) Print(t,"high_low_change up,positive bar,break second high,+3");
            ret=4;
         } else
         if (last_high_gap_pt>=arg_gap_pt2) {
            if (g_debug) Print(t,"high_low_change up,positive bar,+3");
            ret=3;
         } else {
            if (g_debug) Print(t,"high_low_change up,positive bar,but last high gap is too narrow(<",arg_gap_pt2,"pt)");
         }
      }
      //break(down)
      if (  lst_high_low_change==0 && cur_high_low_change==-1 && 
            (cur_high_low_touch==1 || cur_high_low_touch==0) && 
            cur_bar_status==1) {          //high_low_change down,negative bar

         if (lst_high_low_touch2<=-2) {   //break second low
            if (g_debug) Print(t,"high_low_change down,negative bar,break second low,-3");
            ret=-4;
         } else 
         if (last_low_gap_pt>=arg_gap_pt2) {
            if (g_debug) Print(t,"high_low_change down,negative bar,-3");
            ret=-3;
         } else {
            if (g_debug) Print(t,"high_low_change down,negative bar,but last low gap is too narrow(<",arg_gap_pt2,"pt)");
         }
      }
   }
   
   if (ret==0) {
      //rebound(down)
      if (lst_high_low_change==0 && cur_high_low_change==0 && lst_high_low_touch==0 && cur_high_low_touch==1) {     //hit high,turn down
         if (g_debug) Print(t,"hit high,turn down,-2");
         ret=-2;
      }
   }

   if (ret==0) {
      //rebound(up)
      if (lst_high_low_change==0 && cur_high_low_change==0 && lst_high_low_touch==0 && cur_high_low_touch==-1) {    //hit low,turn up
         if (g_debug) Print(t,"hit low,turn up,positive bar,+2");
         ret=2;
      }
   }

   //<<< filter conditions
   arg_touch_status=ret;
   
   //add atr by 20171121
   if (arg_atr_control) {
      double atr_lvl=arg_atr_lvl_pt*Point;
      int atr=getAtrValue(cur_bar_shift,atr_lvl,arg_atr_range);
      if (ret!=0) {
         if (atr==0) {
            Print(t,"atr too small(<=",atr_lvl,")");
            ret=0;
         }
      }
   }
      
   //add ma condition
   if (arg_ma_control) {
      double short_ma,middle_ma;
      short_ma=middle_ma=0;
      int cur_touch_status[2];
      int cur_ma_status=getMAStatus2(PERIOD_CURRENT,cur_bar_shift,cur_touch_status,short_ma,middle_ma,arg_short_ma_ped,arg_mid_ma_ped);
      if (cur_ma_status>=10) cur_ma_status -= 10;
      if (cur_ma_status<=-10) cur_ma_status += 10;
      
      /*  
      if (cur_ma_status==0) {    //ma status is 0
         Print(t,"ma status is 0,0");
         return 0;
      }
      */
      
      //| ma
      //| return value: short>mid,same direction,up,5;
      //|               short>mid,different direction(short down,mid up),4;
      //|               short>mid,different direction(short up,mid down),3;
      //|               short>mid,same direction(short down,mid down),2;
      //|               short>mid,no direction,1;
      //| return value: short<mid,same direction,down,-5;
      //|               short<mid,different direction(short up,mid down),-4;
      //|               short<mid,different direction(short down,mid up),-3;
      //|               short<mid,same direction(short up,mid up),-2;
      //|               short<mid,no direction,-1;
      //|               n/a:0
      //| return value: short break mid,up(within last 2 bars):+10  
      //|               short break mid,down(within last 2 bars):-10  
      if (ret==2) {     //rebound up
         //if (  cur_ma_status==3 || cur_ma_status==2 || cur_ma_status==-5 || cur_ma_status==-4 || 
         //      cur_ma_status==1 || cur_ma_status==-1 || cur_ma_status==0) {  //ma mid is down
         //   Print(t,"rebound up,but ma mid is not down,(ma=",cur_ma_status,")");
         if (cur_ma_status<=0) {    //short<mid
            Print(t,"rebound up,but ma is down,(ma=",cur_ma_status,")");
            ret=0;
         }
      }
      if (ret==-2) {    //rebound down
         //if (  cur_ma_status==5 || cur_ma_status==4 || cur_ma_status==-3 || cur_ma_status==-2 ||
         //      cur_ma_status==1 || cur_ma_status==-1 || cur_ma_status==0) {  //ma mid is up
         //   Print(t,"rebound down,but ma mid is up,(ma=",cur_ma_status,")");
         if (cur_ma_status>=0) {    //short>mid
            Print(t,"rebound up,but ma is up,(ma=",cur_ma_status,")");
            ret=0;
         }
      }
   
      if (ret>=3) {     //break up
         if (  cur_ma_status==3 || cur_ma_status==2 || cur_ma_status<=0 ||
               cur_ma_status==1 || cur_ma_status==-1 || cur_ma_status==0) {  //ma mid is down or short<mid
            Print(t,"break up,but ma mid is down,(ma=",cur_ma_status,")");
            ret=0;
         }
      }
      if (ret<=-3) {    //break down
         if (  cur_ma_status>=0 || cur_ma_status==-3 || cur_ma_status==-2 ||
               cur_ma_status==1 || cur_ma_status==-1 || cur_ma_status==0) {  //ma mid is up or short>mid
            Print(t,"break down,but ma mid is up,(ma=",cur_ma_status,")");
            ret=0;
         }
      }
   }

   //add zt by 20180115
   if (arg_zt_control) {
      int lst_short_low_sht=0,lst_mid_low_sht=0,lst_short_high_sht=0,lst_mid_high_sht=0;
      int expBarShift=0;
      int expPd=expandPeriod(PERIOD_CURRENT,cur_bar_shift,expBarShift,0);
      int zt_status=getZigTurn2(expPd,expBarShift,lst_short_low_sht,lst_mid_low_sht,lst_short_high_sht,lst_mid_high_sht);
      if (ret==2) {     //rebound up
         if (zt_status<=0) {
            Print(t,"rebound up,but zt is down,(zt=",zt_status,")");
            ret=0;
         }
      }
      if (ret==-2) {    //rebound down
         if (zt_status>=0) {
            Print(t,"rebound down,but zt is up,(zt=",zt_status,")");
            ret=0;
         }
      }
      if (ret>=3) {     //break up
         if (zt_status<=0) {
            Print(t,"break up,but zt is down,(zt=",zt_status,")");
            ret=0;
         }
      }
      if (ret<=-3) {    //break down
         if (zt_status>=0) {
            Print(t,"break down,but zt is up,(zt=",zt_status,")");
            ret=0;
         }
      }
   }

   if (MathAbs(ret)>=3) {     //break up or break down
      if (cur_oc_gap_pt<=arg_oc_gap_pt) {  //open close gap is too narrow
         Print(t,"open close gap is too narrow(<=",arg_oc_gap_pt,"pt)");
         ret=0;
      }
   }

   if (ret==0) {     //final
      if (cur_high_low_touch>0) {   //only touch high(can notify by email)
         if (g_debug) Print(t,"final,only touch high,+1");
         ret=1;
         if (arg_touch_status==0)
            arg_touch_status=ret;
      }
      if (cur_high_low_touch<0) {   //only touch low(can notify by email)
         if (g_debug) Print(t,"final,only touch low,-1");
         ret=-1;
         if (arg_touch_status==0)
            arg_touch_status=ret;
      }
   }


   //--------------------
   //get order value
   //--------------------
   
   if (arg_touch_status==0) {
      //Print("arg_touch_status==0");
      return 0;
   }
      
   double ask_price=Ask;
   double bid_price=Bid;
   int ab_gap_pt=(int)NormalizeDouble((ask_price-bid_price)/Point,0);
   double cur_bar_high=High[cur_bar_shift];
   double cur_bar_low=Low[cur_bar_shift];
   //for test
   if (g_debug) {
      bid_price=Open[cur_bar_shift];
      ask_price=bid_price+ab_gap_pt*Point;
   }
   if (g_debug) {
      Print("Time=",Time[cur_bar_shift]);
      Print("ask_price=",ask_price,",bid_price=",bid_price,",ab_gap_pt=",ab_gap_pt);
      Print("cur_bar_high=",cur_bar_high,",cur_bar_low=",cur_bar_low);
   }
   
   double high_price=0;
   double low_price=0;
   double base_price=0;
   if (arg_touch_status==1 || arg_touch_status==3 || arg_touch_status==-2) {    //touch high or break high
      high_price=cur_range_high2;
      base_price=cur_range_high;
      low_price=cur_range_low;
   } else
   if (arg_touch_status==4) {                                                    //break second high
      high_price=cur_range_high3;
      base_price=cur_range_high2;
      low_price=cur_range_low;
   } else
   if (arg_touch_status==-1 || arg_touch_status==-3 || arg_touch_status==2) {    //touch low or break low
      high_price=cur_range_high;
      base_price=cur_range_low;
      low_price=cur_range_low2;
   } else
   if (arg_touch_status==-4) {                                                   //break second low
      high_price=cur_range_low;
      base_price=cur_range_low2;
      low_price=cur_range_low3;
   } else {                                                                      //unknown
      high_price=cur_range_high;
      base_price=0;
      low_price=cur_range_low;
   }

   if (g_debug) Print(t,"arg_touch_status=",arg_touch_status,",high_price=",high_price,",base_price=",base_price,",low_price=",low_price);
   
   if (high_price==0 || low_price==0 || base_price==0) {
      Print(t,"faild to get high low price");
      return 0;
   }
   
   arg_lvl_price[0]=high_price;
   arg_lvl_price[1]=base_price;
   arg_lvl_price[2]=low_price;
   
   double   break_ls_ratio=arg_ls_ratio;
   int      ls_pt=arg_lspt;
   int      min_ls_pt=arg_lspt*2;   //minimum break ls point

   double   ls_tgt_price,ls_price,ls_gap;
   double   price,tp_price1,tp_price2;
   int      ls_gap_pt,tp_gap1_pt,tp_gap2_pt;

   //------------------------
   //clear
   ls_tgt_price=ls_price=ls_gap=0;
   price=tp_price1=tp_price2=0;
   ls_gap_pt=tp_gap1_pt=tp_gap2_pt=0;
   
   //buy break
   price=ask_price;
   ls_tgt_price=NormalizeDouble(base_price-(base_price-low_price)*break_ls_ratio,Digits); //break up stop lose
   ls_price=ls_tgt_price;

   ls_gap=NormalizeDouble(price-ls_price,Digits);
   tp_price1=price+ls_gap;
   tp_price2=price+2*ls_gap;
   tp_gap1_pt=(int)NormalizeDouble(ls_gap/Point,0);
   tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);
   ls_gap_pt=-tp_gap1_pt;

   if (g_debug) {
      Print(t,"buy break");
      Print(t,"price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print(t,"tp_price1=",tp_price1,",tp_price2=",tp_price2,",tp_gap1_pt=",tp_gap1_pt,",tp_gap2_pt=",tp_gap2_pt);
   }
   
   if (MathAbs(ls_gap_pt)<min_ls_pt) {
      if (g_debug) {
         Print(t,"buy break");
         Print(t,"ls_gap_pt(",MathAbs(ls_gap_pt),") is smaller than min_ls_pt(",min_ls_pt,")");
      }
      tp_price1=tp_price2=0;
   } else if (tp_price1>high_price) {
      if (g_debug) {
         Print(t,"buy break");
         Print(t,"tp_price1(",tp_price1,") is higher than high_price(",high_price,")");
      }
      tp_price1=tp_price2=0;
   } else if (tp_price2>high_price) {
      if (g_debug) {
         Print(t,"buy break");
         Print(t,"tp_price2(",tp_price2,") is higher than high_price(",high_price,")");
      }
      tp_price2=0;
   }
   
   arg_price[0]=price;
   arg_ls_price[0]=ls_price;
   arg_ls_price_pt[0]=ls_gap_pt;
   arg_tp_price[0][0]=tp_price1;
   arg_tp_price[0][1]=tp_price2;
   arg_tp_price_pt[0][0]=tp_gap1_pt;
   arg_tp_price_pt[0][1]=tp_gap2_pt;

   //------------------------
   //clear
   ls_tgt_price=ls_price=ls_gap=0;
   price=tp_price1=tp_price2=0;
   ls_gap_pt=tp_gap1_pt=tp_gap2_pt=0;

   //buy rebound
   price=ask_price;
   ls_tgt_price=cur_bar_low;
   ls_price=ls_tgt_price-ls_pt*Point;

   ls_gap=NormalizeDouble(price-ls_price,Digits);
   tp_price1=price+ls_gap;
   tp_price2=price+2*ls_gap;
   tp_gap1_pt=(int)NormalizeDouble(ls_gap/Point,0);
   tp_gap2_pt=(int)NormalizeDouble(2*ls_gap/Point,0);
   ls_gap_pt=-tp_gap1_pt;

   if (g_debug) {
      Print(t,"buy rebound");
      Print(t,"price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print(t,"tp_price1=",tp_price1,",tp_price2=",tp_price2,",tp_gap1_pt=",tp_gap1_pt,",tp_gap2_pt=",tp_gap2_pt);
   }
   
   if (tp_price1>high_price) {
      if (g_debug) {
         Print(t,"buy rebound");
         Print(t,"tp_price1(",tp_price1,") is higher than high_price(",high_price,")");
      }
      tp_price1=tp_price2=0;
   } else if (tp_price2>high_price) {
      if (g_debug) {
         Print(t,"buy rebound");
         Print(t,"tp_price2(",tp_price2,") is higher than high_price(",high_price,")");
      }
      tp_price2=0;
   }

   arg_price[1]=price;
   arg_ls_price[1]=ls_price;
   arg_ls_price_pt[1]=ls_gap_pt;
   arg_tp_price[1][0]=tp_price1;
   arg_tp_price[1][1]=tp_price2;
   arg_tp_price_pt[1][0]=tp_gap1_pt;
   arg_tp_price_pt[1][1]=tp_gap2_pt;

   //------------------------
   //clear
   ls_tgt_price=ls_price=ls_gap=0;
   price=tp_price1=tp_price2=0;
   ls_gap_pt=tp_gap1_pt=tp_gap2_pt=0;

   //sell break
   price=bid_price;
   ls_tgt_price=NormalizeDouble(base_price+(high_price-base_price)*break_ls_ratio,Digits);    //break up stop lose
   ls_price=ls_tgt_price;

   ls_gap=NormalizeDouble(ls_price-price,Digits);
   tp_price1=price-ls_gap;
   tp_price2=price-2*ls_gap;
   tp_gap1_pt=-(int)NormalizeDouble(ls_gap/Point,0);
   tp_gap2_pt=-(int)NormalizeDouble(2*ls_gap/Point,0);
   ls_gap_pt=-tp_gap1_pt;

   if (g_debug) {
      Print(t,"sell break");
      Print(t,"price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print(t,"tp_price1=",tp_price1,",tp_price2=",tp_price2,",tp_gap1_pt=",tp_gap1_pt,",tp_gap2_pt=",tp_gap2_pt);
   }
   
   if (MathAbs(ls_gap_pt)<min_ls_pt) {
      if (g_debug) {
         Print(t,"sell break");
         Print(t,"ls_gap_pt(",MathAbs(ls_gap_pt),") is smaller than min_ls_pt(",min_ls_pt,")");
      }
      tp_price1=tp_price2=0;
   } else if (tp_price1<low_price) {
      if (g_debug) {
         Print(t,"sell break");
         Print(t,"tp_price1(",tp_price1,") is lower than low_price(",low_price,")");
      }
      tp_price1=0;
      tp_price2=0;
   } else if (tp_price2<low_price) {
      if (g_debug) {
         Print(t,"sell break");
         Print(t,"tp_price2(",tp_price2,") is lower than low_price(",low_price,")");
      }
      tp_price2=0;
   }

   arg_price[2]=price;
   arg_ls_price[2]=ls_price;
   arg_ls_price_pt[2]=ls_gap_pt;
   arg_tp_price[2][0]=tp_price1;
   arg_tp_price[2][1]=tp_price2;
   arg_tp_price_pt[2][0]=tp_gap1_pt;
   arg_tp_price_pt[2][1]=tp_gap2_pt;

   //------------------------
   //clear
   ls_tgt_price=ls_price=ls_gap=0;
   price=tp_price1=tp_price2=0;
   ls_gap_pt=tp_gap1_pt=tp_gap2_pt=0;

   //sell rebound
   price=bid_price;
   ls_tgt_price=cur_bar_high;
   ls_price=ls_tgt_price+ls_pt*Point;

   ls_gap=NormalizeDouble(ls_price-price,Digits);
   tp_price1=price-ls_gap;
   tp_price2=price-2*ls_gap;
   tp_gap1_pt=-(int)NormalizeDouble(ls_gap/Point,0);
   tp_gap2_pt=-(int)NormalizeDouble(2*ls_gap/Point,0);
   ls_gap_pt=-tp_gap1_pt;
   
   if (g_debug) {
      Print(t,"sell rebound");
      Print(t,"price=",price,",ls_tgt_price=",ls_tgt_price,",ls_price=",ls_price,",ls_gap=",ls_gap);
      Print(t,"tp_price1=",tp_price1,",tp_price2=",tp_price2,",tp_gap1_pt=",tp_gap1_pt,",tp_gap2_pt=",tp_gap2_pt);
   }
   
   if (tp_price1<low_price) {
      if (g_debug) {
         Print(t,"sell rebound");
         Print(t,"tp_price1(",tp_price1,") is lower than low_price(",low_price,")");
      }
      tp_price1=0;
      tp_price2=0;
   } else if (tp_price2<low_price) {
      if (g_debug) {
         Print(t,"sell rebound");
         Print(t,"tp_price2(",tp_price2,") is lower than low_price(",low_price,")");
      }
      tp_price2=0;
   }

   arg_price[3]=price;
   arg_ls_price[3]=ls_price;
   arg_ls_price_pt[3]=ls_gap_pt;
   arg_tp_price[3][0]=tp_price1;
   arg_tp_price[3][1]=tp_price2;
   arg_tp_price_pt[3][0]=tp_gap1_pt;
   arg_tp_price_pt[3][1]=tp_gap2_pt;

   return ret;
   
}

//+------------------------------------------------------------------+
//| quick shoot stg open(use sma and sar and high_low indicator)
//| date: 2017/11/23
//| arg_shift: bar shift
//| return value: 1,open buy(turn up);-1,open sell(turn down);0,N/A
//+------------------------------------------------------------------+
int isQuickShootOpen(int arg_shift,int arg_lspt,int arg_hl_gap_pt,double arg_hl_gap_ratio,double &arg_price[],double &arg_ls_price[],bool arg_cal=false,int arg_thrd_pt=20)
{

   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   double cur_price=Close[cur_bar_shift];
   double last_price=Close[lst_bar_shift];
   string t1=StringConcatenate(TimeMonth(Time[cur_bar_shift]),"/",TimeDay(Time[cur_bar_shift]));
   string t2=TimeToStr(Time[cur_bar_shift],TIME_MINUTES);
   string t=StringConcatenate("[",t1," ",t2,"]");
    
   int ma_ped=getMAPeriod(PERIOD_CURRENT);
   //Print("ma_ped=",ma_ped);
   if (ma_ped==0) {
      return 0;
   }
   
   //sma   
   int ma_pos=0;        //1 for price above SMA(60),-1 for price below SMA(60)
   double ma1=iMA(NULL,PERIOD_CURRENT,ma_ped,0,MODE_SMA,PRICE_CLOSE,cur_bar_shift);
   double offset=arg_thrd_pt*Point;
   if          (cur_price>(ma1+offset)) {    //price is above sma(60)
      ma_pos=1;
   } else if   (cur_price<(ma1-offset)) {    //price is under sma(60)
      ma_pos=-1;
   }
   
   //sar
   int cur_sar_pos=0;   //1 for price above SAR(0.02,0.2),-1 for price below SAR(0.02,0.2)
   int lst_sar_pos=0;   //1 for price above SAR(0.02,0.2),-1 for price below SAR(0.02,0.2)
   int sar_break=0;     //-1 for SAR(0.02,0.2) from down to up the price,1 for SAR(0.02,0.2) from up to down the price
   int sar_two_bar=0;   //1 for two bar's price is above SAR(0.02,0.2),-1 for two bar's price is below SAR(0.02,0.2)

   double cur_sar=iSAR(NULL,PERIOD_CURRENT,0.02,0.2,cur_bar_shift);
   double last_sar=iSAR(NULL,PERIOD_CURRENT,0.02,0.2,lst_bar_shift);
   if          (cur_price>cur_sar) {      //price is above sar
      cur_sar_pos=1;
   } else if   (cur_price<cur_sar) {      //price is under sar
      cur_sar_pos=-1;
   }
   if          (last_price>last_sar) {      //price is above sar
      lst_sar_pos=1;
   } else if   (last_price<last_sar) {      //price is under sar
      lst_sar_pos=-1;
   }

   if          (lst_sar_pos==-1 && cur_sar_pos==1) {  //last SAR is above price and cur SAR is under price
      sar_break=1;
   } else if   (lst_sar_pos==1 && cur_sar_pos==-1) {  //last SAR is under price and cur SAR is above price
      sar_break=-1;
   }
   
   if          (lst_sar_pos==-1 && cur_sar_pos==-1) { //last SAR is above price and cur SAR is above price
      sar_two_bar=-1;
   } else if   (lst_sar_pos==1 && cur_sar_pos==1) {   //last SAR is under price and cur SAR is under price
      sar_two_bar=1;
   }
   
   int ret=0;

   if (sar_break==1 && ma_pos==1) {    //turn up
   //if (sar_two_bar==1 && ma_pos==1) {    //turn up
      ret=1;
   }
   if (sar_break==-1 && ma_pos==-1) {   //turn down
   //if (sar_two_bar==-1 && ma_pos==-1) {   //turn down
      ret=-1;
   }
   
   if (MathAbs(ret)==1 && arg_cal) {
      int ls_ratio=1;      //take lose ratio
      arg_price[0]=Ask;    //buy price
      arg_price[1]=Bid;    //sell price
      arg_ls_price[0]=NormalizeDouble(Low[cur_bar_shift]-ls_ratio*arg_lspt*Point,Digits);       //buy ls price
      arg_ls_price[1]=NormalizeDouble(High[cur_bar_shift]+ls_ratio*arg_lspt*Point,Digits);      //sell ls price
      
      //high_low
      int low_idx=0;
      int high_idx=1;
      int low2_idx=2;
      int high2_idx=3;
      int high_gap_idx=8;
      int low_gap_idx=9;
      int high_low_gap_idx=10;
      
      double cur_range_high=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_idx,cur_bar_shift);
      double cur_range_high2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high2_idx,cur_bar_shift);
      double cur_range_low=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_idx,cur_bar_shift);
      double cur_range_low2=iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low2_idx,cur_bar_shift);
      int cur_high_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_gap_idx,cur_bar_shift);
      int cur_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",low_gap_idx,cur_bar_shift);
      int cur_high_low_gap_pt=(int)iCustom(NULL,PERIOD_CURRENT,"lang_high_low",high_low_gap_idx,cur_bar_shift);
      if (cur_high_low_gap_pt<arg_hl_gap_pt) {
         Print(t,"cur_high_low_gap is too narrow(<",arg_hl_gap_pt,"pt)");
         return 0;
      }
      
      int cur_price_high_gap_pt=(int)NormalizeDouble((cur_range_high-cur_price)/Point,0);    //maybe minus,breaking high
      int cur_price_low_gap_pt=(int)NormalizeDouble((cur_price-cur_range_low)/Point,0);      //maybe minus,breaking low
      if (cur_price_high_gap_pt<=0 || cur_price_low_gap_pt<=0) {
         Print(t,"cur_price_high_gap_pt is minus or cur_price_low_gap_pt is minus");
         return 0;
      }
      //double cur_hl_gap_ratio=NormalizeDouble((double)cur_price_high_gap_pt/cur_price_low_gap_pt,2);    //ratio is between 0 and 1
      //double cur_lh_gap_ratio=NormalizeDouble((double)cur_price_low_gap_pt/cur_price_high_gap_pt,2);    //ratio is between 0 and 1
      //Print(t,"cur_price_high_gap_pt=",cur_price_high_gap_pt,",cur_price_low_gap_pt=",cur_price_low_gap_pt);
      //Print(t,"cur_hl_gap_ratio=",cur_hl_gap_ratio,",cur_lh_gap_ratio=",cur_lh_gap_ratio);
      
      if (ret==1) {    //turn up
         /*
         if (cur_hl_gap_ratio<arg_hl_gap_ratio) {     //cur price is near range high,avoid to open buy
            Print(t,"cur price is near high, cur_hl_gap_ratio(<",arg_hl_gap_ratio,")");
            ret=0;
         }
         */
         if (cur_price_high_gap_pt<arg_lspt) {     //cur price is near range high,avoid to open buy
            Print(t,"cur price is near high, cur_price_high_gap_pt(<",arg_lspt,"pt)");
            ret=0;
         }
      }
      if (ret==-1) {
         /*
         if (cur_lh_gap_ratio<arg_hl_gap_ratio) {  //cur price is near range low,avoid to open sell
            Print(t,"cur price is near low, cur_lh_gap_ratio(<",arg_hl_gap_ratio,")");
            ret=0;
         }
         */
         if (cur_price_low_gap_pt<arg_lspt) {      //cur price is near range low,avoid to open sell
            Print(t,"cur price is near low, cur_price_low_gap_pt(<",arg_lspt,")");
            ret=0;
         }
      }
   }

   return ret;
}
//+------------------------------------------------------------------+
//| quick shoot stg close(use sma and adx indicator)
//| date: 2017/11/24
//| arg_shift: bar shift
//| return value: 1,close sell(turn up);-1,close buy(turn down);0,N/A
//+------------------------------------------------------------------+
int isQuickShootClose(int arg_shift,int arg_thrd_pt=20)
{
   int cur_bar_shift=arg_shift;
   int lst_bar_shift=arg_shift+1;
   double cur_price=Close[cur_bar_shift];
   double last_price=Close[lst_bar_shift];

   double oc_gap=Open[cur_bar_shift]-Close[cur_bar_shift];
   int oc_gap_pt=(int)NormalizeDouble(MathAbs(oc_gap)/Point,0);
   
   if (g_debug) {
      Print("oc_gap_pt=",oc_gap_pt);
   }
   
   int cur_bar_status=0;
   if (oc_gap>0) cur_bar_status=1;  //1 for negative bar(open>close)
   
   //sma
   int ma_ped=getMAPeriod(PERIOD_CURRENT);
   //Print("ma_ped=",ma_ped);
   if (ma_ped==0) {
      return 0;
   }   
   
   int cur_ma_pos=0;                    //1 for price above SMA(60),-1 for price below SMA(60)
   int lst_ma_pos=0;                    //1 for price above SMA(60),-1 for price below SMA(60)
   double ma1=iMA(NULL,PERIOD_CURRENT,ma_ped,0,MODE_SMA,PRICE_CLOSE,cur_bar_shift);
   double ma2=iMA(NULL,PERIOD_CURRENT,ma_ped,0,MODE_SMA,PRICE_CLOSE,lst_bar_shift);
   double offset=arg_thrd_pt*Point;
   
   if          (cur_price>(ma1+offset)) {    //cur price is above sma(60)
      cur_ma_pos=1;
   } else if   (cur_price<(ma1-offset)) {    //cur price is under sma(60)
      cur_ma_pos=-1;
   }
   if          (last_price>(ma2+offset)) {            //last price is above sma(60)
      lst_ma_pos=1;
   } else if   (last_price<(ma2-offset)) {            //last price is under sma(60)
      lst_ma_pos=-1;
   }
   
   int ma_break=0;
   if          (lst_ma_pos<=0 && cur_ma_pos>0) {      //price is up break ma
      ma_break=1;
   } else if   (lst_ma_pos>=0 && cur_ma_pos<0) {      //price is down break ma
      ma_break=-1;
   }
   
   if (cur_bar_status==0 && ma_break==1) {  //price is above sma(60) and positive bar
      //Print("up break sma");
      return 1;
   }

   if (cur_bar_status==1 && ma_break==-1) {  //price is under sma(60) and negative bar
      //Print("down break sma");
      return -1;
   }

   if (cur_ma_pos==1 && lst_ma_pos==1) {     //two bar's price is above sma(60)
      return 1;
   }
   if (cur_ma_pos==-1 && lst_ma_pos==-1) {     //two bar's price is above sma(60)
      return -1;
   }
   
   /*
   //adx
   int adx=getADXStatus(PERIOD_CURRENT,cur_bar_shift);
   if          (adx>1) {        //adx is top(trend is up),close buy
      //Print("up trend, adx is top");
      return -1;
   } else if   (adx<-1) {       //adx is top(trend is down),close sell
      //Print("down trend, adx is top");
      return 1;
   }
   */
   
   return 0;
}
/*
//+------------------------------------------------------------------+
//| Trend strategy Open (use macd)
//| date: 2018/2/5
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: 6,macd break to plus,macd fast is above range high;-6,macd break to minus,macd fast is below range low;
//|               5,macd break to plus;-5,macd break to minus;
//|               4,macd is plus,macd fast is above range high;-4,macd is minus,macd fast is below range low;
//|               3,macd is plus,fast ma is above slow ma;-3,macd is minus,fast ma is below slow ma;
//|               2,macd is plus,fast ma is below slow ma;-2,macd is minus,fast ma is below slow ma;
//|               1,macd is plus;-1,macd is minus;
//|               0:n/a
//+------------------------------------------------------------------+
int isTrendStgOpen2(int arg_shift,double &arg_ls_price,int arg_slow_pd=26,int arg_fast_pd=12,int arg_signal_pd=9,int arg_mode=MODE_SIGNAL,double arg_deviation=2,int arg_range_ratio=1,int arg_thpt=0)
{
   int cur_bar_shift=arg_shift;
   
   int cur_touch_status[2];
   double cur_short_ma,cur_middle_ma;
   int cur_ret=getMAStatus2(PERIOD_CURRENT,cur_bar_shift,cur_touch_status,cur_short_ma,cur_middle_ma);

   arg_ls_price=cur_middle_ma;
   
   //| return value: 
   //|   +1,keep plus;
   //|   -1,keep minus;
   //|   +2,keep plus(max);
   //|   -2,keep minus(min);
   //|   +10,break to plus;
   //|   -10,break to minus;
   //|   0,N/A;
   cur_ret=getMACDStatus(PERIOD_CURRENT,cur_bar_shift,arg_slow_pd,arg_fast_pd,arg_signal_pd,arg_mode,arg_deviation,arg_range_ratio);

   //| return value: fast>slow,same direction,up,5;
   //|               fast>slow,different direction(fast down,slow up),4;
   //|               fast>slow,different direction(fast up,slow down),3;
   //|               fast>slow,same direction(fast down,slow down),2;
   //|               fast>slow,no direction,1;
   //| return value: fast<slow,same direction,down,-5;
   //|               fast<slow,different direction(fast up,slow down),-4;
   //|               fast<slow,different direction(fast down,slow up),-3;
   //|               fast<slow,same direction(fast up,slow up),-2;
   //|               fast<slow,no direction,-1;
   //|               n/a:0
   //| return value: fast is above slow range upper:+10  
   //|               fast is below slow range lower:-10  
   int cur_ret2=getMACDStatus2(PERIOD_CURRENT,cur_bar_shift,arg_slow_pd,arg_fast_pd,arg_signal_pd,arg_deviation,arg_range_ratio);

   int cur_ret3=getBarStatus(PERIOD_CURRENT,cur_bar_shift,arg_thpt);
   //| return value: 1,positive bar;-1,negative bar
   
   if (cur_ret>0) {                          //macd is plus
      if (cur_ret>=10 && cur_ret2>=10) {     //macd break to plus,macd fast is above range high
         return 6;
      }
      if (cur_ret>=10) {                     //macd break to plus
         return 5;
      }
      //if (cur_ret2>=10 && cur_ret3>0) {    //macd fast is above range high, positive bar
      if (cur_ret2>=10) {                    //macd fast is above range high
         return 4;
      }
      if (cur_ret2>0) {                      //fast ma is above slow ma
         return 3;
      }
      if (cur_ret2<0) {                      //fast ma is below slow ma
         return 2;
      }
      return 1;
   }
   if (cur_ret<0) {                          //macd is minus
      if (cur_ret<=-10 && cur_ret2<=-10) {   //mack break to minus,macd fast is below range low
         return -6;
      }
      if (cur_ret<=-10) {                    //mack break to minus
         return -5;
      }
      //if (cur_ret2<=-10 && cur_ret3<0) {   //macd fast is below range low, negative bar
      if (cur_ret2<=-10) {                   //macd fast is below range low
         return -4;
      }
      if (cur_ret2<0) {                      //fast ma is below slow ma
         return -3;
      }
      if (cur_ret2>0) {                      //fast ma is above slow ma
         return -2;
      }
      return -1;
   }
   
   return 0;
}
*/
//+------------------------------------------------------------------+
//| Trend strategy Open (use macd)
//| date: 2018/3/1
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: +10,macd is break plus;-10,macd is break minus;
//|               1,macd is plus;-1,macd is minus;
//| return value: arg_macd_status
//|               fast>slow,same direction,up,5;
//|               fast>slow,different direction(fast down,slow up),4;
//|               fast>slow,different direction(fast up,slow down),3;
//|               fast>slow,same direction(fast down,slow down),2;
//|               fast>slow,no direction,1;
//|               -----------
//|               fast<slow,same direction,down,-5;
//|               fast<slow,different direction(fast up,slow down),-4;
//|               fast<slow,different direction(fast down,slow up),-3;
//|               fast<slow,same direction(fast up,slow up),-2;
//|               fast<slow,no direction,-1;
//|               -----------
//|               fast is above slow range upper:+10  
//|               fast is below slow range lower:-10  
//|               fast is above slow band upper:+20  
//|               fast is below slow band lower:-20  
//|               -----------
//|               n/a:0
//| return value: arg_bar_status
//|               1,positive bar;-1,negative bar
//+------------------------------------------------------------------+
int isTrendStgOpen3(int arg_shift,double &arg_ls_price,double &arg_macd_slow,double &arg_macd_fast,double &arg_macd_range,int &arg_macd_status,int &arg_bar_status,int arg_slow_pd=26,int arg_fast_pd=12,int arg_signal_pd=9,int arg_mode=MODE_SIGNAL,double arg_deviation=2,int arg_range_ratio=1,int arg_thpt=0)
{
   int cur_bar_shift=arg_shift;
   
   int cur_touch_status[2];
   double cur_short_ma,cur_middle_ma;
   int cur_ret=getMAStatus2(PERIOD_CURRENT,cur_bar_shift,cur_touch_status,cur_short_ma,cur_middle_ma);

   arg_ls_price=cur_middle_ma;
   
   //| return value: 
   //|   +1,keep plus;
   //|   -1,keep minus;
   //|   +2,keep plus(max);
   //|   -2,keep minus(min);
   //|   +10,break to plus;
   //|   -10,break to minus;
   //|   0,N/A;
   cur_ret=getMACDStatus(PERIOD_CURRENT,cur_bar_shift,arg_slow_pd,arg_fast_pd,arg_signal_pd,arg_mode,arg_deviation,arg_range_ratio);

   //| return value: fast>slow,same direction,up,5;
   //|               fast>slow,different direction(fast down,slow up),4;
   //|               fast>slow,different direction(fast up,slow down),3;
   //|               fast>slow,same direction(fast down,slow down),2;
   //|               fast>slow,no direction,1;
   //| return value: fast<slow,same direction,down,-5;
   //|               fast<slow,different direction(fast up,slow down),-4;
   //|               fast<slow,different direction(fast down,slow up),-3;
   //|               fast<slow,same direction(fast up,slow up),-2;
   //|               fast<slow,no direction,-1;
   //|               n/a:0
   //| return value: fast is above slow range upper:+10  
   //|               fast is below slow range lower:-10  
   //|               fast is above slow band upper:+20  
   //|               fast is below slow band lower:-20  
   arg_macd_status=getMACDStatus2(PERIOD_CURRENT,cur_bar_shift,arg_macd_slow,arg_macd_fast,arg_macd_range,arg_slow_pd,arg_fast_pd,arg_signal_pd,arg_deviation,arg_range_ratio);

   arg_bar_status=getBarStatus(PERIOD_CURRENT,cur_bar_shift,arg_thpt);
   //| return value: 1,positive bar;-1,negative bar

   int ret=0;
   if (cur_ret>10) {
      ret+=10;
   }
   if (cur_ret>0) {                          //macd is plus
      ret+=1;
   }
   if (cur_ret<-10) {
      ret+=-10;
   }
   if (cur_ret<0) {                          //macd is minus
      ret+=-1;
   }

   return ret;

}
//+------------------------------------------------------------------+
//| Trend strategy Open
//| date: 2018/5/9
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: +2,open buy;-2,open sell;
//|               1,stay open;-1,stay close;
//|               0,N/A
//+------------------------------------------------------------------+
int isTrendStgOpen4( int arg_shift,double &arg_ls_price,int &arg_last_band_st,
                     int arg_exp_pd=0,
                     int arg_long_pd=20,int arg_mid_pd=10,int arg_short_pd=5
                   )
{
   int bar_shift=arg_shift;
   
   double short_ma,mid_ma,long_ma;
   int ma_st=getMAStatus(PERIOD_CURRENT,bar_shift,short_ma,mid_ma,long_ma,arg_short_pd,arg_mid_pd,arg_long_pd);
   //expand to larger period
   int exp_bar_shift;
   int pd=expandPeriod(PERIOD_CURRENT,bar_shift,exp_bar_shift,arg_exp_pd);
   int ma_st2=getMAStatus(pd,exp_bar_shift,short_ma,mid_ma,long_ma,arg_short_pd,arg_mid_pd,arg_long_pd);
   //| return value: short>mid>long,1;
   //|               short<mid<long,-1;
   //|               n/a:0
   //+------------------------------------------------------------------+
   
   double d2_low,d2_high,d4_low,d4_high,d0_ma;
   int band_st=getBandStatus2(PERIOD_CURRENT,bar_shift,d2_low,d2_high,d4_low,d4_high,d0_ma,arg_mid_pd);
   //| return value: body in up half band,not touch band high and center,2;
   //|               body in up half band,high leg touch band high,3;
   //|               body in up half band,low leg touch band center,1;
   //| return value: body in low half band,not touch band low and center,-2;
   //|               body in low half band,low leg touch band low,-3;
   //|               body in low half band,high leg touch band center,-1;
   //|               n/a:0
   
   /*
   //debug
   string cur=Symbol();
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2018.06.29 04:00");
   datetime t2=StringToTime("2018.06.29 08:00");
   datetime t3=StringToTime("2018.06.29 12:00");
   if (cur=="NZDUSD" && (t==t1 || t==t2 || t==t3)) {
      Print("time=",t,",shift=",arg_shift);
      Print("ma_st=",ma_st,",ma_st2=",ma_st2);
      Print("last_band_st=",arg_last_band_st,",band_st=",band_st);
   }
   */
   
   int last_band_st=arg_last_band_st;
   if (ma_st2==1) {      //large period's trend is up
      arg_ls_price=d4_low;
      if (band_st==3 || band_st<0) {
         arg_last_band_st=band_st;
      }
      if (band_st==5 && ma_st==1) return 2;
      if ((band_st==1 || band_st==0) && last_band_st==3 && ma_st==1) {
         return 2;
      }
      return 1;
   }
   if (ma_st2==-1) {     //large period's trend is down
      arg_ls_price=d4_high;
      if (band_st==-3 || band_st>0) {
         arg_last_band_st=band_st;
      }
      if (band_st==-5 && ma_st==-1) return -2;
      if ((band_st==-1 || band_st==0) && last_band_st==-3 && ma_st==-1) {
         return -2;
      }
      return -1;
   }
   
   arg_ls_price=0;
   arg_last_band_st=0;
   return 0;

}
//+------------------------------------------------------------------+
//| Trend strategy Open
//| date: 2018/7/29
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: +3,open buy(band up);-3,open sell (band dw);
//|               +2,open buy(band dw);-2,open sell (band up);
//|               1,stay open;-1,stay close;
//|               0,N/A
//+------------------------------------------------------------------+
int isTrendStgOpen5( int arg_shift,double &arg_ls_price,
                     double arg_gap_ratio=0,int arg_exp_pd=0,
                     int arg_long_pd=20,int arg_mid_pd=10,int arg_short_pd=5
                   )
{
   int bar_shift=arg_shift;
   
   double short_ma,mid_ma,long_ma;
   //int ma_st=getMAStatus(PERIOD_CURRENT,bar_shift,short_ma,mid_ma,long_ma,arg_short_pd,arg_mid_pd,arg_long_pd);
   //expand to larger period
   int exp_bar_shift;
   int pd=expandPeriod(PERIOD_CURRENT,bar_shift,exp_bar_shift,arg_exp_pd);
   int ma_st2=getMAStatus(pd,exp_bar_shift,short_ma,mid_ma,long_ma,arg_short_pd,arg_mid_pd,arg_long_pd);
   //| return value: short>mid>long,1;
   //|               short<mid<long,-1;
   //|               n/a:0
   //+------------------------------------------------------------------+
   double macd_slow,macd_fast,macd_range;
   int macd_st=getMACDStatus2(PERIOD_CURRENT,bar_shift,macd_slow,macd_fast,macd_range);
   //| return value: fast>slow,same direction,up,5;
   //|               fast>slow,different direction(fast down,slow up),4;
   //|               fast>slow,different direction(fast up,slow down),3;
   //|               fast>slow,same direction(fast down,slow down),2;
   //|               fast>slow,no direction,1;
   //| return value: fast<slow,same direction,down,-5;
   //|               fast<slow,different direction(fast up,slow down),-4;
   //|               fast<slow,different direction(fast down,slow up),-3;
   //|               fast<slow,same direction(fast up,slow up),-2;
   //|               fast<slow,no direction,-1;
   //|               n/a:0
   //| return value: fast is above slow range upper:+10  
   //|               fast is below slow range lower:-10  
   //|               fast is above slow band upper:+20  
   //|               fast is below slow band lower:-20  

   int band_bar_pos[5],bar_status;
   double d2_low,d2_high,d4_low,d4_high,ma,d2_gap,d4_gap;
   getBandStatus3(NULL,bar_shift,d2_low,d2_high,d4_low,d4_high,ma,d2_gap,d4_gap,band_bar_pos,bar_status,arg_gap_ratio);
   //| return value:
   //| <<line pos>>
   //|     (above) 2
   //|  |  (high)  1
   //| [ ] (open)  0
   //| [ ] (close) 0
   //|  |  (low)   -1
   //|     (below) -2
   double high_pos=band_bar_pos[1];
   double low_pos=band_bar_pos[3];
   
   /*
   //debug
   string cur=Symbol();
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2018.06.29 04:00");
   datetime t2=StringToTime("2018.06.29 08:00");
   datetime t3=StringToTime("2018.06.29 12:00");
   if (cur=="NZDUSD" && (t==t1 || t==t2 || t==t3)) {
      Print("time=",t,",shift=",arg_shift);
      Print("ma_st=",ma_st,",ma_st2=",ma_st2);
      Print("high=",band_bar_pos[1]);
      Print("mid=",band_bar_pos[2]);
      Print("low=",band_bar_pos[3]);
      Print("st=",bar_status);
   }
   */
   
   if (ma_st2==1) {    //large period's trend is up, macd fast>slow
      if (macd_st>0) {
         if ((high_pos==1 || high_pos==0) && low_pos==-2) {    //bar hit band high
            arg_ls_price=d2_low;
            return 3;
         }
         if (high_pos==2 && (low_pos==-1 || low_pos==0) && bar_status==0) {  //bar hit band low, positive bar
            arg_ls_price=d4_low;
            return 2;
         }
         return 1;
      }
   }
   if (ma_st2==-1) {   //large period's trend is down, macd fast<slow
      if (macd_st<0) {
         if ((low_pos==-1 || low_pos==0) && high_pos==2) {    //bar hit band low
            arg_ls_price=d2_high;
            return -3;
         }
         if (low_pos==-2 && (high_pos==1 || high_pos==0) && bar_status==1) {  //bar hit band high, negative bar
            arg_ls_price=d4_high;
            return -2;
         }
         return -1;
      }
   }
   
   arg_ls_price=0;
   return 0;

}
//+------------------------------------------------------------------+
//| Trend strategy Open
//| date: 2018/9/18
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: +3,open buy(band up);-3,open sell (band dw);
//|               +2,open buy(band dw);-2,open sell (band up);
//|               1,stay open;-1,stay close;
//|               0,N/A
//+------------------------------------------------------------------+
int isTrendStgOpen6( int arg_shift,double &arg_ls_price,
                     double arg_gap_ratio=0,int arg_exp_pd=0,
                     int arg_long_pd=20,int arg_mid_pd=10,int arg_short_pd=5
                   )
{
   int bar_shift=arg_shift;
   
   double macd_slow,macd_fast,macd_range;
   int macd_st=getMACDStatus2(PERIOD_CURRENT,bar_shift,macd_slow,macd_fast,macd_range);
   //| return value: fast>slow,same direction,up,5;
   //|               fast>slow,different direction(fast down,slow up),4;
   //|               fast>slow,different direction(fast up,slow down),3;
   //|               fast>slow,same direction(fast down,slow down),2;
   //|               fast>slow,no direction,1;
   //| return value: fast<slow,same direction,down,-5;
   //|               fast<slow,different direction(fast up,slow down),-4;
   //|               fast<slow,different direction(fast down,slow up),-3;
   //|               fast<slow,same direction(fast up,slow up),-2;
   //|               fast<slow,no direction,-1;
   //|               n/a:0
   //| return value: fast is above slow range upper:+10  
   //|               fast is below slow range lower:-10  
   //|               fast is above slow band upper:+20  
   //|               fast is below slow band lower:-20  

   int band_bar_pos[5],bar_status;
   double d2_low,d2_high,d4_low,d4_high,ma,d2_gap,d4_gap;
   getBandStatus3(NULL,bar_shift,d2_low,d2_high,d4_low,d4_high,ma,d2_gap,d4_gap,band_bar_pos,bar_status,arg_gap_ratio);
   //| return value:
   //| <<line pos>>
   //|     (above) 2
   //|  |  (high)  1
   //| [ ] (open)  0
   //| [ ] (close) 0
   //|  |  (low)   -1
   //|     (below) -2
   double high_pos=band_bar_pos[1];
   double low_pos=band_bar_pos[3];
   
   /*
   //debug
   string cur=Symbol();
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2018.06.29 04:00");
   datetime t2=StringToTime("2018.06.29 08:00");
   datetime t3=StringToTime("2018.06.29 12:00");
   if (cur=="NZDUSD" && (t==t1 || t==t2 || t==t3)) {
      Print("time=",t,",shift=",arg_shift);
      Print("ma_st=",ma_st,",ma_st2=",ma_st2);
      Print("high=",band_bar_pos[1]);
      Print("mid=",band_bar_pos[2]);
      Print("low=",band_bar_pos[3]);
      Print("st=",bar_status);
   }
   */
   
   if (macd_st>0) {
      if ((high_pos==1 || high_pos==0) && low_pos==-2) {    //bar hit band high
         arg_ls_price=d2_low;
         return 3;
      }
      if (high_pos==2 && (low_pos==-1 || low_pos==0) && bar_status==0) {  //bar hit band low, positive bar
         arg_ls_price=d4_low;
         return 2;
      }
      return 1;
   }
   if (macd_st<0) {
      if ((low_pos==-1 || low_pos==0) && high_pos==2) {    //bar hit band low
         arg_ls_price=d2_high;
         return -3;
      }
      if (low_pos==-2 && (high_pos==1 || high_pos==0) && bar_status==1) {  //bar hit band high, negative bar
         arg_ls_price=d4_high;
         return -2;
      }
      return -1;
   }
   
   arg_ls_price=0;
   return 0;

}

//+------------------------------------------------------------------+
//| Trend strategy Open
//| date: 2018/11/25
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: +3,open buy(band up);-3,open sell (band dw);
//|               +2,open buy(band dw);-2,open sell (band up);
//|               1,stay open;-1,stay close;
//|               0,N/A
//+------------------------------------------------------------------+
int isTrendStgOpen7( int arg_shift,double &arg_ls_price,
                     double arg_gap_ratio=0, int arg_pd=720
                   )
{
   int bar_shift=arg_shift;
   
   int band_bar_pos[5],bar_status;
   double d2_low,d2_high,d4_low,d4_high,d2_gap,d4_gap,ma,ma2;
   getBandStatus3(NULL,bar_shift+1,d2_low,d2_high,d4_low,d4_high,ma2,d2_gap,d4_gap,band_bar_pos,bar_status,arg_gap_ratio,arg_pd);
   getBandStatus3(NULL,bar_shift,d2_low,d2_high,d4_low,d4_high,ma,d2_gap,d4_gap,band_bar_pos,bar_status,arg_gap_ratio,arg_pd);
   //| return value:
   //| <<line pos>>
   //|     (above) 2
   //|  |  (high)  1
   //| [ ] (open)  0
   //| [ ] (close) 0
   //|  |  (low)   -1
   //|     (below) -2
   double high_pos=band_bar_pos[1];
   double low_pos=band_bar_pos[3];
   double ma_pos=band_bar_pos[2];
   double ma_slop=ma-ma2;
   if (MathAbs(ma_slop)<Point()*0.1) ma_slop=0;
   /*
   //debug
   string cur=Symbol();
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2018.06.29 04:00");
   datetime t2=StringToTime("2018.06.29 08:00");
   datetime t3=StringToTime("2018.06.29 12:00");
   if (cur=="NZDUSD" && (t==t1 || t==t2 || t==t3)) {
      Print("time=",t,",shift=",arg_shift);
      Print("ma_st=",ma_st,",ma_st2=",ma_st2);
      Print("high=",band_bar_pos[1]);
      Print("mid=",band_bar_pos[2]);
      Print("low=",band_bar_pos[3]);
      Print("st=",bar_status);
   }
   */
   
   if (ma_slop>0) {
      if ((high_pos==1 || high_pos==0) && ma_pos==-2) {    //bar hit band high
         arg_ls_price=d4_low;
         return 3;
      }
      if (high_pos==2 && (ma_pos==1 || ma_pos==0 || ma_pos==-1)) {  //bar hit band ma
         arg_ls_price=d4_low;
         return 2;
      }
      return 1;
   }
   if (ma_slop<0) {
      if ((low_pos==-1 || low_pos==0) && ma_pos==2) {    //bar hit band low
         arg_ls_price=d4_high;
         return -3;
      }
      if (low_pos==-2 && (ma_pos==1 || ma_pos==0 || ma_pos==-1)) {  //bar hit band ma
         arg_ls_price=d4_high;
         return -2;
      }
      return -1;
   }
   
   arg_ls_price=0;
   return 0;
}

//+------------------------------------------------------------------+
//| Trend strategy Open
//| date: 2019/7/4
//| arg_shift: bar shift
//| &arg_ls_price: lose stop price(for return)
//| return value: +3,open buy(up);-3,open sell (dw)
//|               +2,keep buy(up);-2,keep sell (dw);
//|               +1,turn up;-1,turn dw;
//|               0,N/A
//+------------------------------------------------------------------+
int isTrendStgOpen8( int arg_shift,double &arg_ls_price,
                     double arg_off_pt=270, int arg_ma=60
                   )
{
   int bar_shift=arg_shift;
   int sig=0;
   int val_i;
   double val_h=0,val_l=0;
   
   //| return value: 
   //|   +1,up,2K;
   //|   +2,up,3K;
   //|   -1,down,2K;
   //|   -2,down,3K;
   //|   0,N/A;
   int ret=getBarStatus_illya(PERIOD_CURRENT,bar_shift);
   if (MathAbs(ret)==1) {     //2K
      val_i=iHighest(NULL,0,MODE_HIGH,2,bar_shift);
      if(val_i!=-1) val_h=High[val_i];
      else PrintFormat("Error in call iHighest. Error code=%d",GetLastError());

      val_i=iLowest(NULL,0,MODE_LOW,2,bar_shift);
      if(val_i!=-1) val_l=Low[val_i];
      else PrintFormat("Error in call iLowest. Error code=%d",GetLastError());
   }
   if (MathAbs(ret)==2) {     //3K
      val_i=iHighest(NULL,0,MODE_HIGH,3,bar_shift);
      if(val_i!=-1) val_h=High[val_i];
      else PrintFormat("Error in call iHighest. Error code=%d",GetLastError());

      val_i=iLowest(NULL,0,MODE_LOW,3,bar_shift);
      if(val_i!=-1) val_l=Low[val_i];
      else PrintFormat("Error in call iLowest. Error code=%d",GetLastError());
   }
   
   if (ret!=0) {
      double cur_price=Close[bar_shift];
      double cur_high=High[bar_shift];
      double cur_low=Low[bar_shift];
      double cur_ma=iMA(NULL,0,arg_ma,0,MODE_SMA,PRICE_CLOSE,bar_shift);
      if (ret>0) {
         arg_ls_price=val_l-arg_off_pt*Point();
         if (cur_price>cur_ma) {    //above sma up signal, open buy order
            if ((MathAbs(cur_high-cur_ma)+MathAbs(cur_low-cur_ma))==(cur_high-cur_low)) {    // sma is in the bar
               return 3;
            } else 
               return 2;
         }
         return 1;
      }
      if (ret<0) {
         arg_ls_price=val_h+arg_off_pt*Point();
         if (cur_price<cur_ma) {    //below sma dw signal, open sell order
            if ((MathAbs(cur_high-cur_ma)+MathAbs(cur_low-cur_ma))==(cur_high-cur_low)) {    // sma is in the bar
               return -3;
            } else 
               return -2;
         }
         return -1;
      }
   }

   /*
   //debug
   string cur=Symbol();
   datetime t=Time[arg_shift];
   datetime t1=StringToTime("2018.06.29 04:00");
   datetime t2=StringToTime("2018.06.29 08:00");
   datetime t3=StringToTime("2018.06.29 12:00");
   if (cur=="NZDUSD" && (t==t1 || t==t2 || t==t3)) {
      Print("time=",t,",shift=",arg_shift);
      Print("ma_st=",ma_st,",ma_st2=",ma_st2);
      Print("high=",band_bar_pos[1]);
      Print("mid=",band_bar_pos[2]);
      Print("low=",band_bar_pos[3]);
      Print("st=",bar_status);
   }
   */
   
   arg_ls_price=0;
   return 0;
}

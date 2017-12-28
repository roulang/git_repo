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
//| date: 2017/12/19
//| arg_shift: bar shift
//| arg_last_cross: 1,fast ma up cross slow ma;-1,fast ma down cross slow ma
//| &arg_ls_price: lose stop price(for return)
//| return value: -2,sell(open);2,buy(open);-1,fast ma down cross slow ma;1,fast ma up cross slow ma;0:n/a
//+------------------------------------------------------------------+
int isTrendStgOpen(int arg_shift,int &arg_last_cross,double &arg_ls_price,int arg_ls_pt=100)
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

   if (cur_ret>=10 && arg_last_cross!=1) {   //short ma up cross mid ma
      arg_last_cross=1;
      return 1;
   }
   if (cur_ret<=-10 && arg_last_cross!=-1) {   //short ma down cross mid ma
      arg_last_cross=-1;
      return -1;
   }
   
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
      if (cur_ret==4 || cur_ret==5) {              //short ma is above mid ma,mid ma is up
         if (cur_short_ma_touch==3) {              //current bar is positive and under touch short ma
            if (MathAbs(lst_short_ma_touch)>=3) {   //last bar is above or under touch short ma
               return 2;
            }
         }
      }
   } else if   (arg_last_cross==-1) {              //fast ma down cross slow ma
      if (cur_ret==-4 || cur_ret==-5) {            //short ma is below mid ma,mid ma is down
         if (cur_short_ma_touch==-1) {             //current bar is negative and high touch short ma
            if (MathAbs(lst_short_ma_touch)<=1) {  //last bar is below or high touch short ma
               return -2;
            }
         }
      }
   }

   return 0;
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
                        int &arg_ls_price_pt[],int &arg_tp_price_pt[][],
                        int arg_lspt=50,double arg_ls_ratio=0.6,
                        int arg_length=20,int arg_th_pt=0,int arg_expand=1,int arg_long=1,
                        int arg_oc_gap_pt=5,int arg_high_low_gap_pt=150,int arg_gap_pt2=20,
                        int arg_atr_lvl_pt=5,int arg_atr_range=5,
                        int arg_short_ma_ped=12,int arg_mid_ma_ped=36
                      )
{

   //clear
   ArrayInitialize(arg_price,0);
   ArrayInitialize(arg_ls_price,0);
   ArrayInitialize(arg_ls_price_pt,0);
   ArrayInitialize(arg_tp_price,0);
   ArrayInitialize(arg_tp_price_pt,0);

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
   double atr_lvl=arg_atr_lvl_pt*Point;
   int atr=getAtrValue(cur_bar_shift,atr_lvl,arg_atr_range);
   if (ret!=0) {
      if (atr==0) {
         Print(t,"atr too small(<=",atr_lvl,")");
         ret=0;
      }
   }
      
   //add ma condition
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
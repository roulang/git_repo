//+------------------------------------------------------------------+
//|                                                    lang_macd.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 7
#property  indicator_color1  Silver
#property  indicator_width1  1
#property  indicator_color2  Red
#property  indicator_color3  LightSeaGreen
#property  indicator_style3  STYLE_DASH
#property  indicator_color4  LightSeaGreen
#property  indicator_style4  STYLE_DASH
#property  indicator_color6  Yellow
#property  indicator_style6  STYLE_DOT
#property  indicator_color7  Yellow
#property  indicator_style7  STYLE_DOT

//--- indicator parameters
input int InpFastEMA=12;   // Fast EMA Period
input int InpSlowEMA=26;   // Slow EMA Period
input int InpSignalSMA=9;  // Signal SMA Period

input int      InpBandsShift=0;        // Bands Shift
input double   InpBandsDeviations=2.0; // Bands Deviations

//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
double    ExtUpperBuffer[];
double    ExtLowerBuffer[];
double    ExtStdDevBuffer[];
double    ExtUpperBuffer2[];
double    ExtLowerBuffer2[];

//--- right input parameters flag
bool      ExtParameters=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{
   IndicatorDigits(Digits+1);

//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
   SetIndexDrawBegin(2,InpSignalSMA+InpBandsShift);
   SetIndexDrawBegin(3,InpSignalSMA+InpBandsShift);
   SetIndexDrawBegin(4,InpSignalSMA+InpBandsShift);
   SetIndexDrawBegin(5,InpSignalSMA+InpBandsShift);

//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
   SetIndexBuffer(2,ExtUpperBuffer);
   SetIndexBuffer(3,ExtLowerBuffer);
   SetIndexBuffer(5,ExtUpperBuffer2);
   SetIndexBuffer(6,ExtLowerBuffer2);
//--- work buffer
   SetIndexBuffer(4,ExtStdDevBuffer);

//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"SignalB(up)");
   SetIndexLabel(3,"SignalB(low)");
   SetIndexLabel(5,"SignalR(up)");
   SetIndexLabel(6,"SignalR(low)");
//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA) {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
   } else {
      ExtParameters=true;
   }
   
//--- initialization done
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)
      return(0);

//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++) {
      ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                    iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
   }

//--- signal line counted in the 2-nd buffer
   BandOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer,
                ExtUpperBuffer,ExtLowerBuffer,ExtStdDevBuffer);
   RangeOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer,
                ExtUpperBuffer2,ExtLowerBuffer2);

//--- done
   return(rates_total);
}
//+------------------------------------------------------------------+
//| band on price array                                              |
//+------------------------------------------------------------------+
int BandOnBuffer(const int rates_total,const int prev_calculated,const int begin,
                 const int period,const double& price[],double& buffer[],
                 double& buffer_upper[],double& buffer_lower[],double& buffer_std[])
{
   int i,limit;
//--- check for data
   if(period<=1 || rates_total-begin<period) return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_buffer=ArrayGetAsSeries(buffer);
   bool as_series_buffer_upper=ArrayGetAsSeries(buffer_upper);
   bool as_series_buffer_lower=ArrayGetAsSeries(buffer_lower);
   bool as_series_buffer_std=ArrayGetAsSeries(buffer_std);
   if(as_series_price)  ArraySetAsSeries(price,false);
   if(as_series_buffer) ArraySetAsSeries(buffer,false);
   if(as_series_buffer_upper) ArraySetAsSeries(buffer_upper,false);
   if(as_series_buffer_lower) ArraySetAsSeries(buffer_lower,false);
   if(as_series_buffer_std) ArraySetAsSeries(buffer_std,false);
//--- first calculation or number of bars was changed
   if(prev_calculated==0) {   // first calculation
      limit=period+begin;
      //--- set empty value for first bars
      for(i=0;i<limit-1;i++) {
         buffer[i]=0.0;
         buffer_upper[i]=0.0;
         buffer_lower[i]=0.0;
         buffer_std[i]=0.0;
      }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
      firstValue/=period;
      buffer[limit-1]=firstValue;
   }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total;i++) {
      buffer[i]=buffer[i-1]+(price[i]-price[i-period])/period;
      buffer_std[i]=StdDev_Func(i,price,buffer,period);
      buffer_upper[i]=buffer[i]+InpBandsDeviations*buffer_std[i];
      buffer_lower[i]=buffer[i]-InpBandsDeviations*buffer_std[i];
   }
//--- restore as_series flags
   if(as_series_price)  ArraySetAsSeries(price,true);
   if(as_series_buffer) ArraySetAsSeries(buffer,true);
   if(as_series_buffer_upper) ArraySetAsSeries(buffer_upper,true);
   if(as_series_buffer_lower) ArraySetAsSeries(buffer_lower,true);
   if(as_series_buffer_std) ArraySetAsSeries(buffer_std,true);
//---
    return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
{
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position>=period) {
      //--- calcualte StdDev
      for(int i=0; i<period; i++)
         StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
      StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
   }
//--- return calculated value
   return(StdDev_dTmp);
}
//+------------------------------------------------------------------+
//| range on price array                                              |
//+------------------------------------------------------------------+
int RangeOnBuffer(const int rates_total,const int prev_calculated,const int begin,
                 const int period,const double& price[],double& buffer[],
                 double& buffer_upper[],double& buffer_lower[])
{
   int i,limit;
//--- check for data
   if(period<=1 || rates_total-begin<period) return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_buffer=ArrayGetAsSeries(buffer);
   bool as_series_buffer_upper=ArrayGetAsSeries(buffer_upper);
   bool as_series_buffer_lower=ArrayGetAsSeries(buffer_lower);
   if(as_series_price)  ArraySetAsSeries(price,false);
   if(as_series_buffer) ArraySetAsSeries(buffer,false);
   if(as_series_buffer_upper) ArraySetAsSeries(buffer_upper,false);
   if(as_series_buffer_lower) ArraySetAsSeries(buffer_lower,false);
//--- first calculation or number of bars was changed
   if(prev_calculated==0) {   // first calculation
      limit=period+begin;
      //--- set empty value for first bars
      for(i=0;i<limit-1;i++) {
         buffer[i]=0.0;
         buffer_upper[i]=0.0;
         buffer_lower[i]=0.0;
      }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++) {
         firstValue+=price[i];
      }
      firstValue/=period;
      buffer[limit-1]=firstValue;
   }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total;i++) {
      buffer[i]=buffer[i-1]+(price[i]-price[i-period])/period;
      double max=Max_Func(i-1,price,period);
      buffer_upper[i]=max;
      buffer_lower[i]=-max;
   }
//--- restore as_series flags
   if(as_series_price)  ArraySetAsSeries(price,true);
   if(as_series_buffer) ArraySetAsSeries(buffer,true);
   if(as_series_buffer_upper) ArraySetAsSeries(buffer_upper,true);
   if(as_series_buffer_lower) ArraySetAsSeries(buffer_lower,true);
//---
    return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double Max_Func(int position,const double &price[],int period)
{
//--- variables
   double Max_dTmp=0.0;
//--- check for position
   if(position>=period) {
      //--- calcualte StdDev
      for(int i=0; i<period; i++)
         if (MathAbs(price[position-i])>Max_dTmp) Max_dTmp=MathAbs(price[position-i]);
   }
//--- return calculated value
   return(Max_dTmp);
}

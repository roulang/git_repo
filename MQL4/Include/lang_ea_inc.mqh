//+------------------------------------------------------------------+
//|                                                  lang_ea_inc.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <lang_stg_inc.mqh>

//input
input bool     i_sendmail=true;
input int      i_equity_percent=1;
input double   i_max_lots=0.01;
input int      i_slippage=5;
input int      i_ls_pt=100;      //take lose point
//input bool     i_skip_jpychf_usd_relate=true;

//--- input
//input bool     i_time_control=false;   // time zone control
//input bool     i_news_skip=true;       // news zone skip
//input int      i_news_bef=SEC_H1/4;    // news before 1/4 hour
//input int      i_news_aft=SEC_H1;      // news after 1 hour
//input int      i_zone_bef=SEC_H1/2;    // time zone before 30 minutes
//input int      i_zone_aft=0;           // time zone after 1 hour

//--- global
int      g_LossStopPt = 150;
int      g_ProfitStopPt = 300;
int      g_OOPt = 100;

//+------------------------------------------------------------------+
// OrderBuy2 (auto set risk volume)
// argPrice: Price (0 for not set, buy current)
// argLsPrice: Loss Stop Value (0 for not set, use LossStopPt)
// argPsPrice: Profit Stop Value (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderBuy2(double argPrice, double argLsPrice, double argPsPrice, int argMag)
{
   double pt = Point;
   //double g = Ask - Bid;
   //double gap = NormalizeDouble(g / pt, 0);
   double price = Ask;
   int cmd = OP_BUY;
   if (argPrice != 0) {
	   if (argPrice > price) {
		   cmd = OP_BUYSTOP;
	   } else {
		   cmd = OP_BUYLIMIT;
	   }
      price = argPrice;
   }

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (argLsPrice == 0) {
      ls_price = NormalizeDouble(price - g_LossStopPt * pt, Digits);
	   ls_pt = g_LossStopPt;
   } else {
      ls_price = argLsPrice;
      ls_pt = NormalizeDouble((price - ls_price) / pt, 0);
   }
   
   if (argPsPrice == 0) {
      ps_price = NormalizeDouble(price + g_ProfitStopPt * pt, Digits);
	   ps_pt = g_ProfitStopPt;
   } else if (argPsPrice == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = argPsPrice;
      ps_pt = NormalizeDouble((ps_price - price) / pt, 0);
   }

   double risk_vol = getVolume(i_equity_percent, ls_pt);
   if (risk_vol > i_max_lots) risk_vol = i_max_lots;
   
   s_Order order;
   order.sym=Symbol();
   order.type=cmd;
   order.lots=risk_vol;
   order.open_p=price;
   order.open_t=0;
   order.sl_p=ls_price;
   order.tp_p=ps_price;
   order.com="OrderBuy2";
   order.mag=argMag;

   //<<<<debug
   if (g_debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      //printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int ret = 0;
   int slippage=getSlippage(NULL,i_slippage);
   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, slippage, ls_price, ps_price, "", argMag, 0, Green);
   }
   
   if (ret <0 )
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd,risk_vol,price,ls_price,ps_price,"",argMag);
      order.tic=ret;
      writeOrderCmdToFile(order);
      return true;
   }
   else return false;
}

//+------------------------------------------------------------------+
// OrderSell2 (auto set risk volume)
// argPrice: Price (0 for not set, sell current)
// argLsPrice: Loss Stop Value (0 for not set, use LossStopPt)
// argPsPrice: Profit Stop Value (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderSell2(double argPrice, double argLsPrice, double argPsPrice, int argMag)
{
   double pt = Point;
   //double g = Ask - Bid;
   //double gap = NormalizeDouble(g / pt, 0);
   double price = Bid;
   int cmd = OP_SELL;
   if (argPrice != 0) {
	   if (argPrice > price) {
		   cmd = OP_SELLLIMIT;
	   } else {
		   cmd = OP_SELLSTOP;
	   }
      price = argPrice;
   }

   double ls_price;
   double ps_price;
   double ls_pt;
   double ps_pt;
   if (argLsPrice == 0) {
      ls_price = NormalizeDouble(price + g_LossStopPt * pt, Digits);
	   ls_pt = g_LossStopPt;
   } else {
      ls_price = argLsPrice;
      ls_pt = NormalizeDouble((ls_price - price) / pt, 0);
   }
   
   if (argPsPrice == 0) {
      ps_price = NormalizeDouble(price - g_ProfitStopPt * pt, Digits);
	   ps_pt = g_ProfitStopPt;
   } else if (argPsPrice == -1) {
      ps_price = 0;
      ps_pt = 0;
   } else {
      ps_price = argPsPrice;
      ps_pt = NormalizeDouble((price- ps_price) / pt, 0);
   }

   double risk_vol = getVolume(i_equity_percent, ls_pt);
   if (risk_vol > i_max_lots) risk_vol = i_max_lots;

   s_Order order;
   order.sym=Symbol();
   order.type=cmd;
   order.lots=risk_vol;
   order.open_p=price;
   order.open_t=0;
   order.sl_p=ls_price;
   order.tp_p=ps_price;
   order.com="OrderSell2";
   order.mag=argMag;

   //<<<<debug
   if (g_debug) {
      Print("<<<<debug");
      printf("command=%d", cmd);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price=%.5f", price);
      printf("loss stop price=%.5f", ls_price);
      printf("loss stop point=%.5f", ls_pt);
      printf("profit stop price=%.5f", ps_price);
      printf("profit stop point=%.5f", ps_pt);
      //printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int ret = 0;
   int slippage=getSlippage(NULL,i_slippage);
   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd, risk_vol, price, slippage, ls_price, ps_price, "", argMag, 0, Red);
   }
   
   if (ret < 0)
   {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd,risk_vol,price,ls_price,ps_price,"",argMag);   
      order.tic=ret;
      writeOrderCmdToFile(order);
      return true;
   }
   else return false;

}

//+------------------------------------------------------------------+
// OrderOO (buy stop and sell stop at two directions,auto set risk volume)
// argOPt: offset point
// argLsPt: Loss Stop Point (0 for not set, use LossStopPt)
// argPsPt: Profit Stop Point (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderOO(int argMag, int argOPt=0, int argLsPt=0, int argPsPt=0)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   if (argOPt == 0) argOPt = g_OOPt;
   double price1 = Bid;
   price1 = NormalizeDouble(price1 - argOPt * pt, Digits);  //sell price
   double price2 = Ask;
   price2 = NormalizeDouble(price2 + argOPt * pt, Digits);  //buy price
   int cmd1 = OP_SELLSTOP;
   int cmd2 = OP_BUYSTOP;

   if (argLsPt == 0) argLsPt = g_LossStopPt;
   if (argPsPt == 0) argPsPt = g_ProfitStopPt;
   
   double ls_price1; //sell's lose stop
   double ps_price1; //sell's profit stop
   ls_price1 = NormalizeDouble(price1 + argLsPt * pt, Digits);
   if (argPsPt == -1) {
      ps_price1 = 0;
   } else {
      ps_price1 = NormalizeDouble(price1 - argPsPt * pt, Digits);
   }

   double ls_price2; //buy's lose stop
   double ps_price2; //buy's profit stop
   ls_price2 = NormalizeDouble(price2 - argLsPt * pt, Digits);
   if (argPsPt == -1) {
      ps_price2 = 0;
   } else {
      ps_price2 = NormalizeDouble(price2 + argPsPt * pt, Digits);
   }

   double risk_vol = getVolume(i_equity_percent, argLsPt);
   if (risk_vol > i_max_lots) risk_vol = i_max_lots;

   s_Order order;
   order.sym=Symbol();
   order.type=cmd1;
   order.lots=risk_vol;
   order.open_p=price1;
   order.open_t=0;
   order.sl_p=ls_price1;
   order.tp_p=ps_price1;
   order.com="OrderOO";
   order.mag=argMag;

   s_Order order2;
   order2.sym=Symbol();
   order2.type=cmd2;
   order2.lots=risk_vol;
   order2.open_p=price2;
   order2.open_t=0;
   order2.sl_p=ls_price2;
   order2.tp_p=ps_price2;
   order2.com="OrderOO";
   order2.mag=argMag;

   //<<<<debug
   if (g_debug) {
      Print("<<<<debug");
      printf("command1=%d", cmd1);
      printf("command2=%d", cmd2);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price1=%.5f", price1);
      printf("price2=%.5f", price2);
      printf("loss stop point=%.5f", argLsPt);
      printf("profit stop point=%.5f", argPsPt);
      printf("loss stop price1=%.5f", ls_price1);
      printf("profit stop price1=%.5f", ps_price1);
      printf("loss stop price2=%.5f", ls_price2);
      printf("profit stop price2=%.5f", ps_price2);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int slippage=getSlippage(NULL,i_slippage);
   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd1, risk_vol, price1, slippage, ls_price1, ps_price1, "", argMag, 0, Red);  //sell stop order
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd1,risk_vol,price1,ls_price1,ps_price1,"",argMag);   
      order.tic=ret;
      writeOrderCmdToFile(order);
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }
   
   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd2, risk_vol, price2, slippage, ls_price2, ps_price2, "", argMag, 0, Green); //buy stop order
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd2,risk_vol,price2,ls_price2,ps_price2,"",argMag);   
      order2.tic=ret;
      writeOrderCmdToFile(order2);
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }

   return true;

}

//+------------------------------------------------------------------+
// OrderOO (buy stop and sell stop at two directions,auto set risk volume)
// argPrice1: sell stop price
// argPrice2: buy stop price
// argLs1: loss stop price for sell stop (0 for not set, use LossStopPt)
// argPs1: profit stop price for sell stop (0 use ProfitStopPt, -1 not set profit stop)
// argLs2: loss stop price for buy stop (0 for not set, use LossStopPt)
// argPs2: profit stop price for buy stop (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderOO2(int argMag, double argPrice1, double argPrice2, double argLs1=0, double argPs1=0, double argLs2=0, double argPs2=0)
{
   
   if (argPrice1>=argPrice2 || argPrice1>=Bid || argPrice2<=Ask ) return false;

   double pt=Point;
   double g=Ask-Bid;
   double gap=NormalizeDouble(g / pt, 0);
   
   double price1=argPrice1;       //sell stop price
   double price2=argPrice2;       //buy stop price
   int cmd1=OP_SELLSTOP;
   int cmd2=OP_BUYSTOP;
   
   double ls_price1; //lose stop price for sell stop
   double ps_price1; //profit stop price for sell stop
   if (argLs1==0) ls_price1=NormalizeDouble(price1+g_LossStopPt*pt,Digits);
   else ls_price1=argLs1;
   if (argPs1==0) ps_price1=NormalizeDouble(price1-g_ProfitStopPt*pt,Digits);
   else if(argPs1==-1) ps_price1=0;
   else ps_price1=argPs1;

   double ls_price2; //lose stop price for buy stop
   double ps_price2; //profit stop price for buy stop
   if (argLs2==0) ls_price2=NormalizeDouble(price1-g_LossStopPt*pt,Digits);
   else ls_price2=argLs2;
   if (argPs2==0) ps_price2=NormalizeDouble(price1+g_ProfitStopPt*pt,Digits);
   else if(argPs2==-1) ps_price2=0;
   else ps_price2=argPs2;

   double ls_pt1=(ls_price1-price1)/pt;
   double ls_pt2=(price2-ls_price2)/pt;
   double ls_pt=MathMax(ls_pt1,ls_pt2);
   double risk_vol=getVolume(i_equity_percent, ls_pt);
   if (risk_vol>i_max_lots) risk_vol=i_max_lots;

   s_Order order;
   order.sym=Symbol();
   order.type=cmd1;
   order.lots=risk_vol;
   order.open_p=price1;
   order.open_t=0;
   order.sl_p=ls_price1;
   order.tp_p=ps_price1;
   order.com="OrderOO2";
   order.mag=argMag;

   s_Order order2;
   order2.sym=Symbol();
   order2.type=cmd2;
   order2.lots=risk_vol;
   order2.open_p=price2;
   order2.open_t=0;
   order2.sl_p=ls_price2;
   order2.tp_p=ps_price2;
   order2.com="OrderOO2";
   order2.mag=argMag;

   //<<<<debug
   if (g_debug) {
      Print("<<<<debug");
      printf("command1=%d", cmd1);
      printf("command2=%d", cmd2);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price1=%.5f", price1);
      printf("price2=%.5f", price2);
      printf("loss stop price1=%.5f", ls_price1);
      printf("profit stop price1=%.5f", ps_price1);
      printf("loss stop price2=%.5f", ls_price2);
      printf("profit stop price2=%.5f", ps_price2);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int slippage=getSlippage(NULL,i_slippage);

   int ret=0;
   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd1, risk_vol, price1, slippage, ls_price1, ps_price1, "", argMag, 0, Red);  //sell stop order
   }
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd1,risk_vol,price1,ls_price1,ps_price1,"",argMag);   
      order.tic=ret;
      writeOrderCmdToFile(order);
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }

   ret=0;
   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd2, risk_vol, price2, slippage, ls_price2, ps_price2, "", argMag, 0, Green); //buy stop order
   }
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd2,risk_vol,price2,ls_price2,ps_price2,"",argMag);   
      order2.tic=ret;
      writeOrderCmdToFile(order2);
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }

   return true;

}
//+------------------------------------------------------------------+
// OrderOO (buy direct and sell direct at two directions,auto set risk volume)
// argLsPt: Loss Stop Point (0 for not set, use LossStopPt)
// argPsPt: Profit Stop Point (0 use ProfitStopPt, -1 not set profit stop)
// argCom: Comment
// argMag: Magic
//+------------------------------------------------------------------+
bool OrderOO3(int argMag, int argLsPt=0, int argPsPt=0)
{
   int ret = 0;
   double pt = Point;
   double g = Ask - Bid;
   double gap = NormalizeDouble(g / pt, 0);
   double price1 = Bid;
   double price2 = Ask;
   int cmd1 = OP_SELL;
   int cmd2 = OP_BUY;

   if (argLsPt == 0) argLsPt = g_LossStopPt;
   if (argPsPt == 0) argPsPt = g_ProfitStopPt;
   
   double ls_price1; //sell's lose stop
   double ps_price1; //sell's profit stop
   ls_price1 = NormalizeDouble(price1 + argLsPt * pt, Digits);
   if (argPsPt == -1) {
      ps_price1 = 0;
   } else {
      ps_price1 = NormalizeDouble(price1 - argPsPt * pt, Digits);
   }

   double ls_price2; //buy's lose stop
   double ps_price2; //buy's profit stop
   ls_price2 = NormalizeDouble(price2 - argLsPt * pt, Digits);
   if (argPsPt == -1) {
      ps_price2 = 0;
   } else {
      ps_price2 = NormalizeDouble(price2 + argPsPt * pt, Digits);
   }

   double risk_vol = getVolume(i_equity_percent, argLsPt);
   if (risk_vol > i_max_lots) risk_vol = i_max_lots;

   s_Order order;
   order.sym=Symbol();
   order.type=cmd1;
   order.lots=risk_vol;
   order.open_p=price1;
   order.open_t=0;
   order.sl_p=ls_price1;
   order.tp_p=ps_price1;
   order.com="OrderOO3";
   order.mag=argMag;

   s_Order order2;
   order2.sym=Symbol();
   order2.type=cmd2;
   order2.lots=risk_vol;
   order2.open_p=price2;
   order2.open_t=0;
   order2.sl_p=ls_price2;
   order2.tp_p=ps_price2;
   order2.com="OrderOO3";
   order2.mag=argMag;

   //<<<<debug
   if (g_debug) {
      Print("<<<<debug");
      printf("command1=%d", cmd1);
      printf("command2=%d", cmd2);
      printf("volume=%.5f", risk_vol);
      printf("point=%.5f", pt);
      printf("price1=%.5f", price1);
      printf("price2=%.5f", price2);
      printf("loss stop point=%.5f", argLsPt);
      printf("profit stop point=%.5f", argPsPt);
      printf("loss stop price1=%.5f", ls_price1);
      printf("profit stop price1=%.5f", ps_price1);
      printf("loss stop price2=%.5f", ls_price2);
      printf("profit stop price2=%.5f", ps_price2);
      printf("gap=%.0f", gap);
      Print("debug>>>>");
   }
   //debug>>>>

   int slippage=getSlippage(NULL,i_slippage);

   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd1, risk_vol, price1, slippage, ls_price1, ps_price1, "", argMag, 0, Red);  //sell order
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd1,risk_vol,price1,ls_price1,ps_price1,"",argMag);   
      order.tic=ret;
      writeOrderCmdToFile(order);
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }
   
   if (!g_debug) {
      ret = OrderSend(Symbol(), cmd2, risk_vol, price2, slippage, ls_price2, ps_price2, "", argMag, 0, Green); //buy order
   }
   
   if (ret > 0) {
      mailNoticeOrderOpen(ret,Symbol(),cmd2,risk_vol,price2,ls_price2,ps_price2,"",argMag);   
      order2.tic=ret;
      writeOrderCmdToFile(order2);
   } else {
      int check=GetLastError(); 
      if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check));
      return false;
   }

   return true;

}

// type:1 buy,2 buy stop,-1 sell,-2 sell stop,0 all
int OrderCloseA(string symbol, int type, int magic)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   //Print("1=",symbol,",2=",type,",3=",comment,",4=",magic);
   int t=OrdersTotal();
   //Print("t=",t);
   int cnt=0;
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      //Print("ret=",ret);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         //if((type==0 && StringCompare(OrderSymbol(),cur)==0 && OrderMagicNumber()==magic) ||
         //   (type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic) ||
         //   (type==2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUYSTOP && OrderMagicNumber()==magic) ||
         //   (type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic) ||
         //   (type==-2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELLSTOP && OrderMagicNumber()==magic)) 
         if (isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,magic,type)) {
            if(OrderType()==OP_BUY) {
               //Print("send close buy order command");
               ret=OrderClose(OrderTicket(),OrderLots(),Bid,0,Green);
            }
            if(OrderType()==OP_SELL) {
               //Print("send close sell order command");
               ret=OrderClose(OrderTicket(),OrderLots(),Ask,0,Red);
            }
            if(OrderType()==OP_BUYSTOP) {
               //Print("send delete order command");
               ret=OrderDelete(OrderTicket(),Green);
            }
            if(OrderType()==OP_SELLSTOP) {
               //Print("send delete order command");
               ret=OrderDelete(OrderTicket(),Red);
            }
            
            if (ret!=true) {
               int check=GetLastError(); 
               if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
            } else {
               cnt++;
            }
         }
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return cnt;
}

// type:1 buy,2 buy stop,-1 sell,-2 sell stop,0 all
bool FindOrderA(string symbol, int type, int magic)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         //if((type==0 && StringCompare(OrderSymbol(),cur)==0 && OrderMagicNumber()==magic) ||
         //   (type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic) ||
         //   (type==2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUYSTOP && OrderMagicNumber()==magic) ||
         //   (type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic) ||
         //   (type==-2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELLSTOP && OrderMagicNumber()==magic)) 
         if (isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,magic,type)) {
            return true;
         }
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return false;
}
bool FindOrderCnt(string arg_symbol, int arg_magic, int &arg_buy_cnt, int &arg_sell_cnt, double &arg_ord_pft)
{
   string cur;
   if (arg_symbol==NULL) cur=Symbol();
   else cur=arg_symbol;
   
   int t=OrdersTotal();
   int b_cnt,s_cnt;
   b_cnt=s_cnt=0;
   double b_pft,s_pft;
   b_pft=s_pft=0;
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         //if((type==0 && StringCompare(OrderSymbol(),cur)==0 && OrderMagicNumber()==magic) ||
         //   (type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic) ||
         //   (type==2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUYSTOP && OrderMagicNumber()==magic) ||
         //   (type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic) ||
         //   (type==-2 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELLSTOP && OrderMagicNumber()==magic)) 
         if (isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,arg_magic,1)) {
            b_cnt+=1;
            if (OrderProfit()<0) {
               b_pft=OrderProfit();
            }
         }
         if (isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,arg_magic,-1)) {
            s_cnt+=1;
            if (OrderProfit()<0) {
               s_pft=OrderProfit();
            }
         }
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   
   arg_buy_cnt=b_cnt;
   arg_sell_cnt=s_cnt;
   arg_ord_pft=0;
   if (b_pft<0) arg_ord_pft=b_pft;
   if (s_pft<0) arg_ord_pft=s_pft;
      
   if ((b_cnt+s_cnt)>0) return true;
   
   return false;

}
//+------------------------------------------------------------------+
//| moving stop function
//| type:1 buy,-1 sell
//| spt:stop point
//+------------------------------------------------------------------+
bool movingStop(string symbol, int type, int magic, int shift, int spt)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   bool ret2=false;
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         //if((type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic))
         if (type==1 && isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,magic,type))
         {
            //buy order
            //double cur_price=Bid;
            double cur_price=Close[shift];
            double max_lose_stop_price=NormalizeDouble(cur_price-spt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            if (max_lose_stop_price>cur_lose_stop_price) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit(),0,Green);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         //if((type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic)) 
         if (type==-1 && isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,magic,type))
         {
            //sell order
            //double cur_price=Ask;
            double cur_price=Close[shift];
            double max_lose_stop_price=NormalizeDouble(cur_price+spt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            if (max_lose_stop_price<cur_lose_stop_price || cur_lose_stop_price==0) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit(),0,Red);
               if (!ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),max_lose_stop_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return ret2;
}

//+------------------------------------------------------------------+
//| moving stop function (set to min profit point)
//| type:1 buy,-1 sell
//| tpt:threhold point
//| ppt:profit point
//+------------------------------------------------------------------+
bool movingStop2(string symbol, int type, int magic, int shift, int tpt, int ppt)
{
   string cur;
   if (symbol==NULL) cur=Symbol();
   else cur=symbol;

   bool ret2=false;
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         //if((type==1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_BUY && OrderMagicNumber()==magic))
         if (type==1 && isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,magic,type))
         {
            //buy order
            //double cur_price=Bid;
            double cur_price=Close[shift];
            double threhold_price=NormalizeDouble(OrderOpenPrice()+tpt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            double min_profit_price=NormalizeDouble(OrderOpenPrice()+ppt,Digits);
            if (cur_price>threhold_price && cur_lose_stop_price<min_profit_price) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),min_profit_price,OrderTakeProfit(),0,Green);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),min_profit_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         //if((type==-1 && StringCompare(OrderSymbol(),cur)==0 && OrderType()==OP_SELL && OrderMagicNumber()==magic)) 
         if (type==-1 && isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,magic,type))
         {
            //sell order
            //double cur_price=Ask;
            double cur_price=Close[shift];
            double threhold_price=NormalizeDouble(OrderOpenPrice()-tpt*Point,Digits);
            double cur_lose_stop_price=NormalizeDouble(OrderStopLoss(),Digits);
            double min_profit_price=NormalizeDouble(OrderOpenPrice()-ppt,Digits);
            if (cur_price<threhold_price && cur_lose_stop_price>min_profit_price) {
               ret2=OrderModify(OrderTicket(),OrderOpenPrice(),min_profit_price,OrderTakeProfit(),0,Red);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),min_profit_price,OrderTakeProfit());
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            }
         }
         
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return ret2;
}

//+------------------------------------------------------------------+
//| moving stop function 
//| if (open_price!=ls_price && price>open_price+(open_price-ls_price)) set ls_price=open_price
//+------------------------------------------------------------------+
bool movingStop3(string arg_sym, int arg_mag, int arg_sht)
{
   string cur;
   if (arg_sym==NULL) cur=Symbol();
   else cur=arg_sym;

   bool ret2=false;
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //Print("1=",OrderSymbol(),",2=",OrderType(),",3=",OrderComment(),",4=",OrderMagicNumber());
         //if((StringCompare(OrderSymbol(),cur)==0 && OrderMagicNumber()==arg_mag)) {
         if (isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,arg_mag)) {
            double cur_price=Close[arg_sht];
            double cur_open_price=NormalizeDouble(OrderOpenPrice(),Digits);
            double cur_ls_price=NormalizeDouble(OrderStopLoss(),Digits);
            double cur_tp_price=NormalizeDouble(OrderTakeProfit(),Digits);
            double cur_open_ls_gap=MathAbs(cur_open_price-cur_ls_price);
            if (cur_open_ls_gap>0 && OrderType()==OP_BUY) {    //buy order(not yet adjusted)
               if (cur_price>=(cur_open_price+cur_open_ls_gap)) {
                  ret2=OrderModify(OrderTicket(),cur_open_price,cur_open_price,cur_tp_price,0,Green);
                  if (ret2) {
                     mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),cur_open_price,cur_tp_price);
                  } else {
                     int check=GetLastError(); 
                     if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
                  }
               }
            }
            if (cur_open_ls_gap>0 && OrderType()==OP_SELL) {    //sell order(not yet adjusted)
               if (cur_price<=(cur_open_price-cur_open_ls_gap)) {
                  ret2=OrderModify(OrderTicket(),cur_open_price,cur_open_price,cur_tp_price,0,Red);
                  if (ret2) {
                     mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),cur_open_price,cur_tp_price);
                  } else {
                     int check=GetLastError(); 
                     if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
                  }
               }
            }
         }
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }
   return ret2;
}
//+------------------------------------------------------------------+
//| moving stop function 
//| arg_type:1 buy,-1 sell
//|
//+------------------------------------------------------------------+
bool movingStop4(string arg_sym, int arg_type, int arg_mag, double arg_ls_price, int arg_min_offset_pt)
{
   string cur;
   if (arg_sym==NULL) cur=Symbol();
   else cur=arg_sym;

   bool ret2=false;
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--) {
      bool ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (ret==true) {
         //if (isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,arg_mag)) {
         if (arg_type==1 && isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,arg_mag,arg_type)) {
            //buy order
            double cur_open_price=NormalizeDouble(OrderOpenPrice(),Digits);
            double cur_ls_price=NormalizeDouble(OrderStopLoss(),Digits);
            double cur_tp_price=NormalizeDouble(OrderTakeProfit(),Digits);
            int    offset_pt=(int)NormalizeDouble((arg_ls_price-cur_ls_price)/Point,0);
            if (offset_pt>=arg_min_offset_pt) {
               ret2=OrderModify(OrderTicket(),cur_open_price,arg_ls_price,cur_tp_price,0,Green);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),arg_ls_price,cur_tp_price);
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            } else {
               Print("tgt_ls_price(",arg_ls_price,") is not enough ",arg_min_offset_pt,"pt above the cur_ls_price(",cur_ls_price,")" );
            }
         }
         if (arg_type==-1 && isSameOrder(OrderSymbol(),OrderMagicNumber(),OrderComment(),OrderType(),cur,arg_mag,arg_type)) {
            //sell order
            double cur_open_price=NormalizeDouble(OrderOpenPrice(),Digits);
            double cur_ls_price=NormalizeDouble(OrderStopLoss(),Digits);
            double cur_tp_price=NormalizeDouble(OrderTakeProfit(),Digits);
            int    offset_pt=(int)NormalizeDouble((cur_ls_price-arg_ls_price)/Point,0);
            if (offset_pt>=arg_min_offset_pt) {
               ret2=OrderModify(OrderTicket(),cur_open_price,arg_ls_price,cur_tp_price,0,Red);
               if (ret2) {
                  mailNoticeOrderMod(OrderTicket(),OrderSymbol(),OrderType(),OrderOpenPrice(),arg_ls_price,cur_tp_price);
               } else {
                  int check=GetLastError(); 
                  if(check != ERR_NO_ERROR) Print("Order Modify Error: ", ErrorDescription(check));
               }
            } else {
               Print("tgt_ls_price(",arg_ls_price,") is not enough ",arg_min_offset_pt,"pt below the cur_ls_price(",cur_ls_price,")" );
            }
         }
      } else {
         int check=GetLastError(); 
         if(check != ERR_NO_ERROR) Print("Message not sent. Error: ", ErrorDescription(check)); 
      }
   }

   return ret2;
}
void writeOrderCmdToFile(s_Order &arg_order)
{
   if (i_for_test) return;
   
   string file_name=g_OrderSendFileName;

   Print("write order command to file");
   ResetLastError();
   int h=FileOpen(file_name,FILE_READ|FILE_WRITE|FILE_CSV,',');
   if(h==INVALID_HANDLE) {
      Print("Operation FileOpen failed, error: ",GetLastError());
      return;
   }

   ResetLastError();
   //move to file end to add order record
   if (!FileSeek(h,0,SEEK_END)) {
      Print("Operation FileSeek failed, error: ",GetLastError());
      FileClose(h);
      return;
   }
   
   arg_order.open_t=TimeCurrent();
   arg_order.profit=0;
   arg_order.close_p=0;
   arg_order.close_t=-1;
   arg_order.ped=Period();

   ResetLastError();
   //write file
   if (!wrtOneOrderToFile(h,0,arg_order)) {
      Print("Operation FileWrite failed, error: ",GetLastError());
      FileClose(h);
      return;
   }

   FileClose(h);

}

// arg_type:1 buy,2 buy stop,-1 sell,-2 sell stop,0 all
bool isSameOrder(string arg_order_symbol, int arg_order_magic, string arg_order_comment, int arg_order_type, string arg_symbol, int arg_magic, int arg_type=0)
{
   int tp=-1;
   
   switch (arg_type) {
      case 1:
         tp=OP_BUY;
         break;
      case 2:
         tp=OP_BUYSTOP;
         break;
      case -1:
         tp=OP_SELL;
         break;
      case -2:
         tp=OP_SELLSTOP;
         break;
      default:
         break;
   }
   
   if (tp==-1) {
      if (StringCompare(arg_order_symbol,arg_symbol)==0
         && (arg_order_magic==arg_magic
         || StringCompare(arg_order_comment,IntegerToString(arg_magic))==0)) 
      {         
         return true;
      }
   } else {
      if (StringCompare(arg_order_symbol,arg_symbol)==0
         && (arg_order_magic==arg_magic
         || StringCompare(arg_order_comment,IntegerToString(arg_magic))==0)
         && arg_order_type==tp)
      {
         return true;
      }
   }
   
   return false;
}
int file_read()
{
   string cur=Symbol();
   string fn=StringConcatenate("lang_",cur);
   int ret=0;
   int h=FileOpen(fn,FILE_TXT|FILE_SHARE_READ);
   if(h!=INVALID_HANDLE) {
      if (!FileIsEnding(h)) {
         //read int
         string s=FileReadString(h);
         ret=(int)StringToInteger(s);
      }
      FileClose(h);
   } else {
      Print("Operation FileOpen failed, error: ",ErrorDescription(GetLastError()));
      FileClose(h);
   }

   return ret;
}
int news_impact()
{
   //news impact read
   s_News usd_news[];
   int ret=news_read2(usd_news);
   Print("usd_news_read=",ret);

   //getOHCLfromTime
   int n=ArraySize(usd_news);
   s_Price relate_prices[];
   ArrayResize(relate_prices,n);
   for (int i=0;i<n;i++) {
      relate_prices[i].open=relate_prices[i].close=relate_prices[i].high=relate_prices[i].low=0;
      if (! isNewsRelated(NULL, usd_news[i].cur)) continue;
      getOHCLfromTime(usd_news[i].dt,relate_prices[i]);
      Print("dt=",usd_news[i].dt, " ,open=", relate_prices[i].open, ", close=", relate_prices[i].close, " ,high=", relate_prices[i].high, ", low=", relate_prices[i].low);
   }

   //news_impact_write
   ret=news_impact_write(usd_news,relate_prices);
   Print("news_impact_write=",ret);
   
   return ret;
}
//+------------------------------------------------------------------+
// ea_init: ea init
//+------------------------------------------------------------------+
void ea_init()
{
   CurrentTimeStamp = Time[0];
   getClientServerOffset();
   g_sendmail=i_sendmail;
}

//+------------------------------------------------------------------+
//|                                                    Correlate.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                                          georges |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "georges"
#property version   "1.00"
#property strict
//#include "..//Libraries//stdlib.mq4" //this file makes the err description function work.
#include <Trade\Trade.mqh> //Instatiate Trades Execution Library
#include <Trade\OrderInfo.mqh> //Instatiate Library for Orders Information
#include <Trade\PositionInfo.mqh> //Instatiate Library for Positions Information
//---
CTrade         m_trade; // Trades Info and Executions library
COrderInfo     m_order; //Library for Orders information
CPositionInfo  m_position; // Library for all position features and information

// Input Risk Parameters
input int       LossLimit              = 2000; // Loss Limit in dollars 
input	double	 Lot_Size			=	0.01;	

//	For the basic template enter sl and tp in points, this usually changes by strategy
input	int		InpTakeProfitPts		=  35000;			//	Take profit points
input	int		InpStopLossPts			=	20000;			//	Stop loss points

//	Trade comment Magic numer
input	string	InpTradeComment		=	__FILE__;	//	Trade comment
input	int		InpMagicNumber			=	2000011;		//	Magic number

//	Standard inputs
input double RSI_Sell_Value = 68;
input int RSI_Period = 14;
input int RsiLookBack = 0;
input int PositionsTotals = 2;

//	Use these to store the point values of sl and tp converted to double
double			TakeProfit;
double			StopLoss;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //
	double	point	=	SymbolInfoDouble(_Symbol, SYMBOL_POINT);
	TakeProfit		=	InpTakeProfitPts * point;
	StopLoss			=	InpStopLossPts * point;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick(void){
static datetime candletime;
if(iTime(_Symbol,Period(),0)==candletime){
return;}
else{
TradeLogic();
candletime = iTime(_Symbol,Period(),0);}
}


void TradeLogic(){
// Trade Pair
string Sym = _Symbol;

// Actual Trade Logic
double lotsize = Lot_Size;
double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double sl_value = StopLoss;
double tp_value = TakeProfit;

// Get Rsi Values Chart Time Frame
double myRsiArray[];
double myRsiDefinition = iRSI(Symbol(),Period(),RSI_Period,PRICE_LOW);
ArraySetAsSeries(myRsiArray,true);
CopyBuffer(myRsiDefinition,0,0,20,myRsiArray);
double RsiValue_ = NormalizeDouble(myRsiArray[0],2);

// Logic
if (( PositionsTotal() <= PositionsTotals ) && ( AccountInfoDouble(ACCOUNT_BALANCE) >=   LossLimit ) )

{
if (NormalizeDouble(myRsiArray[RsiLookBack],2) <= 30 ) 
{
Alert("Buy Order",askPrice);
}



else if ( NormalizeDouble(myRsiArray[RsiLookBack],2) >= RSI_Sell_Value )
{
Alert("Sell Order",bidPrice);
PlaceOrderSell(Sym,lotsize,askPrice,bidPrice,sl_value,tp_value);
}

}

else if (PositionsTotal() >= PositionsTotals || ( AccountInfoDouble(ACCOUNT_BALANCE) <=   LossLimit ))
{

Alert("Account Balance",AccountInfoDouble(ACCOUNT_BALANCE));
Alert("Total Positions",PositionsTotal());
}

}

void CloseBuyOrders()
{
 for (int i = OrdersTotal()-1; i >= 0; i--)
   {
      if ( m_order.SelectByIndex(i) )
      {
         if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY)
           m_trade.PositionClose(m_order.Ticket());
      }
   }
}


void CloseSellOrders()
{
 for (int i = OrdersTotal()-1; i >= 0; i--)
   {
      if ( m_order.SelectByIndex(i) )
      {
         if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL)
           m_trade.PositionClose(m_order.Ticket());
      }
   }
}

double open(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double openC = rates[index].open;
         return(openC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
double high(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double highC = rates[index].high;
         return(highC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
  
double low(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double lowC = rates[index].low;
         return(lowC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
double close(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double closeC = rates[index].close;
         return(closeC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
double volume(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double volumeC = rates[index].tick_volume;
         return(volumeC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  
  }
  
double time(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double timeC = rates[index].time;
         return(timeC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  
  }
  
  
void PlaceOrderBuy(string &Sym, double &lotsize, double &askPrice, double &bidPrice, double &sl_value, double &tp_value)
  {
    m_trade.Buy(lotsize,Sym,askPrice,askPrice-(sl_value*_Point*10),askPrice+(tp_value*_Point*10),"Full code");
  }
  
void PlaceOrderSell(string &Sym, double &lotsize, double &askPrice, double &bidPrice, double &sl_value, double &tp_value)
  {
     m_trade.Sell(lotsize,Sym,bidPrice,bidPrice+(sl_value*_Point*10),bidPrice-(tp_value*_Point*10),"Full code");
  }
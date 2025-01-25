//+------------------------------------------------------------------+
//|                                                   MarketData.mqh |
//|                               Copyright 2025, YoonaXCapital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YoonaXCapital Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                        MarketData.mqh                           |
//+------------------------------------------------------------------+

#include <Logger.mqh>

class CMarketData
{
private:
   CLogger* m_logger;

public:
   void Initialize(CLogger &externalLogger)
   {
      m_logger = &externalLogger;
   }

   string GetTickData(const string symbol)
   {
      MqlTick lastTick;
      if(!SymbolInfoTick(symbol, lastTick))
      {
         m_logger.LogError("Failed to get tick for " + symbol);
         return "";
      }
      return StringFormat("TICK|%s|%d|%.5f|%.5f",
               symbol, lastTick.time, lastTick.bid, lastTick.ask);
   }

   string GetOHLCData(const string symbol, ENUM_TIMEFRAMES timeframe, int count)
   {
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      if(CopyRates(symbol, timeframe, 0, count, rates) <= 0)
      {
         m_logger.LogError("Failed to get OHLC for " + symbol);
         return "";
      }
      
      string result = "OHLC|" + symbol + "|" + IntegerToString(timeframe);
      for(int i = 0; i < ArraySize(rates); i++)
      {
         result += StringFormat("|%d,%.5f,%.5f,%.5f,%.5f",
                  rates[i].time, rates[i].open, rates[i].high, 
                  rates[i].low, rates[i].close);
      }
      return result;
   }
};

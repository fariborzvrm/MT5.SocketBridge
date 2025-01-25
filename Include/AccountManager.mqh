//+------------------------------------------------------------------+
//|                                               AccountManager.mqh |
//|                               Copyright 2025, YoonaXCapital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YoonaXCapital Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                       AccountManager.mqh                        |
//+------------------------------------------------------------------+

#include <Logger.mqh>

class CAccountManager
{
private:
   CLogger* m_logger;

public:
   void Initialize(CLogger &externalLogger)
   {
      m_logger = &externalLogger;
   }

   string GetAccountInfo()
   {
      return StringFormat("ACCOUNT|%.2f|%.2f|%.2f|%s",
               AccountInfoDouble(ACCOUNT_BALANCE),
               AccountInfoDouble(ACCOUNT_EQUITY),
               AccountInfoDouble(ACCOUNT_MARGIN_FREE),
               AccountInfoString(ACCOUNT_CURRENCY));
   }

   string GetSymbolInfo(const string symbol)
   {
      return StringFormat("SYMBOL|%s|%.2f|%.5f|%.2f|%.2f|%.2f",
               symbol,
               SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE),
               SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE),
               SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL),
               SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN),
               SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX));
   }
};
//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                               Copyright 2025, YoonaXCapital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YoonaXCapital Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                        OrderManager.mqh                         |
//+------------------------------------------------------------------+
#property strict
#include <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>
#include <Logger.mqh>
#include <CommandTypes.mqh>

class COrderManager
{
private:
   CLogger*  m_logger;
   CTrade    m_trade;
   COrderInfo m_orderInfo;

public:
   void Initialize(CLogger &inputLogger) { m_logger = &inputLogger; }

   bool ExecuteOrder(const ENUM_ORDER_ACTION action, const string symbol,
                    double volume, double price, double sl, double tp)
   {
      if(!ValidateSymbol(symbol)) return false;
      
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      
      switch(action)
      {
         case ORDER_ACTION_BUY:
            return m_trade.Buy(volume, symbol, ask, sl, tp);
            
         case ORDER_ACTION_SELL:
            return m_trade.Sell(volume, symbol, bid, sl, tp);
            
         case ORDER_ACTION_BUY_LIMIT:
            return m_trade.BuyLimit(volume, price, symbol, sl, tp);
            
         case ORDER_ACTION_SELL_LIMIT:
            return m_trade.SellLimit(volume, price, symbol, sl, tp);
            
         case ORDER_ACTION_BUY_STOP:
            return m_trade.BuyStop(volume, price, symbol, sl, tp);
            
         case ORDER_ACTION_SELL_STOP:
            return m_trade.SellStop(volume, price, symbol, sl, tp);
            
         default:
            m_logger.LogError("Invalid order action");
            return false;
      }
   }

   bool ModifyOrder(ulong ticket, double price, double sl, double tp)
{
   if(m_orderInfo.Select(ticket))
   {
      return m_trade.OrderModify(
         ticket,              // Ticket number
         price,               // New price
         sl,                  // New stop loss
         tp,                  // New take profit
         ORDER_TIME_GTC,      // Good-Till-Canceled
         0,                   // Expiration time (not used for GTC)
         0                    // Keep original volume
      );
   }
   m_logger.LogError("Failed to select order: " + IntegerToString(ticket));
   return false;
}

   bool CloseOrder(ulong ticket)
   {
      if(m_orderInfo.Select(ticket))
      {
         if(m_orderInfo.OrderType() == ORDER_TYPE_BUY || m_orderInfo.OrderType() == ORDER_TYPE_SELL)
         {
            return m_trade.PositionClose(ticket);
         }
         else
         {
            return m_trade.OrderDelete(ticket);
         }
      }
      return false;
   }

private:
   bool ValidateSymbol(const string symbol)
   {
      if(!SymbolInfoInteger(symbol, SYMBOL_SELECT))
      {
         m_logger.LogError("Invalid symbol: " + symbol);
         return false;
      }
      return true;
   }

   bool ValidateVolume(const string symbol, double volume)
   {
      double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      
      if(volume < min_lot || volume > max_lot)
      {
         m_logger.LogError(StringFormat("Invalid lot size %.2f for %s (Min: %.2f, Max: %.2f)",
                      volume, symbol, min_lot, max_lot));
         return false;
      }
      return true;
   }
};
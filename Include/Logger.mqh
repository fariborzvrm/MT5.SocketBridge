//+------------------------------------------------------------------+
//|                                                        Logger.mqh|
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YoonaXCapital Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                           Logger.mqh                            |
//+------------------------------------------------------------------+
#property strict

class CLogger
{
private:
   bool m_debugMode;
   
public:
   CLogger(const bool debugMode) : m_debugMode(debugMode) {}
   
   void LogError(const string message)
   {
      Print("[ERROR] ", message);
      if(m_debugMode) Alert(message);
   }

   void LogWarning(const string message)
   {
      if(m_debugMode) Print("[WARNING] ", message);
   }

   void LogInfo(const string message)
   {
      if(m_debugMode) Print("[INFO] ", message);
   }
};
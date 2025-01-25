//+------------------------------------------------------------------+
//|                                              SocketBridgeEA.mq5  |
//|                               Copyright 2025, YoonaXCapital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YoonaXCapital Ltd."
#property link      "https://www.mql5.com"
#property description "Modular EA for C# Bridge with Socket Communication"
#property script_show_inputs

#include <SocketHandler.mqh>
#include <MarketData.mqh>
#include <OrderManager.mqh>
#include <AccountManager.mqh>
#include <Logger.mqh>
#include <CommandTypes.mqh>

input string   ServerIP      = "127.0.0.1";
input int      Port          = 5000;
input int      BufferSize    = 4096;
input bool     DebugMode     = true;
input string   AuthToken     = "MT5SECURE123";
input int      HeartbeatSec  = 5;

CSocketHandler socketHandler;
CMarketData    marketData;
COrderManager  orderManager;
CAccountManager accountManager;
CLogger        logger(DebugMode);
CTrade         m_trade; // Added CTrade declaration

//+------------------------------------------------------------------+
//| Expert Initialization Function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!socketHandler.Initialize(ServerIP, Port, BufferSize, AuthToken))
   {
      logger.LogError("Socket initialization failed");
      return INIT_FAILED;
   }
   
   marketData.Initialize(logger);
   orderManager.Initialize(logger);
   accountManager.Initialize(logger);

   EventSetTimer(HeartbeatSec);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert Deinitialization Function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   socketHandler.Shutdown();
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   ProcessIncomingCommands();
   SendMarketUpdates();
}

//+------------------------------------------------------------------+
//| Timer Function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(!socketHandler.Send("PING"))
      logger.LogWarning("Heartbeat failed");
}

//+------------------------------------------------------------------+
//| Process Incoming Commands                                        |
//+------------------------------------------------------------------+
void ProcessIncomingCommands()
{
   string command;
   while(socketHandler.Receive(command))
   {
      Command parsedCmd = ParseCommand(command);
      if(parsedCmd.type == CMD_UNKNOWN)
      {
         logger.LogError("Invalid command: " + command);
         continue;
      }
      HandleCommand(parsedCmd);
   }
}

//+------------------------------------------------------------------+
//| Parse Command                                                    |
//+------------------------------------------------------------------+
Command ParseCommand(const string commandStr)
{
   Command cmd;
   cmd.type = CMD_UNKNOWN;
   
   string parts[];
   int count = StringSplit(commandStr, '|', parts);
   if(count < 1) return cmd;

   if(parts[0] == "MARKET") cmd.type = CMD_MARKET_DATA;
   else if(parts[0] == "ACCOUNT") cmd.type = CMD_ACCOUNT_INFO;
   else if(parts[0] == "ORDER") cmd.type = CMD_ORDER;

   ArrayResize(cmd.params, count-1);
   for(int i = 1; i < count; i++)
      cmd.params[i-1] = parts[i];

   return cmd;
}

//+------------------------------------------------------------------+
//| Handle Command                                                   |
//+------------------------------------------------------------------+
void HandleCommand(const Command &cmd)
{
   switch(cmd.type)
   {
      case CMD_MARKET_DATA:
         HandleMarketRequest(cmd);
         break;
      
      case CMD_ACCOUNT_INFO:
         HandleAccountRequest(cmd);
         break;
      
      case CMD_ORDER:
         HandleOrderRequest(cmd);
         break;
   }
}

//+------------------------------------------------------------------+
//| Market Data Handler                                              |
//+------------------------------------------------------------------+
void HandleMarketRequest(const Command &cmd)
{
   if(ArraySize(cmd.params) < 2) return;
   
   string response;
   if(cmd.params[0] == "TICK")
      response = marketData.GetTickData(cmd.params[1]);
   else if(cmd.params[0] == "OHLC")
      response = marketData.GetOHLCData(cmd.params[1], StringToTimeFrame(cmd.params[2]), (int)StringToInteger(cmd.params[3]));
   
   if(response != "")
      socketHandler.Send(response);
}

//+------------------------------------------------------------------+
//| Account Info Handler                                             |
//+------------------------------------------------------------------+
void HandleAccountRequest(const Command &cmd)
{
   string response = accountManager.GetAccountInfo();
   if(response != "")
      socketHandler.Send(response);
}


//+------------------------------------------------------------------+
//| Handle order requests                                            |
//+------------------------------------------------------------------+
void HandleOrderRequest(const Command &cmd)
{
   if(ArraySize(cmd.params) < 6) return;
   
   string symbol = cmd.params[1];
   double volume = StringToDouble(cmd.params[2]);
   double price = StringToDouble(cmd.params[3]);
   double sl = StringToDouble(cmd.params[4]);
   double tp = StringToDouble(cmd.params[5]);

   bool success = orderManager.ExecuteOrder(cmd.action, symbol, volume, price, sl, tp);
   
   if(success)
      socketHandler.Send("ORDER|SUCCESS|" + IntegerToString(m_trade.ResultOrder()));
   else
      socketHandler.Send("ORDER|FAILED|" + m_trade.ResultRetcodeDescription());
}

//+------------------------------------------------------------------+
//| Handle order modification                                        |
//+------------------------------------------------------------------+
void HandleOrderModify(const Command &cmd)
{
   if(ArraySize(cmd.params) < 4) return;
   
   ulong ticket = StringToInteger(cmd.params[1]);
   double price = StringToDouble(cmd.params[2]);
   double sl = StringToDouble(cmd.params[3]);
   double tp = StringToDouble(cmd.params[4]);

   if(orderManager.ModifyOrder(ticket, price, sl, tp))
      socketHandler.Send("MODIFY|SUCCESS|" + IntegerToString(ticket));
   else
      socketHandler.Send("MODIFY|FAILED|" + IntegerToString(ticket));
}

//+------------------------------------------------------------------+
//| Handle order closure                                             |
//+------------------------------------------------------------------+
void HandleOrderClose(const Command &cmd)
{
   if(ArraySize(cmd.params) < 2) return;
   
   ulong ticket = StringToInteger(cmd.params[1]);

   if(orderManager.CloseOrder(ticket))
      socketHandler.Send("CLOSE|SUCCESS|" + IntegerToString(ticket));
   else
      socketHandler.Send("CLOSE|FAILED|" + IntegerToString(ticket));
}

//+------------------------------------------------------------------+
//| Send Market Updates                                              |
//+------------------------------------------------------------------+
void SendMarketUpdates()
{
   static datetime lastUpdate = 0;
   if(TimeCurrent() > lastUpdate)
   {
      string update = marketData.GetTickData(_Symbol);
      if(update != "")
         socketHandler.Send(update);
      lastUpdate = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| Convert String to Timeframe                                      |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES StringToTimeFrame(const string tf)
{
   if(tf == "M1")  return PERIOD_M1;
   if(tf == "M5")  return PERIOD_M5;
   if(tf == "M15") return PERIOD_M15;
   if(tf == "H1")  return PERIOD_H1;
   if(tf == "H4")  return PERIOD_H4;
   if(tf == "D1")  return PERIOD_D1;
   return PERIOD_CURRENT;
}
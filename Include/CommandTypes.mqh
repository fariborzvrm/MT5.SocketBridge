//+------------------------------------------------------------------+
//|                                                 CommandTypes.mqh |
//|                               Copyright 2025, YoonaXCapital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YoonaXCapital Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                        CommandTypes.mqh                         |
//|                       Contains Command Definitions              |
//+------------------------------------------------------------------+

enum ENUM_COMMAND_TYPE
{
   CMD_UNKNOWN,
   CMD_MARKET_DATA,
   CMD_ACCOUNT_INFO,
   CMD_ORDER,
   CMD_ORDER_MODIFY,
   CMD_ORDER_CLOSE
};

enum ENUM_ORDER_ACTION
{
   ORDER_ACTION_BUY,
   ORDER_ACTION_SELL,
   ORDER_ACTION_BUY_LIMIT,
   ORDER_ACTION_SELL_LIMIT,
   ORDER_ACTION_BUY_STOP,
   ORDER_ACTION_SELL_STOP
};

struct Command
{
   ENUM_COMMAND_TYPE type;
   ENUM_ORDER_ACTION action;
   string            params[];
};
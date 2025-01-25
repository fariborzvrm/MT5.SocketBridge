# MT5 Socket Bridge Expert Advisor


A professional-grade socket bridge connecting MetaTrader 5 with external applications, supporting advanced order management and real-time market data streaming.

## 📌 Features

- 🔄 **Bi-directional Communication** (C# ↔ MT5)
- 💹 **Real-time Market Data** (Tick/OHLC)
- 🛒 **Advanced Order Management** (Market/Pending Orders, Modifications)
- 📊 **Account/Symbol Information**
- 🔐 **Token-based Authentication**
- ⚡ **Auto-reconnect Functionality**

## 🏗 Architecture

+---------------+ Socket Protocol +-------------------+
| C#/.NET App | <————————[127.0.0.1:5000]————————> | MT5 Expert Advisor |
+---------------+ +-------------------+
│
├── Market Data Stream
├── Trade Execution
└── Account Monitoring

## 📂 File Structure

MT5.SocketBridge/
├── MQL5/
│ ├── Experts/
│ │ └── SocketBridgeEA.mq5
│ └── Include/
│ ├── SocketHandler.mqh # Socket communication
│ ├── MarketData.mqh # Market data handling
│ ├── OrderManager.mqh # Enhanced order system
│ ├── AccountManager.mqh # Account operations
│ ├── Logger.mqh # Logging system
│ └── CommandTypes.mqh # Protocol definitions
├── README.md
└── .gitignore

## 🚀 Installation

1. **Clone Repository**
   ```bash
   git clone https://github.com/fariborzvrm/MT5.SocketBridge.git

    Copy to MT5

        Copy MQL5/Experts/* to [MT5 Installation]/MQL5/Experts/

        Copy MQL5/Include/* to [MT5 Installation]/MQL5/Include/

    MT5 Configuration

        Enable Allow DLL Imports

        Enable AutoTrading

        Attach EA to chart

⚙ Configuration (Input Parameters)
Parameter	Description	Default
ServerIP	C# Application IP	127.0.0.1
Port	Communication Port	5000
BufferSize	Socket Buffer	4096
AuthToken	Security Token	MT5SECURE123
HeartbeatSec	Connection Check	5
📡 Command Protocol
➡ C# → MT5 Commands
plaintext

# Order Execution
ORDER|BUY|SYMBOL|VOLUME|SL|TP
ORDER|SELL|SYMBOL|VOLUME|SL|TP
ORDER|BUY_LIMIT|SYMBOL|VOLUME|PRICE|SL|TP
ORDER|SELL_LIMIT|SYMBOL|VOLUME|PRICE|SL|TP
ORDER|BUY_STOP|SYMBOL|VOLUME|PRICE|SL|TP
ORDER|SELL_STOP|SYMBOL|VOLUME|PRICE|SL|TP

# Order Management
MODIFY|TICKET|PRICE|SL|TP
CLOSE|TICKET

⬅ MT5 → C# Responses
plaintext

# Order Responses
ORDER|SUCCESS|TICKET
ORDER|FAILED|ERROR_DESCRIPTION
MODIFY|SUCCESS|TICKET
MODIFY|FAILED|TICKET
CLOSE|SUCCESS|TICKET
CLOSE|FAILED|TICKET

# Error Example
ERROR|Invalid lot size 0.15 for EURUSD (Min: 0.10, Max: 1.00)

💻 Module Documentation
OrderManager (OrderManager.mqh)

Capabilities:

    Market orders (Buy/Sell)

    Pending orders (Buy Limit/Stop, Sell Limit/Stop)

    Order modification (SL/TP/Price)

    Position closure

    Volume/Symbol validation

Key Methods:
mq5

bool ExecuteOrder(ENUM_ORDER_ACTION action, string symbol, double volume, 
                 double price, double sl, double tp);
bool ModifyOrder(ulong ticket, double price, double sl, double tp);
bool CloseOrder(ulong ticket);

Order Action Types:
mq5

enum ENUM_ORDER_ACTION {
   ORDER_ACTION_BUY,
   ORDER_ACTION_SELL,
   ORDER_ACTION_BUY_LIMIT,
   ORDER_ACTION_SELL_LIMIT,
   ORDER_ACTION_BUY_STOP,
   ORDER_ACTION_SELL_STOP
};

🚨 Troubleshooting
Issue	Solution
Order Rejection	Verify symbol permissions and margin
Modification Failure	Check order ticket validity
Protocol Errors	Validate command formatting
🔒 Security Best Practices

    Use VPN for remote connections

    Rotate authentication tokens monthly

    Enable MT5 confirmation dialogs

    Test in demo environment first

🤝 Contributing

    Fork the Project

    Create Feature Branch (git checkout -b feature/AmazingFeature)

    Commit Changes (git commit -m 'Add feature')

    Push to Branch (git push origin feature/AmazingFeature)

    Open Pull Request

Disclaimer: Use at your own risk. Always test in demo accounts before live trading.

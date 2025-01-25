//+------------------------------------------------------------------+
//|                                                SocketHandler.mqh |
//|                               Copyright 2025, YoonaXCapital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YoonaXCapital Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                        SocketHandler.mqh                        |
//+------------------------------------------------------------------+
#property strict

class CSocketHandler
{
private:
   int         m_socketHandle;
   string      m_serverIP;
   int         m_port;
   int         m_bufferSize;
   string      m_authToken;
   uchar       m_buffer[];

public:
   bool Initialize(const string ip, const int port, const int bufSize, const string token)
   {
      m_serverIP = ip;
      m_port = port;
      m_bufferSize = bufSize;
      m_authToken = token;
      ArrayResize(m_buffer, bufSize);
      return Reconnect();
   }

   bool Reconnect()
   {
      Shutdown();
      m_socketHandle = SocketCreate();
      if(m_socketHandle == INVALID_HANDLE) return false;
      
      if(!SocketConnect(m_socketHandle, m_serverIP, m_port, 5000))
      {
         SocketClose(m_socketHandle);
         return false;
      }
      return Authenticate();
   }

   bool Send(const string data)
   {
      if(m_socketHandle == INVALID_HANDLE) return false;
      
      int dataSize = StringToCharArray(data, m_buffer, 0, StringLen(data));
      return SocketSend(m_socketHandle, m_buffer, dataSize) == dataSize;
   }

   bool Receive(string &outData)
   {
      if(!SocketIsReadable(m_socketHandle)) return false;
      
      int bytesRead = SocketRead(m_socketHandle, m_buffer, m_bufferSize, 100);
      if(bytesRead > 0)
      {
         outData = CharArrayToString(m_buffer, 0, bytesRead);
         return true;
      }
      return false;
   }

   void Shutdown()
   {
      if(m_socketHandle != INVALID_HANDLE)
         SocketClose(m_socketHandle);
      m_socketHandle = INVALID_HANDLE;
   }

private:
   bool Authenticate()
   {
      return Send("AUTH|" + m_authToken);
   }
};
//+------------------------------------------------------------------+
//|                                                          001.mq4 |
//|                           Copyright 2020, Mql Developer Thailand |
//|                             https://www.facebook.com/mqldevthai/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Mql Developer Thailand"
#property link      "https://www.facebook.com/mqldevthai/"
#property version   "1.00"
#property strict

#include <simple-client-socket.mqh>
#include <BitKubErrorCode.mqh>
ClientSocket s;
ushort port=9090;
input string curr="ETH";
double THB,COIN;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string data="{\"type\":\"init\",\"sym\":\""+curr+"\"}";
   SendData(data);
   if(GetReply(data))
     {
      printf("THB: %.2f  %s: %.8f",THB,curr,COIN);
      //Sell(0.00016938);
      //Buy(10);
     }
   else
      ExpertRemove();


//Buy(10.01);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   string data="{\"type\":\"quit\"}";
   SendData(data,false);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Buy(double amt)
  {
   string data=StringFormat("{\"type\":\"buy\",\"amt\":%s,\"sym\":\"%s\"}",(string)amt,curr);
   if(SendData(data))
     {
      GetReply(data);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sell(double amt)
  {
   string data=StringFormat("{\"type\":\"sell\",\"amt\":%s,\"sym\":\"%s\"}",(string)amt,curr);
   if(SendData(data))
     {
      GetReply(data);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetReply(string data)
  {
   string result[];
   int k=StringSplit(data,StringGetCharacter(",",0),result);
   if(result[0]=="1")
     {
      THB=StrToDouble(result[1]);
      COIN=StrToDouble(result[2]);
      return true;
     }
   else
     {
      Print(Error((int)result[1]));
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SendData(string& data,bool rec=true)
  {
   if(s.Connect(port))
     {
      if(s.IsSocketConnected())
        {
         s.Send(data);
         if(rec)
           {
            s.Recv(data);
            Print(data);
           }
        }
      else
        {
         s.CloseConnect();;
         return false;
        }
      s.CloseConnect();
      return true;
     }
   else
      return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
string Error(int err)
  {
   switch(err)
     {
      case  1:
         return "Error # 1 Invalid JSON payload";
         break;
      case  2:
         return "Error # 2 Missing X-BTK-APIKEY";
         break;
      case  3:
         return "Error # 3 Invalid API key";
         break;
      case  4:
         return "Error # 4 API pending for activation";
         break;
      default:
         return StringFormat("Error # %d Don't know error ",err);
         break;
     }
  }
  */
//+------------------------------------------------------------------+

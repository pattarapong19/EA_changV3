//+------------------------------------------------------------------+
//|                                                         0021.mq4 |
//|                       Copyright 2022, IT Investment Studio Corp. |
//|                              https://www.facebook.com/ITinvesman |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, IT Investment Studio Corp."
#property link      "https://www.facebook.com/ITinvesman"
#property version   "2.01"
#property strict
#include <yai_ordermm.mqh>
#include <yai_tools1.mqh>

Cyai_tool1 yai_tool1;
Cordermm order;
input string _token ="GuG6nKGXKOZ2GQd5MUju5T6AIBFZ0w1wzrON8udZPz2";
input int magic = 123456;
extern double Lot = 0.01;
extern double percentSL = 0.03; //%SL Percent (0.03 ==3%)
int typeCandle;
double cutloss = 0;
double stoploss = 0;
bool ckStoploss = false;
int orderType=0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   order.setmagic(magic);
   int candleBegin = 5;
   cutloss = SetSLPriceOnInit(candleBegin,typeCandle);
   printf("cutloss: %.2f type typeCandle: %d",cutloss,typeCandle);
   Comment("");
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
       SetSLPriceOntick(); 
       StoplossAndEntryOrder();
       
       
       
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
double SetSLPriceOnInit(int setCandle,int &lastTypeCandle){
   double setSLPrice = 0;   
          setSLPrice = Open[setCandle];
          lastTypeCandle = yai_tool1.ckBearBullCandle(setCandle);
   //printf("begin setSL %.2f",setSLPrice);
   for(int i=setCandle;i>0;i--)
           {
               if(i-1>0){
                           
                           int prevLastTypeCandle = yai_tool1.ckBearBullCandle(i-1);   
                                    if(lastTypeCandle==1){
                                             if(prevLastTypeCandle==1){
                                                 if(Close[i-1]>setSLPrice){
                                                      setSLPrice = Open[i-1];
                                                      lastTypeCandle=prevLastTypeCandle;
                                                     // printf("%d. lastTypeCandle %d prevLastTypeCandle :%d Set New SL %.2f",i, lastTypeCandle,prevLastTypeCandle,setSLPrice);
                                                 }
                                             }else if(prevLastTypeCandle==2){
                                                   if(Close[i-1]<setSLPrice){
                                                      setSLPrice = Open[i-1];
                                                      lastTypeCandle=prevLastTypeCandle;
                                                      // printf("%d. lastTypeCandle %d prevLastTypeCandle :%d Set New SL %.2f",i, lastTypeCandle,prevLastTypeCandle,setSLPrice);
                                                   }
                                               }
                                       }else if(lastTypeCandle==2){
                                               if(prevLastTypeCandle==1){
                                                      if(Close[i-1]>setSLPrice){
                                                            setSLPrice = Open[i-1];
                                                            lastTypeCandle=prevLastTypeCandle;
                                                          //  printf("%d. lastTypeCandle %d prevLastTypeCandle :%d Set New SL %.2f",i, lastTypeCandle,prevLastTypeCandle,setSLPrice);
                                                         } 
                                                  }else if(prevLastTypeCandle==2){
                                                      if(Close[i-1]<setSLPrice){
                                                            setSLPrice = Open[i-1];
                                                            lastTypeCandle=prevLastTypeCandle;
                                                           // printf("%d. lastTypeCandle %d prevLastTypeCandle :%d Set New SL %.2f",i, lastTypeCandle,prevLastTypeCandle,setSLPrice);
                                                         }
                                                   }                                
                                          }
                   }
           } 
           return setSLPrice;       
}
void SetSLPriceOntick(){
       
         if(yai_tool1.Ck_candle()){         
               double setSLPrice = 0;              
               setSLPrice = cutloss;
               int prevLastTypeCandle = yai_tool1.ckBearBullCandle(1);  
               //printf("prevLastTypeCandle : %d cutloss : %.2f",prevLastTypeCandle,cutloss); 
               if(typeCandle==1){
                  if(prevLastTypeCandle==1){
                       setSLPrice = Open[1];
                       cutloss=setSLPrice;
                       typeCandle=prevLastTypeCandle;
                      // printf(" lastTypeCandle %d prevLastTypeCandle :%d Set New SL %.2f",typeCandle,prevLastTypeCandle,setSLPrice);                  
                     }else if(prevLastTypeCandle==2){
                                   if(Close[1]<setSLPrice){
                                       setSLPrice = Open[1];
                                       cutloss=setSLPrice;
                                       typeCandle=prevLastTypeCandle;
                                      
                                       if(order.Count_Order(Symbol(),2)>0){ 
                                          order.CloseAll(Symbol());
                                       }
                                       order.sell(Symbol(),Lot,0,0);
                                       if(!OrderSelect(0,SELECT_BY_POS,MODE_TRADES))Print(GetLastError());
                                       string txtNotify = StringFormat("Type %s Order Open Price %s ",OrderType()==0?"Buy":OrderType()==1?"Sell":"None",string(OrderOpenPrice()));
                                       if(_token!="")yai_tool1.LineNotify(_token,txtNotify);
                                       ckStoploss=false;                                    
                                   }
                           }
                }else if(typeCandle==2){
                         if(prevLastTypeCandle==1){
                                 if(Close[1]>setSLPrice){
                                          setSLPrice = Open[1];
                                          cutloss=setSLPrice;
                                          typeCandle=prevLastTypeCandle;
                                          
                                          if(order.Count_Order(Symbol(),2)>0){ 
                                                order.CloseAll(Symbol());
                                             }
                                           order.buy(Symbol(),Lot,0,0);
                                           if(!OrderSelect(0,SELECT_BY_POS,MODE_TRADES))Print(GetLastError());
                                           string txtNotify = StringFormat("Type %s Order Open Price %s ",OrderType()==0?"Buy":OrderType()==1?"Sell":"None",string(OrderOpenPrice()));
                                           if(_token!="")yai_tool1.LineNotify(_token,txtNotify);
                                           ckStoploss=false;           
                                        } 
                                    }else if(prevLastTypeCandle==2){
                                         if(Close[1]<setSLPrice){
                                              setSLPrice = Open[1];
                                              cutloss=setSLPrice;
                                              typeCandle=prevLastTypeCandle;
                                             // printf("lastTypeCandle %d prevLastTypeCandle :%d Set New SL %.2f",typeCandle,prevLastTypeCandle,setSLPrice);
                                            }
                                       }      
                }
         }
}

void StoplossAndEntryOrder(){
   if(OrdersTotal()>0 && ckStoploss==false){
            if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)){
               if(OrderType()==0){
                   stoploss =NormalizeDouble(OrderOpenPrice()-(Close[1]*percentSL),(int)MarketInfo(Symbol(),MODE_DIGITS));
               }else if(OrderType()==1){
                   stoploss =NormalizeDouble(OrderOpenPrice()+(Close[1]*percentSL),(int)MarketInfo(Symbol(),MODE_DIGITS));
               }             
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,0,0))Print(GetLastError());
               if(_token!="")yai_tool1.LineNotify(_token,StringFormat("Set Stoploss At : %s",string(stoploss)));
               ckStoploss =true;               
               //Comment(StringFormat(" stoploss %s order %s",string(stoploss),OrderType()==0?"Buy":"Sell"));
            }
            
       }
       if(OrdersTotal()==0&&ckStoploss==true){
            ckStoploss=false;
            if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))Print(GetLastError());
            printf("Line 200 ordertype :%d Orderopenprice %s",OrderType(),string(OrderOpenPrice()));
            if(OrderType()==0){
                  order.sell(Symbol(),Lot,0,0);
                  if(!OrderSelect(0,SELECT_BY_POS,MODE_TRADES))Print(GetLastError());
                  string txtNotify = StringFormat("Type %s Order Open Price %s ",OrderType()==0?"Sell":OrderType()==1?"Sell":"None",string(OrderOpenPrice()));
                  if(_token!="")yai_tool1.LineNotify(_token,txtNotify);
                  cutloss = OrderOpenPrice()+(Close[1]*percentSL);
                  typeCandle=2;
                  //printf("cutloss %s ",string(cutloss));
            }else if(OrderType()==1){
                  order.buy(Symbol(),Lot,0,0);
                  if(!OrderSelect(0,SELECT_BY_POS,MODE_TRADES))Print(GetLastError());
                  string txtNotify = StringFormat("Type %s Order Open Price %s ",OrderType()==0?"Buy":OrderType()==1?"Sell":"None",string(OrderOpenPrice()));
                  if(_token!="")yai_tool1.LineNotify(_token,txtNotify);
                  cutloss = OrderOpenPrice()-(Close[1]*percentSL);
                  typeCandle=1;
                  //printf("cutloss %s ",string(cutloss));
            }         
       }
}
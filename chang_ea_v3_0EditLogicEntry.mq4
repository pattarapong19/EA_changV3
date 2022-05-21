//+------------------------------------------------------------------+
//|                                                chang_ea_v1_0.mq4 |
//|                         Copyright 2022, Investman Software Corp. |
//|                              https://www.facebook.com/ITinvesman |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "3.00"
#property strict
#include <yai_ordermm.mqh>
#include <yai_tools1.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Edit.mqh>
CAppDialog D1;
CButton B[10];
CEdit E[10];
CLabel L[10];
CLabel LBuy;
CLabel LSell;
CLabel LBalance;
CLabel LBeforeProfit;
CLabel LProfitAll;

Cyai_tool1 yai_tool1;
Cordermm order;
extern double percent = 0.5;   //% Entry Order 
extern double percent_cutloss=1;  // % Cutloss
extern double percent_tp = 1; // % Teke Profit
extern string _token ="GuG6nKGXKOZ2GQd5MUju5T6AIBFZ0w1wzrON8udZPz2";  //Token Line
extern bool closeLine =true;  // Close Line
extern double Lot = 0.1;   //Lot Size
extern bool continueOder=true;  //Continue Order 

//"GuG6nKGXKOZ2GQd5MUju5T6AIBFZ0w1wzrON8udZPz2";
double setP = 0;
double set_cutloss=0;
double set_tp=0;
//---
double sig_b =0;
double sig_s =0;
double cutloss=0;
double _tp =  0;
int order_type=0;
string txt_set;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
    printf("test git pull");
   percent = percent/100;
   percent_cutloss=percent_cutloss/100;
   percent_tp = percent_tp/100;
   setP=iClose(Symbol(),0,1)*percent;
   set_cutloss=iClose(Symbol(),0,1)*percent_cutloss;
   set_tp=iClose(Symbol(),0,1)*percent_tp;
   sig_b = iClose(Symbol(),0,1)+setP;
   sig_s = iClose(Symbol(),0,1)-setP;
   printf("**** Begin*****sep_p %.2f set_cutloss %.2f set_tp %.2f",setP,set_cutloss,set_tp);
   //Comment("Set_b = ",sig_b," Set_s = ",sig_s);
   txt_set=StringFormat("setP : %.2f set_cutloss : %.2f set_tp %.2f ",setP,set_cutloss,set_tp);
   if(!closeLine)yai_tool1.LineNotify(_token,"EA Ready.......");
   order.setmagic(12345);
   Creat_Dialog();
   
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
   yai_tool1.Deleteobject("l_");
   D1.Destroy(reason);
   
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double _open_price=0;
double _pf_all;
void OnTick()
  {
//---

      if(yai_tool1.Ck_candle()){
         string txt_daily;  
         double pf_all;
         setP=iClose(Symbol(),0,1)*percent;
         set_cutloss=iClose(Symbol(),0,1)*percent_cutloss;
         set_tp=iClose(Symbol(),0,1)*percent_tp;
         double pf = Ck_profit(pf_all);       
         txt_daily=StringFormat("daily   : %s \nprofit daily : %.2f profit all : %.2f "
         ,TimeToString(int(TimeCurrent())-86400,TIME_DATE),pf,pf_all);
         if(!closeLine)yai_tool1.LineNotify(_token,txt_daily);
       //  Print("Profit Daily :",txt_daily);
         txt_set=StringFormat("setP : %.2f set_cutloss : %.2f set_tp %.2f ",setP,set_cutloss,set_tp);
      }
      double th,tl;
      Operation(th,tl);
      
      SetPanal();
      
      Comment("Open Price >>",_open_price," Order type =",order_type," cutloss = ",cutloss," TP==>",_tp,
            "\n sig_b= ",sig_b," sig_s = ",sig_s,
            "\n Tick High = ",th," Tick Low =",tl,
            "\n"+txt_set);
      
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
       D1.ChartEvent(id,lparam,dparam,sparam);
        if(id==CHARTEVENT_OBJECT_CLICK){
        if(sparam=="CloseAll"){
          
          int answer=MessageBox("You want Close All order And ExpertRemove ?","EA Chang Logic V 3.00 !!!",MB_OKCANCEL);
          if(answer==1){
               order.CloseAll_Anymagic();
               Comment("");
               ExpertRemove();
          }
        }else if(sparam=="modeContinueBT"){
               if(continueOder){
                   B[1].Color(clrRed); 
                   B[1].ColorBackground(clrYellow);
                   continueOder=false;
                   B[1].Text("UNContinue Mode");
               }else{
                   B[1].Color(clrBlue); 
                   B[1].ColorBackground(clrLime);
                   continueOder=true;
                   B[1].Text("Continue Mode");
               }
        }else if(sparam=="modeLineBT"){
               if(closeLine){
                   B[2].Color(clrBlue); 
                   B[2].ColorBackground(clrLime);                   
                   closeLine=false;
                   B[2].Text("On Send Line");
               }else{
                   B[2].Color(clrRed); 
                   B[2].ColorBackground(clrYellow);
                   closeLine=true;
                   B[2].Text("Off Send Line");
               }
            }
        
       }
   
  }
//+------------------------------------------------------------------+
void Operation(double &th,double &tl){
   if(OrdersTotal()==0)open_order(_open_price);
      sl();
     ;
      if(order_type ==1){
            th=TickHigh(_open_price,setP,_tp);
      }else if(order_type==2){
              tl=TickLow(_open_price,setP,_tp);
            }
}


void SetPanal(){
      double diff_bal = Ck_profit(_pf_all);
      LBuy.Text(StringFormat("Profit Buy : %.2f",order.Show_profit_buy(Symbol())));
      LSell.Text(StringFormat("Profit Sell : %.2f",order.Show_profit_sell(Symbol())));
      LBalance.Text(StringFormat("Balance = %.2f",AccountBalance()));
      LBeforeProfit.Text(StringFormat("Before Profit :  %.2f  ",ShowLastProfit()));
      LProfitAll.Text(StringFormat("Profit All :  %.2f  ",_pf_all));
      LBuy.Color(order.Show_profit_buy(Symbol())>=0?clrBlack:clrRed);
      LSell.Color(order.Show_profit_sell(Symbol())>=0?clrBlack:clrRed);
      LBeforeProfit.Color(ShowLastProfit()>=0?clrBlack:clrRed);
      LProfitAll.Color(_pf_all>=0?clrBlack:clrRed);

}

double Ck_profit(double &pf_all){
   static double begin_bal = AccountBalance();
   static double old_profit =AccountBalance();
   static double diff_bal;
   double cur_profit = AccountBalance();
   if(old_profit!=cur_profit){
     // printf("oldB: %.2f curB: %.2f",old_profit,cur_profit);
      diff_bal=cur_profit-old_profit;
      old_profit=cur_profit;
      pf_all = cur_profit-begin_bal;
      return diff_bal;
   }
   return diff_bal; 
}
double Ck_lot(){
   if(OrdersTotal()>0){
      if(OrderSelect(0,SELECT_BY_POS)){
         return OrderLots();
      }
   }
 return 0;
}


void open_order(double &open_p){
   string massage;
   if(order_type ==0){
        
            if(sig_b!=0&&Close[0]>=sig_b ){
                     cutloss = sig_b - set_cutloss;  //1cl
                     //PrintFormat("Cutloss =>%.2f",cutloss);
                     _tp  = sig_b + setP;
                     order_type= 1;
                     sig_b =0;
                     sig_s =0;
                     open_p = Ask;
                     order.buy(NULL,Lot,0,0,"");
                     massage = StringFormat("Buy %s at Price %s",Symbol(),string(Ask));
                     if(!closeLine)yai_tool1.LineNotify(_token,massage);               
                     Print(massage);
               }else if (sig_s!=0&&Close[0]<=sig_s){
                           cutloss = sig_s + set_cutloss;   //cl
                            //PrintFormat("Cutloss =>%.2f",cutloss);
                           _tp  = sig_b - setP;
                           order_type = 2;  
                           sig_b =0;
                           sig_s =0; 
                           open_p = Bid;
                           order.sell(NULL,Lot,0,0,"");
                           massage = StringFormat("Sell %s at Price %s",Symbol(),string(Bid));
                           if(!closeLine)yai_tool1.LineNotify(_token,massage);                           
                           Print(massage);
                     }else{open_p = 0; }
        
     }else{open_p = open_p;}
}
void open_order_continue(double &open_p ,int _orderContinue){
   string massage;
   if(order_type ==0 && OrdersTotal()==0){
        
            if(_orderContinue==1){
                     cutloss = Ask - set_cutloss;  //1cl
                     //PrintFormat("Cutloss =>%.2f",cutloss);
                     _tp  = Ask + setP;
                     order_type= 1;
                     sig_b =0;
                     sig_s =0;
                     open_p = Ask;
                     order.buy(NULL,Lot,0,0,"");
                     massage = StringFormat("Buy %s at Price %s",Symbol(),string(open_p));
                     if(!closeLine)yai_tool1.LineNotify(_token,massage);                           
                     Print(massage);           
               }else if (_orderContinue==2){
                           cutloss = Bid + set_cutloss;   //cl
                            //PrintFormat("Cutloss =>%.2f",cutloss);
                           _tp  = Bid - setP;
                           order_type = 2;  
                           sig_b =0;
                           sig_s =0; 
                           open_p = Bid;
                           order.sell(NULL,Lot,0,0,"");
                           massage = StringFormat("Sell %s at Price %s",Symbol(),string(open_p));
                           if(!closeLine)yai_tool1.LineNotify(_token,massage);                           
                           Print(massage);                          
                     }else{open_p = 0; }
        
     }else{open_p = open_p;}
}
void sl(){
   // order >0
   string massage;
   if(order_type==1){
      if(Close[0]<=cutloss){
            if(OrdersTotal()>0){
                     order.CloseOrder(0,Symbol());
                     order_type =0;
                     massage = StringFormat("SL Order Buy  at %.s profit %s ",string(Bid),string(ShowLastProfit()));      
                     Print(massage);
                     if(!closeLine)yai_tool1.LineNotify(_token,massage);
                                       
                  }
            if(continueOder==false){
                  sig_b =  Close[0]+setP;   //edit
                  sig_s =  Close[0]-setP;   //edit
                  _tp=0;
                  cutloss=0;
                  
               }else{
                       open_order_continue(_open_price,2);  
               }       
         }
      }else if(order_type==2){
               if(Close[0]>=cutloss){
                  if(OrdersTotal()>0){
                      order.CloseOrder(1,Symbol());
                      order_type =0;
                      massage = StringFormat("SL Order Sell  at %.s profit %s ",string(Ask),string(ShowLastProfit()));      
                      Print(massage);
                      if(!closeLine)yai_tool1.LineNotify(_token,massage);
                  }
                  if(continueOder==false){
                        sig_b = Close[0]+setP;   //edit
                        sig_s =  Close[0]-setP;   //edit
                        _tp=0;
                        cutloss=0;
                        
                     }else{
                           open_order_continue(_open_price,1);    
                     }   
            }
        }
   
}
double dis_h=0;
double TickHigh(double open_p,double set_p,double tp){
   static double hightick = Close[0];
   double curtick = Close[0];
   string massage;        
            if(curtick>hightick){
               hightick = curtick;  
            }
            if(curtick> tp){
                  dis_h=hightick-curtick;
                 if(dis_h>=set_tp){     //TP
                        if(OrdersTotal()>0){
                             order.CloseOrder(0,Symbol());
                             order_type =0;
                             _open_price=0;
                             massage = StringFormat("TP Order Buy  at %.s profit %s ",string(Bid),string(ShowLastProfit()));      
                             Print(massage);
                             if(!closeLine)yai_tool1.LineNotify(_token,massage);
                           }
                        if(continueOder==false){
                              sig_b =  Close[0]+setP; // edit
                              sig_s =  Close[0]-setP; // edit
                              _tp=0;
                              cutloss=0; 
                        }else{
                              open_order_continue(_open_price,2);       
                        }  
                        hightick = curtick;
                        return -1000000;  
                  }  
               return dis_h;
            }else{return -1000000;}  
}
double dis_l=0;
double TickLow(double open_p,double set_p,double tp){
   static double lowtick = Close[0];
   double curtick = Close[0];
   string massage;
   if(curtick<lowtick)
   {
      lowtick = curtick;
   }
    if(curtick< tp){
                 dis_l=curtick-lowtick;
                 if(dis_l>=set_tp){      //TP
                        if(OrdersTotal()>0){
                              order.CloseOrder(1,Symbol());
                              order_type =0;
                              _open_price=0;
                              massage = StringFormat("TP Order Sell  at %.s profit %s ",string(Ask),string(ShowLastProfit()));      
                              Print(massage);
                              if(!closeLine)yai_tool1.LineNotify(_token,massage);
                           }
                        if(continueOder==false){
                              sig_b =  Close[0]+setP;   //edit
                              sig_s =  Close[0]-setP;   //edit
                              _tp=0;
                              cutloss=0;   
                        }else{
                           open_order_continue(_open_price,1);
                        } 
                      lowtick = curtick;
                      return -1000000;  
                  }
                 return dis_l;            
            }else{return -1000000;} 
}

double ShowLastProfit(){
      if(!OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))return 0.00;
      return OrderProfit();
}
void Creat_Dialog(){
   D1.Create(0,"D1",0,80,80,550,250);
   D1.Caption("EA Chang Logic V.3.00");
   

   
   LBuy.Create(0,"LBuy",0,0,0,120,40);
   LBuy.Shift(10,10);
   LBuy.Color(clrBlack);
   LBuy.Text("Profit Buy : 0.00");
   D1.Add(LBuy);
   
   LSell.Create(0,"LSell",0,0,0,150,40);
   LSell.Shift(150,10);
   LSell.Color(clrBlack);
   LSell.Text("Profit Sell : 0.00");
   D1.Add(LSell);
   
   LBalance.Create(0,"LBalance",0,0,0,150,40);
   LBalance.Shift(300,10);
   LBalance.Color(clrBlack);
   LBalance.Text("Balane : 0.00");
   D1.Add(LBalance);
   
   LBeforeProfit.Create(0,"LBeforePrifit",0,0,0,150,40);
   LBeforeProfit.Shift(10,40);
   LBeforeProfit.Color(clrBlack);
   LBeforeProfit.Text(StringFormat("Before Profit : %s",string(ShowLastProfit())));
   D1.Add(LBeforeProfit);
   
   LProfitAll.Create(0,"LPrifitAll",0,0,0,120,40);
   LProfitAll.Shift(150,40);
   LProfitAll.Color(clrBlack);
   LProfitAll.Text("Profit All :0.00");
   D1.Add(LProfitAll);
   
   B[0].Create(0,"CloseAll",0,0,0,120,40);
   B[0].ColorBackground(clrAquamarine);
   B[0].Text("Close All Order");
   B[0].Color(clrBlue);
   B[0].Shift(300,80);
   D1.Add(B[0]);
      
   B[1].Create(0,"modeContinueBT",0,0,0,120,40);
   B[1].ColorBackground(clrAquamarine);     
   if(continueOder){
         B[1].Color(clrBlue); 
         B[1].ColorBackground(clrLime);
         B[1].Text("Continue Mode");
     }else{
         B[1].Color(clrRed); 
         B[1].ColorBackground(clrYellow);
         B[1].Text("UNContinue Mode");
     }
   B[1].Shift(10,80);
   D1.Add(B[1]);
   
   B[2].Create(0,"modeLineBT",0,0,0,120,40);
   B[2].ColorBackground(clrAquamarine);     
   if(closeLine){
         B[2].Color(clrRed); 
         B[2].ColorBackground(clrYellow);
         B[2].Text("Off Send Line");
     }else{
         B[2].Color(clrBlue); 
         B[2].ColorBackground(clrLime);
         B[2].Text("On Send Line");
     }
   B[2].Shift(150,80);
   D1.Add(B[2]);
   
   D1.Run();
}

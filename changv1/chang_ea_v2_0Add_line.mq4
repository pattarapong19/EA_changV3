//+------------------------------------------------------------------+
//|                                                chang_ea_v1_0.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "2.00"
#property strict
#include <yai_ordermm.mqh>
#include <yai_tools1.mqh>
Cyai_tool1 yai_tool1;
Cordermm order;
extern double percent = 0.5;   //% Entry Order 
extern double percent_cutloss=1;  // % Cutloss
extern double percent_tp = 1; // % Teke Profit
input string _token =""; 
bool closeLine =true;
extern double Lot = 0.1;
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
         Print("Profit Daily :",txt_daily);
         txt_set=StringFormat("setP : %.2f set_cutloss : %.2f set_tp %.2f ",setP,set_cutloss,set_tp);
      }
      
      if(OrdersTotal()==0)open_order(_open_price);
      sl();
      
  double th,tl;
      if(order_type ==1){
            th=TickHigh(_open_price,setP,_tp);
      }else if(order_type==2){
              tl=TickLow(_open_price,setP,_tp);
            }
      
      double diff_bal = Ck_profit(_pf_all);
      yai_tool1.ctext("l_profit1",300,20,100,40,StringFormat("Profit Buy =%.2f",order.Show_profit_buy(Symbol())),16,"",clrGold);
      yai_tool1.ctext("l_profit2",500,20,100,40,StringFormat("Profit Sell =%.2f",order.Show_profit_sell(Symbol())),16,"",clrGold);
      yai_tool1.ctext("l_profit3",700,20,100,40,StringFormat("Balance =%.2f",AccountBalance()),16,"",clrGold);
      yai_tool1.ctext("l_profit4",300,50,100,40,StringFormat("Before Profit :  %.2f  profit all : %.2f",diff_bal,_pf_all),16,"",clrPink);
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
   
  }
//+------------------------------------------------------------------+

double Ck_profit(double &pf_all){
   static double begin_bal = AccountBalance();
   static double old_profit =AccountBalance();
   static double diff_bal;
   double cur_profit = AccountBalance();
   if(old_profit!=cur_profit){
      printf("oldB: %.2f curB: %.2f",old_profit,cur_profit);
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
   if(order_type ==0){
        
            if(sig_b!=0&&Close[0]>=sig_b ){
                     cutloss = sig_b - set_cutloss;  //1cl
                     PrintFormat("Cutloss =>%.2f",cutloss);
                     _tp  = sig_b + setP;
                     order_type= 1;
                     sig_b =0;
                     sig_s =0;
                     open_p = Ask;
                     order.buy(NULL,Lot,0,0,"");
                     if(!closeLine)yai_tool1.LineNotify(_token,"Buy Symbol:"+Symbol()+" At Price"+DoubleToString(Ask,2));                 
                  Print("Open Buy At",open_p);
               }else if (sig_s!=0&&Close[0]<=sig_s){
                           cutloss = sig_s + set_cutloss;   //cl
                            PrintFormat("Cutloss =>%.2f",cutloss);
                           _tp  = sig_b - setP;
                           order_type = 2;  
                           sig_b =0;
                           sig_s =0; 
                           open_p = Bid;
                          
                              order.sell(NULL,Lot,0,0,"");
                              if(!closeLine)yai_tool1.LineNotify(_token,"Sell Symbol:"+Symbol()+" At Price"+DoubleToString(Bid,2));                           
                           Print("Open Sell At",open_p);
                     }else{open_p = 0; }
        
     }else{open_p = open_p;}
}

void sl(){
   // order >0
   if(order_type==1){
      if(Close[0]<=cutloss){
            
            sig_b =  Close[0]+setP;   //edit
            sig_s =  Close[0]-setP;   //edit
            _tp=0;
            cutloss=0;
            order_type =0;
            if(OrdersTotal()>0){
               order.CloseOrder(0,Symbol());
               if(!closeLine)yai_tool1.LineNotify(_token,"Close Symbol:"+Symbol()+" At Price"+DoubleToString(Bid,2));
            }
            printf("Oder buy Close at %.2f orderbuy sig_b = %.2f sig_s =%.2f",Close[0],sig_b,sig_s);
         }
      }else if(order_type==2){
               if(Close[0]>=cutloss){
                  sig_b = Close[0]+setP;   //edit
                  sig_s =  Close[0]-setP;   //edit
                  _tp=0;
                  cutloss=0;
                  order_type =0;
                  if(OrdersTotal()>0){
                     order.CloseOrder(1,Symbol());
                  }
                   printf("Oder sell Close at %.2f orderbuy sig_b = %.2f sig_s =%.2f",Close[0],sig_b,sig_s);
                   if(!closeLine)yai_tool1.LineNotify(_token,"Close Symbol:"+Symbol()+" At Price"+DoubleToString(Ask,2));
            }
        }
   
}
double dis_h=0;
double TickHigh(double open_p,double set_p,double tp){
   static double hightick = Close[0];
   double curtick = Close[0];
           
            if(curtick>hightick){
               hightick = curtick;  
            }
            if(curtick> tp){
                  dis_h=hightick-curtick;
                 if(dis_h>=set_tp){     //TP
                        sig_b =  Close[0]+setP; // edit
                        sig_s =  Close[0]-setP; // edit
                        _tp=0;
                        cutloss=0;
                        order_type =0;
                        _open_price=0;
                        printf("Oder buy Close at %.2f orderbuy sig_b = %.2f sig_s =%.2f Order_Type %d",Close[0],sig_b,sig_s,order_type);
                        if(OrdersTotal()>0){
                              order.CloseOrder(0,Symbol());
                              if(!closeLine)yai_tool1.LineNotify(_token,"Close Symbol:"+Symbol()+" At Price"+DoubleToString(Bid,2));
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
   if(curtick<lowtick)
   {
      lowtick = curtick;
   }
    if(curtick< tp){
                 dis_l=curtick-lowtick;
                 if(dis_l>=set_tp){      //TP
                        sig_b =  Close[0]+setP;   //edit
                        sig_s =  Close[0]-setP;   //edit
                        _tp=0;
                        cutloss=0;
                        order_type =0;
                        _open_price=0;
                        printf("Oder sell Close at %.2f orderbuy sig_b = %.2f sig_s =%.2f Order_Type %d",Close[0],sig_b,sig_s,order_type);
                        if(OrdersTotal()>0){
                              order.CloseOrder(1,Symbol());
                              if(!closeLine)yai_tool1.LineNotify(_token,"Close Symbol:"+Symbol()+" At Price"+DoubleToString(Ask,2));
                           }
                        lowtick = curtick;
                        return -1000000;
                  }
                  
                  return dis_l;
               
            }else{return -1000000;}
   
}

//+------------------------------------------------------------------+
//|                                                       RMI EA.mq4 |
//|                                     Copyright 2015, Master Forex |
//|             https://www.mql5.com/ru/users/Master_Forex/portfolio |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Master Forex"
#property link      "https://www.mql5.com/ru/users/Master_Forex/portfolio"
#property version   "1.00"
#property strict
#property description "Created - 10.10.2015 17:58"
#property description " "
#property description "Customer ( cubbybgood ): https://www.mql5.com/en/users/cubbybgood"

enum trade{ 
a=0//Same
,b=1//Opposite
};

input string EAComment              = "RMI EA";     //EA Comment  
input string LicenceKey             = "";           //Serial Number
input string Indicator_Parameters   = "______________________________________________________";//Indicators Settings _____________________________________________
input string Indicators_            = "--------------------< RMI >--------------------";//Indicator RMI ...............................................................................................
input int    RMIPeriod              = 14;           //RMI Period
input int    MomPeriod              = 5;            //Mom Period
input int    BuyLevel               = 35;           //Buy Level
input int    SellLevel              = 65;           //Sell Level
input int    BarShift         	    = 1;            //Bar Shift
input string Trade_Parameters       = "______________________________________________________";//Trade Settings_______________________________________________
input bool   UseHedge               = 0;            //Use Hedge
input string Hedge                  = "EURGBP";     //Pair to Hedge
input trade  HedgeType              = 0;            //Hedge Order Type
input double HedgePercent           = 50;           //Hedge lots %
input double StopLoss               = 75;           //Stop Loss
input double TakeProfit             = 0;           //Take Profit
input bool   UseGrid                = 1;            //Use Grid
input double GridPips      	      = 20;           //Grid Pips
input bool   ExitWithSignal         = 0;            //Exit by Reverse 
input bool   ECN_Acc                = 0;            //ECN Broker
input int    Slippage               = 1;            //Slippage 
input double MaxSpread              = 10;           //Spread Filter   
input int    MagicNumber            = 123;          //Magic Number
input int    MaxOpenOrders          = 100;          //Number of Open Orders
input bool   ShowInfo               = 1;            //Show info 
input string TrailingStop           = "--------------------< Trailing Stop >--------------------";//Trailing Stop Settings ............................................................................................................
input bool   UseTrailingStop        = 0;            //Use Trailing Stop
input double TrailingStopStart	    = 20;           //Trailing Stop Start
input double TrailingStopStep       = 10;           //Trailing Stop Step
input string CloseAtPipsProfits     = "--------------------< Close by Pips Profit >--------------------";//Close by Pips Profit ...........................................................................................................
input bool   UseCloseAtPipsProfits  = 1;            //Close by Pips Profit
input int    PipsProfit             = 200;            //Profit in Pips
input string CloseAtPipsProfitsH    = "--------------------< Close by Pips Profit in Hedge >--------------------";//Close by Pips Profit in Hedge ...........................................................................................................
input bool   UseCloseAtPipsProfitsH = 0;            //Close by Pips Profit in Hedge
input int    PipsProfitH            = 5;            //Profit in Pips
input string CloseAtProfits         = "--------------------< Close by $ Profit >--------------------";//Close by $ Profit ...........................................................................................................
input bool   UseCloseAtProfits      = 0;            //Close by $ Profit
input double Profit                 = 5;            //Profit in $ 
input string ClosePercentLoss       = "--------------------< Close by % Loss >--------------------";//Close by % Loss ...........................................................................................................
input bool   CloseAtPercentLoss     = 1;            //Close by % Loss
input double PercentLoss            = 20;            //Loss %
input string MM_Parameters          = "--------------------< Money Management >--------------------";//Money Management Settings ...........................................................................................................
input double FixedLots              = 0.01;          //Lot
input bool   Martingale1            = 1;            //Martingale 1
input bool   Martingale2            = 0;            //Martingale 2 
input double MultiplierLot          = 2.0;          //Lot Multiplier
input bool   LotIncrease            = 1;            //Lot Increase  
input double Increase               = 0.01;          //Increase 
input double BalansStep             = 1000;         //Balans Step 
input string Time_Filter            = "--------------------< Trade Time >--------------------";//Trade Time Settings ............................................................................................................  
input bool   EnableTimer            = 0;            //Trade Time  
input string TimerStart             = "00:15:00";   //Time Start
input string TimerEnd               = "09:00:00";   //Time End
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
double Lotb, Lots, point=0, Sloss, Tprof, ClosingArray[100],LastPriceb=0,LastPrices=999999, max_lot, max_lotb, max_lots, DDBuffer=0, DrawDowns, depo = 0;
int PipValue = 1, lotdigit = 0, sp=0;bool Buy = 0, Sell = 0;string text[19], prefix="";
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() 
{
   if((Bid<10 && _Digits==5)||(Bid>10 && _Digits==3)) { PipValue=10;}
   if((Bid<10 && _Digits==4)||(Bid>10 && _Digits==2)) { PipValue= 1;}
   
   point = Point*PipValue;depo = AccountBalance();
   if(MarketInfo(Symbol(),MODE_LOTSTEP)>=0.01) lotdigit=2;   
   if(MarketInfo(Symbol(),MODE_LOTSTEP)>=0.1) lotdigit=1;   
   if(MarketInfo(Symbol(),MODE_LOTSTEP)>=1) lotdigit=0;
   ArrayResize(text,20);
   
   if(IsTesting()) prefix="Test"+IntegerToString(MagicNumber)+Symbol();
   else prefix=IntegerToString(MagicNumber)+Symbol();
   
  return(0);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
  if(!IsTesting()){
  for(int i= ObjectsTotal(); i>=0; i--) 
     {
      string name= ObjectName(i);
      if(StringSubstr(name,0,4)=="Info")
        {
         ObjectDelete(name);}
        }
     }else GVDel(prefix);
   return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//| Time limited trading                                             |
//+------------------------------------------------------------------+  
bool GoodTime()
 {
  if(!EnableTimer)return(true);
  if(EnableTimer)
    {
    if(TimeCurrent()>StrToTime(TimerStart) && TimeCurrent()<StrToTime(TimerEnd))
    return(true);
    }
   return(false);
 } 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
double DrawDown()
{
   double DD=AccountBalance()-AccountEquity();
   if(DD>DDBuffer)DDBuffer=DD;
   return(DDBuffer);
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
void OrdersClose()
{
   if(ExitWithSignal && 0 < Orders(0) && GVGet("EORb")==0 && Sell){ GVSet("EORb",1);} 
   
   if(ExitWithSignal && 0 < Orders(0) && GVGet("EORb")==1){ if(CloseOrders(0,FIFO(0))){ Print("-> Exit with RMI!");}}
                      
   if(ExitWithSignal && 0 < Orders(1) && GVGet("EORs")==0 && Buy){ GVSet("EORs",1);} 
   
   if(ExitWithSignal && 0 < Orders(1) && GVGet("EORs")==1){ if(CloseOrders(1,FIFO(1))){ Print("-> Exit with RMI!");}}
               
   if(UseCloseAtPipsProfits && 0 < Orders(0) && CheckPipsProfit(0)> PipsProfit && GVGet("EPPb")==0){ GVSet("EPPb",1);} 

   if(UseCloseAtPipsProfits && 0 < Orders(0) && GVGet("EPPb")==1){ if(CloseOrders(0,FIFO(0))){ Print("-> Exit with pips profits!");}}

   if(UseCloseAtPipsProfits && 0 < Orders(1) && CheckPipsProfit(1)> PipsProfit && GVGet("EPPs")==0){ GVSet("EPPs",1);} 

   if(UseCloseAtPipsProfits && 0 < Orders(1) && GVGet("EPPs")==1){ if(CloseOrders(1,FIFO(1))){ Print("-> Exit with pips profits!");}}

   if(UseHedge && UseCloseAtPipsProfitsH && CheckPipsProfith(0) > PipsProfitH && GVGet("EPPbh")==0){ GVSet("EPPbh",1);} 

   if(UseHedge && UseCloseAtPipsProfitsH && GVGet("EPPbh")==1){ if(CloseOrdersh(0,FIFOh(0))){ CloseOrders(0,FIFO(0));Print("-> Exit with pips profits!");}}

   if(UseHedge && UseCloseAtPipsProfitsH && CheckPipsProfith(1) > PipsProfitH && GVGet("EPPsh")==0){ GVSet("EPPsh",1);} 

   if(UseHedge && UseCloseAtPipsProfitsH && GVGet("EPPsh")==1){ if(CloseOrdersh(1,FIFOh(1))){ CloseOrders(1,FIFO(1));Print("-> Exit with pips profits!");}}
       
   if(UseCloseAtProfits && CheckProfit(0) > 0 && CheckProfit(0) >= Profit && GVGet("EPb")==0){ GVSet("EPb",1);} 
   
   if(UseCloseAtProfits && 0 < Orders(0) && GVGet("EPb")==1){ if(CloseOrders(0,FIFO(0))){ Print("-> Exit with $ profits!");}}  
   
   if(UseCloseAtProfits && CheckProfit(1) > 0 && CheckProfit(1) >= Profit && GVGet("EPs")==0){ GVSet("EPs",1);} 
   
   if(UseCloseAtProfits && 0 < Orders(1) && GVGet("EPs")==1){ if(CloseOrders(1,FIFO(1))){ Print("-> Exit with $ profits!");}} 
   
   if(CloseAtPercentLoss && 0 < Orders(0) && CheckProfit(0) < 0 && MathAbs(CheckProfit(0))> (PercentLoss*AccountBalance()/100) && GVGet("EPlb")==0){ GVSet("EPlb",1);} 
   
   if(CloseAtPercentLoss && 0 < Orders(0) && GVGet("EPlb")==1){ if(CloseOrders(0,FIFO(0))){ Print("-> Exit with % loss!");}}
   
   if(CloseAtPercentLoss && 0 < Orders(1) && CheckProfit(1) < 0 && MathAbs(CheckProfit(1))> (PercentLoss*AccountBalance()/100) && GVGet("EPls")==0){ GVSet("EPls",1);} 
   
   if(CloseAtPercentLoss && 0 < Orders(1) && GVGet("EPls")==1){ if(CloseOrders(1,FIFO(1))){ Print("-> Exit with % loss!");}}                                                                   

   if(1 > Orders(0)){ GVSet("EORb",0);GVSet("EOSb",0);GVSet("EPPb",0);GVSet("EPPbh",0);GVSet("EPb",0);GVSet("EPlb",0);} 
   
   if(1 > Orders(1)){ GVSet("EORs",0);GVSet("EOSs",0);GVSet("EPPs",0);GVSet("EPPsh",0);GVSet("EPs",0);GVSet("EPls",0);}                                                                       
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Trailing Stop                                                    |
//+------------------------------------------------------------------+
void TrailingStops() 
{ 
   if(!UseTrailingStop) return;
   
   double profit1, stoptrade1, stopcal1, Average1 = 0, Count1 = 0, PriceTarget1 = 0, AveragePrice1 = 0;
   double profit2, stoptrade2, stopcal2, Average2 = 0, Count2 = 0, PriceTarget2 = 0, AveragePrice2 = 0;
   
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      bool os = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber)) {
         if (OrderType() == OP_BUY) {
            Average1 += OrderOpenPrice() * OrderLots();
            Count1 += OrderLots();
         }}} 
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      bool os = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber)) {
         if (OrderType() == OP_SELL) {
            Average2 += OrderOpenPrice() * OrderLots();
            Count2 += OrderLots();
         }}} 
                  
   if(Orders(0) > 0 && Average1 != 0){ AveragePrice1 = NormalizeDouble(Average1/Count1, Digits);}
   if(Orders(1) > 0 && Average2 != 0){ AveragePrice2 = NormalizeDouble(Average2/Count2, Digits);}
   
   if(TrailingStopStart != 0) 
     {
      for (int x = OrdersTotal() - 1; x >= 0; x--) {
         if (OrderSelect(x, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_BUY) {
                  profit1 = NormalizeDouble((Bid - AveragePrice1) / point, 0);
                  if(profit1 > TrailingStopStart){
                  stoptrade1 = NormalizeDouble(OrderStopLoss(),_Digits);
                  stopcal1 = NormalizeDouble(Bid - TrailingStopStep * point,_Digits);
                  if(stoptrade1 == 0.0 || (stoptrade1 != 0.0 && stopcal1 > stoptrade1)){ 
                  bool om = OrderModify(OrderTicket(), AveragePrice1, stopcal1, OrderTakeProfit(), 0, clrAqua);}
               }}
               if (OrderType() == OP_SELL) {
                  profit2 = NormalizeDouble((AveragePrice2 - Ask) / point, 0);
                  if(profit2 > TrailingStopStart){  
                  stoptrade2 = NormalizeDouble(OrderStopLoss(),_Digits);
                  stopcal2 = NormalizeDouble(Ask + TrailingStopStep * point,_Digits);
                  if(stoptrade2 == 0.0 || (stoptrade2 != 0.0 && stopcal2 < stoptrade2)){ 
                  bool om = OrderModify(OrderTicket(), AveragePrice2, stopcal2, OrderTakeProfit(), 0, clrRed);}
               }}}          
           Sleep(1000);
}  }  }  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//       
void ECN()
{
   for(int i = 0; i < OrdersTotal(); i++) 
      {
       bool OrSel = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);    
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
         {         
       if(OrderType() == OP_BUY) 
         {          
       if(ECN_Acc && OrderTakeProfit()== 0 && OrderStopLoss()== 0 && (TakeProfit != 0 || StopLoss != 0))
         {           
          bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),Sloss,Tprof,OrderExpiration(),clrNONE);}                                                                                                                                                                           
         }    
       if(OrderType() == OP_SELL) 
         {         
       if(ECN_Acc && OrderTakeProfit()== 0 && OrderStopLoss()== 0 && (TakeProfit != 0 || StopLoss != 0))
         {                 
          bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),Sloss,Tprof,OrderExpiration(),clrNONE);}}}                                                                                                                             
         }  
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Get total order                                                  |
//+------------------------------------------------------------------+
int Orders(int type)
{
   int count=0;
   //-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop;   
   for(int x=OrdersTotal()-1;x>=0;x--)
      {
       if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)){ 
       if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
          if(type < 0){ count++;}
          if(OrderType() == type && type >= 0){ count++;}         
         }}}   
   return(count);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//|  Расчет размера ордера                                           |
//+------------------------------------------------------------------+
void Lot()
{ 
    Lots = FixedLots;Lotb = FixedLots;double Exp=0; 
    if(AccountBalance()!=0){DrawDowns = DrawDown()*100/AccountBalance();}
    double profit = FindLastOrderParameterHist("profit"); 
    if(UseGrid){
    max_lotb = FindLastOrderParameter(0, "lot");   
    max_lots = FindLastOrderParameter(1, "lot");}
    if(!UseGrid){ max_lot = FindLastOrderParameterHist("lot");}
    if(Martingale2 && profit < 0 && !UseGrid){ Lots=NormalizeDouble(max_lot * MultiplierLot, lotdigit);}
    if(Martingale2 && profit < 0 && !UseGrid){ Lotb=NormalizeDouble(max_lot * MultiplierLot, lotdigit);}
    if(Martingale2 && UseGrid && Orders(1) > 0){ Lots=NormalizeDouble(max_lots * MultiplierLot, lotdigit);}
    if(Martingale2 && UseGrid && Orders(0) > 0){ Lotb=NormalizeDouble(max_lotb * MultiplierLot, lotdigit);}    
    if(Martingale1 && UseGrid) { Lotb = FixedLots * (Orders(0)+1);} 
    if(Martingale1 && UseGrid) { Lots = FixedLots * (Orders(1)+1);}   
    if(Martingale1 && !UseGrid && profit < 0) { Lotb = max_lot+FixedLots;} 
    if(Martingale1 && !UseGrid && profit < 0) { Lots = max_lot+FixedLots;}  
    Exp = MathFloor((AccountBalance()-depo)/BalansStep);
    if(LotIncrease){ Lotb = Lotb+Exp*Increase;}if(LotIncrease){ Lots = Lots+Exp*Increase;} 
    if(Lotb<MarketInfo(Symbol(),MODE_MINLOT)){ Lotb=MarketInfo(Symbol(),MODE_MINLOT);}
    if(Lotb>MarketInfo(Symbol(),MODE_MAXLOT)){ Lotb=MarketInfo(Symbol(),MODE_MAXLOT);}  
    if(Lots<MarketInfo(Symbol(),MODE_MINLOT)){ Lots=MarketInfo(Symbol(),MODE_MINLOT);}
    if(Lots>MarketInfo(Symbol(),MODE_MAXLOT)){ Lots=MarketInfo(Symbol(),MODE_MAXLOT);}             
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Pips Profit                                                |
//+------------------------------------------------------------------+     
double CheckPipsProfit(int type) //-1= All,0=Buy,1=Sell; 
{
   double Profitb=0,Profits=0;       
   for(int i=OrdersTotal()-1;i>=0;i--)
      {
       bool os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);            
       if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
         {        
          if(OrderType()==OP_BUY){ Profitb=Profitb+((MI("bid")-OrderOpenPrice())/point);} 
          if(OrderType()==OP_SELL){ Profits=Profits+((OrderOpenPrice()-MI("ask"))/point);} 
         }} 
       if(0==type){ return(Profitb);}
       if(1==type){ return(Profits);}
       if(-1==type){ return(Profits+Profitb);}
     return(0);
} 
//+------------------------------------------------------------------+     
double CheckPipsProfith(int type) //-1= All,0=Buy,1=Sell; 
{
   double Profitb=0,Profits=0;       
   for(int i=OrdersTotal()-1;i>=0;i--)
      {
       bool os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);            
       if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
         {        
          if(OrderType()==OP_BUY){ Profitb=Profitb+((MI("bid")-OrderOpenPrice())/point);} 
          if(OrderType()==OP_SELL){ Profits=Profits+((OrderOpenPrice()-MI("ask"))/point);} 
         }
       if(OrderSymbol()==Hedge && OrderMagicNumber() == MagicNumber)
         {        
          if(OrderType()==OP_BUY){ Profitb=Profitb+((MI("bid",Hedge)-OrderOpenPrice())/point);} 
          if(OrderType()==OP_SELL){ Profits=Profits+((OrderOpenPrice()-MI("ask",Hedge))/point);} 
         }} 
       if(0==type){ return(Profitb);}
       if(1==type){ return(Profits);}
       if(-1==type){ return(Profits+Profitb);}
     return(0);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check $ Profit                                                   |
//+------------------------------------------------------------------+     
double CheckProfit(int type) //-1= All,0=Buy,1=Sell;
{
  double Profitb=0,Profits=0;       
  for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);            
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
        {        
        if(OrderType()==OP_BUY){ Profitb+=OrderProfit()+OrderSwap()+OrderCommission();} 
        if(OrderType()==OP_SELL){ Profits+=OrderProfit()+OrderSwap()+OrderCommission();} 
       }} 
       if(0==type){ return(Profitb);}
       if(1==type){ return(Profits);}
       if(-1==type){ return(Profits+Profitb);}
     return(0);
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------+
//|  Close Orders                                              |
//+------------------------------------------------------------+  
bool CloseOrders(int type, int tick)
{  
  bool oc=0;    
  bool os = OrderSelect(tick,SELECT_BY_TICKET, MODE_TRADES);
  if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {   
     if(type==-1){
     if(OrderType()==0){ oc = OrderClose(tick,OrderLots(),Bid,1000,clrGold);}
     if(OrderType()==1){ oc = OrderClose(tick,OrderLots(),Ask,1000,clrGold);}      
     if(OrderType()>1){  oc = OrderDelete(tick);}}  
     if(OrderType()==type && type==0){ oc = OrderClose(tick,OrderLots(),Bid,1000,clrGold);}
     if(OrderType()==type && type==1){ oc = OrderClose(tick,OrderLots(),Ask,1000,clrGold);} 
     if(OrderType()==type && OrderType()> 1){ oc = OrderDelete(tick);} 
     if(OrderType()==0 && type==6){ oc = OrderClose(tick,OrderLots(),Bid,1000,clrGold);}  
     if((OrderType()==2 || OrderType()== 4) && type==6){ oc = OrderDelete(tick);}   
     if(OrderType()==1 && type==7){ oc = OrderClose(tick,OrderLots(),Bid,1000,clrGold);}  
     if((OrderType()==3 || OrderType()== 5) && type==7){ oc = OrderDelete(tick);}       
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } 
   return(oc);
}   
//+------------------------------------------------------------+  
bool CloseOrdersh(int type, int tick)
{  
  bool oc=0, os = OrderSelect(tick,SELECT_BY_TICKET, MODE_TRADES);
  
  if(OrderSymbol()==Hedge && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==type){ oc = OrderClose(tick,OrderLots(),OrderClosePrice(),1000,clrGold);}
      
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } 
   return(oc);
}   
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
double FindLastOrderParameter(int type, string ParamName) 
{
  double mOrderPrice = 0, mOrderLot = 0, mOrderProfit = 0;
  int PrevTicket = 0, CurrTicket = 0, mOrderTicket = 0;
  
  for(int i = OrdersTotal() - 1; i >= 0; i--) 
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
        {
         if(OrderType()==type || type < 0) CurrTicket = OrderTicket();
         if(CurrTicket > PrevTicket) 
           {
            PrevTicket = CurrTicket;
            mOrderPrice = OrderOpenPrice();
            mOrderTicket = OrderTicket();
            mOrderLot = OrderLots();
            mOrderProfit = OrderProfit() + OrderSwap() + OrderCommission();          
           }
       }   
  if(ParamName == "price") return(mOrderPrice);
  else if(ParamName == "ticket") return(mOrderTicket);
  else if(ParamName == "lot") return(mOrderLot);
  else if(ParamName == "profit") return(mOrderProfit);
  return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
double FindLastOrderParameterHist(string ParamName) 
{
  double mOrderPrice = 0, mOrderLot = 0, mOrderProfit = 0;
  int PrevTicket = 0, CurrTicket = 0, mOrderTicket = 0;
  
  for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) 
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
      {
        CurrTicket = OrderTicket();
        if (CurrTicket > PrevTicket) 
        {
          PrevTicket = CurrTicket;
          mOrderPrice = OrderOpenPrice();
          mOrderTicket = OrderTicket();
          mOrderLot = OrderLots();
          mOrderProfit = OrderProfit() + OrderSwap() + OrderCommission();          
        }
      }   
  if(ParamName == "price") return(mOrderPrice);
  else if(ParamName == "ticket") return(mOrderTicket);
  else if(ParamName == "lot") return(mOrderLot);
  else if(ParamName == "profit") return(mOrderProfit);
  return(0);
}
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO//
//+------------------------------------------------------------------+
//|  Get Signals                                                     |
//+------------------------------------------------------------------+
double rmi(int shift){ return(iCustom(NULL, 0, "RMI",RMIPeriod,MomPeriod,0,shift));}   
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//|  Get Signals                                                     |
//+------------------------------------------------------------------+
void Indicators() 
{             
    Buy = (rmi(BarShift) < BuyLevel && iLow(NULL,0,2) <= iLow(NULL,0,iLowest(NULL,0,MODE_LOW,8,2)) && iLow(NULL,0,2) < iLow(NULL,0,1) && iHigh(NULL,0,2) > 
           iHigh(NULL,0,1) && iOpen(NULL,0,2) > iClose(NULL,0,2) && iClose(NULL,0,1) > iOpen(NULL,0,1));
   
    Sell =(rmi(BarShift) > SellLevel && iHigh(NULL,0,2) >= iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,8,2)) && iLow(NULL,0,2) < iLow(NULL,0,1) && iHigh(NULL,0,2) > 
           iHigh(NULL,0,1) && iOpen(NULL,0,2) < iClose(NULL,0,2) && iClose(NULL,0,1) < iOpen(NULL,0,1));       
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() 
{  

   string SERIAL_NUMBER = "cubbybgood"; // You can change this SN and make compile!!! 
   
//+------------------------------------------------------------------+
   if(LicenceKey != SERIAL_NUMBER)
     {
      Alert("Serial Number is wrong! Please Contact ****@***.com"); 
      Comment("Serial Number is wrong! Please Contact ****@***.com"); 
      return(0);
     }
//+------------------------------------------------------------------+
   Indicators();Lot();ECN();OrdersClose();PrintInfo();TrailingStops();   
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//       
           
   LastPriceb = FindLastOrderParameter(0,"price");LastPrices = FindLastOrderParameter(1,"price");
   
   if(SpreadCheck() && (IsTesting() || (IsExpertEnabled() && IsTradeAllowed())))
     { 
      if(Buy && MaxOpenOrders > Orders(0) && GoodTime() && iTime(NULL,0,0)+3 < TimeCurrent() && !UseGrid) 
        {   
         double lot = Lotb;
         if(CurrBar() && ClosedBar()){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Bid - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = Ask + TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage * PipValue, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else int Tiket= OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage* PipValue, 0, 0, EAComment, MagicNumber, 0, clrBlue);}               
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==0){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("bid",Hedge) - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("ask",Hedge) + TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrBlue);}
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==1){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("ask",Hedge) + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("bid",Hedge) - TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrRed);}           
        }   
      if(Sell && MaxOpenOrders > Orders(1) && GoodTime() && iTime(NULL,0,0)+3 < TimeCurrent() && !UseGrid) 
        {   
         double lot = Lots; 
         if(CurrBar() && ClosedBar()){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Ask + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = Bid - TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Symbol(), OP_SELL, lot, Bid, Slippage* PipValue, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else int Tiket= OrderSend(Symbol(), OP_SELL, lot, Bid, Slippage* PipValue, 0, 0, EAComment, MagicNumber, 0, clrRed);}
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==0){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("ask",Hedge) + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("bid",Hedge) - TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrRed);}     
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==1){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("bid",Hedge) - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("ask",Hedge) + TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrBlue);}            
        } 
      if(Buy && 1 > Orders(0) && 1 > Orders(1) && GoodTime() && UseGrid) 
        {   
         double lot = Lotb;int Tikets = -1;   
         
         if(CurrBar() && ClosedBar()){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Bid - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = Ask + TakeProfit * point;}
         if(!ECN_Acc){ Tikets = OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage * PipValue, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else Tikets = OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage* PipValue, 0, 0, EAComment, MagicNumber, 0, clrBlue);} 
         if(Tikets > 0){                   
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==0){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("bid",Hedge) - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("ask",Hedge) + TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrBlue);}
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==1){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("ask",Hedge) + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("bid",Hedge) - TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrRed);}}                         
        }   
      if(Sell && 1 > Orders(1) && 1 > Orders(0) && GoodTime() && UseGrid) 
        {     
         double lot = Lots;int Tikets = -1;  

         if(CurrBar() && ClosedBar()){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Ask + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = Bid - TakeProfit * point;}
         if(!ECN_Acc){ Tikets = OrderSend(Symbol(), OP_SELL, lot, Bid, Slippage* PipValue, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else Tikets = OrderSend(Symbol(), OP_SELL, lot, Bid, Slippage* PipValue, 0, 0, EAComment, MagicNumber, 0, clrRed);}  
         if(Tikets > 0){             
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==0){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("ask",Hedge) + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("bid",Hedge) - TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrRed);}     
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==1){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("bid",Hedge) - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("ask",Hedge) + TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrBlue);}}         
        }          
      if(UseGrid && GoodTime() && LastPriceb-GridPips*point >= Ask && 0 < Orders(0) && 1 > Orders(1) && MaxOpenOrders > Orders(-1)) 
        {   
         double lot = Lotb;int Tikets=-1; 
       
        if(CurrBar() && ClosedBar()){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Bid - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = Ask + TakeProfit * point;}
         if(!ECN_Acc){ Tikets = OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage * PipValue, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else Tikets = OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage* PipValue, 0, 0, EAComment, MagicNumber, 0, clrBlue);}    
         if(Tikets > 0){                               
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==0){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("bid",Hedge) - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("ask",Hedge) + TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrBlue);}
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==1){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("ask",Hedge) + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("bid",Hedge) - TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrRed);}}             
        }   
      if(UseGrid && GoodTime() && LastPrices+GridPips*point <= Bid && 0 < Orders(1) && 1 > Orders(0) && LastPrices!=0 && MaxOpenOrders > Orders(-1)) 
        {     
         double lot = Lots;int Tikets = -1; 

         if(CurrBar() && ClosedBar()){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Ask + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = Bid - TakeProfit * point;}
         if(!ECN_Acc){ Tikets = OrderSend(Symbol(), OP_SELL, lot, Bid, Slippage* PipValue, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else Tikets = OrderSend(Symbol(), OP_SELL, lot, Bid, Slippage* PipValue, 0, 0, EAComment, MagicNumber, 0, clrRed);}       
         if(Tikets > 0){       
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==0){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("ask",Hedge) + StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("bid",Hedge) - TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);}
         else int Tiket= OrderSend(Hedge, OP_SELL, (lot*HedgePercent)/100, MI("bid",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrRed);}     
         if(UseHedge && CurrBar(Hedge) && ClosedBar(Hedge) && HedgeType==1){ 
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = MI("bid",Hedge) - StopLoss * point;}
         if(TakeProfit==0){ Tprof = 0;}else{ Tprof = MI("ask",Hedge) + TakeProfit * point;}
         if(!ECN_Acc){ int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, Sloss, Tprof, EAComment, MagicNumber, 0, clrBlue);}
         else int Tiket= OrderSend(Hedge, OP_BUY, (lot*HedgePercent)/100, MI("ask",Hedge), Slippage, 0, 0, EAComment, MagicNumber, 0, clrBlue);}}   
        } 
     }                 
   return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//| Print info to chart                                              |
//+------------------------------------------------------------------+
void PrintInfo()
{
 if(ShowInfo)
   {    
    text[1]= EAComment;
    text[2]= "Spread: " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD)/PipValue, 2);
    text[3]= "--------------------------------------------------";
    text[4]= "Account Number: " + (string)AccountNumber();
    text[5]= "Account Leverage: " + DoubleToStr(AccountLeverage(), 0);
    text[6]= "Account Balance: " + DoubleToStr(AccountBalance(), 2);
    text[7]= "Account Today Profit: " + DoubleToStr(DailyProfits(), 2);
    text[8]= "Account All Profit: " + DoubleToStr(AllProfits(), 2);
    text[9]= "Free Margin: " + DoubleToStr(AccountFreeMargin(), 2);
    text[10]= "Used Margin: " + DoubleToStr(AccountMargin(), 2);
    text[11]= "Max. Draw Down: " + DoubleToStr(DrawDown(), 2)+"("+DoubleToStr(DrawDowns,2)+"%"")";
    text[12]= "--------------------------------------------------";
    text[13]= "Lot Size: " + DoubleToStr(Lots,lotdigit);
    text[14]= "Take Profit: " + DoubleToStr(Tprof,_Digits);
    text[15]= "Stop Loss: " + DoubleToStr(Sloss,_Digits);
    text[16]= "Magic Number: " + (string)MagicNumber ;    
    text[17]= "--------------------------------------------------";
    
    int i=1, k=15;
    while (i<=17)
      {
       string ChartInfo = "Info"+IntegerToString(i);
       ObjectCreate(ChartInfo, OBJ_LABEL, 0, 0, 0);
       ObjectSetText(ChartInfo, text[i], 9, "Arial", clrGoldenrod);
       ObjectSet(ChartInfo, OBJPROP_CORNER, 0);   
       ObjectSet(ChartInfo, OBJPROP_XDISTANCE, 7);  
       ObjectSet(ChartInfo, OBJPROP_YDISTANCE, k);
       i++; k=k+13;
      }
   }
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+----------------------------------------------------------------------------------+
//| Daily Profit                                                                     |
//+----------------------------------------------------------------------------------+  
double DailyProfits()
 {   
   int i; double LastDayProfits=0;
   for(i=0;i<OrdersHistoryTotal();i++)
    {
    bool os = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
    if(OrderMagicNumber()==MagicNumber && TimeDayOfYear(OrderCloseTime())==DayOfYear()){
    LastDayProfits=LastDayProfits+OrderProfit();}}  
  for(i = 0; i < OrdersTotal(); i++) 
    {
     bool Os = OrderSelect(i, SELECT_BY_POS); 
     if(OrderMagicNumber()==MagicNumber && TimeDayOfYear(OrderOpenTime())==DayOfYear()){
     if(OrderType()==OP_BUY){
     LastDayProfits=LastDayProfits+OrderProfit();}
     if(OrderType()==OP_SELL){
     LastDayProfits=LastDayProfits+OrderProfit();}
   }}       
  return(LastDayProfits);
 }
//+----------------------------------------------------------------------------------+
//| All Profit                                                                       |
//+----------------------------------------------------------------------------------+  
double AllProfits()
 {   
   int i; double LastDayProfits=0;
   for(i=0;i<OrdersHistoryTotal();i++)
    {
    bool os = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
    if(OrderMagicNumber()==MagicNumber){
    LastDayProfits=LastDayProfits+OrderProfit();}}
  
   for(i = 0; i < OrdersTotal(); i++) 
    {
     bool Os = OrderSelect(i, SELECT_BY_POS); 
     if(OrderMagicNumber()==MagicNumber){
     if(OrderType()==OP_BUY){
     LastDayProfits=LastDayProfits+OrderProfit();}
     if(OrderType()==OP_SELL){
     LastDayProfits=LastDayProfits+OrderProfit();}
   }}       
  return(LastDayProfits);
 } 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH   
//+------------------------------------------------------------------+
//|  Global Variable Set                                             |
//+------------------------------------------------------------------+  
datetime GVSet(string name,double value)
{
   return(GlobalVariableSet(prefix+name,value));
}
//+------------------------------------------------------------------+
//|  Global Variable Get                                             |
//+------------------------------------------------------------------+
double GVGet(string name)
{
   return(GlobalVariableGet(prefix+name));
}
//+------------------------------------------------------------------+
//|  Global Variable Delete                                          |
//+------------------------------------------------------------------+
bool GVDel(string pref)
{
   for(int tries=0; tries<10; tries++)
     {
      int obj=GlobalVariablesTotal();
      for(int o=0; o<obj;o++)
        {
         string name=GlobalVariableName(o);
         int index=StringFind(name,pref,0);
         if(index>-1)
            GlobalVariableDel(name);
        }
     }
   return(false);  
}    
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//| get first order ticket                                           |
//+------------------------------------------------------------------+
int FIFO(int type) 
{
  int Prev=999999999, Curr=0, tick=-1;

  for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) 
        { 
         if(OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
         {     
          if(OrderType() == type || type == -1){ Curr = OrderTicket();
          if(Curr < Prev){ Prev = Curr; tick = OrderTicket();          
          }}}}}return(tick);
  return(0);
}   
//+------------------------------------------------------------------+
int FIFOh(int type) 
{
  int Prev=999999999, Curr=0, tick=-1;

  for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) 
        { 
         if(OrderSymbol() != Hedge || OrderType() > OP_SELL) continue;
         if(OrderSymbol() == Hedge && OrderMagicNumber() == MagicNumber) 
         {     
          if(OrderType() == type || type == -1){ Curr = OrderTicket();
          if(Curr < Prev){ Prev = Curr; tick = OrderTicket();          
          }}}}}return(tick);
  return(0);
}   
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Spread                                                     |
//+------------------------------------------------------------------+
bool SpreadCheck()
{     
   double SP=NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)/PipValue),1);
   
   if(SP > MaxSpread){ if(sp==0)
     {
      Print("Spread (",SP,")"," > ","Max Spread (",MaxSpread,")");
      Alert("Spread (",SP,")"," > ","Max Spread (",MaxSpread,")");
      sp=1;}return(false);} else if(SP < MaxSpread){ sp = 0;
     }               
   return(true);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already open)             |
//+------------------------------------------------------------------+
bool CurrBar(string symbol=NULL)
{ 
   bool yes = 1;string sym=symbol; if(symbol==NULL) sym=Symbol();
//+------------------------------------------------------------------+
   for(int i = OrdersTotal()-1; i >= 0; i--)
      {
    	if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    	{  
    	if(OrderSymbol() == sym && OrderMagicNumber() == MagicNumber) 
      {     
       if(OrderOpenTime() >= iTime(sym,0,0)) yes = 0;   
      }}}   
   return(yes);
}     
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already opened and closed)|
//+------------------------------------------------------------------+
bool ClosedBar(string symbol=NULL)
{ 
   bool yes = 1;string sym=symbol; if(symbol==NULL) sym=Symbol();
//+------------------------------------------------------------------+
   for(int i = OrdersHistoryTotal()-1; i>=0; i--)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
      { 
      Print("Error in history!"); break; 
      }
      if(OrderSymbol() != sym || OrderType()>OP_SELL) continue;
      if(OrderSymbol() == sym && OrderMagicNumber() == MagicNumber) 
      {	    
      if(OrderOpenTime() >= iTime(sym,0,0)) yes = 0;   
    	}}   
   return(yes);
}        
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Symbol Info                                                |
//+------------------------------------------------------------------+     
double MI(string type, string symbol=NULL)  
{  
   string sym=symbol;if(symbol==NULL) sym=Symbol();
   if(type=="ask") return(MarketInfo(sym,MODE_ASK)); 
   if(type=="bid") return(MarketInfo(sym,MODE_BID));
   if(type=="point") return(MarketInfo(sym,MODE_POINT));
   if(type=="digits") return(MarketInfo(sym,MODE_DIGITS)); 
   return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Symbol Points                                              |
//+------------------------------------------------------------------+     
double point(string symbol=NULL)  
{  
   string sym=symbol;if(symbol==NULL) sym=Symbol();
   double bid=(int)MarketInfo(sym,MODE_BID);
   int digits=(int)MarketInfo(sym,MODE_DIGITS);
   
   if(digits<=1) return(1); //CFD & Indexes  
   if(digits==4 || digits==5) return(0.0001); 
   if((digits==2 || digits==3) && bid>1000) return(1);
   if((digits==2 || digits==3) && bid<1000) return(0.01);
   if(StringFind(sym,"XAU")>-1 || StringFind(sym,"xau")>-1 || StringFind(sym,"GOLD")>-1) return(0.1);//Gold  
   return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//

//+------------------------------------------------------------------+
//|                                           Order Block Helper.mq4 |
//|                                        Copyright 2021, PapaCoder |
//|                                                  t.me/PrdnNvnRnt |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Simple OB Traders Indonesia"
#property link      "t.me/simpleob"
#property version   "1.00"
#property icon "\\Images\\OB64.ico"
#property description "Untuk Membantu Para Trader Order Block\n\nIdea by : Sigit Pamungkas (https://t.me/mumung99)"
#property strict


string namaLock      = "";//Kalau Mau Diisi Lock Nama - Kosong berarti ngga di lock nama
int    nomorLock     = 0;//Kalau Mau Diisi Lock No Akun - 0 berarti ngga di lock No Akun
datetime expayed     = 0; //D'2021.01.01'//Kalau Mau Diisi Expired - 0 berarti ngga di Expired === FORMAT D'TAHUN.BULAN.TANGGAL'


#include  <stdlib.mqh>
//Control Radio Group=====================================================
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\Edit.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (35)     // size by X coordinate
#define BUTTON_HEIGHT                       (25)      // size by Y coordinate
#define EDIT_HEIGHT                         (20)
#define EDIT_WIDTH                          (20)

#define MASTER          "Master"

#define IMB             "IMB"
#define BOS             "BOS"
#define POI             "POI"
#define OB              "OB"
#define HI              "Hi"
#define LO              "Lo"
#define HH              "HH"
#define LH              "LH"
#define HL              "HL"
#define LL              "LL"
#define DOLLAR          "$"
#define TRENDLINE       "/"

#define BOX             "BOX"
#define BOXFILLED1      "BOXFill1"
#define BOXFILLED2      "BOXFill2"
#define HLINE           "HLine"
#define ARROWUP         "ArrowUp"
#define ARROWDOWN       "ArrowDown"
#define TRENDSOLID      "TrendlineSolid"
//--- for the indication area
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog {
 private:

   CLabel            labelPair, labelTF, labelEntryType, labelRiskType, labelRiskSize, labelTPSize, labelBE, labelEntryPrice, labelLot, labelSL, labelTP, labelGrup;
   CEdit             editRiskSize, editTPSize, editBE, editEntryPrice, editLot, editSL, editTP;
   CComboBox         comboPair, comboTF, comboEntryType, comboRiskType;
   CButton           buttonPlace, buttonDelete, buttonBE, buttonCloseProfit;

 public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   string            getEntryType(void);
   string            getRiskType(void);
   string            getRiskRatio(void);
   string            getRewardRatio(void);
   string            getBE(void);

   bool              updatePrice(string update);
   bool              updateLot(string update);
   bool              updateStoploss(string update);
   bool              updateTakeprofit(string update);
   bool              updateComboTF();

 protected:
   //--- create dependent controls
   bool              CreateEdit(void);
   bool              CreateLabel(void);
   bool              CreateCombo(void);
   bool              CreateButton(void);

   void              OnChangePair(void);
   void              OnChangeTF(void);
   void              clickPlaceOrder(void);
   void              clickDeleteOrder(void);
   void              clickBE(void);
   void              clickCloseProfit(void);

};

//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CHANGE, comboPair, OnChangePair);
ON_EVENT(ON_CHANGE, comboTF, OnChangeTF);
ON_EVENT(ON_CLICK, buttonPlace, clickPlaceOrder);
ON_EVENT(ON_CLICK, buttonDelete, clickDeleteOrder);
ON_EVENT(ON_CLICK, buttonBE, clickBE);
ON_EVENT(ON_CLICK, buttonCloseProfit, clickCloseProfit);
EVENT_MAP_END(CAppDialog)


//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void) {
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void) {
}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2) {
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
      return(false);
//--- create dependent controls

   if(!CreateLabel())
      return(false);

   if(!CreateCombo())
      return(false);

   if(!CreateEdit())
      return(false);

   if(!CreateButton())
      return(false);

//--- succeed
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButton(void) {
//--- coordinates
   int x1 = INDENT_RIGHT + 5;
   int y1 = 350;
   int x2 = x1 + 100;
   int y2 = y1 + 30;

//--- create
   if(!buttonPlace.Create(m_chart_id, m_name + "Place", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!buttonPlace.Text("Place Order"))
      return(false);
   if(!buttonPlace.ColorBackground(clrLime))
      return(false);
   if(!buttonPlace.Color(clrWhite))
      return(false);
   if(!Add(buttonPlace))
      return(false);

//--- coordinates
   x1 = x2 + 35;
   x2 = x1 + 100;
   y2 = y1 + 30;
//--- create
   if(!buttonDelete.Create(m_chart_id, m_name + "Delete", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!buttonDelete.Text("Delete Order"))
      return(false);
   if(!buttonDelete.ColorBackground(clrRed))
      return(false);
   if(!buttonDelete.Color(clrWhite))
      return(false);
   if(!Add(buttonDelete))
      return(false);

//--- coordinates
   int x3 = INDENT_RIGHT + 5;
   int y3 = 35 + 350;
   int x4 = x3 + 100;
   int y4 = y3 + 30;

//--- create
   if(!buttonBE.Create(m_chart_id, m_name + "BE", m_subwin, x3, y3, x4, y4))
      return(false);
   if(!buttonBE.Text("Breakeven"))
      return(false);
   if(!buttonBE.ColorBackground(clrBlue))
      return(false);
   if(!buttonBE.Color(clrWhite))
      return(false);
   if(!Add(buttonBE))
      return(false);

//--- coordinates
   x3 = x4 + 35;
   x4 = x3 + 100;
   y4 = y3 + 30;
//--- create
   if(!buttonCloseProfit.Create(m_chart_id, m_name + "CloseProfit", m_subwin, x3, y3, x4, y4))
      return(false);
   if(!buttonCloseProfit.Text("Close Profit"))
      return(false);
   if(!buttonCloseProfit.ColorBackground(clrOrange))
      return(false);
   if(!buttonCloseProfit.Color(clrWhite))
      return(false);
   if(!Add(buttonCloseProfit))
      return(false);

   return(true);
}

//+------------------------------------------------------------------+
//| Create the "CLabel"                                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel(void) {
//--- coordinates
   int x1 = INDENT_RIGHT;
   int y1 = INDENT_TOP + CONTROLS_GAP_Y;
   int x2 = x1 + 100;
   int y2 = y1 + 20;
//--- create
   if(!labelPair.Create(m_chart_id, m_name + " Pair", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelPair.Text(" Pair "))
      return(false);
   if(!Add(labelPair))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelTF.Create(m_chart_id, m_name + " TF", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelTF.Text(" Timeframe "))
      return(false);
   if(!Add(labelTF))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1;

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelEntryType.Create(m_chart_id, m_name + " Entry Type", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelEntryType.Text(" Entry Type "))
      return(false);
   if(!Add(labelEntryType))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelRiskType.Create(m_chart_id, m_name + " Risk Type", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelRiskType.Text(" Risk Type "))
      return(false);
   if(!Add(labelRiskType))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelRiskSize.Create(m_chart_id, m_name + " Risk Ratio", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelRiskSize.Text(" Risk "))
      return(false);
   if(!Add(labelRiskSize))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelTPSize.Create(m_chart_id, m_name + " Reward Ratio", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelTPSize.Text(" Reward Ratio "))
      return(false);
   if(!Add(labelTPSize))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelBE.Create(m_chart_id, m_name + " BEStart", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelBE.Text(" Breakeven at "))
      return(false);
   if(!Add(labelBE))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1;

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelEntryPrice.Create(m_chart_id, m_name + " Price", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelEntryPrice.Text(" Price "))
      return(false);
   if(!Add(labelEntryPrice))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelLot.Create(m_chart_id, m_name + " Lot", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelLot.Text(" Lot "))
      return(false);
   if(!Add(labelLot))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelSL.Create(m_chart_id, m_name + "SL", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelSL.Text(" Stoploss "))
      return(false);
   if(!Add(labelSL))
      return(false);

//--- coordinates
   y1 = y2 + 8;
   x2 = x1 + 100;
   y2 = y1 + 20;
//--- create
   if(!labelTP.Create(m_chart_id, m_name + "TP", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelTP.Text(" Takeprofit "))
      return(false);
   if(!Add(labelTP))
      return(false);

   x1 = x1 + 45;
   y1 = y2 + 90;
   x2 = x1 + 100;
   y2 = y1 + 20;
   if(!labelGrup.Create(m_chart_id, m_name + "@PrdnNvnRnt", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!labelGrup.Text("Join Us at : t.me/simpleob"))
      return(false);
   if(!Add(labelGrup))
      return(false);

//--- succeed
   return(true);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCombo(void) {
//--- coordinates
   int x1 = INDENT_RIGHT + 100;
   int y1 = INDENT_TOP + CONTROLS_GAP_Y;
   int x2 = x1 + 140;
   int y2 = y1 + 20;
//--- create
   if(!comboPair.Create(m_chart_id, m_name + " Pair List", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!Add(comboPair))
      return(false);
//--- fill out with strings
   int nPairs  = SymbolsTotal(true);
   for(int i = 0; i < nPairs; i++)
      if(!comboPair.ItemAdd(SymbolName(i, true)))
         return(false);
//--- select text
   comboPair.SelectByText(Symbol());

//--- coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
//--- create
   if(!comboTF.Create(m_chart_id, m_name + "TF List", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!Add(comboTF))
      return(false);
//--- fill out with strings
   if(!comboTF.ItemAdd("1 Minutes"))
      return(false);
   if(!comboTF.ItemAdd("5 Minutes"))
      return(false);
   if(!comboTF.ItemAdd("15 Minutes"))
      return(false);
   if(!comboTF.ItemAdd("30 Minutes"))
      return(false);
   if(!comboTF.ItemAdd("1 Hour"))
      return(false);
   if(!comboTF.ItemAdd("4 Hour"))
      return(false);
   if(!comboTF.ItemAdd("1 Day"))
      return(false);
   if(!comboTF.ItemAdd("1 Week"))
      return(false);
   if(!comboTF.ItemAdd("1 Month"))
      return(false);
//--- select text
   comboTF.SelectByText(getString(Period()));

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1;

//--- coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
//--- create
   if(!comboEntryType.Create(m_chart_id, m_name + " EntryType", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!Add(comboEntryType))
      return(false);
//--- fill out with strings
   if(!comboEntryType.ItemAdd("Normal"))
      return(false);
   if(!comboEntryType.ItemAdd("50% OB"))
      return(false);
//--- select text
   comboEntryType.SelectByText("Normal");

//--- coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
//--- create
   if(!comboRiskType.Create(m_chart_id, m_name + " RiskType", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!Add(comboRiskType))
      return(false);
//--- fill out with strings
   if(!comboRiskType.ItemAdd("Balance Percentage"))
      return(false);
   if(!comboRiskType.ItemAdd("By Money Risk"))
      return(false);
//--- select text
   comboRiskType.SelectByText("Balance Percentage");

//--- succeed
   return(true);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit(void) {
//--- coordinates
   int x1 = INDENT_RIGHT + 100;
   int y1 = INDENT_TOP + CONTROLS_GAP_Y;
   int x2 = x1 + 50;
   int y2 = y1 + 20;
//--- coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1;
//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;

//--- create
   if(!editRiskSize.Create(m_chart_id, m_name + "RiskSizeInput", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!editRiskSize.ReadOnly(false))
      return(false);
   if(!editRiskSize.Text("1"))
      return(false);
   if(!Add(editRiskSize))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;

//--- create
   if(!editTPSize.Create(m_chart_id, m_name + "RewardSizeInput", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!editTPSize.ReadOnly(false))
      return(false);
   if(!editTPSize.Text("2"))
      return(false);
   if(!Add(editTPSize))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
//--- create
   if(!editBE.Create(m_chart_id, m_name + "BEInput", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!editBE.ReadOnly(false))
      return(false);
   if(!editBE.Text("0"))
      return(false);
   if(!Add(editBE))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1;

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
   x2 = x1 + 140;

//--- create
   if(!editEntryPrice.Create(m_chart_id, m_name + "EntryPrice", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!editEntryPrice.ReadOnly(true))
      return(false);
   if(!editEntryPrice.Text("Waiting Data"))
      return(false);
   if(!Add(editEntryPrice))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
   x2 = x1 + 140;

//--- create
   if(!editLot.Create(m_chart_id, m_name + "OpenLot", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!editLot.ReadOnly(true))
      return(false);
   if(!editLot.Text("Waiting Data"))
      return(false);
   if(!Add(editLot))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
   x2 = x1 + 140;

//--- create
   if(!editSL.Create(m_chart_id, m_name + "SLPrice", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!editSL.ReadOnly(true))
      return(false);
   if(!editSL.Text("Waiting Data"))
      return(false);
   if(!Add(editSL))
      return(false);

//--- adding coordinates
   y1 = y2 + 8;
   y2 = y1 + 20;
   x2 = x1 + 140;

//--- create
   if(!editTP.Create(m_chart_id, m_name + "TPPrice", m_subwin, x1, y1, x2, y2))
      return(false);
   if(!editTP.ReadOnly(true))
      return(false);
   if(!editTP.Text("Waiting Data"))
      return(false);
   if(!Add(editTP))
      return(false);

   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangePair(void) {
   ChartSetSymbolPeriod(0, comboPair.Select(), PERIOD_CURRENT);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeTF(void) {
   ChartSetSymbolPeriod(0, Symbol(), getTF(comboTF.Select()));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::clickPlaceOrder(void) {

   double lot     = StringToDouble(editLot.Text());
   double price   = StringToDouble(editEntryPrice.Text());
   double SL      = StringToDouble(editSL.Text());
   double TP      = StringToDouble(editTP.Text());

   int slippage = Slippage;
   int type = -1;

   if(price < Ask) {
      type = OP_BUYLIMIT;
   } else if(price > Bid) {
      type = OP_SELLLIMIT;
   }

   if(lot != 0 &&
         price != 0 &&
         SL != 0 &&
         TP != 0) {
      if(OrderSend(Symbol(), type, lot, price, slippage, SL, TP, EAComment, MagicNumber) <= 0) {
         Print("Send Error : ", GetLastError());
      }
   }

   Print("Placing Order Clicked");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::clickDeleteOrder(void) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS) &&
            OrderSymbol() == Symbol() &&
            OrderMagicNumber() == MagicNumber &&
            OrderType() > OP_SELL) {

         if(!OrderDelete(OrderTicket(), clrWhite)) {
            Print("Deleting Order Failed. Error : ", GetLastError());
         }
      }
   }
   Print("Manual Delete Order Clicked");
}

void CControlsDialog::clickBE(void) {

   double minstop = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL) * Point();
   double spread  = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * Point();

   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
         if(OrderType() == OP_BUY &&
               OrderSymbol() == Symbol() &&
               OrderMagicNumber() == MagicNumber)
            if(Bid - OrderOpenPrice() >= minstop) {
               if(OrderStopLoss() == 0 || OrderStopLoss() < OrderOpenPrice()) {
                  bool result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + spread, OrderTakeProfit(), 0, Red);
               }
            }

      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
         if(OrderType() == OP_SELL &&
               OrderSymbol() == Symbol() &&
               OrderMagicNumber() == MagicNumber)
            if(OrderOpenPrice() - Ask >= minstop) {
               if(OrderStopLoss() == 0 || OrderStopLoss() > OrderOpenPrice()) {
                  bool result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - spread, OrderTakeProfit(), 0, Red);
               }
            }
   }

   Print("Manual Breakeven Clicked");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::clickCloseProfit(void) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      bool result = false;
      if(OrderSelect(i, SELECT_BY_POS) == True)
         if(OrderSymbol() == Symbol() &&
               OrderMagicNumber() == MagicNumber) {
            if(OrderType() < OP_BUYLIMIT && OrderProfit() > 0) {
               if(!(OrderClose(OrderTicket(), OrderLots(), ((OrderType() == OP_SELL) ? Ask : Bid), 3, clrWhite))) {
                  Print("Closing Order Failed. Error : ", ErrorDescription(GetLastError()));
               }
            }
         }
   }
   Print("Manual Close Profit Order Clicked");
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getTF(string text) {
   int result = 0;
   if(text == "1 Minutes")
      result = 1;
   if(text == "5 Minutes")
      result = 5;
   if(text == "15 Minutes")
      result = 15;
   if(text == "30 Minutes")
      result = 30;
   if(text == "1 Hour")
      result = 60;
   if(text == "4 Hour")
      result = 240;
   if(text == "1 Day")
      result = 1440;
   if(text == "1 Week")
      result = 10080;
   if(text == "1 Month")
      result = 43200;
   return(result);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getString(int period) {
   string result = "";
   if(period == 1)
      result = "1 Minutes";
   if(period == 5)
      result = "5 Minutes";
   if(period == 15)
      result = "15 Minutes";
   if(period == 30)
      result = "30 Minutes";
   if(period == 60)
      result = "1 Hour";
   if(period == 240)
      result = "4 Hour";
   if(period == 1440)
      result = "1 Day";
   if(period == 10080)
      result = "1 Week";
   if(period == 43200)
      result = "1 Month";
   return(result);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getStringTrend(int period) {
   string result = "";
   if(period == 1)
      result = "M1";
   if(period == 5)
      result = "M5";
   if(period == 15)
      result = "M15";
   if(period == 30)
      result = "M30";
   if(period == 60)
      result = "H1";
   if(period == 240)
      result = "H4";
   if(period == 1440)
      result = "D1";
   if(period == 10080)
      result = "W1";
   if(period == 43200)
      result = "MN1";
   return(result);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string              CControlsDialog::getEntryType(void) {
   return(comboEntryType.Select());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string              CControlsDialog::getRiskType(void) {
   return(comboRiskType.Select());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string              CControlsDialog::getRiskRatio(void) {
   return(editRiskSize.Text());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string              CControlsDialog::getBE(void) {
   return(editBE.Text());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string              CControlsDialog::getRewardRatio(void) {
   return(editTPSize.Text());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              CControlsDialog::updatePrice(string update) {
   if(!editEntryPrice.Text(update))
      return(false);
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              CControlsDialog::updateLot(string update) {
   if(!editLot.Text(update))
      return(false);
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              CControlsDialog::updateStoploss(string update) {
   if(!editSL.Text(update))
      return(false);
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              CControlsDialog::updateTakeprofit(string update) {
   if(!editTP.Text(update))
      return(false);
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::updateComboTF() {
   if(!comboTF.SelectByText(getString(Period())))
      return(false);
   return(true);
}

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;

enum templateMode {
   Default = 0,//Default
   Dark = 1,//Dark Theme
   BlackWhite = 2,//Black and White
};

extern string        _1                   = "..::--====== Display Settings ======--::..";// 
extern string        _1_                  = "..::--=== Text Settings ===--::..";// 
input templateMode Template               = Default;//Template Chart
input int      TextSize                   = 12;//Text Size
input color    IMBColor                   = clrSeaGreen;//IMB Text Color
input color    BOSColor                   = clrRoyalBlue;//BOS Text Color
input color    POIColor                   = clrOrangeRed;//POI Text Color
input color    OBColor                    = clrDarkSlateGray;//OB Text Color
input color    HIColor                    = clrBlue;//HI Text Color
input color    LOColor                    = clrRed;//LO Text Color
input color    HHColor                    = clrBlue;//HH Text Color
input color    LHColor                    = clrRed;//LH Text Color
input color    HLColor                    = clrBlue;//HL Text Color
input color    LLColor                    = clrRed;//LL Text Color
input color    DOLLARColor                = clrDarkOrange;//Dollar Text Color
extern string        _1__                 = "..::--=== Object Settings ===--::..";// 
input color    ArrowUpColor               = clrBlue;//Arrow Up color
input color    ArrowDownColor             = clrDarkOrange;//Arrow Down Color
input color    RectangleColor             = clrDarkViolet;//Rectangle Line Color
input color    RectangleFill1             = clrPink;//Rectangle Filled Color
input color    RectangleFill2             = clrLightBlue;//Rectangle Filled Color
input int      TrendLineWidth             = 2;//TrendLine Width
input color    TrendLineColor             = clrBrown;//TrendLine Color
extern string        break_1              = "";// 

extern string        _2                   = "..::--====== Market Sesions ======--::..";// 
input ENUM_TIMEFRAMES TrendBias           = PERIOD_D1;//Trend Bias
input bool        ShowSessions            = true;//Show Market Sessions Line
input int         DaysBack                = 2;//Days to Show, 1 = Today Only
input string      AsiaStart               = "01:00";//Asia Open Time
input string      AsiaEnd                 = "06:00";//Asia Open Time
input ENUM_LINE_STYLE   AsiaStyle         = STYLE_DOT;//Asia Line Style
input ENUM_LINE_STYLE   AsiaHighStyle     = STYLE_DOT;//Asia Range Line Style
input color       AsiaColor               = clrAqua;//Asia Line Color

input string      LondonStart             = "10:00";//London Open Time
input string      LondonEnd               = "14:00";//London Open Time
input ENUM_LINE_STYLE   LondonStyle       = STYLE_DOT;//London Line Style
input ENUM_LINE_STYLE   LondonHighStyle   = STYLE_DOT;//London Range Line Style
input color       LondonColor             = clrGold;//London Line Color

input string      NewYorkStart            = "15:00";//New York Open Time
input string      NewYorkEnd              = "20:00";//New York Open Time
input ENUM_LINE_STYLE   NewYorkStyle      = STYLE_DOT;//New York Line Style
input ENUM_LINE_STYLE   NewYorkHighStyle  = STYLE_DOT;//New York Range Line Style
input color       NewYorkColor            = clrLime;//New York Line Color
extern string        break_2              = "";// 

extern string        _3                   = "..::--====== Order Settings ======--::..";// 
input int      Spread                     = 30;//Max Spread for Calculation
input int      Slippage                   = 10;//Slippage Order
input int      MagicNumber                = 696969;//Magic Order
input string   EAComment                  = "t.me/simpleob";//Order Comment

string trend = "UNCLEAR TREND";
color trendColor = clrBlack;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
   trend = "WAITING...";

   if(IsDllsAllowed()) {
      Alert("Turn Off Your DLL Allowance");
      ExpertRemove();
   }

   if(namaLock != "") {
      useLockNama(namaLock);
   }

   if(nomorLock != 0) {
      useLockAkun(nomorLock);
   }

   if(expayed != 0) {
      useExpiryDate(expayed);
   }

   if(!IsTesting()) {
      int count = 0;
      bool timerSet = false;
      while(!timerSet && count < 5) {
         timerSet = EventSetTimer(2);
         if(!timerSet) {
            printf("Set Timer Error. Description %s. Trying %d...", ErrorDescription(_LastError), count);
            EventKillTimer();
            Sleep(200);
            timerSet = EventSetTimer(5);
            count++;
         }
      }
      if(!timerSet) {
         Alert("Cannot Set Timer. Please Re Init Your Experts");
         return INIT_FAILED;
      } else {
         printf("Set Timer at %s Success", Symbol());
      }
   }

   if (ExtDialog.Name() == NULL) {
      if(!ExtDialog.Create(0, "Simple Order Block Assistant", 0, 20, 20, 300, 500)) {
         Print ("ERROR: GAGAL CREATE");
      } else {
         //--- run application
         ExtDialog.Run();
         ChartRedraw();
      }
   }
   changeChart();

   createLabel(IMB + " Master", IMB, 65, 15, IMBColor, false);
   createLabel(BOS + " Master", BOS, 115, 15, BOSColor, false);
   createLabel(POI + " Master", POI, 155, 15, POIColor, false);
   createLabel(OB + " Master", OB, 190, 15, OBColor, false);
   createLabel(HI + " Master", HI, 215, 15, HIColor, false);
   createLabel(LO + " Master", LO, 245, 15, LOColor, false);
   createLabel(HH + " Master", HH, 280, 15, HHColor, false);
   createLabel(LH + " Master", LH, 315, 15, LHColor, false);
   createLabel(HL + " Master", HL, 350, 15, HLColor, false);
   createLabel(LL + " Master", LL, 385, 15, LLColor, false);
   createLabel(DOLLAR + " Master", DOLLAR, 405, 15, DOLLARColor, false);
   createLabel(TRENDSOLID + " Master", TRENDLINE, 430, 15, TrendLineColor, false);
   createWingdings(ARROWUP + " Master", "é", 460, 15, ArrowUpColor, false);
   createWingdings(ARROWDOWN + " Master", "ê", 490, 15, ArrowDownColor, false);
   createWingdings(BOX + " Master", "o", 520, 15, RectangleColor, false);
   createWingdings(BOXFILLED1 + " Master", "n", 550, 15, RectangleFill1, false);
   createWingdings(BOXFILLED2 + " Master", "n", 580, 15, RectangleFill2, false);

   createTrendInfo("TrendInfo", trend, 20, 20, trendColor, 3);

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---
//ExtDialog.Destroy();
   ChartRedraw();
   ObjectsDeleteAll(0, "Asia");
   ObjectsDeleteAll(0, "London");
   ObjectsDeleteAll(0, "NewYork");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
   if(IsTesting()) {
      OnTimer();
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer() {
//---
   if(IsDllsAllowed()) {
      Alert("Turn Off Your DLL Allowance");
      ExpertRemove();
   }

   if(namaLock != "") {
      useLockNama(namaLock);
   }

   if(nomorLock != 0) {
      useLockAkun(nomorLock);
   }

   if(expayed != 0) {
      useExpiryDate(expayed);
   }

   ExtDialog.updateComboTF();

   if(ShowSessions) {
      datetime date = TimeCurrent();
      for(int i = 0; i < DaysBack; i++) {

         createVerticalLine(date, "AsiaStart" + (string)i, AsiaStart, "Asian Session Open", AsiaStyle, AsiaColor);
         createVerticalLine(date, "AsiaEnd" + (string)i, AsiaEnd, "Asian Session Close",  AsiaStyle, AsiaColor);

         createVerticalLine(date, "LondonStart" + (string)i, LondonStart, "London Session Open",  LondonStyle, LondonColor);
         createVerticalLine(date, "LondonEnd" + (string)i, LondonEnd, "London Session Close", LondonStyle, LondonColor);

         createVerticalLine(date, "NewYorkStart" + (string)i, NewYorkStart, "New York Session Open",  NewYorkStyle, NewYorkColor);
         createVerticalLine(date, "NewYorkEnd" + (string)i, NewYorkEnd, "New York Session Close",  NewYorkStyle, NewYorkColor);

         createTrendLine(date, "Asia" + (string)i, AsiaStart, AsiaEnd, "Asian Session", AsiaHighStyle, AsiaColor);

         date = decrementDate(date);
         while (TimeDayOfWeek(date) > 5) date = decrementDate(date);
      }
   }


   int total = ObjectsTotal(0, -1, OBJ_RECTANGLE);
   string name = ObjectName(0, total - 1, -1, OBJ_RECTANGLE);

   string entryType = ExtDialog.getEntryType();
   string riskType  = ExtDialog.getRiskType();

   double riskRatio     = StringToDouble(ExtDialog.getRiskRatio());
   double rewardRatio   = StringToDouble(ExtDialog.getRewardRatio());
   double getBE         = StringToDouble(ExtDialog.getBE());

   double MA20          = iMA(Symbol(), TrendBias, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double MA50          = iMA(Symbol(), TrendBias, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double MA100         = iMA(Symbol(), TrendBias, 100, 0, MODE_EMA, PRICE_CLOSE, 0);

   if(MA20 > MA50 &&
         MA50 > MA100) {
      trend = "UPTREND";
      trendColor = clrLime;
   } else if(MA20 < MA50 &&
             MA50 < MA100) {
      trend = "DOWNTREND";
      trendColor = clrRed;
   } else {
      trend = "UNCLEAR TREND";
      trendColor = clrBlue;
   }

   string updateText = getStringTrend(TrendBias) + " " + trend;

   ObjectSetText("TrendInfo", updateText, 14, "Arial Bold", trendColor);

   double high = 0,
          low = 0,
          range = 0,
          lot = 0,
          price = 0,
          SL = 0,
          TP = 0,
          lotStep    = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP),
          tickValue  = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE),
          maxLot     = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX),
          minLot     = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);

   high = ObjectGetDouble(0, name, OBJPROP_PRICE1);
   low = ObjectGetDouble(0, name, OBJPROP_PRICE2);

   range = (high - low);
   double applyBEat = (range + (Spread * Point())) / Point();

   if(getBE != 0) {
      moveToBE(applyBEat);
   }

//BUY OB
   if(Bid > high) {
      if(entryType == "Normal" &&
            high != 0) {
         price = high;
         SL = high - (range + (Spread * Point()));
         TP = high + (rewardRatio * (range + (Spread * Point())));

         if(riskType == "Balance Percentage") {
            lot = fmin(maxLot, fmax(minLot, round(((((riskRatio / 100) * AccountBalance()) / tickValue / ((range + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }

         if(riskType == "By Money Risk") {
            lot = fmin(maxLot, fmax(minLot, round(((riskRatio / tickValue / ((range + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }
      }

      if(entryType == "50% OB" &&
            high != 0) {
         price = high - (range / 2);
         SL = price - ((range / 2) + (Spread * Point()));
         TP = price + (rewardRatio * ((range / 2) + (Spread * Point())));

         if(riskType == "Balance Percentage") {
            lot = fmin(maxLot, fmax(minLot, round(((((riskRatio / 100) * AccountBalance()) / tickValue / (((range / 2) + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }

         if(riskType == "By Money Risk") {
            lot = fmin(maxLot, fmax(minLot, round(((riskRatio / tickValue / (((range / 2) + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }
      }
   }

//SELL OB
   if(Ask < low) {
      if(entryType == "Normal" &&
            low != 0) {
         price = low;
         SL = low + (range + (Spread * Point()));
         TP = low - (rewardRatio * (range + (Spread * Point())));

         if(riskType == "Balance Percentage") {
            lot = fmin(maxLot, fmax(minLot, round(((((riskRatio / 100) * AccountBalance()) / tickValue / ((range + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }

         if(riskType == "By Money Risk") {
            lot = fmin(maxLot, fmax(minLot, round(((riskRatio / tickValue / ((range + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }
      }

      if(entryType == "50% OB" &&
            low != 0) {
         price = low + (range / 2);
         SL = price + ((range / 2) + (Spread * Point()));
         TP = price - (rewardRatio * ((range / 2) + (Spread * Point())));

         if(riskType == "Balance Percentage") {
            lot = fmin(maxLot, fmax(minLot, round(((((riskRatio / 100) * AccountBalance()) / tickValue / (((range / 2) + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }

         if(riskType == "By Money Risk") {
            lot = fmin(maxLot, fmax(minLot, round(((riskRatio / tickValue / (((range / 2) + (Spread * Point())) / Point())) / lotStep)) * lotStep));
         }
      }
   }

   ExtDialog.updateLot(DoubleToString(lot, 2));
   ExtDialog.updatePrice(DoubleToString(price, Digits));
   ExtDialog.updateStoploss(DoubleToString(SL, Digits));
   ExtDialog.updateTakeprofit(DoubleToString(TP, Digits));

   if(high == 0 || low == 0) {
      ExtDialog.updateLot("Waiting Data");
      ExtDialog.updatePrice("Waiting Data");
      ExtDialog.updateStoploss("Waiting Data");
      ExtDialog.updateTakeprofit("Waiting Data");
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {

   ExtDialog.ChartEvent(id, lparam, dparam, sparam);

   if(id == CHARTEVENT_OBJECT_CLICK) {
      if(sparam == IMB + " Master") {
         createText(IMB + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), "IMBALANCE", 428, 60, IMBColor, true);
      }
      if(sparam == BOS + " Master") {
         createText(BOS + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), BOS, 468, 60, BOSColor, true);
      }
      if(sparam == POI + " Master") {
         createText(POI + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), POI, 508, 60, POIColor, true);
      }
      if(sparam == OB + " Master") {
         createText(OB + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), OB, 548, 60, OBColor, true);
      }
      if(sparam == HI + " Master") {
         createText(HI + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), HI, 588, 60, HIColor, true);
      }
      if(sparam == LO + " Master") {
         createText(LO + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), LO, 628, 60, LOColor, true);
      }
      if(sparam == HH + " Master") {
         createText(HH + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), HH, 668, 60, HHColor, true);
      }
      if(sparam == LH + " Master") {
         createText(LH + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), LH, 708, 60, LHColor, true);
      }
      if(sparam == HL + " Master") {
         createText(HL + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), HL, 748, 60, HLColor, true);
      }
      if(sparam == LL + " Master") {
         createText(LL + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), LL, 788, 60, LLColor, true);
      }
      if(sparam == DOLLAR + " Master") {
         createText(DOLLAR + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), DOLLAR, 828, 60, DOLLARColor, true);
      }
      if(sparam == ARROWUP + " Master") {
         createText(ARROWUP + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), "é", 868, 60, ArrowUpColor, true, "Wingdings");
      }
      if(sparam == ARROWDOWN + " Master") {
         createText(ARROWDOWN + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), "ê", 908, 60, ArrowDownColor, true, "Wingdings");
      }
      if(sparam == BOX + " Master") {
         createRect(BOX + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), 548, 60, RectangleColor);
      }
      if(sparam == BOXFILLED1 + " Master") {
         createRect(BOXFILLED1 + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), 468, 60, RectangleFill1, true);
      }
      if(sparam == BOXFILLED2 + " Master") {
         createRect(BOXFILLED2 + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), 468, 60, RectangleFill2, true);
      }
      if(sparam == TRENDSOLID + " Master") {
         createTrend(TRENDSOLID + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), 628, 60, TrendLineWidth, TrendLineColor);
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createVerticalLine(datetime timeC, string name, string time, string text, int lineStyle, color clr) {
   datetime pos;

   pos = StrToTime(TimeToStr(timeC, TIME_DATE) + " " + time);

   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_VLINE, 0, pos, 0);
   } else {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, lineStyle);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetText(name, text, 12, "Arial", clr);
   }
   return(true);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createTrendLine(datetime time, string name, string timeStart, string timeEnd, string text, int lineStyle, color clr) {
   datetime pos1, pos2;
   double high, low, range;
   int barStart, barEnd;

   pos1 = StrToTime(TimeToStr(time, TIME_DATE) + " " + timeStart);
   pos2 = StrToTime(TimeToStr(time, TIME_DATE) + " " + timeEnd);

   barStart = iBarShift(Symbol(), 0, pos1);
   barEnd   = iBarShift(Symbol(), 0, pos2);

   high = iHigh(Symbol(), 0, iHighest(Symbol(), 0, MODE_HIGH, barStart - barEnd, barEnd));
   low = iLow(Symbol(), 0, iLowest(Symbol(), 0, MODE_LOW, barStart - barEnd, barEnd));

   range = (high - low) / Point();

   if(ObjectFind(0, name + "High") < 0) {
      ObjectCreate(name + "High", OBJ_TREND, 0, pos1, high, pos2, high);
   } else {
      ObjectSetInteger(0, name + "High", OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name + "High", OBJPROP_STYLE, lineStyle);
      ObjectSetText(name + "High", DoubleToString(range, 0) + " points", 10, "Arial", clr);
      ObjectSetInteger(0, name + "High", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name + "High", OBJPROP_RAY, false);
   }

   if(ObjectFind(0, name + "Low") < 0) {
      ObjectCreate(name + "Low", OBJ_TREND, 0, pos1, low, pos2, low);
   } else {
      ObjectSetInteger(0, name + "Low", OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name + "Low", OBJPROP_STYLE, lineStyle);
      ObjectSetInteger(0, name + "Low", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name + "Low", OBJPROP_RAY, false);
   }

   return(true);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime decrementDate (datetime dt) {
   int ty = TimeYear(dt);
   int tm = TimeMonth(dt);
   int td = TimeDay(dt);
   int th = TimeHour(dt);
   int ti = TimeMinute(dt);

   td--;
   if (td == 0) {
      tm--;
      if (tm == 0) {
         ty--;
         tm = 12;
      }
      if (tm == 1 || tm == 3 || tm == 5 || tm == 7 || tm == 8 || tm == 10 || tm == 12) td = 31;
      if (tm == 2) if (MathMod(ty, 4) == 0) td = 29;
         else td = 28;
      if (tm == 4 || tm == 6 || tm == 9 || tm == 11) td = 30;
   }
   return(StrToTime((string)ty + "." + (string)tm + "." + (string)td + " " + (string)th + ":" + (string)ti));
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createLabel(string name,
                 string text,
                 int x,
                 int y,
                 color clr,
                 bool selectable,
                 int corner = 1) {

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, text, TextSize, "Arial Bold", clr);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   if(selectable) {
      ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createTrendInfo(string name,
                     string text,
                     int x,
                     int y,
                     color clr,
                     int corner = 3) {

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, text, 12, "Arial Bold", clr);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
}
//+------------------------------------------------------------------+

void changeChart() {

   switch(Template) {
   case 0:
      ChartSetInteger(0, CHART_SHOW_GRID, 0, false);
      ObjectsDeleteAll(0, -1, OBJ_LABEL);
      ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
      ChartSetInteger(0, CHART_SHIFT, true);
      ChartSetDouble(0, CHART_SHIFT_SIZE, 20);
      ChartSetInteger(0, CHART_SCALE, 3);
      ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
      ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
      ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, C'249,248,227');
      ChartSetInteger(0, CHART_COLOR_BID, clrRed);
      ChartSetInteger(0, CHART_COLOR_ASK, clrPink);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, clrMediumBlue);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrRed);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrMediumBlue);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
      ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrGold);
      ChartSetInteger(0, CHART_COLOR_VOLUME, clrLimeGreen);
      ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, true);
      break;

   case 1:
      ChartSetInteger(0, CHART_SHOW_GRID, 0, false);
      ObjectsDeleteAll(0, -1, OBJ_LABEL);
      ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
      ChartSetInteger(0, CHART_SHIFT, true);
      ChartSetDouble(0, CHART_SHIFT_SIZE, 20);
      ChartSetInteger(0, CHART_SCALE, 3);
      ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
      ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
      ChartSetInteger(0, CHART_COLOR_FOREGROUND, 16777215);
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, 3487008);
      ChartSetInteger(0, CHART_COLOR_BID, 255);
      ChartSetInteger(0, CHART_COLOR_ASK, 255);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, 11186720);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, 4678655);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, 11186720);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, 4678655);
      ChartSetInteger(0, CHART_COLOR_CHART_LINE, 55295);
      ChartSetInteger(0, CHART_COLOR_VOLUME, 3329330);
      ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, true);
      break;

   case 2:
      ChartSetInteger(0, CHART_SHOW_GRID, 0, false);
      ObjectsDeleteAll(0, -1, OBJ_LABEL);
      ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
      ChartSetInteger(0, CHART_SHIFT, true);
      ChartSetDouble(0, CHART_SHIFT_SIZE, 20);
      ChartSetInteger(0, CHART_SCALE, 3);
      ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
      ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
      ChartSetInteger(0, CHART_COLOR_FOREGROUND, 0);
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, 15790320);
      ChartSetInteger(0, CHART_COLOR_BID, clrRed);
      ChartSetInteger(0, CHART_COLOR_ASK, 17919);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, 0);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, 0);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, 16777215);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, 0);
      ChartSetInteger(0, CHART_COLOR_CHART_LINE, 0);
      ChartSetInteger(0, CHART_COLOR_VOLUME, 32768);
      ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, true);
      break;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createText(string name,
                string text,
                int x,
                int y,
                color clr,
                bool selectable,
                string font = "Arial Bold") {

   double price;
   datetime time;
   int subWindow;

   if(ChartXYToTimePrice(0, x, y, subWindow, time, price)) {

      ObjectCreate(0, name, OBJ_TEXT, 0, 0, 0);
      ObjectSetText(name, text, TextSize, font, clr);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
      ObjectSetInteger(0, name, OBJPROP_CORNER, 1);
      if(selectable) {
         ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
      }
      ObjectSet(name, OBJPROP_PRICE1, price);
      ObjectSet(name, OBJPROP_TIME1, time);
   } else Print("Error, Code : ", GetLastError());

}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createWingdings(string name,
                     string code,
                     int x,
                     int y,
                     color clr,
                     bool selectable) {

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, code, TextSize, "Wingdings", clr);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_CORNER, 1);

   if(selectable) {
      ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createRect(string name,
                int x,
                int y,
                color clr,
                bool fill = false,
                bool selectable = true) {
   double price;
   datetime time;
   int subWindow;

   if(ChartXYToTimePrice(0, x, y, subWindow, time, price)) {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);

      if(fill) {
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
      } else ObjectSetInteger(0, name, OBJPROP_BACK, false);

      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);

      if(selectable) {
         ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
      }

      ObjectSet(name, OBJPROP_PRICE1, price);
      ObjectSet(name, OBJPROP_PRICE2, price - (200 * Point));
      ObjectSet(name, OBJPROP_TIME1, time);
      ObjectSet(name, OBJPROP_TIME2, time + (20 * Period() * 60));
   } else Print("Error, Code : ", GetLastError());
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createTrend(string name,
                 int x,
                 int y,
                 int width,
                 color clr,
                 bool selectable = true) {
   double price;
   datetime time;
   int subWindow;

   if(ChartXYToTimePrice(0, x, y, subWindow, time, price)) {
      ObjectCreate(0, name, OBJ_TREND, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
      ObjectSetInteger(0, name, OBJPROP_RAY, false);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);

      if(selectable) {
         ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
      }

      ObjectSet(name, OBJPROP_PRICE1, price);
      ObjectSet(name, OBJPROP_PRICE2, price);
      ObjectSet(name, OBJPROP_TIME1, time);
      ObjectSet(name, OBJPROP_TIME2, time + (20 * Period() * 60));
   } else Print("Error, Code : ", GetLastError());
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void              moveToBE(double moveAfter) {

   string symbol  = Symbol();
   int magic      = MagicNumber;
   double point   = Point();
   double Poin    = moveAfter + SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL);
   int spread     = (int)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);

   if(Poin == 0) return;
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
         if(OrderType() == OP_BUY &&
               OrderSymbol() == symbol &&
               OrderMagicNumber() == magic)
            if(Bid - OrderOpenPrice() >= Poin * point) {
               if(OrderStopLoss() == 0 || OrderStopLoss() < OrderOpenPrice()) {
                  bool result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + (spread * point), OrderTakeProfit(), 0, Red);
               }
            }

      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
         if(OrderType() == OP_SELL &&
               OrderSymbol() == symbol &&
               OrderMagicNumber() == magic)
            if(OrderOpenPrice() - Ask >= Poin * point) {
               if(OrderStopLoss() == 0 || OrderStopLoss() > OrderOpenPrice()) {
                  bool result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - (spread * point), OrderTakeProfit(), 0, Red);
               }
            }
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void              useLockNama(string namaAkun) {
   string accname = AccountInfoString(ACCOUNT_NAME);

   if(StringToUpper(accname) && StringToUpper(namaAkun)) {
      if(StringFind(accname, namaAkun, 0) < 0) {
         string pesanLockNama = StringFormat("This EA Not Registered For You, Your Account : %s. This EA Belongs To : %s",
                                             accname,
                                             namaAkun);
         Alert(pesanLockNama);
         ExpertRemove();
      }
   }
}
//+------------------------------------------------------------------+
void              useLockAkun(int nomorAkun) {
   if(AccountInfoInteger(ACCOUNT_LOGIN) != nomorAkun) {
      string pesanLockAkun = StringFormat("This EA Not Registered For You, Your Account : %s. This EA Belongs To Account : %s",
                                          (string)AccountInfoInteger(ACCOUNT_LOGIN),
                                          (string)nomorAkun);
      Alert(pesanLockAkun, nomorAkun);
      ExpertRemove();
   }
}
//+------------------------------------------------------------------+
void              useExpiryDate(datetime tglExpired) {
   string pesanExpiryDate = "This EA Expired";
   if((TimeLocal() > tglExpired || TimeCurrent() > tglExpired)) {
      Alert(pesanExpiryDate);
      ExpertRemove();
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

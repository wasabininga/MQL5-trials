#include <Trade\Trade.mqh>
CTrade trade;

// Example inputs for risk and target buffering
input double RiskLotSize = 0.10;       // Fixed volume per trade
input double TargetBufferRatio = 0.90; // Target 90% of the band width (takes TP before opposite band)
input int    StopLossPoints = 500;     // Stop loss distance in points

void OnTick()
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   
   if(CopyRates(_Symbol, PERIOD_D1, 1, 10, rates) < 10) return;
   
   double upperBand = rates[0].high;
   double lowerBand = rates[0].low;
   
   for(int i = 1; i < 10; i++)
   {
      if(rates[i].high > upperBand) upperBand = rates[i].high;
      if(rates[i].low < lowerBand)  lowerBand = rates[i].low;
   }

   double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double channelWidth = upperBand - lowerBand;

   // Buy Condition (Price touches lower band)
   if(currentAsk <= lowerBand && PositionsTotal() == 0)
   {
      // Take profit set at 90% of the channel width above lower band
      double takeProfit = lowerBand + (channelWidth * TargetBufferRatio);
      double stopLoss   = currentAsk - (StopLossPoints * _Point);

      trade.Buy(RiskLotSize, _Symbol, currentAsk, stopLoss, takeProfit, "Donchian Buy");
   }
   // Sell Condition (Price touches upper band)
   else if(currentBid >= upperBand && PositionsTotal() == 0)
   {
      // Take profit set at 90% of the channel width below upper band
      double takeProfit = upperBand - (channelWidth * TargetBufferRatio);
      double stopLoss   = currentBid + (StopLossPoints * _Point);

      trade.Sell(RiskLotSize, _Symbol, currentBid, stopLoss, takeProfit, "Donchian Sell");
   }
}

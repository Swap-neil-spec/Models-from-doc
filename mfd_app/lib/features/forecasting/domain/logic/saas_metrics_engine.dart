import 'package:mfd_app/features/forecasting/domain/entities/financial_model.dart';
import 'dart:math' as math;

class SaaSMetricsEngine {
  
  /// Calculates the Burn Multiple (Net Burn / Net New ARR) for each month.
  /// Ideally < 2.0 for early stage, < 1.0 for growth.
  List<double> calculateBurnMultiples(FinancialModel model) {
    final multiples = <double>[];
    
    for (int i = 1; i < model.revenue.length; i++) {
      final prevRev = model.revenue[i - 1];
      final currRev = model.revenue[i];
      final netNewArr = (currRev - prevRev) * 12; // Annualized
      
      final burn = model.netBurn[i]; // Positive value means we are burning cash (Total Opex - Gross Profit)
       // Note: In my model, 'netBurn' is (Opex - GM). Positive = Burning.
       
      if (netNewArr <= 1) {
        // If we aren't growing, burn multiple is Infinite (bad).
        multiples.add(0.0); // Or strict penalty like 99.0
      } else {
        // Burn Multiple = Burn / Net New ARR
        // e.g. Burn 10k, Add 5k ARR. Multiple = 2.0.
        // Wait, normally Burn Multiple = Net Burn / Net New ARR.
        // Net New ARR = (MRR_2 - MRR_1) * 12.
        
        // Example: 
        // M1 Rev: 1000. M2 Rev: 1100.
        // Net New MRR: 100. Net New ARR: 1200.
        // Burn M2: 2400.
        // Multiple: 2400 / 1200 = 2.0.
        
        double multiple = burn / netNewArr;
        multiples.add(multiple < 0 ? 0 : multiple); // Cap at 0 if profitable?
      }
    }
    return [0.0, ...multiples]; // Pad first month
  }

  /// Calculates Rule of 40 (Growth % + Profit Margin %)
  double calculateRuleOf40(FinancialModel model) {
    if (model.revenue.isEmpty) return 0.0;
    
    // 1. Annual Growth Rate (Forward 12 months or max available)
    final startRev = model.revenue.first;
    final endRev = model.revenue.length >= 12 ? model.revenue[11] : model.revenue.last;
    
    if (startRev == 0) return 0.0;
    
    final growthRate = (endRev - startRev) / startRev; // e.g. 0.5 for 50%
    
    // 2. Profit Margin (FCF Margin ~= (Rev - Burn) / Rev)
    // Actually, (Rev - Opex) / Rev. 
    // In our model, Net Burn = Opex - GrossProfit. 
    // FCF = Revenue - Opex (assuming no CapEx).
    // GrossProfit = Rev - COGS.
    // NetBurn = (Opex + COGS) - Revenue? No.
    // Model says: NetBurn = TotalOpex - GrossProfit.
    
    // Profit = GrossProfit - TotalOpex = -NetBurn.
    
    double totalRev = 0;
    double totalBurn = 0;
    for (int i = 0; i < (model.revenue.length >= 12 ? 12 : model.revenue.length); i++) {
        totalRev += model.revenue[i];
        totalBurn += model.netBurn[i];
    }
    
    final profit = -totalBurn; // Negative burn is profit
    final margin = totalRev > 0 ? profit / totalRev : 0.0;
    
    return (growthRate * 100) + (margin * 100);
  }
}

import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/forecasting/domain/entities/financial_model.dart';
import 'package:mfd_app/features/forecasting/domain/entities/staff.dart';
import 'package:mfd_app/features/forecasting/domain/logic/saas_metrics_engine.dart';

class ForecastEngine {
  static const int forecastMonths = 18;

  FinancialModel generateModel(List<Assumption> assumptions, {List<Staff> staffList = const []}) {
    // 1. Extract inputs with defaults
    final startCash = _getValue(assumptions, 'opening_cash', 0);
    final startRevenue = _getValue(assumptions, 'current_revenue', 0);
    final revenueGrowthRate = _getValue(assumptions, 'revenue_growth_rate', 0) / 100.0;
    final startOpex = _getValue(assumptions, 'monthly_opex', 0);
    final opexGrowthRate = _getValue(assumptions, 'opex_growth_rate', 0) / 100.0;
    final grossMarginPct = _getValue(assumptions, 'gross_margin', 100) / 100.0;
    
    // 2. Initialize lists
    final List<String> months = [];
    final List<double> revenue = [];
    final List<double> opex = [];
    final List<double> grossMargin = [];
    final List<double> netBurn = [];
    final List<double> cashBalance = [];
    
    double currentCash = startCash;
    double currentRevenue = startRevenue;
    double currentOpex = startOpex;
    
    int runway = forecastMonths;
    bool runwayFound = false;

    // 3. Loop for 18 months
    for (int i = 1; i <= forecastMonths; i++) {
      months.add('M$i'); // Placeholder for real dates later
      
      // Apply Growth
      currentRevenue = currentRevenue * (1 + revenueGrowthRate);
      currentOpex = currentOpex * (1 + opexGrowthRate);

      // Add Staff Costs (Incremental)
      double staffCostForMonth = 0;
      for (final staff in staffList) {
        if (i >= staff.startMonth) {
          staffCostForMonth += staff.monthlySalary;
        }
      }
      
      final totalOpex = currentOpex + staffCostForMonth;
      
      // Calculate derived metrics
      final currentGrossMargin = currentRevenue * grossMarginPct;
      final currentBurn = totalOpex - currentGrossMargin; // Net Burn = Opex - Gross Profit
      
      // Update Cash
      currentCash = currentCash - currentBurn;
      
      // Store values
      revenue.add(currentRevenue);
      opex.add(totalOpex);
      grossMargin.add(currentGrossMargin);
      netBurn.add(currentBurn);
      cashBalance.add(currentCash);
      
      // Check Runway
      if (!runwayFound && currentCash <= 0) {
        runway = i;
        runwayFound = true;
      }
    }

    return FinancialModel(
      monthLabels: months,
      revenue: revenue,
      opex: opex,
      grossMargin: grossMargin,
      netBurn: netBurn,
      cashBalance: cashBalance,
      runwayMonths: runwayFound ? runway : forecastMonths + 1, // +1 indicates "18+"
      // Temporarily create partial model to calc metrics
      burnMultiples: [],
      ruleOf40: 0.0,
    );
    
    // 4. Calculate Advanced Metrics
    // We recreate the model with the metrics populated. 
    // Ideally we'd separate the data class from the calculator, but for now this works.
    final metricsEngine = SaaSMetricsEngine();
    
    // We need to pass the "raw" model to the engine
    final rawModel = FinancialModel(
       monthLabels: months, revenue: revenue, opex: opex, grossMargin: grossMargin, 
       netBurn: netBurn, cashBalance: cashBalance, runwayMonths: 0
    );

    return FinancialModel(
      monthLabels: months,
      revenue: revenue,
      opex: opex,
      grossMargin: grossMargin,
      netBurn: netBurn,
      cashBalance: cashBalance,
      runwayMonths: runwayFound ? runway : forecastMonths + 1,
      burnMultiples: metricsEngine.calculateBurnMultiples(rawModel),
      ruleOf40: metricsEngine.calculateRuleOf40(rawModel),
    );
  }

  double _getValue(List<Assumption> assumptions, String key, double defaultValue) {
    try {
      return assumptions.firstWhere((a) => a.key == key).value;
    } catch (_) {
      return defaultValue;
    }
  }
}

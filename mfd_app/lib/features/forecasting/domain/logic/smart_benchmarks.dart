
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';

enum CompanyStage { bootstrap, seed, seriesA, ipo }

class SmartBenchmarks {
  
  static Map<String, dynamic> analyze(ForecastState state) {
    // 1. Determine Stage based on Revenue
    final revenue = state.assumptions.firstWhere((a) => a.key == 'current_revenue', orElse: () => const Assumption(key: '', label: '', value: 0)).value;
    final burn = state.assumptions.firstWhere((a) => a.key == 'monthly_opex', orElse: () => const Assumption(key: '', label: '', value: 0)).value;
    
    CompanyStage stage = CompanyStage.bootstrap;
    if (revenue > 80000) stage = CompanyStage.seriesA;
    else if (revenue > 10000) stage = CompanyStage.seed;

    // 2. Benchmarks (SaaS Defaults)
    double healthyGrowth = 0;
    double maxBurn = 0;

    switch (stage) {
      case CompanyStage.bootstrap:
        healthyGrowth = 5.0; // 5% MoM
        maxBurn = 5000;
        break;
      case CompanyStage.seed:
        healthyGrowth = 10.0; // 10% MoM
        maxBurn = 30000;
        break;
      case CompanyStage.seriesA:
        healthyGrowth = 15.0; 
        maxBurn = 100000;
        break;
      case CompanyStage.ipo:
        healthyGrowth = 2.0;
        maxBurn = 1000000;
        break;
    }

    // 3. Score
    int score = 100;
    List<String> insights = [];

    // Burn Check
    if (burn > maxBurn) {
      score -= 20;
      insights.add("High Burn for ${stage.name.toUpperCase()} stage. Target < \$$maxBurn.");
    }

    // Runway Check
    // (Simplified: Cash / Burn)
    final cash = state.assumptions.firstWhere((a) => a.key == 'opening_cash', orElse: () => const Assumption(key: '', label: '', value: 0)).value;
    final runway = burn > 0 ? cash / burn : 99.0;
    
    if (runway < 6) {
      score -= 30;
      insights.add("Critical Runway: ${runway.toStringAsFixed(1)} months. Raising needed.");
    } else if (runway > 18 && stage == CompanyStage.seed) {
      score -= 5;
      insights.add("Conservative: ${runway.toStringAsFixed(1)} months. Invest more in growth?");
    }

    // Growth Check
    final growth = state.assumptions.firstWhere((a) => a.key == 'revenue_growth_rate', orElse: () => const Assumption(key: '', label: '', value: 0)).value;
    if (growth < healthyGrowth) {
      score -= 10;
      insights.add("Growth Lagging: ${growth}% vs Industry ${healthyGrowth}%");
    } else if (growth > healthyGrowth * 2) {
      insights.add("Hypergrowth detected: ${growth}% MoM!");
      score += 5; // Bonus
    }

    return {
      'score': score.clamp(0, 100),
      'stage': stage.name.toUpperCase(),
      'insights': insights,
      'runway': runway
    };
  }
}

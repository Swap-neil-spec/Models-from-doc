import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/forecasting/domain/logic/forecast_engine.dart';
import 'dart:math' as math;

class GoalAdjustment {
  final String description;
  final String key;
  final double newValue;
  final String impact;

  GoalAdjustment({required this.description, required this.key, required this.newValue, required this.impact});
}

class GoalEngine {
  final ForecastEngine _engine;

  GoalEngine({ForecastEngine? engine}) : _engine = engine ?? ForecastEngine();

  List<GoalAdjustment> solveRunwayGoal(List<Assumption> currentAssumptions, int currentRunway, {int targetMonths = 18}) {
    if (currentRunway >= targetMonths) return [];

    final suggestions = <GoalAdjustment>[];

    // 1. Solve for Revenue Growth
    final growthAdjustment = _solveForGrowth(currentAssumptions, targetMonths);
    if (growthAdjustment != null) suggestions.add(growthAdjustment);

    // 2. Solve for Burn Reduction (Opex)
    final burnAdjustment = _solveForBurn(currentAssumptions, targetMonths);
    if (burnAdjustment != null) suggestions.add(burnAdjustment);

    return suggestions;
  }

  GoalAdjustment? _solveForGrowth(List<Assumption> baseAssumptions, int target) {
    // Binary Search / Iterative approach
    // Range: Current Growth to +500%
    final currentGrowth = _getValue(baseAssumptions, 'revenue_growth_rate');
    double low = currentGrowth;
    double high = 500.0;
    double? foundUnsafe;

    // Optimization: Try 10 iterations to find approx value
    for (int i = 0; i < 15; i++) {
      double mid = (low + high) / 2;
      final testAssumptions = _update(baseAssumptions, 'revenue_growth_rate', mid);
      final model = _engine.generateModel(testAssumptions);
      
      if (model.runwayMonths >= target) {
        foundUnsafe = mid;
        high = mid; // Try smaller
      } else {
        low = mid; // Need more growth
      }
    }

    if (foundUnsafe != null) {
      // Round to 1 decimal place for cleanliness
      final cleanValue = (foundUnsafe * 10).ceil() / 10.0;
      return GoalAdjustment(
        description: 'Boost Growth',
        key: 'revenue_growth_rate',
        newValue: cleanValue,
        impact: 'Increase Growth to ${cleanValue.toStringAsFixed(1)}%',
      );
    }
    return null;
  }

  GoalAdjustment? _solveForBurn(List<Assumption> baseAssumptions, int target) {
    // Range: Current Burn down to $0
    final currentBurn = _getValue(baseAssumptions, 'monthly_opex');
    double low = 0; // Absolute best case (impossible but mathematically lower bound)
    double high = currentBurn;
    double? foundUnsafe;

    for (int i = 0; i < 15; i++) {
        double mid = (low + high) / 2;
        final testAssumptions = _update(baseAssumptions, 'monthly_opex', mid);
         final model = _engine.generateModel(testAssumptions);

         if (model.runwayMonths >= target) {
           foundUnsafe = mid;
           low = mid; // Try to keep burn as high as possible while still meeting target (maximize spend)
           // Wait, logically we want the *maximum* burn that still gives us 18 months.
           // If mid works, it means this Burn is low enough. We try explicitly higher to see if we can get away with spending more.
         } else {
           high = mid; // Burn is too high, cut it.
         }
    }
    
    // For burn, "safe" means finding the HIGHEST burn that surivives. 
    // Wait, the logic above:
    // If mid works (runway >= 18), then mid is "safe". We want to see if a HIGHER burn works (less pain). So we set low = mid.
    // If mid fails (runway < 18), we need to CUT burn, so high = mid.
    
    if (foundUnsafe != null) {
       final cleanValue = (foundUnsafe / 100).floor() * 100.0; // Round down to nearest 100
       return GoalAdjustment(
        description: 'Reduce Burn',
        key: 'monthly_opex',
        newValue: cleanValue,
        impact: 'Cut Burn to \$${cleanValue.toStringAsFixed(0)}',
      );
    }
    return null;
  }

  double _getValue(List<Assumption> assumptions, String key) {
    return assumptions.firstWhere((a) => a.key == key).value;
  }

  List<Assumption> _update(List<Assumption> assumptions, String key, double val) {
    return assumptions.map((a) => a.key == key ? a.copyWith(value: val) : a).toList();
  }
}

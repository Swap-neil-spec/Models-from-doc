import 'package:flutter_test/flutter_test.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/forecasting/domain/logic/goal_engine.dart';

void main() {
  late GoalEngine goalEngine;

  setUp(() {
    goalEngine = GoalEngine();
  });

  // Base assumptions that lead to a short runway (e.g. burn > revenue)
  // Cash: 10,000
  // Burn: 2,000
  // Revenue: 500
  // Run rate ~5 months
  final shortRunwayAssumptions = [
    const Assumption(key: 'opening_cash', label: 'Cash', value: 10000, unit: '\$'),
    const Assumption(key: 'revenue_growth_rate', label: 'Growth', value: 0, unit: '%'),
    const Assumption(key: 'monthly_opex', label: 'Burn', value: 2000, unit: '\$'),
    const Assumption(key: 'current_revenue', label: 'Revenue', value: 500, unit: '\$'),
    const Assumption(key: 'gross_margin', label: 'Margin', value: 100, unit: '%'),
    const Assumption(key: 'opex_growth_rate', label: 'Opex Growth', value: 0, unit: '%'),
  ];

  test('GoalEngine returns empty list if runway is sufficient', () {
    final suggestions = goalEngine.solveRunwayGoal(shortRunwayAssumptions, 24, targetMonths: 18);
    expect(suggestions, isEmpty);
  });

  test('GoalEngine suggests Growth Fix for short runway', () {
    // Current: 5 months. Target: 18 months.
    // Needs massive growth to outpace burn effectively instantly or over time.
    final suggestions = goalEngine.solveRunwayGoal(shortRunwayAssumptions, 5, targetMonths: 18);
    
    final growthSuggestion = suggestions.firstWhere((s) => s.key == 'revenue_growth_rate');
    expect(growthSuggestion, isNotNull);
    expect(growthSuggestion.newValue, greaterThan(0));
    print('Suggested Growth: ${growthSuggestion.newValue}%');
  });

  test('GoalEngine suggests Burn Reduction for short runway', () {
    final suggestions = goalEngine.solveRunwayGoal(shortRunwayAssumptions, 5, targetMonths: 18);
    
    final burnSuggestion = suggestions.firstWhere((s) => s.key == 'monthly_opex');
    expect(burnSuggestion, isNotNull);
    // Should be less than 2000
    expect(burnSuggestion.newValue, lessThan(2000));
    
    // Check if it's reasonable (e.g., calculates roughly $10k / 18 ~= 555 net burn allowed)
    // Revenue is 500. So max opex around 1055.
    print('Suggested Burn: \$${burnSuggestion.newValue}');
    expect(burnSuggestion.newValue, closeTo(1000, 200)); 
  });
}

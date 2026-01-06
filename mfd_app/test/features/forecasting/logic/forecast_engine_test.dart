import 'package:flutter_test/flutter_test.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/forecasting/domain/logic/forecast_engine.dart';

void main() {
  late ForecastEngine engine;

  setUp(() {
    engine = ForecastEngine();
  });

  test('Should calculate flat revenue and burn correctly', () {
    final assumptions = [
      const Assumption(key: 'opening_cash', label: 'Cash', value: 100000),
      const Assumption(key: 'current_revenue', label: 'Rev', value: 10000),
      const Assumption(key: 'revenue_growth_rate', label: 'Growth', value: 0), // 0% growth
      const Assumption(key: 'monthly_opex', label: 'Opex', value: 20000),
      const Assumption(key: 'opex_growth_rate', label: 'Opex Growth', value: 0), // 0% growth
      const Assumption(key: 'gross_margin', label: 'Margin', value: 100), // 100% margin
    ];

    final model = engine.generateModel(assumptions);

    // M1 Revenue = 10k
    expect(model.revenue.first, 10000);
    // M18 Revenue = 10k (flat)
    expect(model.revenue.last, 10000);
    // M1 Cash = 100k - (20k - 10k) = 90k
    expect(model.cashBalance.first, 90000);
    // Runway = 100k / 10k burn = 10 months
    expect(model.runwayMonths, 10);
  });

  test('Should apply 10% month-over-month growth', () {
    final assumptions = [
      const Assumption(key: 'opening_cash', label: 'Cash', value: 1000000),
      const Assumption(key: 'current_revenue', label: 'Rev', value: 1000),
      const Assumption(key: 'revenue_growth_rate', label: 'Growth', value: 10), // 10%
      const Assumption(key: 'monthly_opex', label: 'Opex', value: 500),
      const Assumption(key: 'gross_margin', label: 'Margin', value: 100),
    ];

    final model = engine.generateModel(assumptions);

    // M1 = 1000 * 1.1 = 1100
    expect(model.revenue[0], closeTo(1100, 0.1));
    // M2 = 1100 * 1.1 = 1210
    expect(model.revenue[1], closeTo(1210, 0.1));
  });

  test('Should detect bankruptcy month correctly', () {
    final assumptions = [
      const Assumption(key: 'opening_cash', label: 'Cash', value: 10000),
      const Assumption(key: 'current_revenue', label: 'Rev', value: 0),
      const Assumption(key: 'monthly_opex', label: 'Opex', value: 4000), // Burn 4k/mo
      const Assumption(key: 'gross_margin', label: 'Margin', value: 100),
    ];

    final model = engine.generateModel(assumptions);

    // M1 Cash = 10k - 4k = 6k
    // M2 Cash = 6k - 4k = 2k
    // M3 Cash = 2k - 4k = -2k (Bankrupt)
    expect(model.runwayMonths, 3);
  });
}

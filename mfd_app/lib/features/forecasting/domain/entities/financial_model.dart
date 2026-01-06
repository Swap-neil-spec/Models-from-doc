class FinancialModel {
  final List<String> monthLabels; // e.g. "Jan 24", "Feb 24"
  final List<double> revenue;
  final List<double> opex;
  final List<double> grossMargin;
  final List<double> netBurn;
  final List<double> cashBalance;
  final int runwayMonths;

  const FinancialModel({
    required this.monthLabels,
    required this.revenue,
    required this.opex,
    required this.grossMargin,
    required this.netBurn,
    required this.cashBalance,
    required this.runwayMonths,
    this.burnMultiples = const [],
    this.ruleOf40 = 0.0,
  });

  final List<double> burnMultiples;
  final double ruleOf40;

  factory FinancialModel.empty() {
    return const FinancialModel(
      monthLabels: [],
      revenue: [],
      opex: [],
      grossMargin: [],
      netBurn: [],
      cashBalance: [],
      runwayMonths: 0,
      burnMultiples: [],
      ruleOf40: 0.0,
    );
  }
}


class ActualsSeries {
  final DateTime date;
  final String metric; // e.g., 'revenue', 'opex', 'cash_balance'
  final double value;
  final String source; // e.g., 'stripe_import', 'manual_override'
  final Map<String, dynamic>? metadata; // Extra tags e.g. {'customer_id': '123'}

  const ActualsSeries({
    required this.date,
    required this.metric,
    required this.value,
    this.source = 'unknown',
    this.metadata,
  });

  // Factory to create from CSV row later
  factory ActualsSeries.fromMap(Map<String, dynamic> map) {
    return ActualsSeries(
      date: map['date'] as DateTime,
      metric: map['metric'] as String,
      value: (map['value'] as num).toDouble(),
      source: map['source'] as String? ?? 'unknown',
    );
  }
}

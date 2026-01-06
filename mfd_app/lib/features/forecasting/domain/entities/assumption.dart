class Assumption {
  final String key;
  final String label;
  final double value;
  final String? sourceSnippet;
  final String unit; // %, $, months

  const Assumption({
    required this.key,
    required this.label,
    required this.value,
    this.sourceSnippet,
    this.unit = '',
  });

  Assumption copyWith({
    String? key,
    String? label,
    double? value,
    String? sourceSnippet,
    String? unit,
  }) {
    return Assumption(
      key: key ?? this.key,
      label: label ?? this.label,
      value: value ?? this.value,
      sourceSnippet: sourceSnippet ?? this.sourceSnippet,
      unit: unit ?? this.unit,
    );
  }
}

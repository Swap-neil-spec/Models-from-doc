class Staff {
  final String id;
  final String role;
  final double monthlySalary;
  final int startMonth; // 1-18

  const Staff({
    required this.id,
    required this.role,
    required this.monthlySalary,
    required this.startMonth,
  });

  Staff copyWith({
    String? id,
    String? role,
    double? monthlySalary,
    int? startMonth,
  }) {
    return Staff(
      id: id ?? this.id,
      role: role ?? this.role,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      startMonth: startMonth ?? this.startMonth,
    );
  }
}

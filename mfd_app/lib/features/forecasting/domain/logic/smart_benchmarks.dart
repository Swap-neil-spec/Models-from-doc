enum AssessmentStatus { good, warning, critical }

class BenchmarkResult {
  final AssessmentStatus status;
  final String message;

  const BenchmarkResult({required this.status, required this.message});
}

class SmartBenchmarks {
  static BenchmarkResult assessGrowth(double growthRate, {String stage = 'Seed'}) {
    if (stage == 'Seed') {
      if (growthRate >= 15) return const BenchmarkResult(status: AssessmentStatus.good, message: 'Top Tier 🚀');
      if (growthRate >= 8) return const BenchmarkResult(status: AssessmentStatus.warning, message: 'Healthy');
      return const BenchmarkResult(status: AssessmentStatus.critical, message: 'Low Growth');
    } else {
      // Series A expectations are higher
      if (growthRate >= 20) return const BenchmarkResult(status: AssessmentStatus.good, message: 'Rocket Ship 🦄');
      if (growthRate >= 10) return const BenchmarkResult(status: AssessmentStatus.warning, message: 'On Track');
      return const BenchmarkResult(status: AssessmentStatus.critical, message: 'Needs Boost');
    }
  }

  static BenchmarkResult assessBurn(double monthlyBurn, double monthlyRevenue, {String stage = 'Seed'}) {
    // Simple Burn Multiple heuristic: Burn should ideally not exceed 2-3x revenue in late seed, 
    // but early seed it can be infinite. Let's use absolute caps for now manually.
    
    if (stage == 'Seed') {
      if (monthlyBurn > 50000) return const BenchmarkResult(status: AssessmentStatus.critical, message: 'High Burn 🔥');
      if (monthlyBurn > 20000) return const BenchmarkResult(status: AssessmentStatus.warning, message: 'Standard');
      return const BenchmarkResult(status: AssessmentStatus.good, message: 'Lean');
    }
    return const BenchmarkResult(status: AssessmentStatus.warning, message: 'Standard');
  }
}

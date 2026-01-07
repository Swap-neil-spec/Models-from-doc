
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';
import 'package:mfd_app/features/forecasting/domain/logic/smart_benchmarks.dart';

class HealthScoreBadge extends ConsumerWidget {
  const HealthScoreBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forecastControllerProvider);
    final benchmark = SmartBenchmarks.analyze(state);
    
    final score = benchmark['score'] as int;
    final stage = benchmark['stage'] as String;
    final insights = benchmark['insights'] as List<String>;

    Color color = AppTheme.electricGreen;
    if (score < 70) color = Colors.orange;
    if (score < 40) color = AppTheme.alertRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          // Show details dialog
          showDialog(context: context, builder: (_) => _HealthDialog(benchmark: benchmark, color: color));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              'Health: $score/100 ($stage)',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthDialog extends StatelessWidget {
  final Map<String, dynamic> benchmark;
  final Color color;

  const _HealthDialog({required this.benchmark, required this.color});

  @override
  Widget build(BuildContext context) {
    final insights = benchmark['insights'] as List<String>;
    final score = benchmark['score'];

    return Dialog(
       backgroundColor: AppTheme.surfaceDark,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: Container(
         padding: const EdgeInsets.all(24),
         width: 400,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: AppTheme.electricBlue.withOpacity(0.3)),
         ),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Text('Venture Health Score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                 const Spacer(),
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
                   child: Text('$score', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                 )
               ],
             ),
             const SizedBox(height: 16),
             const Text("Based on SaaS Industry Benchmarks (Seed/Series A)", style: TextStyle(color: AppTheme.textLow, fontSize: 12)),
             const SizedBox(height: 24),
             if (insights.isEmpty)
               const Text("Looking good! Metrics align with industry standards.", style: TextStyle(color: AppTheme.electricGreen))
             else ...insights.map((i) => Padding(
               padding: const EdgeInsets.only(bottom: 8.0),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Icon(Icons.warning_amber, color: Colors.amber, size: 16),
                   const SizedBox(width: 8),
                   Expanded(child: Text(i, style: const TextStyle(color: Colors.white70))),
                 ],
               ),
             )),
             const SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
             )
           ],
         ),
       ),
    );
  }
}

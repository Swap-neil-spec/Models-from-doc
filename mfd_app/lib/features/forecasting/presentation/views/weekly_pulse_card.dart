import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfd_app/core/ui/glass_container.dart';
import 'package:mfd_app/core/theme/app_theme.dart';

class WeeklyPulseCard extends StatelessWidget {
  final double actualValue;
  final double targetValue;
  final String metricName; // 'Revenue' or 'Burn'

  const WeeklyPulseCard({
    super.key,
    required this.actualValue,
    required this.targetValue,
    this.metricName = 'Revenue',
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // Time Progress (e.g., Day 15 of 30 = 50%)
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final timeProgress = now.day / daysInMonth;

    // Value Progress
    final progress = targetValue > 0 ? (actualValue / targetValue) : 0.0;
    
    // Status Logic
    bool isGood;
    String statusMessage;
    Color statusColor;

    if (metricName == 'Revenue') {
        // Revenue: We want Progress >= TimeProgress
        if (progress >= timeProgress - 0.05) { // 5% buffer
            isGood = true;
            statusMessage = "On Track";
            statusColor = AppTheme.emeraldGreen;
        } else {
            isGood = false;
            statusMessage = "Behind Pace";
            statusColor = Colors.orangeAccent;
        }
    } else {
        // Burn: We want Progress <= TimeProgress
         if (progress <= timeProgress + 0.05) {
            isGood = true;
            statusMessage = "Safe Spend";
            statusColor = AppTheme.emeraldGreen;
        } else {
            isGood = false;
            statusMessage = "Overspending";
            statusColor = Colors.redAccent;
        }
    }

    // Formatting
    final percentFmt = NumberFormat.percentPattern();
    final currencyFmt = NumberFormat.simpleCurrency(decimalDigits: 0);

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Row(
                        children: [
                            const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const Text('WEEKLY PULSE', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                                    Text('$metricName Pacing', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                            ),
                        ],
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(statusMessage, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                ],
            ),
            const SizedBox(height: 20),
            
            // Progress Bar Stack
            Stack(
                children: [
                    // Background Track
                    Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                        ),
                    ),
                    // Value Bar
                    LayoutBuilder(
                        builder: (ctx, constraints) {
                            return Container(
                                height: 12,
                                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.7), statusColor]),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 0)],
                                ),
                            );
                        }
                    ),
                    // Time Marker (The "Ghost" Pacer)
                    LayoutBuilder(
                       builder: (ctx, constraints) {
                           return Transform.translate(
                               offset: Offset(constraints.maxWidth * timeProgress, -4),
                               child: Column(
                                   children: [
                                       Container(
                                           width: 2, 
                                           height: 20, 
                                           color: Colors.white70,
                                       ),
                                   ],
                               )
                           );
                       }
                    ),
                ],
            ),
            const SizedBox(height: 8),
            
            // Labels
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text('${currencyFmt.format(actualValue)} (MTD)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Today: ${percentFmt.format(timeProgress)}', style: const TextStyle(color: Colors.white30, fontSize: 10)),
                    Text('Goal: ${currencyFmt.format(targetValue)}', style: const TextStyle(color: Colors.white70)),
                ],
            ),
        ],
      ),
    );
  }
}

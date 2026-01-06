import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/forecasting/domain/entities/financial_model.dart';
import 'package:mfd_app/core/ui/glass_container.dart';

class SlideExportLayout extends StatelessWidget {
  final FinancialModel model;

  const SlideExportLayout({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    // 16:9 Aspect Ratio Container
    return Container(
      width: 1920,
      height: 1080,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      padding: const EdgeInsets.all(64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Forecast', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  Text('Confidential Investor Update', style: TextStyle(color: Colors.white54, fontSize: 24)),
                ],
              ),
              GlassContainer(
                child: Text('ModelFromDocs.ai', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          
          const SizedBox(height: 64),

          // Main Content: Chart + Metrics
          Expanded(
            child: Row(
              children: [
                // Left: Chart (2/3 width)
                Expanded(
                  flex: 2,
                  child: GlassContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 2)),
                          titlesData: const FlTitlesData(
                             bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 3, reservedSize: 40, getTitlesWidget: _bottomTitleWidgets)),
                             leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: model.cashBalance.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              color: AppTheme.accentAmber, 
                              barWidth: 6,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                                colors: [AppTheme.accentAmber.withValues(alpha: 0.3), AppTheme.accentAmber.withValues(alpha: 0.0)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )),
                            ),
                          ],
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [HorizontalLine(y: 0, color: Colors.redAccent, strokeWidth: 3, dashArray: [10, 10])],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 48),

                // Right: Metrics (1/3 width)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _MetricCard(
                        label: 'Runway',
                        value: '${model.runwayMonths} Months',
                        color: model.runwayMonths > 12 ? Colors.greenAccent : Colors.redAccent,
                      ),
                      const SizedBox(height: 32),
                      _MetricCard(
                        label: 'Cash Balance',
                        value: '\$${(model.cashBalance.last / 1000).toStringAsFixed(0)}k',
                        color: Colors.white,
                      ),
                       const SizedBox(height: 32),
                       // Burn Rate (Approx avg of last 3 months)
                      _MetricCard(
                        label: 'Net Burn (Last Mo)',
                        value: '\$${(model.netBurn.last / 1000).toStringAsFixed(1)}k',
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold);
  return SideTitleWidget(axisSide: meta.axisSide, child: Text('M${value.toInt()}', style: style));
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(48),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 24)),
            const SizedBox(height: 16),
            Text(value, style: TextStyle(color: color, fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

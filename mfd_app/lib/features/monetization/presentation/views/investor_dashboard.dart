
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';
import 'package:mfd_app/features/forecasting/presentation/widgets/health_score_badge.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';

// A simplified Forecast Chart for the Investor
class _InvestorChart extends StatelessWidget {
  final ForecastState state;
  final double sensitivityGrowth; // -5 to +5%

  const _InvestorChart({required this.state, required this.sensitivityGrowth});

  @override
  Widget build(BuildContext context) {
    if (state.baseModel == null) return const SizedBox.shrink();

    // Apply sensitivity on the fly (visual hack for MVP)
    // Real impl would recalculate model.
    // Here we just shift the line visually to show "Impact"
    final data = state.baseModel!.monthlyCash;
    final spots = data.asMap().entries.map((e) {
      double val = e.value;
      if (sensitivityGrowth != 0) {
         // Compound effect approximation
         val = val * (1 + (sensitivityGrowth / 100) * (e.key / 12)); 
      }
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: sensitivityGrowth < 0 ? AppTheme.alertRed : (sensitivityGrowth > 0 ? AppTheme.electricGreen : AppTheme.electricBlue),
            barWidth: 4,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: (sensitivityGrowth < 0 ? AppTheme.alertRed : AppTheme.electricBlue).withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}

class InvestorDashboard extends ConsumerStatefulWidget {
  const InvestorDashboard({super.key});

  @override
  ConsumerState<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends ConsumerState<InvestorDashboard> {
  double _sensitivityGrowth = 0; // +/- 10%
  double _sensitivityBurn = 0; // +/- 10%

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forecastControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: const [
             Icon(Icons.lock_outline, color: AppTheme.electricBlue, size: 16),
             SizedBox(width: 8),
             Text('SECURE DEAL ROOM', style: TextStyle(color: AppTheme.electricBlue, fontSize: 12, letterSpacing: 2)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/dashboard')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Series A Opportunity', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Opacity(opacity: 0.7, child: HealthScoreBadge()),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.electricGreen, foregroundColor: Colors.black),
                  child: const Text('Commit Interest'),
                )
              ],
            ),
            const SizedBox(height: 48),

            // Video Placeholder
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                image: const DecorationImage(
                   image: NetworkImage('https://images.unsplash.com/photo-1557804506-669a67965ba0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1674&q=80'),
                   fit: BoxFit.cover,
                   opacity: 0.5,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            const Text('Sensitivity Analysis (Challenge the Model)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
             const SizedBox(height: 8),
            const Text("Adjust the sliders to see how the company's cash runway holds up against market volatility.", style: TextStyle(color: AppTheme.textMedium)),
            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                       _buildSlider("Revenue Shock", _sensitivityGrowth, (v) => setState(() => _sensitivityGrowth = v), Colors.blue),
                       const SizedBox(height: 24),
                       // Burn logic strictly visual for MVP prototype
                       _buildSlider("Opex Inflation", _sensitivityBurn, (v) => setState(() => _sensitivityBurn = v), Colors.red),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _InvestorChart(state: state, sensitivityGrowth: _sensitivityGrowth),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double val, Function(double) onChanged, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("${val > 0 ? '+' : ''}${val.toStringAsFixed(0)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: val, 
            min: -50, 
            max: 50, 
            activeColor: color,
            onChanged: onChanged,
          ),
          Text(
            val < -20 ? "Severe Stress Test" : (val > 20 ? "Optimistic" : "Base Case"),
            style: const TextStyle(color: AppTheme.textLow, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

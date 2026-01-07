import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/features/monetization/presentation/views/pricing_overlay.dart';
import 'package:mfd_app/features/monetization/domain/services/subscription_service.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mfd_app/core/ui/glass_container.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/export_controller.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/forecasting/presentation/views/hiring_dialog.dart';
import 'package:mfd_app/features/forecasting/domain/logic/smart_benchmarks.dart';
import 'dart:ui' as ui;
import 'package:mfd_app/features/forecasting/presentation/views/weekly_pulse_card.dart';
import 'package:mfd_app/features/forecasting/presentation/views/slide_export_layout.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as java_io;
import 'package:flutter/rendering.dart'; // Required for RenderRepaintBoundary
import 'package:intl/intl.dart';
import 'package:mfd_app/features/forecasting/presentation/views/driver_tree_view.dart';
import 'package:mfd_app/core/ui/onyx_tour_overlay.dart';
import 'package:mfd_app/features/forecasting/domain/logic/goal_engine.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey _slideKey = GlobalKey();
  bool _showTour = false;

  @override
  void initState() {
    super.initState();
    _checkTourStatus();
  }

  Future<void> _checkTourStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
       setState(() {
         // Show tour if NOT seen yet
         _showTour = !(prefs.getBool('hasSeenOnyxTour') ?? false);
       });
    }
  }

  Future<void> _completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnyxTour', true);
    if (mounted) setState(() => _showTour = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forecastControllerProvider);
    final model = state.model;
    final controller = ref.read(forecastControllerProvider.notifier);
    
    final subState = ref.watch(subscriptionProvider);
    final isPro = subState.isPro;

    // Find Growth Rate Assumption for Slider (or Tree)
    final growthAssumption = state.assumptions.firstWhere((a) => a.key == 'revenue_growth_rate', orElse: () => Assumption(key: '', label: '', value: 0));
    final burnAssumption = state.assumptions.firstWhere((a) => a.key == 'monthly_opex', orElse: () => Assumption(key: '', label: '', value: 0));

    return OnyxTourOverlay(
      showTour: _showTour,
      onComplete: _completeTour,
      child: Stack(
      children: [
        // Hidden Slide for Export
        Transform.translate(
          offset: const Offset(0, -2000),
          child: RepaintBoundary(
            key: _slideKey,
            child: SlideExportLayout(model: model),
          ),
        ),
        
        // Main Content Area (No Scaffold, No AppBar)
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- VIEW HEADER (Toolbar) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financial Model', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textHigh)),
                      const SizedBox(height: 4),
                      Text('Live Forecast • ${state.currentScenario.name.toUpperCase()}', style: const TextStyle(color: AppTheme.textMedium, fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                       if (!isPro)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.signalGreen,
                              foregroundColor: AppTheme.voidBlack,
                            ),
                            onPressed: () => _showPricingOverlay(context),
                            icon: const Icon(Icons.star, size: 16),
                            label: const Text('Upgrade'),
                          ),
                        ),
                      IconButton(
                        onPressed: () => _uploadActuals(context, ref),
                        icon: const Icon(Icons.show_chart, color: Colors.purpleAccent),
                        tooltip: 'Upload Actuals',
                      ),
                      IconButton(
                        onPressed: () => _showAiGoalSeeker(context, ref),
                        icon: const Icon(Icons.auto_fix_high, color: AppTheme.signalGreen),
                        tooltip: 'AI Goal Seeker',
                      ),
                      IconButton(
                        onPressed: () => _showExportOptions(context, ref),
                        icon: const Icon(Icons.download, color: AppTheme.textHigh),
                        tooltip: 'Export Report',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 0. Weekly Pulse (Pacing) - Only if data exists
              if (state.rawActuals.isNotEmpty) ...[
                  Builder(builder: (context) {
                      // Find the "Latest Month" in the data to simulate "Now"
                      final now = DateTime.now();
                      final latestDataDate = state.rawActuals.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
                      
                      // Use "Visual Now" - if data is old, show the old data's month context
                      final isOldData = latestDataDate.year != now.year || latestDataDate.month != now.month;
                      final focusDate = isOldData ? latestDataDate : now;
                      
                      final mtdActuals = state.rawActuals.where((s) => s.date.year == focusDate.year && s.date.month == focusDate.month);
                      final mtdSum = mtdActuals.fold(0.0, (sum, item) => sum + item.value);
                      
                      final target = state.assumptions.firstWhere((a) => a.key == 'current_revenue').value;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            if (isOldData) 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                                child: Text('Showing data for ${DateFormat('MMMM yyyy').format(focusDate)}', style: const TextStyle(color: AppTheme.warningAmber, fontSize: 10)),
                              ),
                            WeeklyPulseCard(
                              actualValue: mtdSum,
                              targetValue: target,
                              metricName: 'Revenue',
                            ).animate().fade().slideY(begin: -0.2),
                        ],
                      );
                  }),
                  const SizedBox(height: 24),
              ],

              // 1. Runway Summary Card
              GlassContainer(
                color: model.cashBalance.last < 0 ? AppTheme.alertRed.withOpacity(0.1) : AppTheme.signalGreen.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      model.cashBalance.last < 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: model.cashBalance.last < 0 ? AppTheme.alertRed : AppTheme.signalGreen,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.runwayMonths > 18 ? 'Runway: 18+ Months' : 'Runway: ${model.runwayMonths} Months',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textHigh),
                        ),
                        Text(
                          model.cashBalance.last < 0 ? 'Cash out in Month ${model.runwayMonths}' : 'Safety Buffer: Healthy',
                          style: const TextStyle(color: AppTheme.textMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),

              // Scenario Toggle
              Center(
                child: SegmentedButton<Scenario>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return AppTheme.signalGreen;
                        return Colors.white10;
                    }),
                    foregroundColor: WidgetStateProperty.all(AppTheme.textHigh),
                  ),
                  segments: const [
                      ButtonSegment(value: Scenario.bear, label: Text('🐻 Bear'), icon: Icon(Icons.trending_down, size: 16)),
                      ButtonSegment(value: Scenario.base, label: Text('😐 Base'), icon: Icon(Icons.trending_flat, size: 16)),
                      ButtonSegment(value: Scenario.bull, label: Text('🐂 Bull'), icon: Icon(Icons.trending_up, size: 16)),
                  ], 
                  selected: {state.currentScenario}, 
                  onSelectionChanged: (Set<Scenario> newSelection) {
                    controller.switchScenario(newSelection.first);
                  },
                ),
              ).animate().fade(delay: 200.ms),

              const SizedBox(height: 24),
              
              // SaaS Metrics Card (New)
              _SaaSMetricsCard(
                ruleOf40: model.ruleOf40,
                burnMultiple: model.burnMultiples.isNotEmpty ? model.burnMultiples.last : 0.0,
              ).animate().fade(delay: 250.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),
              
              // 2. Cash Chart
              const Text('Cash Balance (18 Months)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textHigh)),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 3, reservedSize: 22, getTitlesWidget: _bottomTitleWidgets)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Ghost Line: Bear (Red)
                      if (state.currentScenario != Scenario.bear)
                      LineChartBarData(
                        spots: state.bearModel.cashBalance.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: AppTheme.alertRed.withOpacity(0.3),
                        barWidth: 2,
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                      ),
                      // Ghost Line: Bull (Green)
                      if (state.currentScenario != Scenario.bull)
                      LineChartBarData(
                        spots: state.bullModel.cashBalance.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: AppTheme.signalGreen.withOpacity(0.3),
                        barWidth: 2,
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                      ),
                        // Actuals Overlay (Purple)
                        if (state.actualsModel != null)
                        LineChartBarData(
                        spots: state.actualsModel!.cashBalance.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: Colors.purpleAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Active Line
                      LineChartBarData(
                        spots: model.cashBalance.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: AppTheme.warningAmber, 
                        barWidth: 4,
                        isStrokeCapRound: true, 
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                          colors: [AppTheme.warningAmber.withOpacity(0.3), AppTheme.warningAmber.withOpacity(0.0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
                      ),
                    ],
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [HorizontalLine(y: 0, color: AppTheme.alertRed, strokeWidth: 2, dashArray: [5, 5])],
                    ),
                  ),
                ),
              ).animate().fade(duration: 800.ms).slideX(begin: 0.2, duration: 800.ms, curve: Curves.easeOutQuart),

              const SizedBox(height: 32),

              // 3. Living Model (Driver Tree) - Replaces Controls
              GlassContainer(
                 child: const DriverTreeWidget(),
              ).animate().fade().slideY(begin: 0.2, delay: 200.ms),

              const SizedBox(height: 24),

              // 4. Hiring Simulator (Team Plan)
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Team Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textHigh)),
                        IconButton(
                          icon: const Icon(Icons.person_add, color: AppTheme.signalGreen),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => HiringDialog(onHire: (staff) => controller.addHire(staff)),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (state.staff.isEmpty)
                      const Text('No new hires in this scenario.', style: TextStyle(color: AppTheme.textMedium))
                    else
                      ...state.staff.map((staff) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white10,
                              child: Text(staff.role[0], style: const TextStyle(color: AppTheme.textHigh)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(staff.role, style: const TextStyle(color: AppTheme.textHigh, fontWeight: FontWeight.bold)),
                                  Text('Start: M${staff.startMonth} | \$${staff.monthlySalary}/mo', style: const TextStyle(color: AppTheme.textMedium, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.alertRed, size: 20),
                              onPressed: () => controller.removeHire(staff.id),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ).animate().fade(delay: 300.ms),
                
                const SizedBox(height: 24),
                
                // 5. Assumption Table Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textHigh,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _showAssumptions(context, ref),
                    child: const Text('View All Assumptions'),
                  ),
                ).animate().fade(delay: 400.ms),
              ],
            ),
        ),
      ],
    ),
    );
  }

  void _showAssumptions(BuildContext context, WidgetRef ref) {
    final state = ref.read(forecastControllerProvider);
    final assumptions = state.assumptions;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Forecast Assumptions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white54)),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.separated(
                itemCount: assumptions.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final a = assumptions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(a.label, style: const TextStyle(color: Colors.white70)),
                    subtitle: Text('${a.sourceSnippet} (${a.key})', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                    trailing: Text('${a.value} ${a.unit}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility for Chart Labels to fix "const" issue
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white54, fontSize: 12);
    return SideTitleWidget(axisSide: meta.axisSide, child: Text('M${value.toInt()}', style: style));
  }


  void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as CSV (Excel)'),
              onTap: () async {
                Navigator.pop(context);
                final controller = ref.read(exportControllerProvider);
                await controller.exportCsv(ref.read(forecastControllerProvider).model);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV Exported!')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF Report'),
              trailing: !ref.read(subscriptionProvider).isPro ? const Icon(Icons.lock, size: 16, color: Colors.white24) : null,
              onTap: () async {
                Navigator.pop(context);
                if (!ref.read(subscriptionProvider).isPro) {
                   _showPricingOverlay(context);
                   return;
                }
                final controller = ref.read(exportControllerProvider);
                final state = ref.read(forecastControllerProvider);
                await controller.exportPdf(state.model, state.assumptions);
                 if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF Exported!')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.amber),
              title: const Text('Export Investor Slide (PNG)'),
              subtitle: const Text('Perfect for Pitch Decks', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(context);
                try {
                   final boundary = _slideKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                   final image = await boundary.toImage(pixelRatio: 3.0); // High Res
                   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                   
                   if (byteData != null) {
                     final controller = ref.read(exportControllerProvider);
                     await controller.exportImage(byteData.buffer.asUint8List());
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slide Exported!')));
                     }
                   }
                } catch (e) {
                  print('Export Error: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPricingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (ctx) => PricingOverlay(onClose: () => Navigator.pop(ctx)),
    );
  }
  void _uploadActuals(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Actuals / Comparison'),
        content: const Text('Select a file to act as the "Actuals" or "Comparison Model". This will be overlaid on your chart as a purple line.'),
        actions: [
          TextButton(
             onPressed: () => Navigator.pop(ctx),
             child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
            onPressed: () {
               Navigator.pop(ctx);
               _pickAndProcessActuals(context, ref);
            },
            child: const Text('Select File', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndProcessActuals(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Load bytes into memory (Critical for Web & Simplified Logic)
      );

      if (result != null && result.files.isNotEmpty) {
         final file = result.files.single;
         await ref.read(forecastControllerProvider.notifier).processAndLoadActuals(file);
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comparison Model Loaded! Purple line updated.')));
         }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAiGoalSeeker(BuildContext context, WidgetRef ref) {
    final state = ref.read(forecastControllerProvider);
    if (state.model.runwayMonths >= 18) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You already have 18+ months runway! Great job. 🚀')));
       return;
    }

    final suggestions = GoalEngine().solveRunwayGoal(state.assumptions, state.model.runwayMonths);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚡ AI Goal Seeker', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Current Runway: ${state.model.runwayMonths} Months. Target: 18 Months.', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ...suggestions.map((s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: AppTheme.emeraldGreen, child: Icon(Icons.auto_fix_high, color: Colors.white)),
              title: Text(s.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(s.impact, style: const TextStyle(color: Colors.white70)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                onPressed: () {
                  ref.read(forecastControllerProvider.notifier).updateAssumption(s.key, s.newValue);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal Applied! Check the chart. 📈')));
                },
                child: const Text('Apply', style: TextStyle(color: AppTheme.emeraldGreen)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ControlSlider extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final Function(double) onChanged;
  final BenchmarkResult? benchmark; // Optional benchmark context

  const _ControlSlider({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
    this.benchmark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                if (benchmark != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(benchmark!.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(benchmark!.status).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      benchmark!.message,
                      style: TextStyle(fontSize: 10, color: _getStatusColor(benchmark!.status), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            Text('${value.toStringAsFixed(1)}$unit', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppTheme.emeraldGreen,
          inactiveColor: Colors.white10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Color _getStatusColor(AssessmentStatus status) {
    switch (status) {
      case AssessmentStatus.good: return Colors.greenAccent;
      case AssessmentStatus.warning: return Colors.orangeAccent;
      case AssessmentStatus.critical: return Colors.redAccent;
    }
  }
}

class _SaaSMetricsCard extends StatelessWidget {
  final double ruleOf40;
  final double burnMultiple;

  const _SaaSMetricsCard({required this.ruleOf40, required this.burnMultiple});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SaaS Health Scorecard (Investor View)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                label: 'Rule of 40',
                value: '${ruleOf40.toStringAsFixed(1)}%',
                isGood: ruleOf40 >= 40,
                tooltip: 'Growth % + Profit Margin %. Target > 40%.',
              ),
              Container(width: 1, height: 40, color: Colors.white10),
              _MetricItem(
                label: 'Burn Multiple',
                value: '${burnMultiple.toStringAsFixed(1)}x',
                isGood: burnMultiple < 2.0 && burnMultiple > 0,
                tooltip: 'Net Burn / Net New ARR. Target < 2.0x.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;
  final String tooltip;

  const _MetricItem({required this.label, required this.value, required this.isGood, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isGood ? AppTheme.emeraldGreen : Colors.redAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

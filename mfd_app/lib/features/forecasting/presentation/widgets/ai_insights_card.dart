
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/extraction/domain/services/gemini_service.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AIInsightsCard extends ConsumerStatefulWidget {
  const AIInsightsCard({super.key});

  @override
  ConsumerState<AIInsightsCard> createState() => _AIInsightsCardState();
}

class _AIInsightsCardState extends ConsumerState<AIInsightsCard> {
  String? _insights;
  bool _isLoading = false;

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final state = ref.read(forecastControllerProvider);
      
      // Prepare compact summary
      final summary = {
        'scenario': state.currentScenario.toString(),
        'cash_start': state.assumptions.firstWhere((a) => a.key == 'opening_cash').value,
        'revenue_growth': state.assumptions.firstWhere((a) => a.key == 'revenue_growth_rate').value,
        'burn_rate': state.assumptions.firstWhere((a) => a.key == 'monthly_opex').value,
        'headcount': state.staff.length,
      };

      final service = const GeminiService();
      final result = await service.generateInsights(summary);
      
      if (mounted) setState(() => _insights = result);
    } catch (e) {
      if (mounted) setState(() => _insights = "Could not generate insights.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.electricBlue.withOpacity(0.15),
            AppTheme.voidBlack.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.electricBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.electricBlue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Analyst Insights',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (!_isLoading && _insights == null)
                TextButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.play_arrow, size: 16, color: AppTheme.electricBlue),
                  label: const Text('Generate', style: TextStyle(color: AppTheme.electricBlue)),
                ),
               if (_isLoading)
                 const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.electricBlue)),
            ],
          ),
          
          if (_insights != null) ...[
            const SizedBox(height: 16),
            MarkdownBody(
              data: _insights!,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: AppTheme.textMedium, height: 1.5),
                strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                listBullet: const TextStyle(color: AppTheme.electricBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

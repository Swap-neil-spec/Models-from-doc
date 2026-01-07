import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class GuidanceWizard extends ConsumerStatefulWidget {
  final VoidCallback onFinish;

  const GuidanceWizard({super.key, required this.onFinish});

  @override
  ConsumerState<GuidanceWizard> createState() => _GuidanceWizardState();
}

class _GuidanceWizardState extends ConsumerState<GuidanceWizard> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Welcome to Onyx',
      'subtitle': 'The Financial Operating System for Founders.',
      'icon': Icons.rocket_launch,
      'color': AppTheme.signalGreen,
    },
    {
      'title': 'Why Onyx?',
      'subtitle': 'Stop guessing. Start simulating.\nBuild investor-ready forecasts in minutes, not days.',
      'icon': Icons.auto_graph,
      'color': AppTheme.electricBlue,
    },
    {
      'title': 'How it Works',
      'subtitle': '1. Upload your P&L (PDF/CSV).\n2. Onyx extracts the math.\n3. You control the drivers.',
      'icon': Icons.psychology, // AI Brain
      'color': Colors.purpleAccent,
    },
    {
      'title': 'Ready to Launch?',
      'subtitle': 'Let\'s build your first model.',
      'icon': Icons.bolt,
      'color': Colors.amber,
      'isLast': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      body: Stack(
        children: [
          // Background Gradient (Subtle)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    _steps[_currentStep]['color'].withOpacity(0.15),
                    AppTheme.voidBlack,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Pagination Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Row(
                    children: List.generate(_steps.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index <= _currentStep 
                                ? _steps[index]['color'] 
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Force button nav
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(48.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: (step['color'] as Color).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: (step['color'] as Color).withOpacity(0.5), width: 2),
                                  boxShadow: [BoxShadow(color: (step['color'] as Color).withOpacity(0.2), blurRadius: 40)],
                                ),
                                child: Icon(step['icon'], size: 64, color: step['color']),
                              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                              
                              const SizedBox(height: 48),
                              
                              Text(
                                step['title'],
                                style: GoogleFonts.getFont('Inter', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),
                              
                              const SizedBox(height: 24),
                              
                              Text(
                                step['subtitle'],
                                style: GoogleFonts.getFont('Inter', fontSize: 18, color: AppTheme.textMedium, height: 1.5),
                                textAlign: TextAlign.center,
                              ).animate().slideY(begin: 0.2, end: 0, delay: 400.ms).fadeIn(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: () {
                            setState(() => _currentStep--);
                            _pageController.previousPage(duration: 400.ms, curve: Curves.easeInOut);
                          },
                          child: const Text('Back', style: TextStyle(color: Colors.white54)),
                        )
                      else
                        const SizedBox.shrink(),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _steps[_currentStep]['color'],
                          foregroundColor: AppTheme.voidBlack,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: () {
                          if (_currentStep < _steps.length - 1) {
                            setState(() => _currentStep++);
                            _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut);
                          } else {
                            widget.onFinish();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_currentStep == _steps.length - 1 ? 'Start Forecasting' : 'Continue'),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
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

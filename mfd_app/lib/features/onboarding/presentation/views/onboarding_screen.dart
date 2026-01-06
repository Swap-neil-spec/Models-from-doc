import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/features/onboarding/domain/entities/onboarding_goal.dart';
import 'package:mfd_app/core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  OnboardingGoal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                'MISSION PARAMETERS',
                style: TextStyle(
                  color: AppTheme.signalGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontFamily: 'JetBrains Mono'
                ),
              ).animate().fadeIn().slideX(begin: -0.2),
              const SizedBox(height: 16),
              const Text(
                'Define Your Objective',
                style: TextStyle(
                  color: AppTheme.textHigh,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 12),
              const Text(
                'Select the primary driver for your financial model. We will calibrate the cockpit accordingly.',
                style: TextStyle(color: AppTheme.textMedium, fontSize: 16),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),

              Expanded(
                child: ListView(
                  children: OnboardingGoal.values.map((goal) {
                    final isSelected = _selectedGoal == goal;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGoal = goal),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.signalGreen.withOpacity(0.1) : AppTheme.commandGrey,
                          border: Border.all(
                            color: isSelected ? AppTheme.signalGreen : AppTheme.borderGrey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8), // Sharp Onyx style
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.signalGreen : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? Colors.transparent : AppTheme.borderGrey),
                              ),
                              child: Icon(
                                _getIcon(goal),
                                color: isSelected ? AppTheme.voidBlack : AppTheme.textMedium,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.label.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.textHigh : AppTheme.textMedium,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    goal.description,
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.textMedium : AppTheme.textLow,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, color: AppTheme.signalGreen),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 400.ms),
              ),

              if (_selectedGoal != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.signalGreen,
                      foregroundColor: AppTheme.voidBlack,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.go('/upload', extra: _selectedGoal);
                    },
                    child: const Text('INITIALIZE SYSTEM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ).animate().fadeIn().slideY(begin: 1.0, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(OnboardingGoal goal) {
    switch (goal) {
      case OnboardingGoal.survival: return Icons.shield_outlined;
      case OnboardingGoal.fundraising: return Icons.rocket_launch_outlined;
      case OnboardingGoal.hiring: return Icons.group_add_outlined;
    }
  }
}

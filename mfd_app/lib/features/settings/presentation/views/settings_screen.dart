
import 'package:flutter/material.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/core/ui/fintech_scaffold.dart';
import 'package:mfd_app/features/forecasting/domain/repositories/project_repository.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  Future<void> _resetData() async {
    setState(() => _isLoading = true);
    final repo = ProjectRepository();
    await repo.clearProject();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project Data Cleared. Restarting...')),
      );
      // context.go('/dashboard'); 
      // Ideally we should reload the app or reload the controller.
      // For now, navigating to dashboard might show stale data unless we force refresh.
      // Best is to ask user to restart or reload.
      Future.delayed(const Duration(seconds: 1), () {
         context.go('/dashboard'); // Dashboard init might not re-load if controller is alive.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinTechScaffold(
      currentRoute: '/settings',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your application preferences and data.',
                style: TextStyle(color: AppTheme.textMedium),
              ),
              const SizedBox(height: 48),

              // Data Management Section
              const Text(
                'Data Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.electricBlue),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGrey),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delete_forever, color: AppTheme.alertRed, size: 32),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Reset Project Data',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Clear all saved assumptions, staffing, and valid scenarios. This action cannot be undone.',
                            style: TextStyle(color: AppTheme.textLow, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.alertRed.withOpacity(0.2),
                        foregroundColor: AppTheme.alertRed,
                        elevation: 0,
                        side: const BorderSide(color: AppTheme.alertRed),
                      ),
                      child: _isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Text('Reset'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              
              const Divider(color: AppTheme.borderGrey),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Model Forecasting Tool v1.0.0 (RC6)',
                  style: TextStyle(color: AppTheme.textLow, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

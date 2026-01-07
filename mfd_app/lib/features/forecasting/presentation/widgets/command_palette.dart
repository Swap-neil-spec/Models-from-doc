
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/forecasting/domain/services/agent_service.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mfd_app/features/forecasting/domain/entities/staff.dart';

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _feedback;

  Future<void> _executeCommand() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      final service = AgentService(Supabase.instance.client);
      final action = await service.parseIntent(query);

      if (!mounted) return;

      _processAction(action);
      
    } catch (e) {
      if (mounted) setState(() => _feedback = "Error: $e");
    } finally {
      if (mounted) {
         setState(() => _isLoading = false);
         _controller.clear();
      }
    }
  }

  void _processAction(Map<String, dynamic> action) {
    print("Agent Action: $action");
    final refController = ref.read(forecastControllerProvider.notifier);

    switch (action['action']) {
      case 'update_assumption':
        final key = action['key'];
        final value = (action['value'] as num).toDouble();
        
        // Basic mapping for human-readable feedback
        String label = key;
        
        refController.updateAssumption(key, value);
        setState(() => _feedback = "Updated $label to $value");
        break;

      case 'add_hire':
        final role = action['role'];
        final salary = (action['salary'] as num).toDouble();
        final start = action['start_month'] as int? ?? 1;

        final newStaff = Staff(
          id: const Uuid().v4(), 
          role: role, 
          monthlySalary: salary, 
          startMonth: start
        );
        refController.addHire(newStaff);
        setState(() => _feedback = "Hired $role at \$$salary/mo");
        break;

      case 'switch_scenario':
         final s = action['scenario'];
         if (s == 'bull') refController.switchScenario(Scenario.bull);
         else if (s == 'bear') refController.switchScenario(Scenario.bear);
         else refController.switchScenario(Scenario.base);
         setState(() => _feedback = "Switched to ${s.toUpperCase()} case.");
         break;

      default:
        setState(() => _feedback = action['message'] ?? "Unknown command.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.electricBlue, width: 1),
        boxShadow: [
          BoxShadow(color: AppTheme.electricBlue.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: AppTheme.electricBlue),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier New'),
                  decoration: const InputDecoration(
                    hintText: 'Ask the Oracle... (e.g., "Hire 2 devs", "Set growth to 15%")',
                    hintStyle: TextStyle(color: AppTheme.textLow),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _executeCommand(),
                  autofocus: true,
                ),
              ),
              if (_isLoading)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.electricBlue),
                  onPressed: _executeCommand,
                ),
            ],
          ),
          if (_feedback != null) ...[
            const Divider(color: AppTheme.borderGrey),
            const SizedBox(height: 8),
            Text(
              _feedback!,
              style: const TextStyle(color: AppTheme.electricGreen, fontWeight: FontWeight.bold),
            ),
          ]
        ],
      ),
    );
  }
}

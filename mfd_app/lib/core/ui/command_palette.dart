import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<_CommandAction> _filteredActions = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredActions = _allActions;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredActions = _allActions.where((a) => a.label.toLowerCase().contains(query)).toList();
      _selectedIndex = 0;
    });
  }
  
  // Define Actions dynamically based on context? 
  // For now, hardcoded global actions.
  List<_CommandAction> get _allActions => [
    _CommandAction(icon: Icons.dashboard, label: 'Go to Cockpit', onExecute: (ref, context) => context.go('/dashboard')),
    _CommandAction(icon: Icons.settings, label: 'System Settings', onExecute: (ref, context) => context.go('/settings')),
    _CommandAction(icon: Icons.trending_down, label: 'Scenario: Bear Case', onExecute: (ref, context) {
       ref.read(forecastControllerProvider.notifier).switchScenario(Scenario.bear);
    }),
    _CommandAction(icon: Icons.trending_up, label: 'Scenario: Bull Case', onExecute: (ref, context) {
       ref.read(forecastControllerProvider.notifier).switchScenario(Scenario.bull);
    }),
    _CommandAction(icon: Icons.person_add, label: 'Add New Hire', onExecute: (ref, context) {
       // Only works if on dashboard? Or we navigate there first?
       context.go('/dashboard');
       // Ideally we trigger the dialog. This requires a global key or event bus.
       // For now, let's just nav. 
       // TODO: Implement global event bus for "Open Hire Dialog".
    }),
  ];

  void _execute(int index) {
    if (index >= 0 && index < _filteredActions.length) {
      Navigator.pop(context); // Close palette
      _filteredActions[index].onExecute(ref, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      alignment: Alignment.topCenter,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: AppTheme.voidBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGrey),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppTheme.electricBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Type a command...',
                        hintStyle: TextStyle(color: AppTheme.textLow),
                      ),
                      onSubmitted: (_) => _execute(_selectedIndex),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.commandGrey, borderRadius: BorderRadius.circular(4)),
                    child: const Text('ESC', style: TextStyle(color: AppTheme.textMedium, fontSize: 10)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderGrey),
            
            // Results List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredActions.length,
                itemBuilder: (context, index) {
                  final action = _filteredActions[index];
                  final isSelected = index == _selectedIndex;
                  
                  return InkWell(
                    onTap: () => _execute(index),
                    onHover: (hovering) {
                      if (hovering) setState(() => _selectedIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: isSelected ? AppTheme.electricBlue.withOpacity(0.1) : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(action.icon, color: isSelected ? AppTheme.electricBlue : AppTheme.textMedium, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            action.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textMedium,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(Icons.keyboard_return, size: 16, color: AppTheme.textMedium),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderGrey)),
                color: AppTheme.commandGrey,
              ),
              child: Row(
                children: const [
                  Text('ProTip: Use arrow keys to navigate.', style: TextStyle(color: AppTheme.textMedium, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandAction {
  final IconData icon;
  final String label;
  final Function(WidgetRef, BuildContext) onExecute;

  _CommandAction({required this.icon, required this.label, required this.onExecute});
}

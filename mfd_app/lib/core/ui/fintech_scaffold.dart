import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/core/ui/fintech_sidebar.dart';
import 'package:mfd_app/core/ui/command_palette.dart';

class FinTechScaffold extends StatelessWidget {
  final Widget child;

  const FinTechScaffold({super.key, required this.child});

  void _openCommandPalette(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const CommandPalette(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();

    // Keyboard Shortcut Wrapper
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () => _openCommandPalette(context), // Cmd+K (Mac)
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () => _openCommandPalette(context), // Ctrl+K (Windows)
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.voidBlack,
          body: Row(
            children: [
              FinTechSidebar(currentRoute: currentRoute),
              Expanded(
                child: Column(
                  children: [
                    // A. Command Header
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppTheme.borderGrey)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.home_filled, size: 16, color: AppTheme.textMedium),
                          const SizedBox(width: 8),
                          const Text('/', style: TextStyle(color: AppTheme.textLow)),
                          const SizedBox(width: 8),
                          Text(
                            _getRouteName(currentRoute),
                            style: const TextStyle(color: AppTheme.textHigh, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          
                          // Interactive Command Bar
                          GestureDetector(
                            onTap: () => _openCommandPalette(context),
                            child: Container(
                              width: 320,
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.commandGrey,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderGrey),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, size: 16, color: AppTheme.textMedium),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Type a command...', 
                                      style: TextStyle(color: AppTheme.textLow, fontSize: 13, fontFamily: 'JetBrains Mono'),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Cmd K', style: TextStyle(color: AppTheme.textLow, fontSize: 10)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 24),
                          IconButton(onPressed: (){}, icon: const Icon(Icons.notifications_none, color: AppTheme.textMedium)),
                        ],
                      ),
                    ),

                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRouteName(String route) {
    if (route.contains('dashboard')) return 'Cockpit';
    if (route.contains('settings')) return 'System Config';
    if (route.contains('onboarding')) return 'Initialization';
    return 'Unknown Sector';
  }
}

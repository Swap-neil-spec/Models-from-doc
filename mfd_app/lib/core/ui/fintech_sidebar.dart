import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mfd_app/core/theme/app_theme.dart';

class FinTechSidebar extends StatelessWidget {
  final String currentRoute;

  const FinTechSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Compact Rail
      color: AppTheme.voidBlack,
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Brand Icon
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppTheme.electricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.electricBlue.withOpacity(0.3)),
            ),
            child: const Icon(Icons.hub, color: AppTheme.electricBlue),
          ),
          const SizedBox(height: 48),

          // Nav Items
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Cockpit',
            isActive: currentRoute == '/dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          // _NavItem(
          //   icon: Icons.show_chart,
          //   label: 'Forecast',
          //   isActive: currentRoute == '/forecast',
          //   onTap: () => context.go('/forecast'),
          // ),
          _NavItem(
            icon: Icons.people_outline,
            label: 'Team',
            isActive: currentRoute == '/team',
            onTap: () {}, // TODO
          ),
          
          const Spacer(),
          
          // User
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isActive: currentRoute == '/settings',
            onTap: () => context.go('/settings'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.commandGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: AppTheme.borderGrey) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.textHigh : AppTheme.textLow,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppTheme.textHigh : AppTheme.textLow,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

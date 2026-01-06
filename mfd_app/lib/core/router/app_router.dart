import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/features/extraction/presentation/views/upload_screen.dart';
import 'package:mfd_app/features/forecasting/presentation/views/dashboard_screen.dart';
import 'package:mfd_app/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:mfd_app/features/home/presentation/views/home_screen.dart';
import 'package:mfd_app/features/auth/presentation/views/login_screen.dart';
import 'package:mfd_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mfd_app/features/onboarding/domain/entities/onboarding_goal.dart';
import 'package:mfd_app/core/ui/fintech_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthStateNotifier(ref), // Triggers redirect on state change
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/onboarding'; // Or /dashboard if already onboarded

      return null;
    },
    routes: [
      // Public / Setup Routes (No Sidebar)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authenticated Shell (Sidebar + Command Bar)
      ShellRoute(
        builder: (context, state, child) {
          return FinTechScaffold(child: child);
        },
        routes: [
           GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(),
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) {
              final goal = state.extra as OnboardingGoal?;
              return UploadScreen(goal: goal);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Settings Placeholder'))), // Temp
          ),
          GoRoute(
            path: '/team',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Team Placeholder'))), // Temp
          ),
        ],
      ),
      
      // Redirect Root to Dashboard (or Login)
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
    ],
  );
});

// Helper to notify router of riverpod state changes
class _AuthStateNotifier extends ChangeNotifier {
  final Ref _ref;
  _AuthStateNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }
}

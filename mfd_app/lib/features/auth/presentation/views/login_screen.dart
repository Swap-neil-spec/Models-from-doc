
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/core/ui/glass_container.dart';
import 'package:mfd_app/features/auth/presentation/controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_isSignUp) {
      await ref.read(authControllerProvider.notifier).signUp(email, password);
    } else {
      await ref.read(authControllerProvider.notifier).signIn(email, password);
    }

    if (mounted) {
       final authState = ref.read(authControllerProvider);
       if (authState.status == AuthStatus.authenticated) {
         GoRouter.of(context).go('/onboarding');
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
               Color(0xFF0F172A), // Deep Blue
               Color(0xFF1E293B), // Slate
               Color(0xFF0F172A), // Deep Blue Loop
             ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  const Icon(Icons.area_chart, size: 64, color: AppTheme.emeraldGreen)
                      .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  
                  AnimatedSwitcher(
                    duration: 300.ms,
                    child: Text(
                      _isSignUp ? 'Create Account' : 'Welcome Back',
                      key: ValueKey<bool>(_isSignUp),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ).animate().fade().slideY(begin: 0.3, duration: 600.ms),
                  
                  const SizedBox(height: 8),
                  
                  AnimatedSwitcher(
                    duration: 300.ms,
                    child: Text(
                      _isSignUp ? 'Start your financial journey.' : 'Sign in to your forecasting workspace.',
                      key: ValueKey<bool>(_isSignUp),
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ).animate().fade(delay: 200.ms),

                  const SizedBox(height: 48),

                  // Login Form (Glass)
                  GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(label: 'Email', icon: Icons.email_outlined, controller: _emailController),
                        const SizedBox(height: 16),
                        _buildTextField(label: 'Password', icon: Icons.lock_outline,  isPassword: true, controller: _passwordController),
                        const SizedBox(height: 24),
                        
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.emeraldGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : Text(_isSignUp ? 'Create Account' : 'Sign In', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp ? 'Already have an account? Sign In' : 'Don\'t have an account? Sign Up',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 32),
                  
                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Colors.white54))),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ).animate().fade(delay: 600.ms),

                  const SizedBox(height: 32),

                  // Social Login (Simulated)
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ).animate().fade(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.emeraldGreen)),
      ),
    );
  }
}

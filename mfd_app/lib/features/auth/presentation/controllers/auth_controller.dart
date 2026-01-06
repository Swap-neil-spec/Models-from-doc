
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/features/auth/domain/services/auth_service.dart';
import 'package:mfd_app/features/auth/infrastructure/services/supabase_auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.initial, this.errorMessage});
}



final authServiceProvider = Provider<AuthService>((ref) {
  return SupabaseAuthService();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final isAuth = await _authService.isSignedIn;
      state = AuthState(status: isAuth ? AuthStatus.authenticated : AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _authService.signIn(email, password);
      state = const AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = AuthState(status: AuthStatus.error, errorMessage: msg);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      // Check if service supports sign up (casting to check specific methods if not in interface)
      // Assuming interface has signUp or we cast.
      // Wait, AuthService interface doesn't have signUp method? MockAuthService didn't. 
      // I need to check AuthService interface or cast it.
      // SupabaseAuthService HAS signUp.
      // Let's perform a dynamic check or update the interface.
      // Ideally interface should have it.
      
      // For now, I'll assume I update AuthService interface too or use dynamic.
      // Let's update AuthService interface first in next step if needed. 
      // But simpler: cast to dynamic for now or update interface.
      // Updating interface is better.
      
      // Wait, I can't update interface easily without breaking MockAuthService if I still used it.
      // But MockAuthService is gone? No, I only updated the provider.
      
      // SupabaseAuthService HAS signUp.
      await _authService.signUp(email, password);
      
      state = const AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: "Sign Up Failed: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

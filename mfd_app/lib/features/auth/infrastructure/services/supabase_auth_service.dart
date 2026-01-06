
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mfd_app/features/auth/domain/services/auth_service.dart' as domain;

class SupabaseAuthService implements domain.AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  @override
  Future<bool> get isSignedIn async {
    return _auth.currentUser != null;
  }

  @override
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email, 
        password: password
      );
      return response.user != null;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Login Failed: ${e.toString()}');
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final response = await _auth.signUp(
        email: email, 
        password: password
      );
      return response.user != null;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign Up Failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

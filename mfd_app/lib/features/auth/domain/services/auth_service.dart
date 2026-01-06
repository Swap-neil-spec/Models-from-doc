
import 'dart:async';

abstract class AuthService {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String email, String password);
  Future<void> signOut();
  Future<bool> get isSignedIn;
}

class MockAuthService implements AuthService {
  bool _signedIn = false;

  @override
  Future<bool> get isSignedIn async {
    // Simulate check delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _signedIn;
  }

  @override
  Future<bool> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    _signedIn = true;
    return true;
  }

  @override
  Future<bool> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    _signedIn = true;
    return true;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _signedIn = false;
  }
}

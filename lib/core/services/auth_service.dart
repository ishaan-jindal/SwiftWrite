import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  StreamSubscription<User?>? _authSubscription;

  AuthService() {
    _user = _auth.currentUser;
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
    });
  }

  void dispose() {
    _authSubscription?.cancel();
  }

  User? get currentUser => _user;
  bool get isSignedIn => currentUser != null;
  String? get email => currentUser?.email;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String explainAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No account was found for that email address.';
        case 'wrong-password':
          return 'The password is incorrect.';
        case 'email-already-in-use':
          return 'An account already exists for that email address.';
        case 'weak-password':
          return 'Use a stronger password.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    return error.toString();
  }
}

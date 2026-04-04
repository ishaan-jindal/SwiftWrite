import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rxn<User> _user = Rxn<User>();
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _user.value = _auth.currentUser;
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user.value = user;
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  User? get currentUser => _user.value;
  Rxn<User> get userRx => _user;
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

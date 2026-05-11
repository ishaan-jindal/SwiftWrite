import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:writer/core/services/auth_service.dart';
import 'package:writer/core/services/cloud_sync_service.dart';
import 'package:writer/core/services/firebase_service.dart';
import 'package:writer/injection/dependency_injection.dart';
import 'package:writer/features/auth/bloc/auth_state.dart';
import 'package:writer/features/notes/bloc/note_bloc.dart';
import 'package:writer/features/notes/bloc/note_event.dart';

@injectable
class AuthBloc extends Cubit<AuthState> {
  AuthBloc()
    : super(
        const AuthState(isPreparing: false, isSignedIn: false, email: null),
      ) {
    _init();
  }

  StreamSubscription<User?>? _authSub;

  Future<void> _init() async {
    if (getIt.isRegistered<AuthService>()) {
      final svc = getIt.get<AuthService>();
      emit(state.copyWith(isSignedIn: svc.isSignedIn, email: svc.email));
    }

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      emit(state.copyWith(isSignedIn: user != null, email: user?.email));
    });
  }

  Future<bool> ensureAuthInitialized() async {
    if (getIt.isRegistered<AuthService>()) return true;

    emit(state.copyWith(isPreparing: true));
    final initialized = await FirebaseService.initializeFromEnv();
    if (!initialized) {
      emit(state.copyWith(isPreparing: false));
      return false;
    }

    // Register services now that Firebase is initialized
    if (!getIt.isRegistered<AuthService>()) {
      getIt.registerLazySingleton<AuthService>(() => AuthService());
    }
    if (!getIt.isRegistered<CloudSyncService>()) {
      getIt.registerLazySingleton<CloudSyncService>(() => CloudSyncService());
    }

    final svc = getIt.get<AuthService>();
    emit(
      state.copyWith(
        isPreparing: false,
        isSignedIn: svc.isSignedIn,
        email: svc.email,
      ),
    );
    return true;
  }

  Future<void> signIn(String email, String password) async {
    if (!getIt.isRegistered<AuthService>()) {
      final ok = await ensureAuthInitialized();
      if (!ok) throw Exception('Firebase init failed');
    }

    final svc = getIt.get<AuthService>();
    await svc.signInWithEmailAndPassword(email: email, password: password);

    if (getIt.isRegistered<NoteBloc>()) {
      getIt.get<NoteBloc>().add(const NoteSyncRequested());
    }
  }

  Future<void> register(String email, String password) async {
    if (!getIt.isRegistered<AuthService>()) {
      final ok = await ensureAuthInitialized();
      if (!ok) throw Exception('Firebase init failed');
    }

    final svc = getIt.get<AuthService>();
    await svc.registerWithEmailAndPassword(email: email, password: password);

    if (getIt.isRegistered<NoteBloc>()) {
      getIt.get<NoteBloc>().add(const NoteSyncRequested());
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (!getIt.isRegistered<AuthService>()) {
      final ok = await ensureAuthInitialized();
      if (!ok) throw Exception('Firebase init failed');
    }

    final svc = getIt.get<AuthService>();
    await svc.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    if (!getIt.isRegistered<AuthService>()) return;
    final svc = getIt.get<AuthService>();
    await svc.signOut();
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}

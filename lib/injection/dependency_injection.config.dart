// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dependency_injection.dart';

extension GetItInjectableX on GetIt {
  void init({String? environment}) {
    if (!isRegistered<DatabaseService>()) {
      registerLazySingleton<DatabaseService>(() => DatabaseService());
    }

    if (!isRegistered<ThemeService>()) {
      registerLazySingleton<ThemeService>(() => ThemeService());
    }

    if (!isRegistered<NoteRepository>()) {
      registerLazySingleton<NoteRepository>(
        () => NoteRepository(get<DatabaseService>()),
      );
    }

    if (!isRegistered<NoteBloc>()) {
      registerFactory<NoteBloc>(() => NoteBloc(get<NoteRepository>()));
    }

    if (!isRegistered<SettingsBloc>()) {
      registerFactory<SettingsBloc>(() => SettingsBloc(get<ThemeService>()));
    }

    if (!isRegistered<AuthBloc>()) {
      registerFactory<AuthBloc>(() => AuthBloc());
    }

    if (!isRegistered<CodeExecutionBloc>()) {
      registerFactory<CodeExecutionBloc>(() => CodeExecutionBloc());
    }
  }
}

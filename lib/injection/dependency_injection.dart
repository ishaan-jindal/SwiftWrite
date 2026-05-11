import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:writer/core/services/auth_service.dart';
import 'package:writer/core/services/cloud_sync_service.dart';
import 'package:writer/core/services/database_service.dart';
import 'package:writer/core/services/theme_service.dart';
import 'package:writer/features/auth/bloc/auth_bloc.dart';
import 'package:writer/features/code_execution/bloc/code_execution_bloc.dart';
import 'package:writer/features/notes/bloc/note_bloc.dart';
import 'package:writer/features/notes/repository/note_repository.dart';
import 'package:writer/features/settings/bloc/settings_bloc.dart';

part 'dependency_injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(initializerName: 'init')
Future<void> configureDependencies({required bool firebaseReady}) async {
  getIt.init();

  if (firebaseReady) {
    if (!getIt.isRegistered<AuthService>()) {
      getIt.registerLazySingleton<AuthService>(() => AuthService());
    }
    if (!getIt.isRegistered<CloudSyncService>()) {
      getIt.registerLazySingleton<CloudSyncService>(() => CloudSyncService());
    }
  }
}

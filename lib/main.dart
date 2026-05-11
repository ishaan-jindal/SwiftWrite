import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:writer/app/app.dart';
import 'package:writer/injection/dependency_injection.dart';
import 'package:writer/features/code_execution/bloc/code_execution_bloc.dart';
import 'package:writer/features/notes/bloc/note_bloc.dart';
import 'package:writer/features/auth/bloc/auth_bloc.dart';
import 'package:writer/features/settings/bloc/settings_bloc.dart';
import 'package:writer/features/notes/models/note.dart';
import 'package:writer/core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('note_sync');

  final firebaseReady = await FirebaseService.initializeFromEnv();

  await configureDependencies(firebaseReady: firebaseReady);

  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SettingsBloc>()),
        BlocProvider(create: (_) => getIt<NoteBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<CodeExecutionBloc>()),
      ],
      child: const App(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:writer/app/app.dart';
import 'package:writer/data/models/note.dart';
import 'package:writer/data/services/auth_service.dart';
import 'package:writer/data/services/cloud_sync_service.dart';
import 'package:writer/data/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('note_sync');

  final firebaseReady = await FirebaseService.initializeFromEnv();
  if (firebaseReady) {
    Get.put(AuthService(), permanent: true);
    Get.put(CloudSyncService(), permanent: true);
  }

  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');
  runApp(App());
}

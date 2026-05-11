import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  const FirebaseService._();

  static Future<bool> initializeFromEnv() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    final FirebaseOptions? options = _optionsForCurrentPlatform();
    if (options == null) {
      debugPrint(
        'Firebase skipped: missing required env vars for the active platform.',
      );
      return false;
    }

    await Firebase.initializeApp(options: options);
    return true;
  }

  static FirebaseOptions? _optionsForCurrentPlatform() {
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
    final storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET'];
    final authDomain = dotenv.env['FIREBASE_AUTH_DOMAIN'];

    if (kIsWeb) {
      final apiKey = dotenv.env['FIREBASE_WEB_API_KEY'];
      final appId = dotenv.env['FIREBASE_WEB_APP_ID'];

      if (_isMissing(apiKey, appId, projectId, messagingSenderId)) {
        return null;
      }

      return FirebaseOptions(
        apiKey: apiKey!,
        appId: appId!,
        messagingSenderId: messagingSenderId!,
        projectId: projectId!,
        authDomain: authDomain,
        storageBucket: storageBucket,
      );
    }

    final apiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'];
    final appId = dotenv.env['FIREBASE_ANDROID_APP_ID'];

    if (_isMissing(apiKey, appId, projectId, messagingSenderId)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey!,
      appId: appId!,
      messagingSenderId: messagingSenderId!,
      projectId: projectId!,
      storageBucket: storageBucket,
    );
  }

  static bool _isMissing(String? a, String? b, String? c, String? d) {
    return a == null ||
        a.isEmpty ||
        b == null ||
        b.isEmpty ||
        c == null ||
        c.isEmpty ||
        d == null ||
        d.isEmpty;
  }
}

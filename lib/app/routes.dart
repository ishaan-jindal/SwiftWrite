import 'package:flutter/material.dart';
import 'package:writer/features/auth/pages/auth_screen.dart';
import 'package:writer/features/code_execution/pages/code_output_view.dart';
import 'package:writer/features/notes/pages/home_screen.dart';
import 'package:writer/features/settings/pages/settings_screen.dart';
import 'package:writer/features/notes/pages/writer_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case '/auth':
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
          settings: settings,
        );
      case '/writer':
        return MaterialPageRoute(
          builder: (_) => const WriterScreen(),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case '/code-output':
        return MaterialPageRoute(
          builder: (_) => const CodeOutputView(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
          settings: settings,
        );
    }
  }
}

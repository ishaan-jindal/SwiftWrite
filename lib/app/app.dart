import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writer/app/routes.dart';
import 'package:writer/core/services/navigation_service.dart';
import 'package:writer/features/settings/bloc/settings_bloc.dart';
import 'package:writer/features/settings/bloc/settings_state.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'SwiftWrite',
          theme: state.lightTheme,
          darkTheme: state.darkTheme,
          themeMode: state.themeMode,
          initialRoute: '/',
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writer/data/services/theme_service.dart';
import 'package:writer/core/constants/app_routes.dart';
import 'package:writer/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.isRegistered<ThemeService>()
        ? Get.find<ThemeService>()
        : Get.put(ThemeService(), permanent: true);

    final ThemeData initialLightTheme = themeService.isFallModeActive
        ? AppTheme.lightThemeFall
        : AppTheme.lightTheme;

    final ThemeData initialDarkTheme = themeService.isFallModeActive
        ? AppTheme.darkThemeFall
        : AppTheme.darkTheme;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwiftWrite',
      theme: initialLightTheme,
      darkTheme: initialDarkTheme,
      themeMode: themeService.activeThemeMode,
      initialRoute: '/',
      getPages: AppRoutes.routes,
    );
  }
}

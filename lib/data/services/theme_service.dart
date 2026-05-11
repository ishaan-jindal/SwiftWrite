import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:writer/core/theme/app_theme.dart';

class ThemeService {
  final _box = Hive.box('settings');
  final _isDarkModeKey = 'isDarkModePreferred';
  final _isFallModeActiveKey = 'isFallModeActive';

  ThemeData _getThemeData(bool isDarkMode, bool isFallActive) {
    if (isFallActive) {
      return isDarkMode ? AppTheme.darkThemeFall : AppTheme.lightThemeFall;
    } else {
      return isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
  }

  ThemeMode _getThemeMode(bool isDarkMode) {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkModePreferred {
    // Default to false (light mode) if no preference is saved
    return _box.get(_isDarkModeKey, defaultValue: false);
  }

  bool get isFallModeActive {
    return _box.get(_isFallModeActiveKey, defaultValue: false);
  }

  ThemeData get activeThemeData {
    return _getThemeData(isDarkModePreferred, isFallModeActive);
  }

  ThemeMode get activeThemeMode {
    return _getThemeMode(isDarkModePreferred);
  }

  void _saveDarkModePreference(bool isDarkMode) {
    _box.put(_isDarkModeKey, isDarkMode);
  }

  void _saveFallModeState(bool isActive) {
    _box.put(_isFallModeActiveKey, isActive);
  }

  void switchTheme() {
    bool nextIsDarkMode = !isDarkModePreferred;
    ThemeData nextThemeData = _getThemeData(nextIsDarkMode, isFallModeActive);
    ThemeMode nextThemeMode = _getThemeMode(nextIsDarkMode);

    Get.changeTheme(nextThemeData);
    Get.changeThemeMode(nextThemeMode);
    _saveDarkModePreference(nextIsDarkMode);
  }

  void toggleFallTheme(BuildContext context) {
    bool currentFallState = isFallModeActive;
    bool nextFallState = !currentFallState;

    _saveFallModeState(nextFallState);

    ThemeData targetThemeData = _getThemeData(
      isDarkModePreferred,
      nextFallState,
    );
    ThemeMode targetThemeMode = activeThemeMode;

    Get.changeTheme(targetThemeData);
    Get.changeThemeMode(targetThemeMode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("Forcing app update after fall toggle...");
      Get.forceAppUpdate();
    });

    final message = nextFallState
        ? "Autumn theme activated! 🍁"
        : "Original theme restored.";

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

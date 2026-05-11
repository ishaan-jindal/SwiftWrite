import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:writer/core/theme/app_theme.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.isDarkModePreferred,
    required this.isFallModeActive,
  });

  final bool isDarkModePreferred;
  final bool isFallModeActive;

  ThemeData get lightTheme {
    return isFallModeActive ? AppTheme.lightThemeFall : AppTheme.lightTheme;
  }

  ThemeData get darkTheme {
    return isFallModeActive ? AppTheme.darkThemeFall : AppTheme.darkTheme;
  }

  ThemeMode get themeMode {
    return isDarkModePreferred ? ThemeMode.dark : ThemeMode.light;
  }

  SettingsState copyWith({bool? isDarkModePreferred, bool? isFallModeActive}) {
    return SettingsState(
      isDarkModePreferred: isDarkModePreferred ?? this.isDarkModePreferred,
      isFallModeActive: isFallModeActive ?? this.isFallModeActive,
    );
  }

  @override
  List<Object> get props => [isDarkModePreferred, isFallModeActive];
}

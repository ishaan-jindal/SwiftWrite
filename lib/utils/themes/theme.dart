import 'package:flutter/material.dart';
import 'package:writer/utils/constants/app_colors.dart';

class AppTheme {
  const AppTheme._();

  // --- Original Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColorLight,
    scaffoldBackgroundColor: AppColors.backgroundColorLight,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColorLight,
      circularTrackColor: AppColors.secondaryColorLight,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textColorLight,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textColorLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textColorLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textColorLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.textColorLight, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textColorLight, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textColorLight, fontSize: 12),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColorLight,
      secondary: AppColors.secondaryColorLight,
      surface: AppColors.cardColorLight,
      error: AppColors.destructiveColorLight,
      onError: AppColors.onErrorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColorLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textColorLight),
      titleTextStyle: TextStyle(
        color: AppColors.textColorLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardColorLight,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColorLight,
      foregroundColor: AppColors.backgroundColorLight,
    ),
    dividerColor: AppColors.dividerColorLight,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardColorDark, // Using dark card for contrast
      contentTextStyle: const TextStyle(color: AppColors.textColorDark),
      actionTextColor: AppColors.primaryColorLight,
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardColorLight,
      labelStyle: const TextStyle(
        color: AppColors.textColorLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: AppColors.primaryColorLight,
      secondaryLabelStyle: const TextStyle(
        color: AppColors.backgroundColorLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.dividerColorLight, // Adjusted side color
          width: 1, // Adjusted width
        ),
      ),
      deleteIconColor: AppColors.textColorLight,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardColorLight,
      hintStyle: TextStyle(
        color: AppColors.textColorLight.withValues(alpha: 0.6),
      ), // Adjusted opacity
      prefixIconColor: AppColors.textColorLight,
      suffixIconColor: AppColors.textColorLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textColorLight),
  );

  // --- Original Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColorDark,
    scaffoldBackgroundColor: AppColors.backgroundColorDark,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColorDark,
      circularTrackColor: AppColors.secondaryColorDark,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textColorDark,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textColorDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textColorDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textColorDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.textColorDark, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textColorDark, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textColorDark, fontSize: 12),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColorDark,
      secondary: AppColors.secondaryColorDark,
      surface: AppColors.cardColorDark,
      error: AppColors.destructiveColorDark,
      onError: AppColors.onErrorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColorDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textColorDark),
      titleTextStyle: TextStyle(
        color: AppColors.textColorDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardColorDark,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColorDark,
      foregroundColor: AppColors.backgroundColorDark,
    ),
    dividerColor: AppColors.dividerColorDark,
    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          AppColors.cardColorLight, // Using light card for contrast
      contentTextStyle: const TextStyle(color: AppColors.textColorLight),
      actionTextColor: AppColors.primaryColorDark, // Adjusted action color
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardColorDark,
      labelStyle: const TextStyle(
        color: AppColors.textColorDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: AppColors.primaryColorDark,
      secondaryLabelStyle: const TextStyle(
        color: AppColors.backgroundColorDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.dividerColorDark, // Adjusted side color
          width: 1, // Adjusted width
        ),
      ),
      deleteIconColor: AppColors.textColorDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardColorDark,
      hintStyle: TextStyle(
        color: AppColors.textColorDark.withValues(alpha: 0.6),
      ), // Adjusted opacity
      prefixIconColor: AppColors.textColorDark,
      suffixIconColor: AppColors.textColorDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textColorDark),
  );

  // --- Fall Light Theme ---
  static final ThemeData lightThemeFall = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColorFallLight,
    scaffoldBackgroundColor: AppColors.backgroundColorFallLight,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColorFallLight,
      circularTrackColor: AppColors.secondaryColorFallLight,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textColorFallLight,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textColorFallLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textColorFallLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textColorFallLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.textColorFallLight, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textColorFallLight, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textColorFallLight, fontSize: 12),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColorFallLight,
      secondary: AppColors.secondaryColorFallLight,
      surface: AppColors.cardColorFallLight,
      error: AppColors.destructiveColorFallLight,
      onError: AppColors.onErrorColor, // Reusing onErrorColor for consistency
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColorFallLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textColorFallLight),
      titleTextStyle: TextStyle(
        color: AppColors.textColorFallLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardColorFallLight,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColorFallLight,
      foregroundColor: AppColors.backgroundColorFallLight, // Contrast color
    ),
    dividerColor: AppColors.dividerColorFallLight,
    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          AppColors.cardColorFallDark, // Using dark card for contrast
      contentTextStyle: const TextStyle(color: AppColors.textColorFallDark),
      actionTextColor: AppColors.primaryColorFallLight,
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardColorFallLight,
      labelStyle: const TextStyle(
        color: AppColors.textColorFallLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: AppColors.primaryColorFallLight,
      secondaryLabelStyle: const TextStyle(
        color: AppColors.backgroundColorFallLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.dividerColorFallLight, // Fall divider color
          width: 1,
        ),
      ),
      deleteIconColor: AppColors.textColorFallLight,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardColorFallLight,
      hintStyle: TextStyle(
        color: AppColors.textColorFallLight.withValues(alpha: 0.6),
      ),
      prefixIconColor: AppColors.textColorFallLight,
      suffixIconColor: AppColors.textColorFallLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textColorFallLight),
  );

  // --- Fall Dark Theme ---
  static final ThemeData darkThemeFall = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColorFallDark,
    scaffoldBackgroundColor: AppColors.backgroundColorFallDark,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColorFallDark,
      circularTrackColor: AppColors.secondaryColorFallDark,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textColorFallDark,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textColorFallDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textColorFallDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textColorFallDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.textColorFallDark, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textColorFallDark, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textColorFallDark, fontSize: 12),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColorFallDark,
      secondary: AppColors.secondaryColorFallDark,
      surface: AppColors.cardColorFallDark,
      error: AppColors.destructiveColorFallDark,
      onError: AppColors.onErrorColor, // Reusing onErrorColor
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColorFallDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textColorFallDark),
      titleTextStyle: TextStyle(
        color: AppColors.textColorFallDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardColorFallDark,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColorFallDark,
      foregroundColor: AppColors.backgroundColorFallDark, // Contrast color
    ),
    dividerColor: AppColors.dividerColorFallDark,
    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          AppColors.cardColorFallLight, // Using light card for contrast
      contentTextStyle: const TextStyle(color: AppColors.textColorFallLight),
      actionTextColor: AppColors.primaryColorFallDark,
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardColorFallDark,
      labelStyle: const TextStyle(
        color: AppColors.textColorFallDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: AppColors.primaryColorFallDark,
      secondaryLabelStyle: const TextStyle(
        color: AppColors.backgroundColorFallDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.dividerColorFallDark, // Fall divider color
          width: 1,
        ),
      ),
      deleteIconColor: AppColors.textColorFallDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardColorFallDark,
      hintStyle: TextStyle(
        color: AppColors.textColorFallDark.withValues(alpha: 0.6),
      ),
      prefixIconColor: AppColors.textColorFallDark,
      suffixIconColor: AppColors.textColorFallDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textColorFallDark),
  );
}

// lib/utils/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // --- Original Light Theme ---
  static const Color primaryColorLight = Color(0xFF458588); // Blue
  static const Color secondaryColorLight = Color(0xFF98971A); // Green
  static const Color backgroundColorLight = Color(0xFFFBF1C7); // Background
  static const Color textColorLight = Color(0xFF3C3836); // Dark Gray
  static const Color cardColorLight = Color(0xFFEBDBB2); // Lighter Background
  static const Color destructiveColorLight = Color(0xFF9D0006); // Red
  static const Color dividerColorLight = Color(0xFFD5C4A1);

  // --- Original Dark Theme ---
  static const Color primaryColorDark = Color(0xFF83A598); // Blue
  static const Color secondaryColorDark = Color(0xFFB8BB26); // Green
  static const Color backgroundColorDark = Color(0xFF282828); // Background
  static const Color textColorDark = Color(0xFFEBDBB2); // Foreground
  static const Color cardColorDark = Color(0xFF3C3836); // Lighter Background
  static const Color destructiveColorDark = Color(0xFFCC241D); // Red
  static const Color dividerColorDark = Color(0xFF504945);

  // --- Fall Light Theme ---
  static const Color primaryColorFallLight = Color(0xFFD65D0E); // Orange
  static const Color secondaryColorFallLight = Color(0xFF9D6343); // Brown
  static const Color backgroundColorFallLight = Color(
    0xFFFDF4E1,
  ); // Creamy Background
  static const Color textColorFallLight = Color(0xFF504945); // Dark Brown/Gray
  static const Color cardColorFallLight = Color(0xFFF5E5C0); // Lighter Cream
  static const Color destructiveColorFallLight = Color(
    0xFFCC241D,
  ); // Red (can reuse dark's red)
  static const Color dividerColorFallLight = Color(0xFFB5A481); // Muted Brown

  // --- Fall Dark Theme ---
  static const Color primaryColorFallDark = Color(
    0xFFFE8019,
  ); // Brighter Orange
  static const Color secondaryColorFallDark = Color(
    0xFFA8775A,
  ); // Lighter Brown
  static const Color backgroundColorFallDark = Color(
    0xFF32302F,
  ); // Dark Brownish Gray
  static const Color textColorFallDark = Color(0xFFD5C4A1); // Light Beige
  static const Color cardColorFallDark = Color(
    0xFF4A4540,
  ); // Medium Brownish Gray
  static const Color destructiveColorFallDark = Color(
    0xFFFB4934,
  ); // Brighter Red
  static const Color dividerColorFallDark = Color(0xFF665C54); // Muted Gray

  // --- Shared ---
  static const Color onErrorColor = Color(
    0xFFFBF1C7,
  ); // Consistent across themes for contrast
}

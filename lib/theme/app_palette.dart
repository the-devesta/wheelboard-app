import 'package:flutter/material.dart';

/// Canonical Wheelboard colour palette (the de-facto design system used across
/// the modern screens — #F36969 / Poppins).
///
/// New screens should reference [AppPalette] instead of redeclaring per-screen
/// `const _primary = …` tokens. The legacy `constants/apps_colors.dart`
/// `AppColors` is kept only for older widgets and should not be used in new code.
class AppPalette {
  AppPalette._();

  // Brand
  static const primary = Color(0xFFF36969);
  static const primaryDark = Color(0xFFE84545); // gradient end / pressed
  static const primaryLight = Color(0xFFFFF1F1); // tinted backgrounds

  // Surfaces
  static const bg = Color(0xFFF9FAFB);
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB);

  // Text
  static const textDark = Color(0xFF111827);
  static const textMid = Color(0xFF374151);
  static const textGrey = Color(0xFF6B7280);
  static const textFaint = Color(0xFF9CA3AF);

  // Semantic / accents
  static const green = Color(0xFF22C55E);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const danger = Color(0xFFEF4444);
  static const purple = Color(0xFF7C3AED);

  // Soft backgrounds for status surfaces
  static const greenBg = Color(0xFFF0FDF4);
  static const amberBg = Color(0xFFFFFBEB);
  static const blueBg = Color(0xFFEFF6FF);
  static const dangerBg = Color(0xFFFEF2F2);

  /// Brand gradient used on headers/heroes.
  static const brandGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

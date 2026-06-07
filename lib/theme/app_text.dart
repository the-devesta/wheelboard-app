import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Poppins-based typography scale. Use `AppText.title`, `AppText.body`, etc.
/// instead of repeating `GoogleFonts.poppins(fontSize: …, fontWeight: …)`.
class AppText {
  AppText._();

  static TextStyle _p(
    double size,
    FontWeight weight, {
    Color color = AppPalette.textDark,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Headings
  static TextStyle get h1 => _p(20, FontWeight.w700);
  static TextStyle get h2 => _p(18, FontWeight.w700);
  static TextStyle get h3 => _p(16, FontWeight.w700);

  // Titles / body
  static TextStyle get title => _p(15, FontWeight.w700);
  static TextStyle get subtitle => _p(14, FontWeight.w600);
  static TextStyle get body => _p(14, FontWeight.w400, color: AppPalette.textMid, height: 1.45);
  static TextStyle get bodySm => _p(13, FontWeight.w400, color: AppPalette.textMid, height: 1.45);

  // Supporting
  static TextStyle get label => _p(12, FontWeight.w500, color: AppPalette.textGrey);
  static TextStyle get caption => _p(11, FontWeight.w400, color: AppPalette.textGrey);
  static TextStyle get micro => _p(10, FontWeight.w600, color: AppPalette.textGrey);

  /// Helper to recolour any base style inline: `AppText.title.on(Colors.white)`.
}

extension AppTextColorX on TextStyle {
  TextStyle on(Color color) => copyWith(color: color);
  TextStyle weight(FontWeight w) => copyWith(fontWeight: w);
  TextStyle size(double s) => copyWith(fontSize: s);
}

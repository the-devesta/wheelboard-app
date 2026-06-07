import 'package:flutter/material.dart';

/// Spacing scale (4-pt based) — use instead of ad-hoc `SizedBox(height: 14)`.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Common gap widgets (const, cheap to reuse).
  static const gapXs = SizedBox(height: xs, width: xs);
  static const gapSm = SizedBox(height: sm, width: sm);
  static const gapMd = SizedBox(height: md, width: md);
  static const gapLg = SizedBox(height: lg, width: lg);
  static const gapXl = SizedBox(height: xl, width: xl);

  static const vGapSm = SizedBox(height: sm);
  static const vGapMd = SizedBox(height: md);
  static const vGapLg = SizedBox(height: lg);
  static const vGapXl = SizedBox(height: xl);

  static const hGapSm = SizedBox(width: sm);
  static const hGapMd = SizedBox(width: md);
  static const hGapLg = SizedBox(width: lg);
}

/// Corner-radius scale.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double pill = 999;

  static BorderRadius all(double r) => BorderRadius.circular(r);
  static final rSm = BorderRadius.circular(sm);
  static final rMd = BorderRadius.circular(md);
  static final rLg = BorderRadius.circular(lg);
  static final rXl = BorderRadius.circular(xl);
  static final rPill = BorderRadius.circular(pill);
}

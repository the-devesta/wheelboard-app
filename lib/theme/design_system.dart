/// Wheelboard Design System — single import for the modern, professional UI
/// language used across the app.
///
/// ```dart
/// import 'package:wheelboard/theme/design_system.dart';
/// ```
///
/// Provides:
///  - [AppPalette]  — canonical colours (brand #F36969, surfaces, semantics)
///  - [AppSpacing]/[AppRadius] — 4-pt spacing scale + corner radii
///  - [AppText]     — Poppins typography scale (+ `.on()/.weight()/.size()`)
///  - [AppPrimaryButton]/[AppSecondaryButton]/[AppCard] — buttons + card
///  - [AppSheetScaffold] — standard modern bottom-sheet shell
///  - [AppLoading]/[AppEmptyState]/[AppErrorState]/[AppBanner] — UI states
///
/// New and redesigned screens should consume these instead of redeclaring
/// per-screen `const _primary = …` tokens or re-implementing empty/error
/// states and sheet headers.
library;

export 'app_palette.dart';
export 'app_spacing.dart';
export 'app_text.dart';
export 'widgets/app_buttons.dart';
export 'widgets/app_sheet.dart';
export 'widgets/app_states.dart';

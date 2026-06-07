import 'package:flutter/material.dart';

import '../app_palette.dart';
import '../app_spacing.dart';
import '../app_text.dart';

/// The standard modern bottom-sheet shell: rounded top, grab handle, an
/// icon+title header with a close button, and a scrollable body. Replaces the
/// per-sheet boilerplate that was duplicated across the app.
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => AppSheetScaffold(
///     icon: Iconsax.lock, title: 'Change Password', child: …),
/// );
/// ```
class AppSheetScaffold extends StatelessWidget {
  final IconData? icon;
  final String title;
  final Widget child;
  final double maxHeightFactor;
  final EdgeInsets bodyPadding;

  const AppSheetScaffold({
    super.key,
    this.icon,
    required this.title,
    required this.child,
    this.maxHeightFactor = 0.9,
    this.bodyPadding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * maxHeightFactor),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppPalette.border,
                  borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppPalette.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.rMd),
                    child: Icon(icon, size: 18, color: AppPalette.primary),
                  ),
                  AppSpacing.hGapSm,
                ],
                Expanded(child: Text(title, style: AppText.h2)),
                IconButton(
                  icon: const Icon(Icons.close, color: AppPalette.textGrey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
            ),
            const Divider(height: 1, color: AppPalette.border),
            Flexible(
              child: SingleChildScrollView(
                padding: bodyPadding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

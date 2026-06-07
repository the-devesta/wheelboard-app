import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../theme/design_system.dart';

/// Shared white header with back button + centred title (brand). Used by the
/// Calendar and Earnings screens.
class CalendarHeaderWidget extends StatelessWidget {
  final String? title;
  final bool showMenu;
  final VoidCallback? onMenuTap;

  const CalendarHeaderWidget({
    super.key,
    this.title,
    this.showMenu = true,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppPalette.card,
        border: Border(bottom: BorderSide(color: AppPalette.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Iconsax.arrow_left_2, color: AppPalette.primary),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title ?? 'My Calendar',
                  style: AppText.h2.on(AppPalette.primary),
                ),
              ),
            ),
            if (showMenu)
              IconButton(
                onPressed: onMenuTap ?? () {},
                icon: const Icon(Iconsax.refresh, color: AppPalette.primary),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

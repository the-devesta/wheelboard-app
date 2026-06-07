import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../app_palette.dart';
import '../app_spacing.dart';
import '../app_text.dart';

/// Centered loading indicator with an optional message.
class AppLoading extends StatelessWidget {
  final String? message;
  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppPalette.primary),
          if (message != null) ...[
            AppSpacing.vGapMd,
            Text(message!, style: AppText.bodySm, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Modern empty-state: tinted icon tile + title + subtitle + optional action.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon = Iconsax.box,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: AppPalette.primaryLight, borderRadius: AppRadius.rXl),
              child: Icon(icon, color: AppPalette.primary, size: 32),
            ),
            AppSpacing.vGapLg,
            Text(title,
                textAlign: TextAlign.center,
                style: AppText.h3.on(AppPalette.textGrey)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center, style: AppText.caption),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.vGapLg,
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
                ),
                child: Text(actionLabel!, style: AppText.subtitle.on(Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern error-state with a retry action.
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 44, color: AppPalette.primary),
            AppSpacing.vGapMd,
            Text(message, textAlign: TextAlign.center, style: AppText.bodySm),
            if (onRetry != null) ...[
              AppSpacing.vGapLg,
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
                ),
                child: Text(retryLabel, style: AppText.subtitle.on(Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline status banner (info / success / warning / error).
class AppBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color background;
  final Color borderColor;

  const AppBanner({
    super.key,
    required this.text,
    this.icon = Iconsax.info_circle,
    this.color = AppPalette.blue,
    this.background = AppPalette.blueBg,
    this.borderColor = const Color(0x333B82F6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: borderColor),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: color),
        AppSpacing.hGapSm,
        Expanded(child: Text(text, style: AppText.caption.on(color))),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../theme/design_system.dart';

/// Transaction row — brand design system. Credit/debit coloured amount.
class TransactionItemWidget extends StatelessWidget {
  final String date;
  final String companyName;
  final String amount;
  final bool isCredit;
  final double? opacity;

  const TransactionItemWidget({
    super.key,
    required this.date,
    required this.companyName,
    required this.amount,
    this.isCredit = true,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isCredit ? AppPalette.green : AppPalette.danger;
    return Opacity(
      opacity: opacity ?? 1.0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppPalette.card,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Icon(
                  isCredit ? Iconsax.arrow_down_1 : Iconsax.arrow_up_3,
                  size: 18,
                  color: accent),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(companyName,
                      style: AppText.subtitle.size(13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(date, style: AppText.caption),
                ],
              ),
            ),
            AppSpacing.hGapSm,
            Text('${isCredit ? '+' : '-'}$amount',
                style: AppText.subtitle.on(accent).size(15)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../theme/design_system.dart';

/// Shared status colour + badge for leads (list + detail).
class LeadStatusStyle {
  LeadStatusStyle._();

  static Color color(String status) {
    switch (status.toLowerCase()) {
      case 'converted':
        return AppPalette.green;
      case 'qualified':
        return AppPalette.purple;
      case 'contacted':
        return AppPalette.amber;
      case 'lost':
        return AppPalette.danger;
      case 'new':
      default:
        return AppPalette.blue;
    }
  }

  static Widget badge(String status) {
    final c = color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: AppRadius.rPill,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(status, style: AppText.micro.on(c).weight(FontWeight.w700)),
    );
  }
}

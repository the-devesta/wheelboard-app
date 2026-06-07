import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared status/priority badge styling for Issues (used by list + detail).
class IssueStatusStyle {
  IssueStatusStyle._();

  static const _green = Color(0xFF22C55E);
  static const _amber = Color(0xFFF59E0B);
  static const _blue = Color(0xFF3B82F6);
  static const _danger = Color(0xFFEF4444);
  static const _grey = Color(0xFF6B7280);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return _green;
      case 'in-process':
        return _amber;
      case 'open':
        return _blue;
      default:
        return _grey;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return _danger;
      case 'medium':
        return _amber;
      case 'low':
        return _green;
      default:
        return _grey;
    }
  }

  static Widget badge(String status) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(status,
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w700, color: c)),
    );
  }

  static Widget priorityPill(String priority) {
    final c = priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text('$priority priority',
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: c)),
      ]),
    );
  }
}

/// Single source of truth for Professional trip status → UI classification.
///
/// Mirrors `wheelboard-fe/src/lib/tripsTransform.ts` (`mapBackendStatus` +
/// `calculateProgress`) so the mobile app and the web frontend bucket and
/// progress every trip **identically**. All Professional screens must classify
/// trips through this mapper instead of redeclaring per-screen status string
/// sets.
library;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_palette.dart';

/// The three top-level buckets shown to professionals (web parity:
/// `Trip['status']` = 'Upcoming' | 'In-Process' | 'Completed').
enum TripBucket { upcoming, inProcess, completed }

extension TripBucketX on TripBucket {
  /// The exact label the web uses for the bucket.
  String get label {
    switch (this) {
      case TripBucket.upcoming:
        return 'Upcoming';
      case TripBucket.inProcess:
        return 'In-Process';
      case TripBucket.completed:
        return 'Completed';
    }
  }

  /// Accent colour used on cards / badges for this bucket.
  Color get color {
    switch (this) {
      case TripBucket.upcoming:
        return AppPalette.amber;
      case TripBucket.inProcess:
        return AppPalette.blue;
      case TripBucket.completed:
        return AppPalette.green;
    }
  }

  Color get softBg {
    switch (this) {
      case TripBucket.upcoming:
        return AppPalette.amberBg;
      case TripBucket.inProcess:
        return AppPalette.blueBg;
      case TripBucket.completed:
        return AppPalette.greenBg;
    }
  }

  /// Gradient used on the card header hero, matching the web status gradients
  /// (amber→orange, blue→indigo, emerald→green).
  LinearGradient get gradient {
    switch (this) {
      case TripBucket.upcoming:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case TripBucket.inProcess:
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case TripBucket.completed:
        return const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }
}

class TripStatusMapper {
  TripStatusMapper._();

  /// Mirror of web `mapBackendStatus`. Unknown statuses fall back to Upcoming.
  static TripBucket bucketOf(String backendStatus) {
    switch (backendStatus.toLowerCase().trim()) {
      case 'draft':
      case 'scheduled':
      case 'pending-lr-confirmation':
      case 'awaiting-lr-confirmation':
      case 'lr-confirmed':
        return TripBucket.upcoming;
      case 'en-route-to-pickup':
      case 'arrived-at-pickup':
      case 'in-progress':
      case 'arrived':
      case 'awaiting-pod':
        return TripBucket.inProcess;
      case 'pod-collected':
      case 'pod-verified':
      case 'completed':
      case 'cancelled':
        return TripBucket.completed;
      default:
        return TripBucket.upcoming;
    }
  }

  /// Mirror of web `calculateProgress` (0–100). The web map omits the two
  /// pickup-leg states (they fall through to 0); we fill them with interpolated
  /// values so an In-Process bar is never misleadingly empty — a pure visual
  /// improvement that does not affect any business rule or state transition.
  static int progressOf(String backendStatus) {
    final s = backendStatus.toLowerCase().trim();
    if (s == 'completed' || s == 'pod-collected' || s == 'pod-verified') return 100;
    if (s == 'cancelled') return 0;
    const map = <String, int>{
      'draft': 0,
      'scheduled': 10,
      'awaiting-lr-confirmation': 20,
      'pending-lr-confirmation': 20,
      'lr-confirmed': 30,
      'en-route-to-pickup': 40,
      'arrived-at-pickup': 45,
      'in-progress': 50,
      'arrived': 80,
      'awaiting-pod': 85,
    };
    return map[s] ?? 0;
  }

  /// A trip counts as "assigned" exactly like the web:
  /// `status !== 'draft' && !!driverId`.
  static bool isAssigned(String backendStatus, String driverId) {
    return backendStatus.toLowerCase().trim() != 'draft' && driverId.isNotEmpty;
  }

  /// Human-readable label for a raw backend status, e.g.
  /// `en-route-to-pickup` → `En Route To Pickup`.
  static String prettyStatus(String backendStatus) {
    final s = backendStatus.trim();
    if (s.isEmpty) return 'Unknown';
    return s
        .split(RegExp(r'[-_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  /// Iconsax glyph that best represents the current backend status — used on
  /// timeline / status chips in the lifecycle screens.
  static IconData iconFor(String backendStatus) {
    switch (bucketOf(backendStatus)) {
      case TripBucket.upcoming:
        return Iconsax.calendar_1;
      case TripBucket.inProcess:
        return Iconsax.routing;
      case TripBucket.completed:
        return Iconsax.tick_circle;
    }
  }
}

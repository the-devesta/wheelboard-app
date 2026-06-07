import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/notification_controller.dart';
import '../../../models/notification_model.dart';
import '../../../theme/design_system.dart';
import '../../../widgets/custom_snackbar.dart';
import '../TrackTrip/TrackTripScreen.dart';

/// Professional notifications — real data, web parity.
///
/// Replaces the old static Figma mock. Trip-assignment notifications render a
/// rich card with the **LR OTP** (Start Code) + copy, route, earnings, distance
/// and payment info, plus a "Start Trip with OTP" CTA — mirroring the web
/// `/professional/notifications` page. Everything is backed by
/// [NotificationController] (`GET /notifications`, mark-read, mark-all-read).
class Notification1Screen extends StatelessWidget {
  const Notification1Screen({super.key});

  NotificationController get _ctrl => Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;

    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        centerTitle: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Iconsax.arrow_left_2,
                    color: AppPalette.textDark),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Text('Notifications', style: AppText.h2),
        actions: [
          Obx(() => ctrl.unreadCount > 0
              ? TextButton(
                  onPressed: ctrl.markAllAsRead,
                  child: Text('Mark all read',
                      style: AppText.label
                          .on(AppPalette.primary)
                          .weight(FontWeight.w600)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.notifications.isEmpty) {
          return const AppLoading(message: 'Loading notifications…');
        }

        return RefreshIndicator(
          color: AppPalette.primary,
          onRefresh: ctrl.fetchNotifications,
          child: ctrl.notifications.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    AppEmptyState(
                      icon: Iconsax.notification,
                      title: 'No notifications yet',
                      subtitle:
                          "You'll see trip assignments and updates here.",
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: ctrl.notifications.length,
                  separatorBuilder: (_, __) => AppSpacing.vGapMd,
                  itemBuilder: (_, i) {
                    final n = ctrl.notifications[i];
                    return n.isTripAssignment
                        ? _TripAssignmentCard(n: n, ctrl: ctrl)
                        : _RegularCard(n: n, ctrl: ctrl);
                  },
                ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip-assignment card (with LR OTP)
// ─────────────────────────────────────────────────────────────────────────────
class _TripAssignmentCard extends StatelessWidget {
  final NotificationModel n;
  final NotificationController ctrl;
  const _TripAssignmentCard({required this.n, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.rXl,
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.green.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: AppPalette.green, shape: BoxShape.circle),
              child: const Icon(Iconsax.truck, color: Colors.white, size: 19),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title.isEmpty ? 'New Trip Assignment' : n.title,
                      style: AppText.h3),
                  Text(n.formattedDate, style: AppText.caption),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 4, right: 8),
                decoration: const BoxDecoration(
                    color: AppPalette.green, shape: BoxShape.circle),
              ),
            IconButton(
              icon: const Icon(Iconsax.trash, size: 20, color: AppPalette.danger),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _showDeleteModal(context, ctrl, n);
              },
            ),
          ]),

          if (n.lrNumber != null) ...[
            AppSpacing.vGapMd,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: AppRadius.rMd),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Iconsax.document_text,
                    size: 15, color: AppPalette.textGrey),
                AppSpacing.hGapSm,
                Text('LR: ', style: AppText.caption),
                Text(n.lrNumber!,
                    style: AppText.label
                        .on(AppPalette.textDark)
                        .weight(FontWeight.w700)),
              ]),
            ),
          ],

          // LR OTP — prominent
          if (n.lrOtp != null) ...[
            AppSpacing.vGapMd,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.rLg,
                border: Border.all(color: AppPalette.green, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('START CODE (LR OTP)', style: AppText.micro.size(10)),
                  AppSpacing.vGapSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        n.lrOtp!,
                        style: AppText.h1.on(AppPalette.green).copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 8,
                            ),
                      ),
                      InkWell(
                        borderRadius: AppRadius.rMd,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: n.lrOtp!));
                          SnackBarHelper.success('OTP copied to clipboard!');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                              color: AppPalette.greenBg,
                              borderRadius: AppRadius.rMd),
                          child: const Icon(Iconsax.copy,
                              size: 20, color: AppPalette.green),
                        ),
                      ),
                    ],
                  ),
                  if (n.otpExpiry != null) ...[
                    AppSpacing.vGapSm,
                    Text('Expires: ${_pretty(n.otpExpiry!)}',
                        style: AppText.caption),
                  ],
                ],
              ),
            ),
          ],

          // Route
          if ((n.fromLocation ?? '').isNotEmpty ||
              (n.toLocation ?? '').isNotEmpty) ...[
            AppSpacing.vGapMd,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: AppRadius.rLg),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Iconsax.location, size: 16, color: AppPalette.blue),
                AppSpacing.hGapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route', style: AppText.micro.size(10)),
                      Text(n.fromLocation ?? '—',
                          style: AppText.subtitle.size(13)),
                      Text('↓', style: AppText.caption),
                      Text(n.toLocation ?? '—',
                          style: AppText.subtitle.size(13)),
                    ],
                  ),
                ),
              ]),
            ),
          ],

          // Earnings + distance
          AppSpacing.vGapMd,
          Row(children: [
            if (n.estimatedEarnings != null)
              Expanded(
                child: _miniStat(
                  bg: AppPalette.greenBg,
                  icon: Iconsax.money_recive,
                  color: AppPalette.green,
                  label: 'Your Earnings',
                  value: '₹${n.estimatedEarnings!.toStringAsFixed(0)}',
                ),
              ),
            if (n.estimatedEarnings != null && (n.distance ?? '').isNotEmpty)
              AppSpacing.hGapMd,
            if ((n.distance ?? '').isNotEmpty)
              Expanded(
                child: _miniStat(
                  bg: AppPalette.blueBg,
                  icon: Iconsax.routing,
                  color: AppPalette.blue,
                  label: 'Distance',
                  value: '${n.distance} km',
                ),
              ),
          ]),

          // Payment info
          if ((n.paymentTiming ?? '').isNotEmpty ||
              (n.paymentMode ?? '').isNotEmpty) ...[
            AppSpacing.vGapMd,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                  color: AppPalette.amberBg, borderRadius: AppRadius.rLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💰 Payment: '
                    '${n.paymentTiming == "advance" ? "Paid in Advance" : "Payment at Trip End"}'
                    '${(n.paymentMode ?? "").isNotEmpty ? " (${n.paymentMode == "cash" ? "Cash" : "Online"})" : ""}',
                    style: AppText.caption
                        .on(const Color(0xFF92400E))
                        .weight(FontWeight.w600),
                  ),
                  if (n.platformFee != null)
                    Text(
                      'Platform fee of ₹${n.platformFee!.toStringAsFixed(0)} already deducted',
                      style: AppText.caption.on(const Color(0xFFB45309)),
                    ),
                ],
              ),
            ),
          ],

          AppSpacing.vGapLg,
          AppPrimaryButton(
            label: (n.otpVerified || (n.lrStatus != null && n.lrStatus != 'pending')) ? 'Trip Started' : 'Start Trip with OTP',
            icon: Iconsax.play_circle,
            color: (n.otpVerified || (n.lrStatus != null && n.lrStatus != 'pending')) ? AppPalette.textMid : AppPalette.green,
            onPressed: (n.otpVerified || (n.lrStatus != null && n.lrStatus != 'pending')) ? null : () {
              if (n.notificationId.isNotEmpty) ctrl.markAsRead(n.notificationId);
              final tripId = n.tripId;
              if (tripId != null) {
                Get.to(() => TrackTripScreen(tripId: tripId),
                    transition: Transition.cupertino);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required Color bg,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rLg),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.micro.size(10)),
              Text(value,
                  style: AppText.subtitle.on(color).size(16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Regular notification card
// ─────────────────────────────────────────────────────────────────────────────
class _RegularCard extends StatelessWidget {
  final NotificationModel n;
  final NotificationController ctrl;
  const _RegularCard({required this.n, required this.ctrl});

  ({IconData icon, Color color}) get _glyph {
    switch (n.type) {
      case 'success':
        return (icon: Iconsax.tick_circle, color: AppPalette.green);
      case 'warning':
        return (icon: Iconsax.warning_2, color: AppPalette.amber);
      case 'error':
        return (icon: Iconsax.close_circle, color: AppPalette.danger);
      default:
        return (icon: Iconsax.info_circle, color: AppPalette.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = _glyph;
    final tripId = n.tripId;
    return AppCard(
      onTap: () {
        if (!n.isRead && n.notificationId.isNotEmpty) {
          ctrl.markAsRead(n.notificationId);
        }
      },
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Opacity(
        opacity: n.isRead ? 0.75 : 1,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: g.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.rMd),
            child: Icon(g.icon, color: g.color, size: 19),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title,
                    style: AppText.subtitle.on(
                        n.isRead ? AppPalette.textMid : AppPalette.textDark)),
                if (n.message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(n.message, style: AppText.bodySm),
                  ),
                AppSpacing.vGapSm,
                Text(n.formattedDate, style: AppText.caption),
                if (tripId != null) ...[
                  AppSpacing.vGapSm,
                  AppSecondaryButton(
                    label: 'View Trip',
                    icon: Iconsax.eye,
                    color: AppPalette.blue,
                    expand: false,
                    onPressed: () {
                      if (!n.isRead && n.notificationId.isNotEmpty) {
                        ctrl.markAsRead(n.notificationId);
                      }
                      Get.to(() => TrackTripScreen(tripId: tripId),
                          transition: Transition.cupertino);
                    },
                  ),
                ],
              ],
            ),
          ),
          if (!n.isRead)
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.only(top: 4, right: 8),
              decoration: BoxDecoration(
                  color: g.color, shape: BoxShape.circle),
            ),
          IconButton(
            icon: const Icon(Iconsax.trash, size: 20, color: AppPalette.danger),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              _showDeleteModal(context, ctrl, n);
            },
          ),
        ]),
      ),
    );
  }
}

void _showDeleteModal(BuildContext context, NotificationController ctrl, NotificationModel n) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppPalette.danger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.trash, color: AppPalette.danger, size: 32),
          ),
          AppSpacing.vGapLg,
          Text('Delete Notification', style: AppText.h2),
          AppSpacing.vGapSm,
          Text(
            'Are you sure you want to delete this notification? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: AppText.body.on(AppPalette.textGrey),
          ),
          AppSpacing.vGapXl,
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
                  ),
                  child: Text('Cancel', style: AppText.subtitle.weight(FontWeight.w600).on(AppPalette.textGrey)),
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal first
                    ctrl.deleteNotification(n.notificationId);
                    SnackBarHelper.success("Notification deleted");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.danger,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
                  ),
                  child: Text('Delete', style: AppText.subtitle.weight(FontWeight.w600).on(Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

String _pretty(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final l = dt.toLocal();
  final hh = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final mm = l.minute.toString().padLeft(2, '0');
  final ap = l.hour >= 12 ? 'PM' : 'AM';
  return '${l.day}/${l.month} $hh:$mm $ap';
}

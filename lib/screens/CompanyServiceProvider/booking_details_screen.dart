import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/ServiceProvider/booking_details_controller.dart';
import '../../models/service_booking_model.dart';
import '../../theme/design_system.dart';
import '../../widgets/custom_snackbar.dart';

/// Booking detail + lifecycle for the provider — mirrors wheelboard-fe
/// `business/bookings/[id]`: Start → Complete (with amount) → cash/payment
/// status, dual completion confirmation, platform-fee breakdown and cancel.
class BookingDetailsScreen extends StatefulWidget {
  final String serviceId;
  final ServiceBookingModel? initialBookingData;

  const BookingDetailsScreen({
    super.key,
    required this.serviceId,
    this.initialBookingData,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late final BookingDetailsController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.put(
      BookingDetailsController(
        serviceId: widget.serviceId,
        initialBookingData: widget.initialBookingData,
      ),
      tag: widget.serviceId,
    );
  }

  @override
  void dispose() {
    Get.delete<BookingDetailsController>(tag: widget.serviceId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: const BackButton(color: AppPalette.textDark),
        centerTitle: false,
        title: Text('Booking Details', style: AppText.h2),
      ),
      body: Obx(() {
        if (_c.isLoading.value) {
          return const AppLoading(message: 'Loading booking…');
        }
        final b = _c.bookingData.value;
        if (b == null) {
          return const AppEmptyState(
            icon: Iconsax.task_square,
            title: 'No booking found',
            subtitle: 'This service has no assignments yet.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _header(b),
            AppSpacing.vGapLg,
            _pricingCard(b),
            AppSpacing.vGapLg,
            _scheduleCard(b),
            AppSpacing.vGapLg,
            _serviceDetailsCard(b),
            if (b.status.toLowerCase() == 'completed' ||
                b.businessCompletionConfirmed ||
                b.companyCompletionConfirmed) ...[
              AppSpacing.vGapLg,
              _completionCard(b),
            ],
            if (b.description?.isNotEmpty ?? false) ...[
              AppSpacing.vGapLg,
              _notesCard(b),
            ],
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final b = _c.bookingData.value;
        if (b == null) return const SizedBox.shrink();
        return _actionBar(b);
      }),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _header(ServiceBookingModel b) {
    final style = _statusStyle(b.status);
    final initials = b.customerName.isNotEmpty
        ? b.customerName.trim().substring(0, b.customerName.length >= 2 ? 2 : 1).toUpperCase()
        : 'CO';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: AppRadius.rXl,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: AppRadius.rLg),
                child: Text(initials, style: AppText.h2.on(Colors.white)),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.serviceTitle,
                        style: AppText.h3.on(Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(b.customerName,
                        style: AppText.bodySm.on(Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: AppRadius.rPill),
                child: Text(style.label,
                    style: AppText.micro.on(style.color)),
              ),
              AppSpacing.hGapSm,
              if (b.paymentStatus.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white24, borderRadius: AppRadius.rPill),
                  child: Text('Payment: ${b.paymentStatus}',
                      style: AppText.micro.on(Colors.white)),
                ),
              const Spacer(),
              if ((b.bookingNo ?? '').isNotEmpty)
                Text('#${b.bookingNo}', style: AppText.micro.on(Colors.white70)),
            ],
          ),
          if ((b.customerMobile ?? '').isNotEmpty) ...[
            AppSpacing.vGapMd,
            GestureDetector(
              onTap: () => _launch('tel:${b.customerMobile}'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: AppRadius.rLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.call, size: 18, color: AppPalette.primary),
                    AppSpacing.hGapSm,
                    Text('Call ${b.customerMobile}',
                        style: AppText.subtitle.on(AppPalette.primary)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Pricing + platform fee ─────────────────────────────────────────────────
  Widget _pricingCard(ServiceBookingModel b) {
    final onRequest = _c.isOnRequest;
    final amount = b.amount;
    final fee = b.platformFee;
    final net = b.providerEarnings ?? (amount - fee);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(onRequest ? 'Pricing' : 'Approx Price', style: AppText.label),
              Text(
                onRequest
                    ? 'On Request'
                    : '₹${amount % 1 == 0 ? amount.toInt() : amount}',
                style: AppText.h1.on(
                    onRequest ? AppPalette.amber : AppPalette.textDark),
              ),
            ],
          ),
          if (!onRequest && fee > 0) ...[
            const Divider(height: 22, color: AppPalette.border),
            _feeRow('Platform Fee', '-₹${fee % 1 == 0 ? fee.toInt() : fee}',
                AppPalette.danger),
            const SizedBox(height: 6),
            _feeRow('Net Earnings', '₹${net % 1 == 0 ? net.toInt() : net}',
                AppPalette.green,
                bold: true),
          ],
          if (onRequest) ...[
            const SizedBox(height: 4),
            Text('Final amount is set when you complete the service.',
                style: AppText.caption),
          ],
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value, Color color, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold ? AppText.subtitle : AppText.bodySm),
        Text(value,
            style: (bold ? AppText.subtitle : AppText.bodySm).on(color)),
      ],
    );
  }

  // ── Schedule ────────────────────────────────────────────────────────────
  Widget _scheduleCard(ServiceBookingModel b) {
    String date = b.scheduledDate;
    if (date.isNotEmpty) {
      final dt = DateTime.tryParse(date);
      if (dt != null) date = DateFormat('EEE, dd MMM yyyy').format(dt);
    }
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _iconStat(Iconsax.calendar_1, 'Date',
                date.isEmpty ? 'Not scheduled' : date),
          ),
          Container(width: 1, height: 36, color: AppPalette.border),
          Expanded(
            child: _iconStat(Iconsax.clock, 'Time',
                b.scheduledTime.isEmpty ? '—' : b.scheduledTime),
          ),
        ],
      ),
    );
  }

  Widget _iconStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppPalette.primary),
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.caption),
              Text(value, style: AppText.subtitle, maxLines: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _serviceDetailsCard(ServiceBookingModel b) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Details', style: AppText.h3),
          AppSpacing.vGapMd,
          _detailRow(Iconsax.tag, 'Category', b.category ?? 'N/A'),
          if ((b.location ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            _detailRow(Iconsax.location, 'Location', b.location!),
          ],
          if ((b.vehicleNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            _detailRow(Iconsax.truck, 'Vehicle', b.vehicleNumber!),
          ],
          const SizedBox(height: 10),
          _detailRow(Iconsax.wallet, 'Payment Method', b.paymentMethod),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration:
            BoxDecoration(color: AppPalette.bg, borderRadius: AppRadius.rSm),
        child: Icon(icon, size: 16, color: AppPalette.textMid),
      ),
      AppSpacing.hGapMd,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.caption),
            Text(value, style: AppText.subtitle),
          ],
        ),
      ),
    ]);
  }

  // ── Dual completion confirmation ────────────────────────────────────────
  Widget _completionCard(ServiceBookingModel b) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Completion', style: AppText.h3),
            const Spacer(),
            if (b.fullyCompleted)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppPalette.greenBg, borderRadius: AppRadius.rPill),
                child: Text('Fully Completed',
                    style: AppText.micro.on(AppPalette.green)),
              ),
          ]),
          AppSpacing.vGapMd,
          _confirmRow('You confirmed completion', b.businessCompletionConfirmed),
          const SizedBox(height: 8),
          _confirmRow('Company confirmed completion',
              b.companyCompletionConfirmed),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, bool done) {
    return Row(children: [
      Icon(done ? Iconsax.tick_circle : Iconsax.clock,
          size: 18, color: done ? AppPalette.green : AppPalette.textFaint),
      AppSpacing.hGapSm,
      Expanded(
          child: Text(label,
              style: AppText.bodySm.on(
                  done ? AppPalette.textDark : AppPalette.textGrey))),
      Text(done ? 'Confirmed' : 'Pending',
          style: AppText.micro.on(done ? AppPalette.green : AppPalette.amber)),
    ]);
  }

  Widget _notesCard(ServiceBookingModel b) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes', style: AppText.h3),
          AppSpacing.vGapSm,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppPalette.bg, borderRadius: AppRadius.rMd),
            child: Text(b.description ?? '', style: AppText.bodySm),
          ),
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  Widget _actionBar(ServiceBookingModel b) {
    final status = b.status.toLowerCase();
    final pStatus = b.paymentStatus.toLowerCase();

    final showStart = status == 'assigned' || status == 'pending';
    final showComplete =
        status == 'started' || (status == 'completed' && !b.businessCompletionConfirmed);
    final showConfirmCash = b.paymentMethod.toLowerCase() == 'cash' &&
        status == 'completed' &&
        pStatus != 'completed' &&
        pStatus != 'paid';
    final showPaymentStatus = !['completed', 'paid', 'cancelled', 'refunded']
        .contains(pStatus);
    final showCancel = status != 'cancelled' && status != 'completed';

    final buttons = <Widget>[];
    if (showStart) {
      buttons.add(AppPrimaryButton(
        label: 'Start Service',
        icon: Iconsax.play_circle,
        color: AppPalette.purple,
        loading: _c.isUpdating.value,
        onPressed: () => _c.startService(b.assignmentId),
      ));
    }
    if (showComplete) {
      buttons.add(AppPrimaryButton(
        label: 'Mark as Completed',
        icon: Iconsax.tick_circle,
        color: AppPalette.green,
        loading: _c.isUpdating.value,
        onPressed: () => _completeFlow(b),
      ));
    }
    if (showConfirmCash) {
      buttons.add(AppPrimaryButton(
        label: 'Confirm Cash Payment',
        icon: Iconsax.money_recive,
        color: AppPalette.amber,
        loading: _c.isUpdating.value,
        onPressed: () => _cashFlow(b),
      ));
    }
    if (showPaymentStatus) {
      buttons.add(_paymentStatusButtons(b));
    }
    if (showCancel) {
      buttons.add(AppSecondaryButton(
        label: 'Cancel Appointment',
        icon: Iconsax.close_circle,
        color: AppPalette.danger,
        onPressed: () => _cancelFlow(b),
      ));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppPalette.card,
        border: Border(top: BorderSide(color: AppPalette.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) AppSpacing.vGapSm,
            buttons[i],
          ],
        ],
      ),
    );
  }

  Widget _paymentStatusButtons(ServiceBookingModel b) {
    Widget btn(String label, Color color, VoidCallback onTap) {
      return Expanded(
        child: OutlinedButton(
          onPressed: _c.isUpdating.value ? null : onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.6)),
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          ),
          child: Text(label, style: AppText.label.on(color)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Update Payment Status', style: AppText.label),
        const SizedBox(height: 8),
        Row(children: [
          btn('✓ Completed', AppPalette.green, () {
            if (b.paymentMethod.toLowerCase() == 'online') {
              SnackBarHelper.error(
                  'Online payments are completed by the company via Pay Now.');
              return;
            }
            _confirm('Mark payment as completed?',
                () => _c.updatePaymentStatus('Completed'));
          }),
          AppSpacing.hGapSm,
          btn('Cancelled', AppPalette.danger,
              () => _confirm('Mark payment as cancelled?',
                  () => _c.updatePaymentStatus('Cancelled'))),
          AppSpacing.hGapSm,
          btn('Refunded', AppPalette.amber,
              () => _confirm('Mark payment as refunded?',
                  () => _c.updatePaymentStatus('Refunded'))),
        ]),
      ],
    );
  }

  // ── Flows ─────────────────────────────────────────────────────────────────
  Future<void> _completeFlow(ServiceBookingModel b) async {
    final prefill = b.amount > 0 ? b.amount : null;
    final amount = await _amountSheet(
      title: 'Complete Service',
      subtitle: 'Enter the final amount to complete this service.',
      icon: Iconsax.tick_circle,
      accent: AppPalette.green,
      prefill: prefill,
    );
    if (amount != null) {
      await _c.completeService(b.assignmentId, amount);
    }
  }

  Future<void> _cashFlow(ServiceBookingModel b) async {
    final prefill = b.amount > 0 ? b.amount : null;
    final amount = await _amountSheet(
      title: 'Confirm Cash Payment',
      subtitle: 'Enter the amount received from the company.',
      icon: Iconsax.money_recive,
      accent: AppPalette.amber,
      prefill: prefill,
    );
    if (amount != null) {
      await _c.confirmCashPayment(amountPaid: amount);
    }
  }

  void _cancelFlow(ServiceBookingModel b) {
    _confirm('Cancel this appointment?', () => _c.cancelService(b.assignmentId));
  }

  void _confirm(String message, VoidCallback onYes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
        title: Text('Please confirm', style: AppText.title),
        content: Text(message, style: AppText.bodySm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No', style: AppText.subtitle.on(AppPalette.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onYes();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
            ),
            child: Text('Yes', style: AppText.subtitle.on(Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<double?> _amountSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    double? prefill,
  }) {
    final ctrl = TextEditingController(
        text: prefill != null && prefill > 0
            ? (prefill % 1 == 0 ? prefill.toInt().toString() : prefill.toString())
            : '');
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.rMd),
                child: Icon(icon, color: accent),
              ),
              AppSpacing.hGapMd,
              Text(title, style: AppText.h3),
            ]),
            AppSpacing.vGapMd,
            Text(subtitle, style: AppText.bodySm),
            AppSpacing.vGapLg,
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppText.h2.on(AppPalette.textDark),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: AppText.h2.on(AppPalette.textGrey),
                hintText: 'Enter amount',
                filled: true,
                fillColor: AppPalette.bg,
                border: OutlineInputBorder(
                    borderRadius: AppRadius.rLg,
                    borderSide: const BorderSide(color: AppPalette.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.rLg,
                    borderSide: const BorderSide(color: AppPalette.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.rLg,
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            AppSpacing.vGapLg,
            Row(children: [
              Expanded(
                child: AppSecondaryButton(
                  label: 'Cancel',
                  color: AppPalette.textGrey,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: AppPrimaryButton(
                  label: 'Confirm',
                  color: accent,
                  onPressed: () {
                    final v = double.tryParse(ctrl.text.trim());
                    if (v == null || v <= 0) {
                      SnackBarHelper.error('Please enter a valid amount');
                      return;
                    }
                    Navigator.pop(ctx, v);
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final u = Uri.parse(uri);
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  _StatusStyle _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const _StatusStyle('Completed', AppPalette.green);
      case 'started':
        return const _StatusStyle('Started', AppPalette.purple);
      case 'assigned':
        return const _StatusStyle('Assigned', AppPalette.blue);
      case 'cancelled':
        return const _StatusStyle('Cancelled', AppPalette.danger);
      default:
        return const _StatusStyle('Pending', AppPalette.amber);
    }
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  const _StatusStyle(this.label, this.color);
}

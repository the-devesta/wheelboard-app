import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../controllers/ServiceProvider/service_provider_home_controller.dart';
import '../../models/service_booking_model.dart';
import '../../theme/design_system.dart';
import 'booking_details_screen.dart';

/// My Bookings — modern list of all service assignments for the provider
/// (mirrors wheelboard-fe `business/bookings`). Backed by
/// `ServiceProviderHomeController.fetchBookings()` (`/services/bookings/provider/:id`).
class BookingListScreen extends StatefulWidget {
  /// Kept for call-site compatibility; the controller now resolves the provider
  /// from the JWT and ignores per-service ids.
  final List<String> serviceIds;

  const BookingListScreen({super.key, this.serviceIds = const []});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late final ServiceProviderHomeController _controller;

  static const _statuses = [
    'All',
    'Pending',
    'Assigned',
    'Started',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ServiceProviderHomeController>()
        ? Get.find<ServiceProviderHomeController>()
        : Get.put(ServiceProviderHomeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchBookings(widget.serviceIds);
    });
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
        title: Text('My Bookings', style: AppText.h2),
      ),
      body: Column(
        children: [
          _statsStrip(),
          _filterBar(),
          Expanded(
            child: Obx(() {
              if (_controller.isLoadingBookings.value) {
                return const AppLoading(message: 'Fetching bookings…');
              }
              final bookings = _controller.filteredBookings;
              return RefreshIndicator(
                color: AppPalette.primary,
                onRefresh: () => _controller.fetchBookings(widget.serviceIds),
                child: bookings.isEmpty
                    ? ListView(children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: const AppEmptyState(
                            icon: Iconsax.task_square,
                            title: 'No bookings found',
                            subtitle:
                                'New service requests from companies will appear here.',
                          ),
                        ),
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: bookings.length,
                        itemBuilder: (_, i) => _BookingCard(
                          booking: bookings[i],
                          index: i,
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _statsStrip() {
    return Obx(() {
      final all = _controller.allBookings;
      final active = all
          .where((b) => ['assigned', 'started', 'pending']
              .contains(b.status.toLowerCase()))
          .length;
      final completed =
          all.where((b) => b.status.toLowerCase() == 'completed').length;
      return Container(
        color: AppPalette.card,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
        child: Row(
          children: [
            _statChip('${all.length}', 'Total', AppPalette.blue),
            AppSpacing.hGapMd,
            _statChip('$active', 'Active', AppPalette.amber),
            AppSpacing.hGapMd,
            _statChip('$completed', 'Completed', AppPalette.green),
          ],
        ),
      );
    });
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.rLg,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Text(value, style: AppText.h2.on(color)),
          Text(label, style: AppText.caption),
        ]),
      ),
    );
  }

  Widget _filterBar() {
    return Container(
      color: AppPalette.card,
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 38,
        child: Obx(() {
          final selected = _controller.selectedStatus.value;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _statuses.length,
            separatorBuilder: (_, __) => AppSpacing.hGapSm,
            itemBuilder: (_, i) {
              final s = _statuses[i];
              final active = selected == s;
              return GestureDetector(
                onTap: () => _controller.setStatusFilter(s),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? AppPalette.primary : AppPalette.bg,
                    borderRadius: AppRadius.rPill,
                    border: Border.all(
                        color: active ? AppPalette.primary : AppPalette.border),
                  ),
                  child: Text(s,
                      style: AppText.label
                          .on(active ? Colors.white : AppPalette.textGrey)),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final ServiceBookingModel booking;
  final int index;
  const _BookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context) {
    final style = _BookingStatusStyle.of(booking.status);
    final amount = booking.isPaid && (booking.paymentAmount ?? 0) > 0
        ? booking.paymentAmount!
        : booking.amount;

    String date = booking.scheduledDate;
    if (date.isNotEmpty) {
      final dt = DateTime.tryParse(date);
      if (dt != null) date = DateFormat('dd MMM yyyy').format(dt);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index.clamp(0, 8)) * 50),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          onTap: () => Get.to(() => BookingDetailsScreen(
                serviceId: booking.serviceId,
                initialBookingData: booking,
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(booking.serviceTitle,
                        style: AppText.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  AppSpacing.hGapSm,
                  _badge(style.label, style.color, style.bg),
                ],
              ),
              AppSpacing.vGapSm,
              _row(Iconsax.building, booking.customerName),
              const SizedBox(height: 6),
              _row(Iconsax.calendar_1,
                  '$date${booking.scheduledTime.isNotEmpty ? ' · ${booking.scheduledTime}' : ''}'),
              const Divider(height: 20, color: AppPalette.border),
              Row(
                children: [
                  if (booking.paymentStatus.isNotEmpty)
                    _paymentChip(booking),
                  const Spacer(),
                  Text(
                    amount > 0
                        ? '₹${amount % 1 == 0 ? amount.toInt() : amount}'
                        : 'On Request',
                    style: amount > 0
                        ? AppText.h3.on(AppPalette.primary)
                        : AppText.subtitle.on(AppPalette.amber),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 15, color: AppPalette.textFaint),
      AppSpacing.hGapSm,
      Expanded(
          child: Text(text,
              style: AppText.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _badge(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Text(label, style: AppText.micro.on(color)),
    );
  }

  Widget _paymentChip(ServiceBookingModel b) {
    final paid = b.isPaid;
    final color = paid ? AppPalette.green : AppPalette.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), borderRadius: AppRadius.rSm),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(paid ? Iconsax.tick_circle : Iconsax.wallet_money,
            size: 12, color: color),
        const SizedBox(width: 4),
        Text(b.paymentStatus, style: AppText.micro.on(color)),
      ]),
    );
  }
}

class _BookingStatusStyle {
  final String label;
  final Color color;
  final Color bg;
  const _BookingStatusStyle(this.label, this.color, this.bg);

  static _BookingStatusStyle of(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const _BookingStatusStyle(
            'Completed', AppPalette.green, AppPalette.greenBg);
      case 'started':
        return const _BookingStatusStyle(
            'Started', AppPalette.purple, Color(0xFFF3E8FF));
      case 'assigned':
        return const _BookingStatusStyle(
            'Assigned', AppPalette.blue, AppPalette.blueBg);
      case 'cancelled':
        return const _BookingStatusStyle(
            'Cancelled', AppPalette.danger, AppPalette.dangerBg);
      default:
        return const _BookingStatusStyle(
            'Pending', AppPalette.amber, AppPalette.amberBg);
    }
  }
}

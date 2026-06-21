import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/Transport/service_controller.dart';
import '../../controllers/Transport/company_booking_controller.dart';
import '../../models/service_model.dart';
import '../../models/service_booking_model.dart';
import 'service_details.dart';
import 'company_booking_detail_screen.dart';
import 'enquiry_form_page.dart';

/// Company "Services" hub — mirrors the web `/company/services` page:
/// a tabbed view of available **Services** (browse → book) and the company's
/// own **My Bookings** (the full service-booking lifecycle).
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFFF36969);
  static const _bg = Color(0xFFF6F7F8);
  static const _textDark = Color(0xFF111827);
  static const _textGrey = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);

  late final TabController _tab;
  final _serviceCtrl = Get.put(ServiceController());
  final _bookingCtrl = Get.put(CompanyBookingController());
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase().trim()));
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: _textDark),
        title: const Text('Services',
            style: TextStyle(
                color: _textDark, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        centerTitle: true,
        actions: [
          // Mirrors wheelboard-fe /company/services "Request Service" button.
          TextButton.icon(
            onPressed: () => Get.to(() => const EnquiryFormPage()),
            icon: const Icon(Icons.support_agent, size: 18, color: _primary),
            label: const Text('Request',
                style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins')),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: _primary,
          unselectedLabelColor: _textGrey,
          indicatorColor: _primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 14),
          tabs: const [Tab(text: 'Services'), Tab(text: 'My Bookings')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_servicesTab(), _bookingsTab()],
      ),
    );
  }

  // ── Services (browse) ───────────────────────────────────────────────────────
  Widget _servicesTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(children: [
            const Icon(Icons.search, color: _textGrey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search services...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: _textGrey),
                ),
              ),
            ),
          ]),
        ),
      ),
      Expanded(
        child: Obx(() {
          if (_serviceCtrl.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }
          final all = _serviceCtrl.services;
          final list = _query.isEmpty
              ? all
              : all.where((s) {
                  return s.serviceTitle.toLowerCase().contains(_query) ||
                      s.businessName.toLowerCase().contains(_query) ||
                      s.city.toLowerCase().contains(_query) ||
                      (s.serviceCategory ?? '').toLowerCase().contains(_query);
                }).toList();
          if (list.isEmpty) {
            return _empty(
              icon: Icons.miscellaneous_services,
              title: 'No services available',
              subtitle: _serviceCtrl.errorMessage.value.isNotEmpty
                  ? _serviceCtrl.errorMessage.value
                  : 'Check back later for services near you.',
              onRetry: _serviceCtrl.fetchServices,
            );
          }
          return RefreshIndicator(
            color: _primary,
            onRefresh: _serviceCtrl.fetchServices,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: list.length,
              itemBuilder: (_, i) => _ServiceCard(
                service: list[i],
                onTap: () => Get.to(
                    () => ServiceDetailScreen(serviceId: list[i].serviceId)),
              ),
            ),
          );
        }),
      ),
    ]);
  }

  // ── My Bookings ─────────────────────────────────────────────────────────────
  Widget _bookingsTab() {
    return Obx(() {
      if (_bookingCtrl.isLoading.value && _bookingCtrl.bookings.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _primary));
      }
      final list = _bookingCtrl.bookings;
      if (list.isEmpty) {
        return _empty(
          icon: Icons.receipt_long,
          title: 'No bookings yet',
          subtitle: 'Book a service to see it here.',
          onRetry: _bookingCtrl.fetchMyBookings,
        );
      }
      return RefreshIndicator(
        color: _primary,
        onRefresh: _bookingCtrl.fetchMyBookings,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: list.length,
          itemBuilder: (_, i) => _BookingCard(
            booking: list[i],
            onTap: () async {
              await Get.to(() =>
                  CompanyBookingDetailScreen(bookingId: list[i].assignmentId));
              _bookingCtrl.fetchMyBookings();
            },
          ),
        ),
      );
    });
  }

  Widget _empty({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 52, color: _textGrey),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textGrey, fontFamily: 'Poppins')),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary)),
              child: const Text('Refresh'),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Service card ───────────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});
  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = service.amount != null && service.amount! > 0
        ? '₹${service.amount!.toStringAsFixed(0)}'
        : 'On request';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                service.serviceTitle.isNotEmpty ? service.serviceTitle : 'Service',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins'),
              ),
            ),
            if (service.isAvailable)
              const Icon(Icons.verified, color: Color(0xFF22C55E), size: 18),
          ]),
          const SizedBox(height: 8),
          if (service.categoryList.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: service.categoryList
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(c,
                            style: const TextStyle(
                                color: Color(0xFFF36969),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins')),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.store_outlined,
                size: 14, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                service.businessName.isNotEmpty
                    ? '${service.businessName} · ${service.city}'
                    : (service.city.isNotEmpty ? service.city : 'Address N/A'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      fontFamily: 'Poppins')),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36969),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('View Details',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

// ── Booking card ────────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});
  final ServiceBookingModel booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final st = bookingStatusStyle(booking.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(booking.serviceTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF111827),
                      fontFamily: 'Poppins')),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: st.bg, borderRadius: BorderRadius.circular(20)),
              child: Text(booking.status,
                  style: TextStyle(
                      color: st.fg,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins')),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              booking.scheduledDate.isNotEmpty
                  ? booking.scheduledDate.split('T').first
                  : '—',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            const Spacer(),
            Text('₹${booking.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(booking.isPaid ? Icons.check_circle : Icons.schedule,
                size: 14,
                color: booking.isPaid
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            Text(
              booking.isPaid ? 'Paid' : 'Payment ${booking.paymentStatus}',
              style: TextStyle(
                  color: booking.isPaid
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Text('View',
                style: TextStyle(
                    color: Color(0xFFF36969),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Poppins')),
            const Icon(Icons.chevron_right, color: Color(0xFFF36969), size: 18),
          ]),
        ]),
      ),
    );
  }
}

/// Shared status → colour mapping for service bookings.
({Color bg, Color fg}) bookingStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return (bg: const Color(0xFFDCFCE7), fg: const Color(0xFF16A34A));
    case 'started':
      return (bg: const Color(0xFFDBEAFE), fg: const Color(0xFF2563EB));
    case 'assigned':
      return (bg: const Color(0xFFEDE9FE), fg: const Color(0xFF7C3AED));
    case 'cancelled':
      return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFFDC2626));
    default: // Pending
      return (bg: const Color(0xFFFEF3C7), fg: const Color(0xFFD97706));
  }
}

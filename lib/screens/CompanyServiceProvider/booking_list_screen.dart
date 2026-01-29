import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_loader.dart';
import '../../controllers/ServiceProvider/service_provider_home_controller.dart';
import 'booking_details_screen.dart';

class BookingListScreen extends StatefulWidget {
  final List<String> serviceIds;

  const BookingListScreen({super.key, required this.serviceIds});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late final ServiceProviderHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ServiceProviderHomeController());
    _controller.fetchBookings(widget.serviceIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF36969)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Booking Leads',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Obx(() {
              if (_controller.isLoadingBookings.value) {
                return const CustomLoader(message: "Fetching leads...");
              }
              if (_controller.allBookings.isEmpty) {
                return _buildEmptyState();
              }
              return _buildBookingsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      'All',
      'Pending',
      'Confirmed',
      'Started',
      'Completed',
      'Cancelled',
    ];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(() {
        final selectedStatus = _controller.selectedStatus.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final status = statuses[index];
            final isSelected = selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _controller.setStatusFilter(status);
                  }
                },
                selectedColor: const Color(0xFFF36969),
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFF36969)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildBookingsList() {
    return RefreshIndicator(
      onRefresh: () => _controller.fetchBookings(widget.serviceIds),
      child: Obx(() {
        final bookings = _controller.filteredBookings;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildBookingCard(booking);
          },
        );
      }),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = (booking['status'] ?? 'Pending').toString();
    final serviceTitle = booking['serviceTitle'] ?? 'Service';
    final customerName = booking['customerName'] ?? 'Customer';
    final scheduledDate = booking['scheduledDate'] ?? '';
    final scheduledTime = booking['scheduledTime'] ?? '';
    final amount = booking['amount'] ?? 0;

    // Format date
    String formattedDate = scheduledDate;
    if (scheduledDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(scheduledDate);
        formattedDate = DateFormat('dd MMM yyyy').format(dt);
      } catch (e) {}
    }

    return GestureDetector(
      onTap: () {
        Get.to(
          () => BookingDetailsScreen(
            serviceId: booking['serviceId'] ?? '',
            initialBookingData: booking,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    serviceTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Text(
                  customerName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Text(
                  "$formattedDate at $scheduledTime",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const Spacer(),
                if (amount > 0)
                  Text(
                    "₹$amount",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF36969),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'started':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No leads found',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'New service requests will appear here',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_loader.dart';
import '../../utils/app_logger.dart';
import 'booking_details_screen.dart';

class BookingListScreen extends StatefulWidget {
  final List<String> serviceIds;

  const BookingListScreen({super.key, required this.serviceIds});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _filteredBookings = [];
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      List<Map<String, dynamic>> collectedBookings = [];

      for (String serviceId in widget.serviceIds) {
        if (serviceId.isEmpty) continue;

        final endpoint = '${API.serviceAssignList}?serviceId=$serviceId';
        final response = await HttpHelper.getData(
          endpoint: endpoint,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data =
              jsonDecode(response.body) as List<dynamic>? ?? [];
          collectedBookings.addAll(
            data.map((e) => e as Map<String, dynamic>).toList(),
          );
        }
      }

      // Sort by date (descending)
      collectedBookings.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['scheduledDate'] ?? '') ?? DateTime(0);
        final dateB =
            DateTime.tryParse(b['scheduledDate'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _allBookings = collectedBookings;
        _applyFilter();
      });
    } catch (e) {
      AppLogger.d("Error fetching bookings: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedStatus == 'All') {
      _filteredBookings = List.from(_allBookings);
    } else {
      _filteredBookings = _allBookings.where((booking) {
        final status = (booking['status'] ?? '').toString().toLowerCase();
        return status == _selectedStatus.toLowerCase();
      }).toList();
    }
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
            child: _isLoading
                ? const CustomLoader(message: "Fetching leads...")
                : _allBookings.isEmpty
                ? _buildEmptyState()
                : _buildBookingsList(),
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = status;
                    _applyFilter();
                  });
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
      ),
    );
  }

  Widget _buildBookingsList() {
    return RefreshIndicator(
      onRefresh: _fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = _filteredBookings[index];
          return _buildBookingCard(booking);
        },
      ),
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
        // Navigate to details by providing serviceId
        // The details screen fetches the list and takes [0], which is not ideal
        // but we can try to improve it later or pass the specific data if we modify details screen.
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/transport/lease_models.dart';
import '../../../utils/constants.dart';
import '../../../constants/apps_colors.dart';
import '../../../utils/session_manager.dart';

/// Lease Details Screen - Viewing lease information
class LeaseDetailsScreen extends StatefulWidget {
  final String leaseId;

  const LeaseDetailsScreen({super.key, required this.leaseId});

  @override
  State<LeaseDetailsScreen> createState() => _LeaseDetailsScreenState();
}

class _LeaseDetailsScreenState extends State<LeaseDetailsScreen> {
  final LeaseController _leaseController = Get.find<LeaseController>();
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leaseController.fetchLeaseDetails(widget.leaseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Obx(() {
        if (_leaseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final lease = _leaseController.leaseDetails.value;

        if (lease == null) {
          return Center(
            child: Text(
              "Failed to load lease details",
              style: GoogleFonts.inter(color: Colors.red),
            ),
          );
        }

        return Column(
          children: [
            // Header
            _buildHeader(),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Vehicle Information Section
                    _buildVehicleInfoSection(lease),
                    const SizedBox(height: 16),
                    // Lease Pricing & Terms Section
                    _buildPricingTermsSection(lease),
                    const SizedBox(height: 16),
                    // Availability Window Section
                    _buildAvailabilitySection(lease),
                    const SizedBox(height: 16),
                    // Owner Information Section
                    _buildOwnerInfoSection(lease),
                    const SizedBox(height: 16),
                    // Additional Information Section
                    _buildAdditionalInfoSection(lease),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      // Footer with Apply Now Button
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Back Button
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF111827),
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              // Title
              Text(
                'Lease Details',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const Spacer(),
              // Share/Favorite Button
              InkWell(
                onTap: () {
                  // Handle share/favorite
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF111827),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoSection(LeaseDetails lease) {
    final vehicleImage =
        lease.vehicleImage != null && lease.vehicleImage!.isNotEmpty
        ? (lease.vehicleImage!.startsWith('http') ||
                  lease.vehicleImage!.contains('uploads/')
              ? (lease.vehicleImage!.startsWith('http')
                    ? lease.vehicleImage!
                    : '${ApiConstants.baseUrl}${lease.vehicleImage}')
              : lease.vehicleImage!)
        : 'assets/truckImg.png';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image
          Container(
            height: 192,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: vehicleImage.startsWith('http')
                  ? Image.network(
                      vehicleImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.local_shipping,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      vehicleImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.local_shipping,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Name and Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lease.vehicleTitle ?? 'Unknown Vehicle',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lease.vehicleNumber ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lease.status == 'Available'
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        lease.status ?? 'Unknown',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: lease.status == 'Available'
                              ? const Color(0xFF15803D)
                              : const Color(0xFFC2410C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 12),
                // Vehicle Details Grid
                _buildVehicleDetailsGrid(lease),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsGrid(LeaseDetails lease) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFEFF6FF),
                icon: Icons.local_shipping,
                iconColor: const Color(0xFF2563EB),
                label: 'Vehicle Type',
                value: lease.vehicleType ?? 'N/A',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFFAF5FF),
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF9333EA),
                label: 'Year',
                value: '${lease.modelYear ?? "N/A"}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFFFF7ED),
                icon: Icons.speed,
                iconColor: const Color(0xFFF59E0B),
                label: 'Odometer',
                value: '${lease.odometerStartReading ?? 0} km',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFF0FDF4),
                icon: Icons.trending_up,
                iconColor: const Color(0xFF16A34A),
                label: 'Trip Efficiency',
                value: '${lease.tripEfficiencyRate ?? 0}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFEEF2FF),
                icon: Icons.trending_up,
                iconColor: const Color(0xFF6366F1),
                label: 'Avg Monthly Run',
                value: '${lease.avgMonthlyRun ?? 0} km',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingTermsSection(LeaseDetails lease) {
    String pricingType = 'Flat Price'; // Default
    if (lease.pricingType == '1') pricingType = 'Per KM';
    if (lease.pricingType == '2') pricingType = 'Per Trip';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.currency_rupee,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Lease Pricing & Terms',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pricing Mode
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pricing Mode',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pricingType,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Rates
          Row(
            children: [
              Expanded(
                child: _buildRateCard(
                  label: 'Flat Rate',
                  value: '₹${lease.flatPrice ?? 0}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(LeaseDetails lease) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Availability Window',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dates
          Row(
            children: [
              Expanded(
                child: _buildDateCard(
                  'Start Date',
                  _formatDate(lease.startDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateCard('End Date', _formatDate(lease.endDate)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Business Days
          Text(
            'Business Days',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          _buildBusinessDays(lease.businessDays),
          const SizedBox(height: 16),
          // Business Hours
          Text(
            'Business Hours',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          _buildBusinessHours(lease.startTime, lease.endTime),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDays(String? daysString) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays =
        daysString?.split(', ').map((e) => e.trim()).toList() ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          final isSelected = selectedDays.any((d) => d.startsWith(day));
          return Container(
            margin: EdgeInsets.only(right: day != 'Sun' ? 8 : 0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBusinessHours(String? start, String? end) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                'From',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                start ?? '--:--',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              size: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Column(
            children: [
              Text(
                'To',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                end ?? '--:--',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoSection(LeaseDetails lease) {
    if (lease.ownerName == null || lease.ownerName!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owner Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    lease.profileImage != null && lease.profileImage!.isNotEmpty
                    ? NetworkImage(lease.profileImage!)
                    : null,
                child: lease.profileImage == null || lease.profileImage!.isEmpty
                    ? Text(lease.ownerName![0])
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lease.ownerName!,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lease.email ?? "",
                      style: GoogleFonts.inter(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(LeaseDetails lease) {
    // Placeholder if more info needed
    return const SizedBox.shrink();
  }

  Widget _buildFooter() {
    return Obx(() {
      final lease = _leaseController.leaseDetails.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: SafeArea(
          child: FutureBuilder<String?>(
            future: _sessionManager.getString('userId'),
            builder: (context, snapshot) {
              final currentUserId = snapshot.data;
              final isOwnVehicle =
                  lease?.userId != null &&
                  currentUserId != null &&
                  lease!.userId == currentUserId;

              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isOwnVehicle
                      ? null
                      : () {
                          _showApplyDialog();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOwnVehicle
                        ? Colors.grey.shade300
                        : AppColors.buttonBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    isOwnVehicle
                        ? 'Cannot Apply (Your Vehicle)'
                        : 'Apply for Lease',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOwnVehicle ? Colors.grey.shade600 : Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  void _showApplyDialog() {
    final TextEditingController notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Lease'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add some notes for your application:'),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Notes...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _leaseController.applyForLease(
                widget.leaseId,
                message: notesController.text,
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

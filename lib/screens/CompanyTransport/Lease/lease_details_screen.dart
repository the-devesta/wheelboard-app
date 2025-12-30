import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Lease Details Screen - Viewing lease information (matches Figma design)
class LeaseDetailsScreen extends StatelessWidget {
  const LeaseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
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
                  _buildVehicleInfoSection(),
                  const SizedBox(height: 16),
                  // Lease Pricing & Terms Section
                  _buildPricingTermsSection(),
                  const SizedBox(height: 16),
                  // Availability Window Section
                  _buildAvailabilitySection(),
                  const SizedBox(height: 16),
                  // Owner Information Section
                  _buildOwnerInfoSection(),
                  const SizedBox(height: 16),
                  // Additional Information Section
                  _buildAdditionalInfoSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
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
                  decoration: BoxDecoration(
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
                  decoration: BoxDecoration(
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

  Widget _buildVehicleInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                'https://via.placeholder.com/343x192',
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
                            'Tata Ace Gold',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DL 8C AX 1234',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Available Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Available',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF15803D),
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
                _buildVehicleDetailsGrid(),
                const SizedBox(height: 12),
                // Divider
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 12),
                // Past Usage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Past Usage',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      'E-commerce Deliveries',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsGrid() {
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
                value: 'Mini Truck',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFFAF5FF),
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF9333EA),
                label: 'Year',
                value: '2022',
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
                value: '45,230 km',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFF0FDF4),
                icon: Icons.local_gas_station,
                iconColor: const Color(0xFF16A34A),
                label: 'Fuel Type',
                value: 'Diesel',
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
                value: '2,500 km',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                iconBg: const Color(0xFFFDF2F8),
                icon: Icons.access_time,
                iconColor: const Color(0xFFEC4899),
                label: 'Lease Duration',
                value: '6-12 months',
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

  Widget _buildPricingTermsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  'Flat Price per Day',
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
                child: _buildRateCard(label: 'Daily Rate', value: '₹1,200'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRateCard(label: 'Rate per KM', value: '₹8'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Other Details
          _buildPricingDetailRow('Est. Monthly Run', '2,500 km'),
          const SizedBox(height: 12),
          _buildPricingDetailRow('Transport Charges', '₹500 (One-time)'),
          const SizedBox(height: 12),
          _buildPricingDetailRow('Security Deposit', '₹15,000'),
          const SizedBox(height: 16),
          // Terms Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Color(0xFF78350F),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Insurance and maintenance included. Fuel costs are borne by lessee. Minimum lease period: 6 months.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF78350F),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildPricingDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Expanded(child: _buildDateCard('Start Date', '15 Jan 2025')),
              const SizedBox(width: 12),
              Expanded(child: _buildDateCard('End Date', '15 Jul 2025')),
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
          _buildBusinessDays(),
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
          _buildBusinessHours(),
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

  Widget _buildBusinessDays() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          final isSelected = selectedDays.contains(day);
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

  Widget _buildBusinessHours() {
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
                '06:00 AM',
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
            decoration: BoxDecoration(
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
                '10:00 PM',
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

  Widget _buildOwnerInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF9333EA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Owner Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Owner Profile
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://via.placeholder.com/56',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(
                          Icons.person,
                          size: 28,
                          color: Color(0xFF9CA3AF),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rajesh Kumar',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 12,
                                color: Color(0xFF1D4ED8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          4,
                          (index) => const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFFFBBF24),
                          ),
                        ),
                        const Icon(
                          Icons.star_half,
                          size: 12,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(4.5)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contact Info
          _buildContactInfo(
            icon: Icons.phone,
            label: 'Phone Number',
            value: '+91 98765 43210',
          ),
          const SizedBox(height: 12),
          _buildContactInfo(
            icon: Icons.email,
            label: 'Email Address',
            value: 'rajesh.k@fleetowner.com',
          ),
          const SizedBox(height: 12),
          _buildContactInfo(
            icon: Icons.location_on,
            label: 'Service Region',
            value: 'Delhi NCR & North India',
          ),
          const SizedBox(height: 16),
          // Reliability Score
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield,
                      size: 14,
                      color: Color(0xFF14532D),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reliability Score',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF14532D),
                      ),
                    ),
                  ],
                ),
                Text(
                  '95/100',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
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
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Additional Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This well-maintained Tata Ace Gold is perfect for intra-city logistics and last-mile deliveries. The vehicle has been regularly serviced and is in excellent condition. Ideal for e-commerce businesses, courier services, or small-scale transport operations.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 16),
          // Vehicle Capabilities
          Text(
            'Vehicle Capabilities',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildCapabilityItem('Payload capacity: 750 kg'),
          const SizedBox(height: 8),
          _buildCapabilityItem('GPS tracking enabled'),
          const SizedBox(height: 8),
          _buildCapabilityItem('Air conditioning available'),
          const SizedBox(height: 8),
          _buildCapabilityItem('Power steering for easy handling'),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 16),
          // Required Documents
          Text(
            'Required Documents',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem('Valid driving license'),
          const SizedBox(height: 8),
          _buildDocumentItem('Aadhaar card & PAN card'),
          const SizedBox(height: 8),
          _buildDocumentItem('Business registration proof'),
          const SizedBox(height: 8),
          _buildDocumentItem('Security deposit cheque'),
          const SizedBox(height: 16),
          // Terms & Conditions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Color(0xFF7F1D1D),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7F1D1D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Any damage to the vehicle during the lease period will be charged to the lessee. Late payment will incur penalty charges of ₹200 per day. Vehicle must be returned in the same condition as received.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF991B1B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 12, color: Color(0xFF16A34A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String text) {
    return Row(
      children: [
        const Icon(Icons.description, size: 9, color: Color(0xFF374151)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 81,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // Handle Apply Now
            Get.snackbar('Success', 'Application submitted');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Apply Now',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

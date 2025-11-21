import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../LiveMap/LiveMapScreen.dart';

class TripProgressScreen extends StatelessWidget {
  const TripProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String heroImageUrl = 'https://www.figma.com/api/mcp/asset/22622ffa-9dbe-41df-928c-a69296a3502e';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildHeroSection(context, heroImageUrl),
                    const SizedBox(height: 20),
                    _buildDetailsCard(context),
                  ],
                ),
              ),
            ),
            _buildContactButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Trip Progress',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF36969),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          _circleIconButton(
            icon: Icons.refresh_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Row(
              children: const [
                _StatusBadge(label: 'Active', color: Color(0xFF06C167)),
                SizedBox(width: 8),
                _StatusBadge(label: 'In Progress', color: Color(0xFF2F80ED)),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const LiveMapScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5E5E),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Start Trip',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLocationCard(
                  label: 'Origin',
                  address1: 'Warehouse A, 123',
                  address2: 'Main St',
                  icon: Icons.location_on,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLocationCard(
                  label: 'Destination',
                  address1: 'Distribution Center,',
                  address2: '456 Oak Ave',
                  icon: Icons.place,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Current Location',
                  value: 'Highway 101',
                  icon: Icons.my_location,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  label: 'ETA',
                  value: '2:30 PM PST',
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Driver',
                  value: 'John Doe',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  label: 'Status',
                  value: 'En Route',
                  icon: Icons.local_shipping_outlined,
                  showStatusIndicator: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Distance Left',
                  value: '125 mi',
                  icon: Icons.route,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  label: 'Trip Started',
                  value: '1 hour ago',
                  icon: Icons.hourglass_bottom,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar(),
          const SizedBox(height: 28),
          _buildTimeline(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Get.to(() => const LiveMapScreen()),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2F80ED),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF2F80ED)),
                ),
              ),
              icon: const Icon(Icons.navigation, size: 16),
              label: const Text('Live Map'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.78,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0 mi',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            Text(
              '125 mi left',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimelineStep(
          label: 'Origin',
          isCompleted: true,
          icon: Icons.check,
        ),
        Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF34D399),
                  Color(0xFF2F80ED),
                ],
              ),
            ),
          ),
        ),
        _buildTimelineStep(
          label: 'In Transit',
          isCompleted: false,
          isActive: true,
          icon: Icons.local_shipping,
        ),
        Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
            ),
          ),
        ),
        _buildTimelineStep(
          label: 'Arrived',
          isCompleted: false,
          icon: Icons.location_on,
        ),
      ],
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F80ED),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.phone, color: Colors.white, size: 18),
          label: Text(
            'Contact Owner',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildLocationCard({
    required String label,
    required String address1,
    required String address2,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 14, color: const Color(0xFF7A8194)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7A8194),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address1,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF101828),
            ),
          ),
          Text(
            address2,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    bool showStatusIndicator = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF7A8194)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7A8194),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (showStatusIndicator)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF06C167),
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF101828),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String label,
    required bool isCompleted,
    required IconData icon,
    bool isActive = false,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData displayIcon;

    if (isCompleted) {
      backgroundColor = const Color(0xFF06C167);
      iconColor = Colors.white;
      displayIcon = Icons.check;
    } else if (isActive) {
      backgroundColor = const Color(0xFF2F80ED);
      iconColor = Colors.white;
      displayIcon = icon;
    } else {
      backgroundColor = const Color(0xFFE5E7EB);
      iconColor = const Color(0xFF98A2B3);
      displayIcon = icon;
    }

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            displayIcon,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF98A2B3),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFF36969), size: 18),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}


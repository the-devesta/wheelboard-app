import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripProgressScreen extends StatelessWidget {
  const TripProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Asset URLs from Figma
    const String mapImageUrl = 'https://www.figma.com/api/mcp/asset/292a7002-0429-4169-80b7-507644756298';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFAFBFC),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 20,
                      height: 20,
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Trip In Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 21.6,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                          letterSpacing: -1.04,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
            // Map Section
            Stack(
              children: [
                Container(
                  height: 152,
                  width: double.infinity,
                  child: Image.network(
                    mapImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.map, size: 64, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                // Status Badges
                Positioned(
                  left: 12,
                  top: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34D399),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.poppins(
                            fontSize: 14.67,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'In Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 14.67,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Live Map Button
                Positioned(
                  right: 16,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map, size: 12, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 4),
                        Text(
                          'Live Map',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Main Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Start Trip Button (positioned at top)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 22),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5E5E),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Start Trip',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.325,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Origin and Destination
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
                                  address1: 'Distribution',
                                  address2: 'Center, 456 Oak',
                                  address3: 'Ave',
                                  icon: Icons.place,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 40, color: Color(0xFFE5E7EB)),
                          // Current Location and ETA
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
                          const Divider(height: 40, color: Color(0xFFE5E7EB)),
                          // Driver and Status
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  label: 'Driver',
                                  value: 'John Doe',
                                  icon: Icons.person,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard(
                                  label: 'Status',
                                  value: 'En Route',
                                  icon: Icons.directions_car,
                                  showStatusIndicator: true,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 40, color: Color(0xFFE5E7EB)),
                          // Distance Left and Trip Started
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  label: 'Distance Left',
                                  value: '125 mi',
                                  icon: Icons.straighten,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard(
                                  label: 'Trip Started',
                                  value: '1 hour ago',
                                  icon: Icons.access_time,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 40, color: Color(0xFFE5E7EB)),
                          // Progress Bar
                          Column(
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
                                    widthFactor: 0.78, // 254.266 / 326 ≈ 78%
                                    child: Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
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
                          ),
                          const SizedBox(height: 32),
                          // Progress Timeline
                          Row(
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
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF34D399),
                                        const Color(0xFF3B82F6),
                                        const Color(0xFFE5E7EB),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              _buildTimelineStep(
                                label: 'In Transit',
                                isCompleted: false,
                                isActive: true,
                                icon: Icons.directions_car,
                              ),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF3B82F6),
                                        const Color(0xFFE5E7EB),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              _buildTimelineStep(
                                label: 'Arrived',
                                isCompleted: false,
                                isActive: false,
                                icon: Icons.location_on,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Contact Owner Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Contact Owner',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.42,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required String label,
    required String address1,
    required String address2,
    String? address3,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address1,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            address2,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          if (address3 != null)
            Text(
              address3,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
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
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (showStatusIndicator)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
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
      backgroundColor = const Color(0xFF34D399);
      iconColor = Colors.white;
      displayIcon = Icons.check;
    } else if (isActive) {
      backgroundColor = const Color(0xFF3B82F6);
      iconColor = Colors.white;
      displayIcon = icon;
    } else {
      backgroundColor = const Color(0xFFF3F4F6);
      iconColor = const Color(0xFF6B7280);
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
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


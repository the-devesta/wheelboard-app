import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Asset URLs from Figma
    const String mapImageUrl =
        'https://www.figma.com/api/mcp/asset/609f42f8-f799-4c0d-9d47-db02bcad37d1';
    const String vehicleMarkerUrl =
        'https://www.figma.com/api/mcp/asset/7179e743-f7a9-4b7a-8d1d-69d543db0b1e';
    const String destinationMarkerUrl =
        'https://www.figma.com/api/mcp/asset/d1998470-12ca-41e7-81ef-b42adf75ab0e';
    const String locationIconUrl =
        'https://www.figma.com/api/mcp/asset/4f5396fa-3f78-4047-b476-68c1b15580b4';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Stack(
          children: [
            // Map View
            Stack(
              children: [
                // Map Background
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
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
                // Back Button
                Positioned(
                  left: 8,
                  top: 42,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ),
                // Menu Button
                Positioned(
                  right: 8,
                  top: 42,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ),
                // Vehicle Marker (Current Position)
                Positioned(
                  left: 122,
                  top: 296,
                  child: Image.network(
                    vehicleMarkerUrl,
                    width: 74,
                    height: 74,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                // Destination Marker
                Positioned(
                  left: 205,
                  top: 150,
                  child: Image.network(
                    destinationMarkerUrl,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                // Route Line
                Positioned(
                  left: 159,
                  top: 176,
                  child: CustomPaint(
                    size: const Size(77, 157),
                    painter: RouteLinePainter(),
                  ),
                ),
                // Location Card
                Positioned(
                  left: 20,
                  top: 232,
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    width: 196,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F5F8),
                            shape: BoxShape.circle,
                          ),
                          child: Image.network(
                            locationIconUrl,
                            width: 12,
                            height: 12,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Color(0xFF2F80ED),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distribution Center',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E2E31),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '456, Oak Ave',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFADADB7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.52,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A202020),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle Bar
                      Container(
                        margin: const EdgeInsets.only(top: 9),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EBED),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
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
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor:
                                            0.78, // 254.266 / 326 ≈ 78%
                                        child: Container(
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                              const Divider(
                                height: 40,
                                color: Color(0xFFE5E7EB),
                              ),
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
                              const Divider(
                                height: 40,
                                color: Color(0xFFE5E7EB),
                              ),
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
                              const SizedBox(height: 24),
                              // End Trip Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle end trip
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF36969),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: Text(
                                    'End trip',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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
}

// Custom painter for route line
class RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width / 2,
      size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

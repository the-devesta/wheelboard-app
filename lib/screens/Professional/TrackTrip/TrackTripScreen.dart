import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackTripScreen extends StatelessWidget {
  const TrackTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Asset URLs from Figma
    const String mapImageUrl = 'https://www.figma.com/api/mcp/asset/1a7d4319-4d6e-495f-b01f-0734d40eef23';
    const String vehicleMarkerUrl = 'https://www.figma.com/api/mcp/asset/9e035f3c-9747-40d9-a438-1a01d60d3339';
    const String destinationMarkerUrl = 'https://www.figma.com/api/mcp/asset/1237482f-b399-4fa4-bb50-8dfe1d9a2989';
    const String routeLineUrl = 'https://www.figma.com/api/mcp/asset/39970617-7d6e-4ba6-ba38-25784be0d463';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.arrow_back_ios, size: 16),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Trip Route',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF36969),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trip ID: ST0624ADI2024',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF27AE60),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Map View
            Expanded(
              child: Stack(
                children: [
                  // Map
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      border: Border(
                        left: BorderSide(color: Color(0xFFE8EAEC)),
                        right: BorderSide(color: Color(0xFFE8EAEC)),
                      ),
                    ),
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
                  // Back Button Overlay
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
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
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
                            color: Colors.black.withOpacity(0.06),
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
                            child: const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFF2F80ED),
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
                  // Vehicle Marker (Destination)
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
                          child: const Icon(Icons.place, color: Colors.white, size: 30),
                        );
                      },
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
                          child: const Icon(Icons.directions_car, color: Colors.white, size: 40),
                        );
                      },
                    ),
                  ),
                  // Route Line (simplified)
                  Positioned(
                    left: 159,
                    top: 176,
                    child: CustomPaint(
                      size: const Size(77, 157),
                      painter: RouteLinePainter(),
                    ),
                  ),
                  // Bottom Sheet Handle
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EBED),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for route line
class RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F80ED)
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


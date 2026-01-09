import 'package:flutter/material.dart';
import '../../../widgets/common_header_widget.dart';
import '../../../utils/navigation_helper.dart';

class TripAccepted extends StatelessWidget {
  final String tripId;
  final String vehicleType;
  final String driverName;
  final String date;
  final String time;

  const TripAccepted({
    super.key,
    required this.tripId,
    this.vehicleType = 'Bus',
    this.driverName = 'Driver',
    this.date = 'Date TBD',
    this.time = 'Time TBD',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Logo
                const CommonHeaderWidget(),
                const SizedBox(height: 30),

                // Success Image
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 70,
                      color: Color(0xFF34B27D),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Congratulations Text
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF545454),
                  ),
                ),

                const SizedBox(height: 8),

                // Success Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    'You have Successfully Scheduled your trip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // Trip Details Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E3E3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trip Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6C7278),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vehicle
                      _buildDetailRow(
                        icon: Icons.directions_bus,
                        label: 'Vehicle',
                        value: vehicleType,
                      ),
                      const SizedBox(height: 12),

                      // Driver
                      _buildDetailRow(
                        icon: Icons.person,
                        label: 'Driver',
                        value: driverName,
                      ),
                      const SizedBox(height: 12),

                      // Date
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: date,
                      ),
                      const SizedBox(height: 12),

                      // Time
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: time,
                      ),
                      const SizedBox(height: 16),

                      // Trip ID in same row
                      Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            size: 11,
                            color: Color(0xFF575757),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Trip ID:',
                            style: TextStyle(
                              fontSize: 16.8,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: Color(0xFF575757),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF34B27D),
                                    Color(0xFF34B27D),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  tripId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    letterSpacing: -0.14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // OK Button at Bottom
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Home Screen (Main Wrapper)
                    NavigationHelper.navigateToMainWrapper();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF36969),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16.2,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 11, color: const Color(0xFF575757)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 16.8,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Color(0xFF575757),
            ),
          ),
        ),
      ],
    );
  }
}

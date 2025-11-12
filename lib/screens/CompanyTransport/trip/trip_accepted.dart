import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../manage_trip/manage_trip.dart';
import '../../../widgets/common_header_widget.dart';

class TripAccepted extends StatelessWidget {
  final String tripId;
  final String vehicleType;
  final String driverName;
  final String date;
  final String time;

  const TripAccepted({
    super.key,
    this.tripId = 'ST0624ADI2024',
    this.vehicleType = 'Bus',
    this.driverName = 'Jon Doe',
    this.date = 'July 25th, 2024',
    this.time = '13:55 P.M',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
            
                
                // Logo
                const CommonHeaderWidget(),
                const SizedBox(height: 100),
                
                // Success Image
                Center(
                  child: Container(
                    height: 120,
                    width: 121,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Color(0xFF34B27D),
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Congratulations Text
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 29.3,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF545454),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Success Message
                const Text(
                  'You have Successfully Scheduled your trip',
                  style: TextStyle(
                    fontSize: 16.9,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 50),
                
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
                      const SizedBox(height: 20),
                      
                      // Vehicle
                      _buildDetailRow(
                        icon: Icons.directions_bus,
                        label: 'Vehicle',
                        value: vehicleType,
                      ),
                      const SizedBox(height: 16),
                      
                      // Driver
                      _buildDetailRow(
                        icon: Icons.person,
                        label: 'Driver',
                        value: driverName,
                      ),
                      const SizedBox(height: 16),
                      
                      // Date
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: date,
                      ),
                      const SizedBox(height: 16),
                      
                      // Time
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: time,
                      ),
                      const SizedBox(height: 20),
                      
                      // Trip ID Label
                      const Text(
                        'Trip ID',
                        style: TextStyle(
                          fontSize: 16.8,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF575757),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Trip ID Button
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF34B27D),
                              Color(0xFF34B27D),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              letterSpacing: -0.14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100),
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
                    // Navigate to Manage Trips page
                    Get.offAll(() => const ManageTrip());
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
        Icon(
          icon,
          size: 11,
          color: const Color(0xFF575757),
        ),
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


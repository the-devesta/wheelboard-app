import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common_header_widget.dart';
import '../driver/view_driver_screen.dart';
import '../../../widgets/custom_loader.dart';

class ManageTrip extends StatelessWidget {
  const ManageTrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // Reusable Header (same as Feeds screen)
            const CommonHeaderWidget(),

            // Title and Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Manage trips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF535353),
                        letterSpacing: -0.36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search Trips',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  color: Colors.grey[600],
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xFF535353),
                          ),
                          onPressed: () {},
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            icon: const Icon(
                              Icons.filter_alt,
                              color: Color(0xFF535353),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Trip Cards List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  _buildTripCard(
                    driverName: 'Jon Doe',
                    driverImage: 'https://i.pravatar.cc/150?img=1',
                    pickupAddress: '123 Main street, AnyTown, CA 321 32',
                    destinationAddress: '456 Oak Avenue, OtherTown, NY, 100001',
                    dateTime: 'October 26, 2024, 10:00 A.M',
                    specialRequirements: 'Fragile, Cargo, requires Lift Gate',
                  ),
                  const SizedBox(height: 16),
                  _buildTripCard(
                    driverName: 'Jon Doe',
                    driverImage: 'https://i.pravatar.cc/150?img=2',
                    pickupAddress: '123 Main street, AnyTown, CA 321 32',
                    destinationAddress: '456 Oak Avenue, OtherTown, NY, 100001',
                    dateTime: 'October 26, 2024, 10:00 A.M',
                    specialRequirements: 'Fragile, Cargo, requires Lift Gate',
                  ),
                  const SizedBox(height: 16),
                  _buildTripCard(
                    driverName: 'Jon Doe',
                    driverImage: 'https://i.pravatar.cc/150?img=3',
                    pickupAddress: '123 Main street, AnyTown, CA 321 32',
                    destinationAddress: '456 Oak Avenue, OtherTown, NY, 100001',
                    dateTime: 'October 26, 2024, 10:00 A.M',
                    specialRequirements: 'Fragile, Cargo, requires Lift Gate',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required String driverName,
    required String driverImage,
    required String pickupAddress,
    required String destinationAddress,
    required String dateTime,
    required String specialRequirements,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(4, 0),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.29),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Driver Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  driverImage,
                  height: 147,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppImages.driver,
                      height: 147,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 147,
                      color: Colors.grey[200],
                      child: const CustomLoader.small(),
                    );
                  },
                ),
              ),
              // Verified Badge
              Positioned(
                top: 5,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F8CFF),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.21),
                        blurRadius: 4,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Trip Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF535353),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailText('Driver Name', driverName),
                _buildDetailText('Pickup Address', pickupAddress),
                _buildDetailText('Destination Address', destinationAddress),
                _buildDetailText('Date and Time', dateTime),
                _buildDetailText('Special Requirements', specialRequirements),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(
                            () => const ViewDriverScreen(
                              driverId: '', // Placeholder ID for static trip
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFF36363),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'View Profile',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFFF36666),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle cancel trip
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFF36363),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Cancel trip',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFFF36666),
                          ),
                        ),
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

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: Color(0xFF545454),
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/constants.dart';
import '../../../controllers/Professional/track_trip_controller.dart';
import '../../../models/assigned_trip_model.dart';
import '../TrackTrip/TrackTripScreen.dart';

class TripProgressScreen extends StatelessWidget {
  final AssignedTrip trip;
  const TripProgressScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final TrackTripController trackController = Get.put(TrackTripController());
    const String heroImageUrl =
        'https://www.figma.com/api/mcp/asset/22622ffa-9dbe-41df-928c-a69296a3502e';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Trip Progress',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section (Image 0 style)
            _buildHeroSection(context, heroImageUrl, trackController),

            const SizedBox(height: 24),

            // 2. Info Grid
            _buildInfoGrid(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    String imageUrl,
    TrackTripController controller,
  ) {
    final status = trip.tripStatus.toLowerCase();
    final isInProgress = [
      'in progress',
      'inprogress',
      'active',
      'ongoing',
      'en route',
    ].contains(status);
    final isCompleted = status == 'completed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(AppImages.trip, fit: BoxFit.cover);
                },
              ),
            ),
          ),
          // Badges
          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                _buildBadge(
                  isCompleted
                      ? 'Finished'
                      : (isInProgress ? 'Active' : 'Assigned'),
                  isCompleted
                      ? Colors.grey
                      : (isInProgress
                            ? const Color(0xFF06C167)
                            : const Color(0xFFFFC107)),
                ),
                if (!isCompleted && !isInProgress) ...[
                  const SizedBox(width: 8),
                  _buildBadge('Pending Start', const Color(0xFF2F80ED)),
                ],
              ],
            ),
          ),
          // Action Button (Dynamic)
          Positioned(
            right: 20,
            bottom: 20,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value || isCompleted
                    ? null
                    : () {
                        if (isInProgress) {
                          Get.to(() => TrackTripScreen(tripId: trip.tripId));
                        } else {
                          controller.startTrip(trip.tripId);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? Colors.grey
                      : (isInProgress
                            ? const Color(0xFF2F80ED)
                            : const Color(0xFFFF5E5E)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  shadowColor:
                      (isInProgress
                              ? const Color(0xFF2F80ED)
                              : const Color(0xFFFF5E5E))
                          .withValues(alpha: 0.5),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isCompleted
                            ? 'Trip Finished'
                            : (isInProgress ? 'Track Trip' : 'Start Trip'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationRow(
            'Origin',
            trip.pickupLocation,
            Icons.location_on,
            const Color(0xFF06C167),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildLocationRow(
            'Destination',
            trip.deliveryLocation,
            Icons.place,
            const Color(0xFFFF5E5E),
          ),
          const SizedBox(height: 32),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.9,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildSmallCard(
                'Company',
                trip.companyName ?? "WSPL Transport",
                Icons.business,
              ),
              _buildSmallCard(
                'Status',
                trip.tripStatus,
                Icons.local_shipping_outlined,
              ),
              _buildSmallCard(
                'Trip ID',
                // trip.tripId.substring(0, 8).toUpperCase(),
                trip.tripCode.toUpperCase(),
                Icons.numbers,
              ),
              _buildSmallCard('Date', 'Today', Icons.calendar_today_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    String label,
    String address,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

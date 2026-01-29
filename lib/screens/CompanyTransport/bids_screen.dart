import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'driver/view_driver_screen.dart';
import 'trip/assign_trip_screen.dart';
import '../../controllers/Transport/trip_bids_controller.dart';
import '../../models/trip_bid_model.dart';

class BidsScreen extends StatefulWidget {
  final String tripId;

  const BidsScreen({super.key, required this.tripId});

  @override
  State<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends State<BidsScreen> {
  final TripBidsController bidsController = Get.put(TripBidsController());

  @override
  void initState() {
    super.initState();
    if (mounted) {
      bidsController.fetchTripBids(widget.tripId);
    }
  }

  @override
  void dispose() {
    // Clean up any pending operations
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF25C5C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'WB',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'WHEELBOARD',
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Drivers',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.grey),
                    onPressed: () {},
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // View Bids Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'View Bids',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bids List
          Expanded(
            child: Obx(() {
              if (bidsController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bidsController.bids.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bids available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => bidsController.refreshBids(widget.tripId),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: bidsController.bids.map((bid) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildBidCard(
                        bid: bid,
                        driverName: bid.name,
                        driverImage: _getDriverImage(bid),
                        bidAmount: '₹${bid.bidAmount.toStringAsFixed(0)}',
                        rating:
                            4, // Default rating, can be updated if API provides
                        platform: 'WheelBoard',
                        isVerified: true,
                        onViewProfile: () {
                          Get.to(
                            () => ViewDriverScreen(
                              driverName: bid.name,
                              driverImage: _getDriverImage(bid),
                              tripId: widget.tripId,
                              bidId: bid.bidId,
                            ),
                          );
                        },
                        onAssignTrip: () {
                          Get.to(
                            () => AssignTripScreen(
                              tripId: bid.tripId.isNotEmpty
                                  ? bid.tripId
                                  : widget.tripId,
                              bidId: bid.bidId,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard({
    required TripBid bid,
    required String driverName,
    required String driverImage,
    required String bidAmount,
    required int rating,
    required String platform,
    required bool isVerified,
    required VoidCallback onViewProfile,
    required VoidCallback onAssignTrip,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Image Section with Error Handling
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: driverImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: driverImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF36969),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildInitialsPlaceholder(driverName),
                        )
                      : _buildInitialsPlaceholder(driverName),
                ),
              ),
              // Verified Badge
              if (isVerified)
                Positioned(
                  top: 12,
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
                          color: Colors.black.withOpacity(0.21),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Driver Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Name
                Text(
                  'Driver Name: $driverName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF535353),
                  ),
                ),
                const SizedBox(height: 8),
                // Bid Amount
                Text(
                  'Bid Amount: $bidAmount',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF535353),
                  ),
                ),
                const SizedBox(height: 8),
                // Bid Description
                if (bid.bidDescription.isNotEmpty)
                  Text(
                    'Description: ${bid.bidDescription}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: Color(0xFF6C7278),
                    ),
                  ),
                if (bid.bidDescription.isNotEmpty) const SizedBox(height: 8),
                // Contact Number
                Text(
                  'Contact: ${bid.contactNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Color(0xFF6C7278),
                  ),
                ),
                const SizedBox(height: 12),

                // Rating Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E3E3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.44),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              'Rating:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: Color(0xFF535353),
                                letterSpacing: -0.28,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Stars
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 20,
                                  color: const Color(0xFFFF5E5E),
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            // Platform Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F2F4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                platform,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFF36565),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$rating/5',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF535353),
                          letterSpacing: -0.28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewProfile,
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
                        onPressed: onAssignTrip,
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
                          'Assign Trip',
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

  // Get driver image from different source
  // Get driver image from model
  String _getDriverImage(TripBid bid) {
    return bid.driverImagePath ?? '';
  }

  Widget _buildInitialsPlaceholder(String name) {
    final initials = name.trim().isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((n) => n.isNotEmpty ? n[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'DR';
    return Container(
      color: const Color(0xFFEBF4FF), // Light blue background
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F80ED), // Blue text
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

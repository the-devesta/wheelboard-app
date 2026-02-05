// import 'package:flutter/material.dart';

// class TripOverviewScreen extends StatelessWidget {
//   const TripOverviewScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trip Overview'),
//       ),
//       body: const Center(
//         child: Text('Trip Overview Screen'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/call_utils.dart';
import '../BidSubmit/BidSubmitScreen.dart';
import '../../../models/unassigned_trip_model.dart';
import '../../../controllers/Transport/user_profile_controller.dart';
import '../../../widgets/custom_snackbar.dart';

class TripOverviewPopup {
  static void show(
    BuildContext context, {
    required String tripId,
    required UnassignedTripDetails tripDetails,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          TripOverviewSheet(tripId: tripId, tripDetails: tripDetails),
    );
  }
}

class TripOverviewSheet extends StatelessWidget {
  final String tripId;
  final UnassignedTripDetails tripDetails;

  const TripOverviewSheet({
    super.key,
    required this.tripId,
    required this.tripDetails,
  });

  String _formatDate(DateTime? date, String time) {
    if (date == null) return time;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    final timeStr = time.isNotEmpty
        ? ' – ${time.substring(0, time.length > 5 ? 5 : time.length)}'
        : '';
    return "$dateStr$timeStr";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85, // Limit height
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      // Icon(Iconsax.truck_fast, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text(
                        "Trip Overview",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Pickup Location",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tripDetails.pickupLocation),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Drop-off Location",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tripDetails.deliveryLocation),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Vehicle",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${tripDetails.vehicleModel} (${tripDetails.vehicleNumber})",
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Payment",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("₹${tripDetails.payRange}"),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Pickup Date & Time",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(
                        tripDetails.pickupDate,
                        tripDetails.pickupTime,
                      ),
                    ),

                    if (tripDetails.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Additional Instructions",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(tripDetails.specialInstructions),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Submit button
              Obx(() {
                final userProfileController = Get.put(UserProfileController());
                if (userProfileController.userProfile.value == null) {
                  userProfileController.fetchCurrentUserProfile();
                }

                final profile = userProfileController.userProfile.value;
                final isProfessional = profile?.isProfessional ?? false;
                final professionalType =
                    profile?.professionalType?.toLowerCase() ?? '';
                final isDriver = professionalType == 'driver';

                // If it's a professional but not a driver, show warning and disable bid
                if (isProfessional && !isDriver) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Only Drivers can place bids on trips. Technicians and Helpers are restricted.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF856404),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            SnackBarHelper.error(
                              "Only Drivers can place bids on trips.",
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Bidding Restricted"),
                        ),
                      ),
                    ],
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(
                        () => BidSubmissionScreen(
                          tripId: tripId,
                          tripDetails: tripDetails,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Submit Bid"),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Fleet Owner card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Fleet Owner",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            tripDetails.companyName.isNotEmpty
                                ? tripDetails.companyName
                                : "N/A",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (tripDetails.companyMobileNo.isNotEmpty)
                            Text(
                              tripDetails.companyMobileNo,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (tripDetails.companyMobileNo.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () =>
                            CallUtils.makeCall(tripDetails.companyMobileNo),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text("Call"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/Professional/unassigned_trips_controller.dart';
import '../../../models/unassigned_trip_model.dart';
import '../../../widgets/custom_loader.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../../controllers/Transport/user_profile_controller.dart';
import '../../../widgets/custom_snackbar.dart';

class BidSubmissionScreen extends StatefulWidget {
  final String tripId;
  final UnassignedTripDetails tripDetails;

  const BidSubmissionScreen({
    super.key,
    required this.tripId,
    required this.tripDetails,
  });

  @override
  State<BidSubmissionScreen> createState() => _BidSubmissionScreenState();
}

class _BidSubmissionScreenState extends State<BidSubmissionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final UnassignedTripsController controller = Get.put(
    UnassignedTripsController(),
  );

  String _getLocationName(String location) {
    if (location.isEmpty) return 'Unknown';
    final parts = location.split(',');
    return parts.isNotEmpty ? parts[0].trim() : location;
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bid Submission",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.redAccent),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trip Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "From: ${_getLocationName(widget.tripDetails.pickupLocation)}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "To: ${_getLocationName(widget.tripDetails.deliveryLocation)}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(
                          widget.tripDetails.pickupDate,
                          widget.tripDetails.pickupTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee, size: 16),
                      const SizedBox(width: 4),
                      Text("Pay Range: ₹${widget.tripDetails.payRange}"),
                    ],
                  ),
                  if (widget.tripDetails.vehicleNumber.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.directions_car, size: 16),
                        const SizedBox(width: 4),
                        Text("Vehicle: ${widget.tripDetails.vehicleNumber}"),
                      ],
                    ),
                  ],
                  if (widget.tripDetails.specialInstructions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Special Instructions:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.tripDetails.specialInstructions),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section title
            const Text(
              "Submit Your Bid",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Proposed Amount
            const Text(
              "Proposed Amount",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount (e.g., 6000)",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.tealAccent,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal, width: 1.2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message
            Row(
              children: const [
                Text("Message", style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Text("(optional)", style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: messageController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: "Write a short message to the fleet owner...",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.tealAccent,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal, width: 1.2),
                ),
                counterText: "",
              ),
            ),

            const SizedBox(height: 20),

            // Submit Bid button
            Obx(() {
              final isHired = AuthService.to.isUserHired;
              final isSubmitting = controller.isSubmittingBid.value;

              final userProfileController = Get.find<UserProfileController>();
              final profile = userProfileController.userProfile.value;
              final isProfessional = profile?.isProfessional ?? false;
              final professionalType =
                  profile?.professionalType?.toLowerCase() ?? '';
              final isDriver = professionalType == 'driver';
              final isRestricted = isProfessional && !isDriver;

              return Column(
                children: [
                  if (isHired)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You are currently hired by a company. Bidding is not available.",
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isHired || isSubmitting || isRestricted
                          ? () {
                              if (isRestricted) {
                                SnackBarHelper.error(
                                  "Only Drivers can place bids on trips.",
                                );
                              }
                            }
                          : () async {
                              final amount = double.tryParse(
                                amountController.text.trim(),
                              );
                              if (amount == null || amount <= 0) {
                                Get.snackbar(
                                  "Error",
                                  "Please enter a valid bid amount",
                                );
                                return;
                              }

                              final success = await controller.submitBid(
                                tripId: widget.tripId,
                                bidAmount: amount,
                                bidDescription: messageController.text.trim(),
                              );

                              if (success) {
                                Navigator.pop(context);
                                controller.refreshTrips();
                              }
                            },
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CustomLoader.small(color: Colors.white),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: Text(
                        isRestricted
                            ? "Bidding Restricted"
                            : (isHired
                                  ? "Bidding Disabled (Hired)"
                                  : (isSubmitting
                                        ? "Submitting..."
                                        : "Submit Bid")),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isHired || isRestricted)
                            ? Colors.grey.shade400
                            : Colors.tealAccent.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 30),

            // No recent bids placeholder
            const Center(
              child: Text(
                "No recent bids...",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Illustration (optional placeholder)
            Center(
              child: Image.network(
                "https://cdn-icons-png.flaticon.com/512/7436/7436481.png",
                width: 120,
              ),
            ),
          ],
        ),
      ),

      backgroundColor: Colors.white,
    );
  }
}

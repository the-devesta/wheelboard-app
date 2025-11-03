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
import '../BidSubmit/BidSubmitScreen.dart';

class TripOverviewPopup {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const TripOverviewSheet(),
    );
  }
}

class TripOverviewSheet extends StatelessWidget {
  const TripOverviewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
                  const Text("123 Main Street, Bangalore"),

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
                  const Text("456 Oak Avenue, Chennai"),

                  const SizedBox(height: 10),

                  const Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Cargo Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Freight: Electronics\nWeight: 500kg"),

                  const SizedBox(height: 10),

                  const Row(
                    children: [
                      Icon(Icons.currency_rupee, size: 18, color: Colors.grey),
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
                  const Text("INR 5,000"),

                  const SizedBox(height: 10),

                  const Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "Deadline",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("June 15, 2024, 10:00 AM"),

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
                  const Text("Handle with care.\nContact: John Doe"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => BidSubmissionScreen());
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
            ),

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
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/100?img=12',
                    ), // demo image
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fleet Owner",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        "ABC Logistics",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {},
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
    );
  }
}

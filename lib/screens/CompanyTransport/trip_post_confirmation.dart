import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';

import '../../utils/navigation_helper.dart';

class PostConfirmTripPage extends StatelessWidget {
  const PostConfirmTripPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              children: [
                // Logo and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/headingImg.png', // replace with your image
                      height: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Star Graphic
                Image.asset(
                  'assets/star.png', // replace with star graphic
                  height: 100,
                ),
                const SizedBox(height: 24),

                // Congrats Text
                const Text(
                  "Congratulations!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your Trip has been  successfully posted and is now open for bids from freelance drivers.You’ll receive notifications as bids come in",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // Trip Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4E3E3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Trip Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 12),
                      TripDetailRow(
                        title: "Pickup Address",
                        value: "123 Main street, AnyTown,\nCA 321 32",
                      ),
                      TripDetailRow(
                        title: "Destination Address",
                        value: "456 Oak Avenue, OtherTown ,\nNY, 100001",
                      ),
                      TripDetailRow(
                        title: "Date and Time",
                        value: "October 26, 2024, 10:00 A.M",
                      ),
                      TripDetailRow(
                        title: "Special Requirements",
                        value: "Fragile, Cargo,\nrequires Lift Gate",
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Trip ID",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      TripIDBox("ST0624ADI2024"),
                    ],
                  ),
                ),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => NavigationHelper.navigateToTripsTab(),
                    child: const Text(
                      "OK",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Trip Detail Row
// class TripDetailRow extends StatelessWidget {
//   final String detail;
//   const TripDetailRow(this.detail);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(Icons.check, size: 18, color: Colors.black87),
//           const SizedBox(width: 8),
//           Expanded(child: Text(detail, style: const TextStyle(fontSize: 15))),
//         ],
//       ),
//     );
//   }
// }

// Trip ID Box
class TripIDBox extends StatelessWidget {
  final String tripId;
  const TripIDBox(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF34B27D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Center(
        child: Text(
          tripId,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TripDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const TripDetailRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          text: "$title : ",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

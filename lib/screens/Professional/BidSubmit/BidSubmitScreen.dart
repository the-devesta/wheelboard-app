// import 'package:flutter/material.dart';

// class BidSubmitScreen extends StatelessWidget {
//   const BidSubmitScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bid Submit'),
//       ),
//       body: const Center(
//         child: Text('Bid Submit Screen'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BidSubmissionScreen extends StatefulWidget {
  const BidSubmissionScreen({super.key});

  @override
  State<BidSubmissionScreen> createState() => _BidSubmissionScreenState();
}

class _BidSubmissionScreenState extends State<BidSubmissionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // handle submit logic here
                },
                icon: const Icon(Icons.send, size: 18),
                label: const Text(
                  "Submit Bid",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

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

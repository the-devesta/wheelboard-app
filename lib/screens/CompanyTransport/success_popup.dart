import 'package:flutter/material.dart';

class SuccessPopup extends StatelessWidget {
  const SuccessPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "YOUR INQUIRY FOR TYRE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D1C3A), // navy blue
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, thickness: 1),

            const SizedBox(height: 20),

            // Success Text
            Text(
              "SUBMITTED ✨\nSUCCESSFULLY! ✅",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6464), // red button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context); // close popup
                },
                child: const Text(
                  "Submit Another Enquiry?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

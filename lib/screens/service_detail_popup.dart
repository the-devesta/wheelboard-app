import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/screens/service_confirmation.dart';

class ServiceDetailsPopup extends StatelessWidget {
  const ServiceDetailsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // shrink to content
                  children: [
                    const Icon(Icons.event_note, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      "Service Details",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     const Icon(Icons.event_note, color: Colors.blue),
              //     const SizedBox(width: 8),
              //     Text.rich(
              //       TextSpan(
              //         text: "Service Details",
              //         style: const TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),

              // Service Title
              const Text("Service Title"),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Enter Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Service Date
              const Text("Service Date"),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Write Service Date",
                  suffixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Service Time
              const Text("Service Time"),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Write Service Time",
                  suffixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vehicle Number
              const Text("Enter Vehicle Number:"),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter Vehicle Number:",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Service Description
              const Text(
                "Service Description",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 4,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Write Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close popup
                    Get.to(ServiceConfirmationPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Details",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

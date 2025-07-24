import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/truck.png'),
          ),
          const SizedBox(width: 12),

          // Title + Description + Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Tyre Replacement",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE1FFF3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Tyre Repair",
                        style: TextStyle(
                          color: Color(0xFF00A88B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  "Puncture and flat tyre repair service.\nQuick turnaround and warranty",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 10),

                // Buttons
                Row(
                  children: [
                    // Edit button
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.edit, size: 16, color: Colors.teal),
                      label: Text(
                        "Edit",
                        style: TextStyle(color: Colors.teal, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // Unpublish button
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.visibility_off,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: Text(
                        "Unpublish",
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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
}

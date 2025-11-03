// import 'package:flutter/material.dart';

// class JobProgressScreen extends StatelessWidget {
//   const JobProgressScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Job Progress'),
//       ),
//       body: const Center(
//         child: Text('Job Progress Screen'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class JobProgressScreen extends StatelessWidget {
  const JobProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appliedJobs = [
      {
        "title": "On-site Tyre Fitting - Pune",
        "company": "QuickFit Pvt Ltd",
        "date": "May 18, 2025",
        "status": "Accepted",
      },
      {
        "title": "Fleet Battery Swap - Nashik",
        "company": "ChargeGrid Services",
        "date": "May 18, 2025",
        "status": "Accepted",
      },
      {
        "title": "Brake Pad Service - Mumbai",
        "company": "UrbanMechanic",
        "date": "May 17, 2025",
        "status": "Rejected",
      },
      {
        "title": "Tyre Inspection - Surat",
        "company": "SpeedyOps India",
        "date": "May 16, 2025",
        "status": "Accepted",
      },
    ];

    final savedJobs = [
      {
        "title": "On-site Tyre Fitting - Pune",
        "company": "QuickFit Pvt Ltd",
        "date": "May 18, 2025",
      },
      {
        "title": "Fleet Battery Swap - Nashik",
        "company": "ChargeGrid Services",
        "date": "May 18, 2025",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Job Progress",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Applied Jobs",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                "Track your job application status",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 10),

              // 🔍 Search bar + filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Iconsax.search_normal_1,
                          size: 20,
                        ),
                        hintText: "Search jobs...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.sort, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: "All",
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.black),
                    items: ["All", "Accepted", "Rejected"]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (_) {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🧾 Applied Jobs List
              ...appliedJobs.map(
                (job) => JobCard(
                  title: job['title']!,
                  company: job['company']!,
                  date: job['date']!,
                  status: job['status']!,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "My Saved Jobs",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              ...savedJobs.map(
                (job) => SavedJobCard(
                  title: job['title']!,
                  company: job['company']!,
                  date: job['date']!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String date;
  final String status;

  const JobCard({
    super.key,
    required this.title,
    required this.company,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = status == "Accepted";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  company,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  "Applied on $date",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Right side content
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAccepted ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isAccepted ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "→ View Details",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SavedJobCard extends StatelessWidget {
  final String title;
  final String company;
  final String date;

  const SavedJobCard({
    super.key,
    required this.title,
    required this.company,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                company,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                "Saved on $date",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          // Right
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Find Job"),
          ),
        ],
      ),
    );
  }
}

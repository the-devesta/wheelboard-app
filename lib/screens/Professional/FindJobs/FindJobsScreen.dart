import 'package:flutter/material.dart';

// class FindJobsScreen extends StatelessWidget {
//   const FindJobsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Find Jobs'),
//       ),
//       body: const Center(
//         child: Text('Find Jobs Screen'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../TripOverview/TripOverviewScreen.dart';
import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';

class FindJobsScreen extends StatelessWidget {
  const FindJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const JobBoardScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
    );
  }
}

class JobBoardScreen extends StatelessWidget {
  const JobBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Job Board",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: Colors.black87),
        actions: const [
          Icon(Icons.notifications_none_rounded, color: Colors.black87),
          SizedBox(width: 16),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search Jobs or Trips...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Jobs Section
            JobCard(
              company: "Transvolt Dhar",
              title: "Electric Truck Drivers Needed",
              location: "Chicago, IL",
              type: "Permanent",
              salary: "₹2,300/month",
              phone: "+1 555 012 5552",
            ),
            const SizedBox(height: 12),
            JobCard(
              company: "FreightXpress",
              title: "CDL A Drivers for Regional Routes",
              location: "Dallas, TX",
              type: "Task-based",
              salary: "₹1,800/month",
              phone: "+1 555 988 2233",
            ),

            const SizedBox(height: 24),
            const Divider(height: 30),
            const Center(
              child: Text(
                "Trips",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 16),

            TripCard(
              title: "Trip to Los Angeles",
              tags: ["Standard", "Delivery"],
              destination: "Los Angeles, CA",
              date: "July 18, 2024",
            ),
            TripCard(
              title: "Trip to Phoenix",
              tags: ["Express"],
              destination: "Phoenix, AZ",
              date: "July 22, 2024",
            ),
            TripCard(
              title: "Trip to Phoenix",
              tags: ["Express"],
              destination: "Phoenix, AZ",
              date: "July 22, 2024",
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String company, title, location, type, salary, phone;
  const JobCard({
    super.key,
    required this.company,
    required this.title,
    required this.location,
    required this.type,
    required this.salary,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                company,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, size: 16),
                label: const Text("Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Text(location),
              const SizedBox(width: 12),
              // const Icon(Iconsax.briefcase, size: 16),
              const SizedBox(width: 4),
              Text(type),
              const SizedBox(width: 12),
              // const Icon(Iconsax.money_4, size: 16),
              const SizedBox(width: 4),
              Text(salary),
            ],
          ),
          const SizedBox(height: 8),
          Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Apply now"),
          ),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final String title, destination, date;
  final List<String> tags;
  const TripCard({
    super.key,
    required this.title,
    required this.destination,
    required this.date,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              ...tags.map(
                (e) => Chip(
                  label: Text(
                    e,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Text("Destination: $destination"),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16),
              const SizedBox(width: 4),
              Text("Departure: $date"),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Get.to(() => TripOverviewPopup());
              TripOverviewPopup.show(Get.context!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("View Details"),
          ),
        ],
      ),
    );
  }
}

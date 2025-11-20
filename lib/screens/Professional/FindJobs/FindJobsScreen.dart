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
import 'package:get/get.dart';
import '../../../controllers/Professional/unassigned_trips_controller.dart';
import '../../../models/unassigned_trip_model.dart';
import '../TripOverview/TripOverviewScreen.dart';
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

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final UnassignedTripsController tripsController = Get.put(UnassignedTripsController());
  final TextEditingController _searchController = TextEditingController();

  // Hardcoded jobs data
  final List<Map<String, String>> _allJobs = [
    {
      "company": "Transvolt Dhar",
      "title": "Electric Truck Drivers Needed",
      "location": "Chicago, IL",
      "type": "Permanent",
      "salary": "₹2,300/month",
      "phone": "+1 555 012 5552",
    },
    {
      "company": "FreightXpress",
      "title": "CDL A Drivers for Regional Routes",
      "location": "Dallas, TX",
      "type": "Task-based",
      "salary": "₹1,800/month",
      "phone": "+1 555 988 2233",
    },
  ];

  List<Map<String, String>> _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _filteredJobs = _allJobs;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    // Update trips search query
    tripsController.searchQuery.value = query;

    // Filter local jobs list
    setState(() {
      if (query.isEmpty) {
        _filteredJobs = _allJobs;
      } else {
        _filteredJobs = _allJobs.where((job) {
          return job.values.any((value) => value.toLowerCase().contains(query));
        }).toList();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Navigate to home screen instead of going back
          Navigator.of(context).pushReplacementNamed('/professional-home');
        }
      },
      child: Scaffold(
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
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
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
              controller: _searchController,
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
            if (_filteredJobs.isNotEmpty) ...[
              ..._filteredJobs.map((jobData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: JobCard(
                    company: jobData["company"]!,
                    title: jobData["title"]!,
                    location: jobData["location"]!,
                    type: jobData["type"]!,
                    salary: jobData["salary"]!,
                    phone: jobData["phone"]!,
                  ),
                );
              }).toList(),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No matching jobs found.", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],

            const SizedBox(height: 12),
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

            Obx(() {
              if (tripsController.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final displayedTrips = tripsController.filteredTrips;

              if (displayedTrips.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "No trips available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: displayedTrips.map((trip) {
                  return TripCard(
                    trip: trip,
                    onTap: () async {
                      await tripsController.fetchTripDetails(trip.tripId);
                      if (tripsController.tripDetails.value != null) {
                        TripOverviewPopup.show(
                          context,
                          tripId: trip.tripId,
                          tripDetails: tripsController.tripDetails.value!,
                        );
                      }
                    },
                  );
                }).toList(),
              );
            }),
          ],
        ),
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
  final UnassignedTrip? trip;
  final VoidCallback? onTap;
  
  const TripCard({
    super.key,
    this.trip,
    this.onTap,
  });

  String _getLocationName(String location) {
    if (location.isEmpty) return 'Unknown';
    final parts = location.split(',');
    return parts.isNotEmpty ? parts[0].trim() : location;
  }

  String _formatDate(DateTime? date, String time) {
    if (date == null) return time;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    final timeStr = time.isNotEmpty
        ? ' – ${time.substring(0, time.length > 5 ? 5 : time.length)}'
        : '';
    return "$dateStr$timeStr";
  }

  @override
  Widget build(BuildContext context) {
    if (trip == null) {
      return const SizedBox.shrink();
    }

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
                "Trip to ${_getLocationName(trip!.destination)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Chip(
                label: Text(
                  trip!.tripType,
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
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text("From: ${_getLocationName(trip!.pickupLocation)}"),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text("To: ${_getLocationName(trip!.destination)}"),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16),
              const SizedBox(width: 4),
              Text(_formatDate(trip!.pickupDate, trip!.pickupTime)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.currency_rupee, size: 16),
              const SizedBox(width: 4),
              Text("Pay Range: ₹${trip!.payRange}"),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onTap,
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


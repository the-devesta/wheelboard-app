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
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/Professional/unassigned_trips_controller.dart';
import '../../../controllers/Professional/open_jobs_controller.dart';
import '../../../models/unassigned_trip_model.dart';
import '../../../models/Professional/open_job_model.dart';
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
  final OpenJobsController jobsController = Get.put(OpenJobsController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Fetch jobs on init
    jobsController.fetchOpenJobs();
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
    // Jobs filtering will be done in the UI using Obx
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

            // Jobs Section - Dynamic from API
            Obx(() {
              if (jobsController.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (jobsController.openJobs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No jobs available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // Filter jobs based on search query
              final searchQuery = _searchController.text.toLowerCase();
              final filteredJobs = searchQuery.isEmpty
                  ? jobsController.openJobs
                  : jobsController.openJobs.where((job) {
                      return job.role.toLowerCase().contains(searchQuery) ||
                          job.city.toLowerCase().contains(searchQuery) ||
                          job.jobType.toLowerCase().contains(searchQuery) ||
                          job.description.toLowerCase().contains(searchQuery);
                    }).toList();

              if (filteredJobs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No matching jobs found.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: filteredJobs.map((job) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: JobCard(
                      job: job,
                      onApply: () async {
                        if (!job.isApplied) {
                          final success = await jobsController.applyForJob(job.jobId);
                          if (success) {
                            await jobsController.refreshOpenJobs();
                          }
                        }
                      },
                      onLikeToggle: () async {
                        await jobsController.toggleJobLike(job.jobId);
                      },
                      isApplying: jobsController.isApplying(job.jobId),
                    ),
                  );
                }).toList(),
              );
            }),

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
  final OpenJob job;
  final VoidCallback onApply;
  final VoidCallback? onLikeToggle;
  final bool isApplying;

  const JobCard({
    super.key,
    required this.job,
    required this.onApply,
    this.onLikeToggle,
    this.isApplying = false,
  });

  String _formatSalary(double salary) {
    if (salary == 0) return "Not specified";
    if (salary >= 100000) {
      return "₹${(salary / 100000).toStringAsFixed(1)}L";
    } else if (salary >= 1000) {
      return "₹${(salary / 1000).toStringAsFixed(1)}K";
    }
    return "₹${salary.toStringAsFixed(0)}";
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Remove any spaces, dashes, or special characters
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Ensure the number starts with tel: protocol
      final Uri phoneUri = Uri.parse('tel:$cleanNumber');
      
      // Use launchUrl with mode: LaunchMode.externalApplication for better compatibility
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: try to launch directly without checking
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make phone call. Please check if your device supports phone calls.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      print('Phone call error: $e');
    }
  }

  void _showCallDialog(BuildContext context, OpenJob job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController phoneController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Call Employer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job: ${job.role.isNotEmpty ? job.role : job.description}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter contact number to call:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final phoneNumber = phoneController.text.trim();
                if (phoneNumber.isNotEmpty) {
                  Navigator.of(context).pop();
                  _makePhoneCall(phoneNumber);
                } else {
                  Get.snackbar(
                    'Error',
                    'Please enter a phone number',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Call'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row - Company name and Call button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.role.isNotEmpty ? job.role : "Job Opening",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showCallDialog(context, job);
                },
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
          
          // Job Title
          Text(
            job.description.isNotEmpty ? job.description : job.role,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Location, Type, Salary row
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                job.city.isNotEmpty ? job.city : "Location not specified",
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.work_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                job.jobType,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.currency_rupee, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _formatSalary(job.salary),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Contact/Additional info (optional - can show openings or duration)
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                job.jobDuration,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              if (job.openings > 0) ...[
                const SizedBox(width: 12),
                const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${job.openings} openings",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          
          // Likes row
          if (onLikeToggle != null)
            Row(
              children: [
                GestureDetector(
                  onTap: onLikeToggle,
                  child: Row(
                    children: [
                      Icon(
                        job.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 16,
                        color: job.isLiked ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${job.likeCount} Likes",
                        style: TextStyle(
                          fontSize: 13,
                          color: job.isLiked ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          
          // Apply now button
          ElevatedButton(
            onPressed: (isApplying || job.isApplied) ? null : onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: job.isApplied 
                  ? Colors.grey.shade300 
                  : Colors.lightBlueAccent,
              foregroundColor: job.isApplied ? Colors.grey.shade600 : Colors.white,
              minimumSize: const Size(double.infinity, 35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isApplying
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(job.isApplied ? "Applied" : "Apply now"),
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
              Text(
                trip!.payRange.isNotEmpty 
                    ? "Pay Range: ${trip!.payRange}" 
                    : "Pay Range: Not specified",
                style: TextStyle(
                  color: trip!.payRange.isNotEmpty ? Colors.black87 : Colors.grey,
                ),
              ),
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


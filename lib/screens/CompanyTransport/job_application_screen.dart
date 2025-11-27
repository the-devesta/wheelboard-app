import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/job_controller.dart';
import '../../models/job_application_model.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String? jobId; // Optional jobId if navigating from a specific job

  const JobApplicationsScreen({super.key, this.jobId});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  late final JobController jobController;
  String? selectedLocation;
  String? selectedRole;
  final List<String> locations = ['All'];
  final List<String> roles = ['All'];

  @override
  void initState() {
    super.initState();
    jobController = Get.put(JobController(), permanent: false);
    
    // Fetch all applications from all jobs
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await jobController.fetchAllJobApplications();
      _updateFilterOptions();
    });
  }

  Future<void> _fetchApplications() async {
    await jobController.fetchAllJobApplications();
    _updateFilterOptions();
  }

  void _updateFilterOptions() {
    // Extract unique locations and roles from all applications
    final allApps = jobController.allApplications;
    
    // Get unique locations - trim whitespace and filter empty
    final uniqueLocationsSet = <String>{};
    for (var app in allApps) {
      final loc = app.location.trim();
      if (loc.isNotEmpty) {
        uniqueLocationsSet.add(loc);
      }
    }
    final uniqueLocations = uniqueLocationsSet.toList()..sort();
    
    locations.clear();
    locations.add('All');
    locations.addAll(uniqueLocations);
    
    // Get unique roles - trim whitespace, filter empty, and handle case
    final uniqueRolesSet = <String>{};
    for (var app in allApps) {
      if (app.jobTitle != null && app.jobTitle!.trim().isNotEmpty) {
        // Normalize to title case for consistency
        final role = app.jobTitle!.trim();
        uniqueRolesSet.add(role);
      }
    }
    final uniqueRoles = uniqueRolesSet.toList()..sort();
    
    roles.clear();
    roles.add('All');
    roles.addAll(uniqueRoles);
    
    // Reset filters if current selections are not available
    if (selectedLocation != null && !locations.contains(selectedLocation)) {
      selectedLocation = 'All';
    }
    if (selectedRole != null && !roles.contains(selectedRole)) {
      selectedRole = 'All';
    }
    
    // Apply filters
    jobController.filterApplications(
      location: selectedLocation == 'All' ? null : selectedLocation,
      role: selectedRole == 'All' ? null : selectedRole,
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFFD1FAE5);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF065F46);
      case 'rejected':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF92400E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Job Applications',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (jobController.isLoading.value && jobController.jobs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (jobController.jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "No jobs posted yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Post a job to see applications",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Filters
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
              ),
              child: Row(
                children: [
                  // Location Filter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedLocation ?? 'All',
                              isExpanded: true,
                              items: locations.map((location) {
                                return DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedLocation = newValue ?? 'All';
                                });
                                jobController.filterApplications(
                                  location: selectedLocation == 'All' ? null : selectedLocation,
                                  role: selectedRole == 'All' ? null : selectedRole,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Role Filter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedRole ?? 'All',
                              isExpanded: true,
                              items: roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(
                                    role,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedRole = newValue ?? 'All';
                                });
                                jobController.filterApplications(
                                  location: selectedLocation == 'All' ? null : selectedLocation,
                                  role: selectedRole == 'All' ? null : selectedRole,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Applications List
            Expanded(
              child: Obx(() {
                if (jobController.isApplicationsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (jobController.applications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "No applications found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Applications will appear here",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _fetchApplications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: jobController.applications.length,
                    itemBuilder: (context, index) {
                      final application = jobController.applications[index];
                      
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < jobController.applications.length - 1 ? 16 : 100,
                        ),
                        child: _buildApplicationCard(
                          application: application,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildApplicationCard({
    required JobApplicationModel application,
  }) {
    final isAccepted = application.status.toLowerCase() == 'accepted';
    final isRejected = application.status.toLowerCase() == 'rejected';
    final statusColor = _getStatusColor(application.status);
    final statusTextColor = _getStatusTextColor(application.status);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: application.profileImage.isNotEmpty
                    ? NetworkImage(application.profileImage)
                    : null,
                child: application.profileImage.isEmpty
                    ? Text(
                        application.fullName.isNotEmpty
                            ? application.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
                backgroundColor: const Color(0xFFE5E7EB),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            application.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            application.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applied on ${_formatDate(application.appliedDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Job Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type of Job',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.jobTitle ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Right Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Salary',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.salaryExpectation > 0
                        ? '₹${application.salaryExpectation.toStringAsFixed(0)}'
                        : 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Navigate to profile - for now just show a message
                      // You can implement navigation to professional profile screen here
                      Get.snackbar(
                        'Profile',
                        'Profile view coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          if (!isAccepted && !isRejected)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await jobController.updateApplicationStatus(
                        applicationId: application.applicationId,
                        status: 'Accepted',
                      );
                      if (success) {
                        await _fetchApplications();
                      }
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await jobController.updateApplicationStatus(
                        applicationId: application.applicationId,
                        status: 'Rejected',
                      );
                      if (success) {
                        await _fetchApplications();
                      }
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          else if (isAccepted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Application Accepted',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            )
          else if (isRejected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Application Rejected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../controllers/Transport/job_controller.dart';
import '../../models/job_application_model.dart';
import '../../models/applied_user_profile_model.dart';
import '../../widgets/custom_loader.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String? jobId; // Optional jobId if navigating from a specific job

  const JobApplicationsScreen({super.key, this.jobId});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  late final JobController jobController;

  @override
  void initState() {
    super.initState();
    jobController = Get.put(JobController(), permanent: false);

    // Fetch applications - if jobId is provided, fetch only for that job, otherwise fetch all
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.jobId != null && widget.jobId!.isNotEmpty) {
        await jobController.fetchJobApplications(widget.jobId!);
      } else {
        await jobController.fetchAllJobApplications();
      }
    });
  }

  Future<void> _fetchApplications() async {
    if (widget.jobId != null && widget.jobId!.isNotEmpty) {
      await jobController.fetchJobApplications(widget.jobId!);
    } else {
      await jobController.fetchAllJobApplications();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
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

  Future<void> _showUserProfile(String userId, String fallbackName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CustomLoader.small()),
    );

    try {
      final response = await HttpHelper.getData(
        endpoint: '${API.getAppliedUserProfile}$userId',
        headers: {'Accept': '*/*'},
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        final profile = AppliedUserProfile.fromJson(profileData);

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          builder: (_) => _buildProfileBottomSheet(profile),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      Get.snackbar(
        'Error',
        'Failed to load profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildProfileBottomSheet(AppliedUserProfile profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundImage: profile.profileImage.isNotEmpty
                  ? NetworkImage(profile.profileImage)
                  : null,
              backgroundColor: const Color(0xFFE5E7EB),
              child: profile.profileImage.isEmpty
                  ? Text(
                      profile.profileName.isNotEmpty
                          ? profile.profileName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              profile.profileName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            if (profile.profileType.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.profileType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF36969),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildProfileDetailRow(Icons.phone, 'Phone', profile.phone),
            _buildProfileDetailRow(Icons.email, 'Email', profile.email),
            if (profile.address.isNotEmpty)
              _buildProfileDetailRow(
                Icons.location_on,
                'Address',
                profile.address,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36969),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFFF36969)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          return const CustomLoader(message: "Loading jobs...");
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
            // Applications List
            Expanded(
              child: Obx(() {
                if (jobController.isApplicationsLoading.value) {
                  return const CustomLoader(message: "Loading applications...");
                }

                if (jobController.applications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: jobController.applications.length,
                    itemBuilder: (context, index) {
                      final application = jobController.applications[index];

                      return Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : 0,
                          bottom: index < jobController.applications.length - 1
                              ? 16
                              : 100,
                        ),
                        child: _buildApplicationCard(application: application),
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

  Widget _buildApplicationCard({required JobApplicationModel application}) {
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
                backgroundColor: const Color(0xFFE5E7EB),
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
                    'Job Duration',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.jobDuration ??
                        application.jobTitle ??
                        'Not specified',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color:
                          (application.jobDuration != null ||
                              application.jobTitle != null)
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFF9CA3AF),
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
                    (application.salary != null && application.salary! > 0)
                        ? '₹${application.salary!.toStringAsFixed(0)}'
                        : (application.salaryExpectation > 0
                              ? '₹${application.salaryExpectation.toStringAsFixed(0)}'
                              : 'Not specified'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color:
                          ((application.salary != null &&
                                  application.salary! > 0) ||
                              application.salaryExpectation > 0)
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFF9CA3AF),
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
                      final success = await jobController
                          .updateApplicationStatus(
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
                      final success = await jobController
                          .updateApplicationStatus(
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
            Column(
              children: [
                // Application Accepted Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 1,
                    ),
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
                ),
                const SizedBox(height: 12),
                // View Profile & Contact Driver buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Fetch and show user profile
                          await _showUserProfile(
                            application.userId,
                            application.fullName,
                          );
                        },
                        icon: const Icon(Icons.person, size: 18),
                        label: const Text('View Profile'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF36969)),
                          foregroundColor: const Color(0xFFF36969),
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
                          // Fetch profile to get phone number
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                const Center(child: CustomLoader.small()),
                          );

                          try {
                            final response = await HttpHelper.getData(
                              endpoint:
                                  '${API.getAppliedUserProfile}${application.userId}',
                              headers: {'Accept': '*/*'},
                            );

                            if (!mounted) return;
                            Navigator.of(context).pop();

                            if (response.statusCode == 200) {
                              final profileData = json.decode(response.body);
                              final profile = AppliedUserProfile.fromJson(
                                profileData,
                              );
                              final phone = profile.phone;

                              if (phone.isNotEmpty) {
                                final Uri phoneUri = Uri(
                                  scheme: 'tel',
                                  path: phone,
                                );
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Cannot make phone call',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'No contact number available',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to load contact number',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            Get.snackbar(
                              'Error',
                              'Failed to load contact number',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Contact'),
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
                  ],
                ),
              ],
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
                  Icon(Icons.cancel, color: Color(0xFFEF4444), size: 16),
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

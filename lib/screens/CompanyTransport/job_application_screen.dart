import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/Transport/job_controller.dart';
import '../../models/job_application_model.dart';
import '../../models/applied_user_profile_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/ui/app_ui.dart';

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

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'hired':
        return const Color(0xFF065F46);
      case 'shortlisted':
        return const Color(0xFF5B21B6);
      case 'reviewed':
        return const Color(0xFF1E40AF);
      case 'rejected':
        return const Color(0xFF991B1B);
      default: // pending
        return const Color(0xFF92400E);
    }
  }

  Future<void> _showUserProfile(String jobId, String applicationId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CustomLoader.small()),
    );

    final data = await jobController.getApplicantProfile(jobId, applicationId);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (data != null) {
      final profile = AppliedUserProfile.fromJson(data);
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
      backgroundColor: AppUi.scaffold,
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
      body: Column(
        children: [
          // Status filter chips
          _buildStatusFilter(),
          Expanded(
            child: Obx(() {
              if (jobController.isApplicationsLoading.value &&
                  jobController.allApplications.isEmpty) {
                return const CustomLoader(message: "Loading applications...");
              }

              if (jobController.applications.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.people_alt_outlined,
                  title: "No applications found",
                  subtitle: "Applications to your jobs will appear here.",
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
      ),
    );
  }

  static const List<String> _filterOptions = [
    'All',
    'pending',
    'reviewed',
    'shortlisted',
    'rejected',
    'hired',
  ];

  Widget _buildStatusFilter() {
    return Obx(
      () => AppFilterChips(
        options: _filterOptions,
        selected: jobController.applicationStatusFilter.value,
        labelOf: (o) => o == 'All' ? 'All' : _capitalize(o),
        onSelected: (o) {
          jobController.applicationStatusFilter.value = o;
          jobController.filterApplications(status: o);
        },
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _buildApplicationCard({required JobApplication application}) {
    final statusTextColor = _getStatusTextColor(application.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
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
                        StatusPill(
                          text: application.statusLabel,
                          color: statusTextColor,
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
          const SizedBox(height: 16),

          // Application details
          _detailItem(
            'Experience',
            application.experience.isNotEmpty
                ? application.experience
                : 'Not specified',
          ),
          if ((application.expectedSalary ?? '').isNotEmpty)
            _detailItem('Expected Salary', application.expectedSalary!),
          if (application.applicantEmail.isNotEmpty)
            _detailItem('Email', application.applicantEmail),
          if (application.applicantPhone.isNotEmpty)
            _detailItem('Phone', application.applicantPhone),
          if ((application.coverLetter ?? '').isNotEmpty)
            _detailItem('Cover Letter', application.coverLetter!),
          const SizedBox(height: 16),

          // Actions: manage status, view profile, contact
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showUserProfile(
                    _jobIdFor(application),
                    application.id,
                  ),
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('Profile'),
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
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactApplicant(application),
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
              const SizedBox(width: 10),
              _buildStatusMenu(application),
            ],
          ),
        ],
      ),
    );
  }

  String _jobIdFor(JobApplication application) =>
      widget.jobId ??
      jobController.jobIdForApplication(application.id) ??
      '';

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMenu(JobApplication application) {
    return PopupMenuButton<String>(
      tooltip: 'Update status',
      onSelected: (status) async {
        final ok = await jobController.updateApplicationStatus(
          applicationId: application.id,
          status: status,
          jobId: _jobIdFor(application),
        );
        if (ok) await _fetchApplications();
      },
      itemBuilder: (_) => JobApplication.statuses
          .map((s) => PopupMenuItem(value: s, child: Text(_capitalize(s))))
          .toList(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_vert, size: 20, color: Color(0xFF6B7280)),
      ),
    );
  }

  Future<void> _contactApplicant(JobApplication application) async {
    String phone = application.applicantPhone;
    if (phone.isEmpty) {
      final data = await jobController.getApplicantProfile(
        _jobIdFor(application),
        application.id,
      );
      if (data != null) {
        phone = AppliedUserProfile.fromJson(data).phone;
      }
    }
    if (phone.isEmpty) {
      Get.snackbar(
        'Contact',
        'No contact number available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Error',
        'Cannot make phone call',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

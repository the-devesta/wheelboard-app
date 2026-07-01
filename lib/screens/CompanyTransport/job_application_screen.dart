import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/Transport/job_controller.dart';
import '../../models/job_application_model.dart';
import '../../models/applied_user_profile_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/ui/app_ui.dart';
import '../../widgets/custom_snackbar.dart';

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
        isScrollControlled: true,
        backgroundColor: Colors.white,
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

  /// Complete applicant profile — mirrors the web `CandidateProfileModal`:
  /// header, Contact Information, Professional Information, Skills, About and
  /// Documents.
  Widget _buildProfileBottomSheet(AppliedUserProfile profile) {
    final statusText =
        profile.status.isNotEmpty ? profile.status : 'Applicant';
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
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
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.profileName.isNotEmpty
                              ? profile.profileName
                              : 'Applicant',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Professional • $statusText',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Contact Information
              _profileSection('Contact Information', Icons.mail_outline, [
                if (profile.email.isNotEmpty)
                  _buildProfileDetailRow(Icons.email, 'Email', profile.email),
                if (profile.phone.isNotEmpty)
                  _buildProfileDetailRow(Icons.phone, 'Phone', profile.phone),
                if (profile.address.isNotEmpty)
                  _buildProfileDetailRow(
                      Icons.location_on, 'Address', profile.address),
                if (profile.dateOfBirth.isNotEmpty)
                  _buildProfileDetailRow(Icons.cake_outlined, 'Date of Birth',
                      _formatDate(profile.dateOfBirth)),
              ]),
              if (profile.hasProfessionalInfo) ...[
                const SizedBox(height: 16),
                _profileSection(
                    'Professional Information', Icons.work_outline, [
                  _professionalInfoGrid(profile),
                ]),
              ],
              if (profile.skills.isNotEmpty) ...[
                const SizedBox(height: 16),
                _profileSection('Skills', Icons.workspace_premium_outlined, [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills.map(_skillPill).toList(),
                  ),
                ]),
              ],
              if (profile.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                _profileSection('About', Icons.description_outlined, [
                  Text(
                    profile.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF374151),
                    ),
                  ),
                ]),
              ],
              if (profile.hasDocuments) ...[
                const SizedBox(height: 16),
                _profileSection('Documents', Icons.folder_outlined, [
                  if (profile.licenseDoc.isNotEmpty)
                    _docRow('License', profile.licenseDoc),
                  if (profile.insuranceDoc.isNotEmpty)
                    _docRow('Insurance', profile.insuranceDoc),
                  if (profile.backgroundCheckDoc.isNotEmpty)
                    _docRow('Background Check', profile.backgroundCheckDoc),
                ]),
              ],
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
      ),
    );
  }

  Widget _profileSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF1F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFF36969)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  /// Two-column grid of professional info, matching the web layout.
  Widget _professionalInfoGrid(AppliedUserProfile p) {
    final items = <Widget>[];
    void add(String label, String value) {
      if (value.trim().isNotEmpty) items.add(_infoItem(label, value));
    }

    add('Experience', p.experience.isNotEmpty ? '${p.experience} years' : '');
    add('Vehicle Type', p.vehicleType);
    add('License Number', p.licenseNumber);
    add('License Expiry',
        p.licenseExpiry.isNotEmpty ? _formatDate(p.licenseExpiry) : '');
    add('Rating', p.rating.isNotEmpty ? '${p.rating} / 5.0' : '');
    add('Total Trips', p.totalTrips);

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + 2 < items.length ? 16 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: items[i]),
            const SizedBox(width: 16),
            Expanded(
              child:
                  i + 1 < items.length ? items[i + 1] : const SizedBox.shrink(),
            ),
          ],
        ),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _skillPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF36969),
        ),
      ),
    );
  }

  Widget _docRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEFF1F4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
            InkWell(
              onTap: () => _openDoc(url),
              child: const Text(
                'View',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF36969),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDoc(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SnackBarHelper.warning('Cannot open this document');
    }
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
      SnackBarHelper.warning('No contact number available');
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      SnackBarHelper.error('Cannot make phone call');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/job_model.dart';
import '../../../models/job_application_model.dart';
import '../../../constants/apps_colors.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  JobApplication? get _app => job.myApplication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.buttonBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Job Details",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.buttonBg, Color(0xFFD32F2F)],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Job Title and Status
                  _buildHeaderCard(),
                  const SizedBox(height: 20),

                  // Job Information
                  if (_hasJobInfo(job)) ...[
                    _buildSectionTitle("Job Information", Icons.work_outline),
                    const SizedBox(height: 12),
                    _buildJobInfoCard(),
                    const SizedBox(height: 20),
                  ],

                  // Job Description
                  if (job.description.isNotEmpty) ...[
                    _buildSectionTitle(
                      "Description",
                      Icons.description_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDescriptionCard(),
                    const SizedBox(height: 20),
                  ],

                  // Application Details
                  if (_hasApplicationInfo(job)) ...[
                    _buildSectionTitle(
                      "Application Details",
                      Icons.assignment_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildApplicationCard(),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (job.title.isNotEmpty)
                      Text(
                        job.title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.buttonBg,
                        ),
                      ),
                    if (job.city.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.city,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;

    final status = _app?.status ?? '';
    if (status == 'hired') {
      bgColor = const Color(0xFF10B981);
      textColor = Colors.white;
      icon = Icons.check_circle;
    } else if (status == 'rejected') {
      bgColor = const Color(0xFFEF4444);
      textColor = Colors.white;
      icon = Icons.cancel;
    } else if (status == 'shortlisted') {
      bgColor = const Color(0xFF8B5CF6);
      textColor = Colors.white;
      icon = Icons.star;
    } else if (status == 'reviewed') {
      bgColor = const Color(0xFF3B82F6);
      textColor = Colors.white;
      icon = Icons.visibility;
    } else {
      bgColor = const Color(0xFFF59E0B);
      textColor = Colors.white;
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            _app?.statusLabel ?? 'Applied',
            style: GoogleFonts.poppins(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.buttonBg),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.buttonBg,
          ),
        ),
      ],
    );
  }

  Widget _buildJobInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: _buildJobInfoRows()),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        job.description,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildApplicationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: _buildApplicationInfoRows()),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.buttonBg.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.buttonBg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasJobInfo(JobModel job) {
    return job.title.isNotEmpty ||
        job.jobDuration.isNotEmpty ||
        job.city.isNotEmpty ||
        job.salary.isNotEmpty;
  }

  bool _hasApplicationInfo(JobModel job) {
    final app = job.myApplication;
    if (app == null) return false;
    return app.appliedDateFormatted.isNotEmpty ||
        app.status.isNotEmpty ||
        (app.expectedSalary ?? '').isNotEmpty ||
        (app.notes ?? app.coverLetter ?? '').isNotEmpty;
  }

  List<Widget> _buildJobInfoRows() {
    List<Widget> rows = [];

    if (job.title.isNotEmpty) {
      rows.add(_buildInfoRow("Job Role", job.title, Icons.work_outline));
    }

    if (job.city.isNotEmpty) {
      rows.add(
        _buildInfoRow("Location", job.city, Icons.location_on_outlined),
      );
    }

    if (job.jobDuration.isNotEmpty) {
      rows.add(_buildInfoRow("Duration", job.jobDuration, Icons.access_time));
    }

    if (job.salary.isNotEmpty) {
      rows.add(
        _buildInfoRow("Salary", job.salary, Icons.currency_rupee),
      );
    }

    // Remove bottom padding from last item
    if (rows.isNotEmpty) {
      rows[rows.length - 1] = Padding(
        padding: EdgeInsets.zero,
        child: rows[rows.length - 1],
      );
    }

    return rows;
  }

  List<Widget> _buildApplicationInfoRows() {
    List<Widget> rows = [];
    final app = _app;
    if (app == null) return rows;

    if (app.appliedDateFormatted.isNotEmpty) {
      rows.add(
        _buildInfoRow(
          "Applied Date",
          app.appliedDateFormatted,
          Icons.calendar_today,
        ),
      );
    }

    if (app.status.isNotEmpty) {
      rows.add(_buildInfoRow("Status", app.statusLabel, Icons.info_outline));
    }

    if ((app.expectedSalary ?? '').isNotEmpty) {
      rows.add(
        _buildInfoRow(
          "Salary Expectation",
          app.expectedSalary!,
          Icons.attach_money,
        ),
      );
    }

    final remarks = app.notes ?? app.coverLetter ?? '';
    if (remarks.isNotEmpty) {
      rows.add(_buildInfoRow("Remarks", remarks, Icons.note_outlined));
    }

    // Remove bottom padding from last item
    if (rows.isNotEmpty) {
      rows[rows.length - 1] = Padding(
        padding: EdgeInsets.zero,
        child: rows[rows.length - 1],
      );
    }

    return rows;
  }
}

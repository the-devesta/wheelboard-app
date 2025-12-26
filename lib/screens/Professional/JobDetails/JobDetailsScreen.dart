import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/Professional/applied_job_model.dart';
import '../../../constants/apps_colors.dart';

class JobDetailsScreen extends StatelessWidget {
  final AppliedJob job;

  const JobDetailsScreen({super.key, required this.job});

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
                "Job Detailsss",
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
                  if (job.jobDescription.isNotEmpty) ...[
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
            color: Colors.black.withOpacity(0.08),
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
                    if (job.jobRole.isNotEmpty)
                      Text(
                        job.jobRole,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.buttonBg,
                        ),
                      ),
                    if (job.jobCity.isNotEmpty) ...[
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
                            job.jobCity,
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

    if (job.isAccepted) {
      bgColor = const Color(0xFF10B981);
      textColor = Colors.white;
      icon = Icons.check_circle;
    } else if (job.isRejected) {
      bgColor = const Color(0xFFEF4444);
      textColor = Colors.white;
      icon = Icons.cancel;
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
            color: bgColor.withOpacity(0.3),
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
            job.status,
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
            color: Colors.black.withOpacity(0.06),
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        job.jobDescription,
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
            color: Colors.black.withOpacity(0.06),
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
              color: AppColors.buttonBg.withOpacity(0.1),
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

  bool _hasJobInfo(AppliedJob job) {
    return job.jobRole.isNotEmpty ||
        job.jobDuration.isNotEmpty ||
        job.jobCity.isNotEmpty ||
        job.salary > 0;
  }

  bool _hasApplicationInfo(AppliedJob job) {
    return job.formattedDate.isNotEmpty ||
        job.status.isNotEmpty ||
        job.salaryExpectation > 0 ||
        job.remarks.isNotEmpty;
  }

  List<Widget> _buildJobInfoRows() {
    List<Widget> rows = [];

    if (job.jobRole.isNotEmpty) {
      rows.add(_buildInfoRow("Job Role", job.jobRole, Icons.work_outline));
    }

    if (job.jobCity.isNotEmpty) {
      rows.add(
        _buildInfoRow("Location", job.jobCity, Icons.location_on_outlined),
      );
    }

    if (job.jobDuration.isNotEmpty) {
      rows.add(_buildInfoRow("Duration", job.jobDuration, Icons.access_time));
    }

    if (job.salary > 0) {
      rows.add(
        _buildInfoRow(
          "Salary",
          "₹${job.salary.toStringAsFixed(0)}/month",
          Icons.currency_rupee,
        ),
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

    if (job.formattedDate.isNotEmpty) {
      rows.add(
        _buildInfoRow("Applied Date", job.formattedDate, Icons.calendar_today),
      );
    }

    if (job.status.isNotEmpty) {
      rows.add(_buildInfoRow("Status", job.status, Icons.info_outline));
    }

    if (job.salaryExpectation > 0) {
      rows.add(
        _buildInfoRow(
          "Salary Expectation",
          "₹${job.salaryExpectation.toStringAsFixed(0)}",
          Icons.attach_money,
        ),
      );
    }

    if (job.remarks.isNotEmpty) {
      rows.add(_buildInfoRow("Remarks", job.remarks, Icons.note_outlined));
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

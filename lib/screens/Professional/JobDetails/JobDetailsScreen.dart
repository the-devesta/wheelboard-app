import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/Professional/applied_job_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final AppliedJob job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Job Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.jobRole.isNotEmpty)
                          Text(
                            job.jobRole,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        if (job.jobCity.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            job.jobCity,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: job.isAccepted
                          ? Colors.green.shade50
                          : job.isRejected
                              ? Colors.red.shade50
                              : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: job.isAccepted
                            ? Colors.green
                            : job.isRejected
                                ? Colors.red
                                : Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Job Information Section
            if (_hasJobInfo(job)) ...[
              _buildSectionTitle("Job Information"),
              const SizedBox(height: 8),
              _buildInfoCard(
                children: _buildJobInfoRows(job),
              ),
              const SizedBox(height: 16),
            ],

            // Job Description Section
            if (job.jobDescription.isNotEmpty) ...[
              _buildSectionTitle("Job Description"),
              const SizedBox(height: 8),
              _buildInfoCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      job.jobDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Application Details Section
            if (_hasApplicationInfo(job)) ...[
              _buildSectionTitle("Application Details"),
              const SizedBox(height: 8),
              _buildInfoCard(
                children: _buildApplicationInfoRows(job),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
    );
  }

  bool _hasJobInfo(AppliedJob job) {
    return job.jobRole.isNotEmpty ||
        job.jobType.isNotEmpty ||
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

  List<Widget> _buildJobInfoRows(AppliedJob job) {
    List<Widget> rows = [];
    int itemCount = 0;

    if (job.jobRole.isNotEmpty) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Job Role", job.jobRole));
      itemCount++;
    }

    if (job.jobType.isNotEmpty) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Job Type", job.jobType));
      itemCount++;
    }

    if (job.jobDuration.isNotEmpty) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Job Duration", job.jobDuration));
      itemCount++;
    }

    if (job.jobCity.isNotEmpty) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Location", job.jobCity));
      itemCount++;
    }

    if (job.salary > 0) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Salary", "₹${job.salary.toStringAsFixed(0)}"));
    }

    return rows;
  }

  List<Widget> _buildApplicationInfoRows(AppliedJob job) {
    List<Widget> rows = [];
    int itemCount = 0;

    if (job.formattedDate.isNotEmpty) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Applied Date", job.formattedDate));
      itemCount++;
    }

    if (job.status.isNotEmpty) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Status", job.status));
      itemCount++;
    }

    if (job.salaryExpectation > 0) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Salary Expectation", "₹${job.salaryExpectation.toStringAsFixed(0)}"));
      itemCount++;
    }

    if (job.remarks.isNotEmpty) {
      if (itemCount > 0) {
        rows.add(_buildDivider());
      }
      rows.add(_buildInfoRow("Remarks", job.remarks));
    }

    return rows;
  }
}


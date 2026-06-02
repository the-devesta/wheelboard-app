import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'job_form_screen.dart';
import 'job_application_screen.dart';
import 'hired_professionals_screen.dart';
import 'package:wheelboard/utils/share_service.dart';
import '../../controllers/Transport/job_controller.dart';
import '../../models/job_model.dart';
import '../../models/job_stats_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/ui/app_ui.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late final JobController jobController;

  @override
  void initState() {
    super.initState();
    // Get or create controller instance
    jobController = Get.put(JobController(), permanent: false);
    // Refresh jobs when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jobController.refreshJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text("Your Jobs", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Hired Professionals',
            icon: const Icon(Icons.groups_outlined, color: Colors.black),
            onPressed: () => Get.to(() => const HiredProfessionalsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (jobController.isLoading.value && jobController.jobs.isEmpty) {
          return const CustomLoader(message: "Loading jobs...");
        }

        if (jobController.jobs.isEmpty) {
          return const AppEmptyState(
            icon: Icons.work_outline,
            title: "No jobs posted yet",
            subtitle: "Tap “Post Job” below to create your first listing.",
          );
        }

        return RefreshIndicator(
          onRefresh: () => jobController.refreshJobs(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Obx(() {
                final stats = jobController.stats.value;
                if (stats == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _JobStatsBanner(stats: stats),
                );
              }),
              ...jobController.jobs.asMap().entries.map((entry) {
                final index = entry.key;
                final job = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < jobController.jobs.length - 1 ? 16 : 0,
                  ),
                  child: JobCard(
                    job: job,
                    jobController: jobController,
                    onEdit: () async {
                      await Get.to(() => PostJobScreen(jobToEdit: job));
                      // Refresh jobs after returning from edit screen
                      jobController.refreshJobs();
                    },
                    onCardTap: () {
                      // Navigate to applications screen filtered by this job
                      Get.to(() => JobApplicationsScreen(jobId: job.jobId));
                    },
                  ),
                );
              }),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5C5C),
        onPressed: () async {
          await Get.to(() => const PostJobScreen());
          // Refresh jobs after returning from post job screen
          jobController.refreshJobs();
        },
        icon: SvgPicture.asset(
          'assets/add_circle.svg',
          width: 24,
          height: 24,
          color: Colors.white,
        ),
        label: const Text("Post Job", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final JobModel job;
  final JobController jobController;
  final VoidCallback onEdit;
  final VoidCallback? onCardTap;

  const JobCard({
    super.key,
    required this.job,
    required this.jobController,
    required this.onEdit,
    this.onCardTap,
  });

  String _getDefaultImage(String role) {
    if (role.toLowerCase().contains('driver')) {
      return AppImages.driver;
    }
    return AppImages.mechanics;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppUi.radius),
          boxShadow: AppUi.softShadow,
        ),
        child: Column(
          children: [
            // Image with Edit Icon overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: job.imagePaths.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: job.imagePaths.first,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 140,
                            color: Colors.grey[200],
                            child: const Center(child: CustomLoader.small()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 140,
                            color: Colors.grey[200],
                            child: Image.asset(
                              _getDefaultImage(job.role),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Image.asset(
                          _getDefaultImage(job.role),
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                ),
                // Edit Icon on top right corner of image
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Color(0xFFF36969),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role & Icons
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              job.role,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            Obx(() {
                              final applicationCount = jobController
                                  .getApplicationCount(job.jobId);
                              if (applicationCount > 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF317873),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$applicationCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Status chip with quick status change (Active/Paused/Closed)
                      Obx(() {
                        final currentJob = jobController.jobs.firstWhere(
                          (j) => j.jobId == job.jobId,
                          orElse: () => job,
                        );
                        final status = currentJob.status.isNotEmpty
                            ? currentJob.status
                            : 'Active';
                        final color = status == 'Active'
                            ? Colors.green
                            : status == 'Paused'
                                ? Colors.orange
                                : Colors.grey;
                        return PopupMenuButton<String>(
                          tooltip: 'Change status',
                          onSelected: (s) =>
                              jobController.updateJobStatus(job.jobId, s),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'Active', child: Text('Active')),
                            PopupMenuItem(value: 'Paused', child: Text('Paused')),
                            PopupMenuItem(value: 'Closed', child: Text('Closed')),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, size: 16, color: color),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                      // Share Button
                      GestureDetector(
                        onTap: () {
                          ShareService.shareJob(
                            jobId: job.jobId,
                            jobTitle: job.role,
                            city: job.city,
                            jobType: job.jobType,
                            jobDuration: job.jobDuration,
                            openings: job.openings,
                            salary: job.salary,
                            description: job.description,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.share,
                            size: 18,
                            color: Color(0xFF6C7278),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow("Duration", job.jobDuration),
                  _infoRow("Openings", job.openings.toString()),
                  _infoRow("Salary", job.salary.isNotEmpty ? job.salary : '—'),
                  _infoRow("City", job.city),
                  if (job.views > 0) _infoRow("Views", job.views.toString()),
                  _infoRow("Description", job.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF8C8C8C),
              ),
            ),
          ),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Compact statistics banner shown above the employer's job list.
class _JobStatsBanner extends StatelessWidget {
  final JobStats stats;
  const _JobStatsBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatTile(value: '${stats.activeJobs}', label: 'Active', color: AppUi.green),
          _divider(),
          StatTile(value: '${stats.totalApplications}', label: 'Applicants'),
          _divider(),
          StatTile(value: '${stats.pendingApplications}', label: 'Pending', color: AppUi.amber),
          _divider(),
          StatTile(value: '${stats.hiredCount}', label: 'Hired', color: AppUi.blue),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 32, color: AppUi.border);
}

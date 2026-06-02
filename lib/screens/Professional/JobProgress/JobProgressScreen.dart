// import 'package:flutter/material.dart';

// class JobProgressScreen extends StatelessWidget {
//   const JobProgressScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Job Progress'),
//       ),
//       body: const Center(
//         child: Text('Job Progress Screen'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../controllers/Professional/job_progress_controller.dart';
import '../../../models/job_model.dart';
import '../JobDetails/JobDetailsScreen.dart';
import '../../../widgets/custom_loader.dart';

class JobProgressScreen extends StatelessWidget {
  const JobProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(JobProgressController());

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
            "Job Progress",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          leading: const SizedBox.shrink(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Applied Jobs",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Track your job application status",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),

                // 🔍 Search bar + filter
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            controller.updateSearchQuery(value);
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Iconsax.search_normal_1,
                              size: 20,
                            ),
                            hintText: "Search jobs...",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.sort,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: controller.selectedFilter.value,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.black),
                        items:
                            [
                                  "All",
                                  "pending",
                                  "reviewed",
                                  "shortlisted",
                                  "rejected",
                                  "hired",
                                ]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      value == 'All'
                                          ? 'All'
                                          : value[0].toUpperCase() +
                                                value.substring(1),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateFilter(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🧾 Applied Jobs List
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CustomLoader.small(),
                      ),
                    );
                  }

                  final filteredJobs = controller.filteredAppliedJobs;

                  if (filteredJobs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchQuery.value.isNotEmpty ||
                                      controller.selectedFilter.value != 'All'
                                  ? "No jobs found"
                                  : "No applied jobs yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.searchQuery.value.isNotEmpty ||
                                      controller.selectedFilter.value != 'All'
                                  ? "Try adjusting your search or filter"
                                  : "Apply for jobs to see them here",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredJobs
                        .map((job) => JobCard(job: job))
                        .toList(),
                  );
                }),

                const SizedBox(height: 20),
                const Text(
                  "My Saved Jobs",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.isSavedLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CustomLoader.small(),
                      ),
                    );
                  }
                  if (controller.savedJobs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "No saved jobs yet",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: controller.savedJobs
                        .map(
                          (job) => JobCard(
                            job: job,
                            onUnsave: () => controller.unsaveJob(job.id),
                          ),
                        )
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final JobModel job;

  /// When provided this card represents a *saved* job and shows a remove action
  /// instead of the application status badge.
  final VoidCallback? onUnsave;

  const JobCard({super.key, required this.job, this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final app = job.myApplication;
    final status = app?.status ?? '';

    Color statusBg;
    Color statusFg;
    switch (status) {
      case 'hired':
        statusBg = Colors.green.shade50;
        statusFg = Colors.green;
        break;
      case 'rejected':
        statusBg = Colors.red.shade50;
        statusFg = Colors.red;
        break;
      case 'shortlisted':
        statusBg = const Color(0xFFEDE9FE);
        statusFg = const Color(0xFF7C3AED);
        break;
      case 'reviewed':
        statusBg = const Color(0xFFDBEAFE);
        statusFg = const Color(0xFF2563EB);
        break;
      default:
        statusBg = Colors.orange.shade50;
        statusFg = Colors.orange;
    }

    final title = job.title.isNotEmpty
        ? (job.city.isNotEmpty ? "${job.title} - ${job.city}" : job.title)
        : (job.description.isNotEmpty ? job.description : "Job");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.length > 40 ? "${title.substring(0, 40)}..." : title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  job.type.isNotEmpty ? job.type : job.city,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (job.salary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    job.salary,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (app?.appliedDateFormatted.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Applied on ${app!.appliedDateFormatted}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),

          // Right side content
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (onUnsave != null)
                GestureDetector(
                  onTap: onUnsave,
                  child: const Icon(
                    Icons.bookmark_remove,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                )
              else if (app != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.statusLabel,
                    style: TextStyle(
                      color: statusFg,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Get.to(() => JobDetailsScreen(job: job));
                },
                child: const Text(
                  "→ View Details",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

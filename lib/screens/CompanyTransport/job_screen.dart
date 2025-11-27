import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'job_form_screen.dart';
import 'job_application_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/job_controller.dart';
import '../../models/job_model.dart';

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
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Your Jobs", style: TextStyle(color: Colors.black)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                Get.to(() => JobApplicationsScreen());
              },
              child: const Text(
                "Applications",
                style: TextStyle(color: Colors.black38),
              ),
            ),
          ],
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
                  "Tap the button below to post your first job",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => jobController.refreshJobs(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: jobController.jobs.asMap().entries.map((entry) {
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
                ),
              );
            }).toList(),
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

  const JobCard({
    super.key,
    required this.job,
    required this.jobController,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Card
        Container(
          margin: const EdgeInsets.only(
            bottom: 30,
          ), // leave space for overlay button
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Image
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
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 140,
                          color: Colors.grey[200],
                child: Image.asset(
                            "assets/jobdescription.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Image.asset(
                        "assets/jobdescription.png",
                  width: double.infinity,
                  height: 140,
                        fit: BoxFit.cover,
                ),
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
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            job.role,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() {
                          final currentJob = jobController.jobs.firstWhere(
                            (j) => j.jobId == job.jobId,
                            orElse: () => job,
                          );
                          return GestureDetector(
                            onTap: () {
                              jobController.toggleJobLike(job.jobId);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  currentJob.isLiked 
                                      ? Icons.favorite 
                                      : Icons.favorite_border,
                                  size: 24,
                                  color: currentJob.isLiked 
                                      ? AppColors.buttonBg 
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${currentJob.likeCount}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: currentJob.isLiked 
                                        ? AppColors.buttonBg 
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // Share job details
                            Share.share(
                              "Job: ${job.role}\n"
                              "Duration: ${job.jobDuration}\n"
                              "Openings: ${job.openings}\n"
                              "Salary: ₹${job.salary}\n"
                              "City: ${job.city}\n"
                              "Description: ${job.description}",
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/shareBtnWBg.svg',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _infoRow("Duration", job.jobDuration),
                    _infoRow("Openings", job.openings.toString()),
                    _infoRow("Salary", "₹${job.salary}"),
                    _infoRow("City", job.city),
                    _infoRow("Job Type", job.jobType),
                    _infoRow("Description", job.description),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Edit Button (Overlayed)
        Positioned(
          right: 16,
          bottom: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C5C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              elevation: 4,
            ),
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16, color: Colors.white),
            label: const Text("Edit", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
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

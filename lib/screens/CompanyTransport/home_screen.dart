import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/CompanyTransport/dashboard.dart';
import 'package:wheelboard/screens/CompanyTransport/notification_screen.dart';
import '../../controllers/Transport/notification_controller.dart';
import 'banner_carousel.dart';
import 'fleet_userprofile.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'companyuser_profile_screen.dart';
import 'service_dashboard.dart';
import 'services_screen.dart';
import '../../utils/share_service.dart';
import 'job_form_screen.dart';
import '../Professional/TransactionSummary/TransactionSummaryScreen.dart';
import 'professional_list.dart';
import 'fleet_screen.dart';
import '../../controllers/Transport/user_profile_controller.dart';
import '../../utils/constants.dart';
import 'package:wheelboard/controllers/Transport/job_controller.dart';
import 'package:wheelboard/screens/CompanyTransport/job_screen.dart';
import '../../controllers/Professional/feeds_controller.dart';
import 'feed_screen.dart';
import '../../services/auth_service.dart';
import '../../controllers/Transport/post_controller.dart';
import '../../widgets/custom_loader.dart';
import '../../utils/app_logger.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final List<Map<String, dynamic>> menuItems = [
    {'icon': 'assets/vehicle.svg', 'label': 'Vehicles'},
    {'icon': 'assets/professional.svg', 'label': 'Professional'},
    {'icon': 'assets/expense.svg', 'label': 'Expenses'},
    {'icon': 'assets/hire.svg', 'label': 'Hire'},
    {'icon': 'assets/servicelogo.svg', 'label': 'Services'},
    {'icon': 'assets/dashboard.svg', 'label': 'Dashboard'},
  ];

  final List<Map<String, dynamic>> stats = [
    {
      'label': 'Services',
      'value': 5,
      'icon': Icons.work_outline,
      'bgColor': Color(0xFFFFF1D6),
      'iconColor': Color(0xFFFBAE4B),
    },
    {
      'label': 'Leads',
      'value': 12,
      'icon': Icons.show_chart,
      'bgColor': Color(0xFFE1FFF3),
      'iconColor': Color(0xFFFB4B74),
    },
  ];
  final String profileImage = 'https://i.pravatar.cc/100';

  @override
  Widget build(BuildContext context) {
    // Use Get.put to be safe - it will return existing instance if already registered
    final profileController = Get.put(UserProfileController());
    final jobController = Get.put(JobController());
    final feedsController = Get.put(FeedsController());
    final notificationController = Get.put(NotificationController());

    // Fetch profile and notifications on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchCurrentUserProfile();
      notificationController.refreshNotifications();
    });

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4E3E3,
      ), // Light pink background from Figma
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Obx(() {
                  final profile = profileController.userProfile.value;
                  final companyName =
                      profile?.displayName ?? 'Delhi Transport.';

                  // Use random profile image - fallback to random avatar service
                  String profileImageUrl =
                      'https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 70}';

                  // Get profile image URL - handle both full URLs and relative paths
                  if (profile != null &&
                      profile.profileImage != null &&
                      profile.profileImage!.isNotEmpty) {
                    final imagePath = profile.profileImage!;
                    // If it's already a full URL, use it as is; otherwise prepend base URL
                    profileImageUrl =
                        imagePath.startsWith('http://') ||
                            imagePath.startsWith('https://')
                        ? imagePath
                        : ApiConstants.baseUrl + imagePath;
                  }

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => CompanyProfileScreen());
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFF25C5C),
                          backgroundImage: NetworkImage(profileImageUrl),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Link fails
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome!',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              companyName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        final unreadCount = notificationController.unreadCount;

                        return GestureDetector(
                          onTap: () {
                            Get.to(() => const NotificationScreen());
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Red square with rounded corners and white bell
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors
                                      .buttonBg, // AppColors.buttonBg (red)
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),

                              // Unread count badge
                              if (unreadCount > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(
                                        0xFF317873,
                                      ), // AppColors.badge
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Center(
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
                const SizedBox(height: 20),

                /// Banner Image
                BannerCarousel(),
                const SizedBox(height: 20),

                /// Menu Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = 3;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: menuItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return GestureDetector(
                          onTap: () {
                            // Handle tap here
                            AppLogger.d(
                              'Tapped on item: ${item['label']} (Index: $index)',
                            );

                            // Vehicles tab
                            if (index == 0) {
                              // Navigate to Fleet Vehicles Screen
                              Get.to(() => FleetVehiclesScreen());
                            }
                            // Professional tab
                            if (index == 1) {
                              // Navigate to Professional List Screen
                              Get.to(() => const ProfessionalListScreen());
                            }
                            if (index == 2) {
                              // Expenses - Navigate to Transaction Summary Screen
                              Get.to(() => TransactionSummaryScreen());
                            }
                            if (index == 3) {
                              // Hire - Navigate to Post Job Screen
                              Get.to(() => PostJobScreen());
                            }
                            if (index == 4) {
                              // Navigate, show dialog, etc.
                              Get.to(() => ServiceDashboardScreen());
                            }

                            if (index == 5) {
                              // Navigate, show dialog, etc.
                              Get.to(() => DashboardScreen());
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _getIconBgColor(index),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      item['icon'],
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  child: Text(
                                    item['label'],
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: const Color(0xFF535353),
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Jobs Created",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const JobsScreen());
                      },
                      child: Text(
                        "view more",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Job Card
                Obx(() {
                  if (jobController.isLoading.isTrue) {
                    return const CustomLoader(message: "Loading jobs...");
                  }

                  if (jobController.jobs.isEmpty) {
                    return const Center(child: Text("No recent jobs."));
                  }

                  // Display first 5 jobs
                  final recentJobs = jobController.jobs.take(5).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentJobs.length,
                    itemBuilder: (context, index) {
                      final job = recentJobs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title + Call Now
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (job.companyName != null &&
                                          job.companyName!.isNotEmpty) ...[
                                        Text(
                                          job.companyName!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.buttonBg,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Text(
                                        job.role,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox.shrink(),
                              ],
                            ),
                            const SizedBox(height: 8),

                            /// Likes + Applicants
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    jobController.toggleJobLike(job.jobId);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        job.isLiked
                                            ? Icons.thumb_up
                                            : Icons.thumb_up_alt_outlined,
                                        size: 16,
                                        color: job.isLiked
                                            ? AppColors.buttonBg
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${job.likeCount} Likes",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: job.isLiked
                                                  ? AppColors.buttonBg
                                                  : null,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.person_outline, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${job.openings} Positions",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            /// Share + Services
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Use ShareService for proper Wheelboard URL
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00AEEF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "Share",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.to(
                                        () => PostJobScreen(jobToEdit: job),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFFD1E5E2,
                                      ), // Light green from Figma
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "Edit",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFFFF5E5E),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Feeds",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const FeedScreen());
                      },
                      child: Text(
                        "view more",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (feedsController.isLoading.isTrue) {
                    return const CustomLoader(message: "Loading feeds...");
                  }

                  if (feedsController.feeds.isEmpty) {
                    return const Center(child: Text("No popular feeds."));
                  }

                  // Display first 5 feeds
                  final popularFeeds = feedsController.feeds.take(5).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: popularFeeds.length,
                    itemBuilder: (context, index) {
                      final feed = popularFeeds[index];
                      return _buildFeedPostCard(context, feed);
                    },
                  );
                }),

                /// Delhi Transport Footer
                const SizedBox(height: 100), // space for nav bar
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => ServicesScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              minimumSize: const Size(137.906, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/servicelogo.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Services",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Get.to(() => PostJobScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              minimumSize: const Size(137.906, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  "Post Job",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// Bottom Nav Bar
    );
  }

  Widget _buildFeedPostCard(BuildContext context, Post post) {
    // Use company logo if available, otherwise use a placeholder
    final companyLogoUrl =
        post.companyLogo != null && post.companyLogo!.isNotEmpty
        ? post.companyLogo!
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              // Navigate to dynamic profile screen
              Get.to(() => FleetUserprofile(companyId: post.companyId));
            },
            borderRadius: BorderRadius.circular(50),
            child: Row(
              children: [
                // Company Logo or Profile Avatar
                companyLogoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _formatImageUrl(companyLogoUrl),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          headers: _imageHeaders(),
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to initials avatar if logo fails to load
                            return CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFFFE6E6),
                              child: Text(
                                post.userName.isNotEmpty
                                    ? post.userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF25C5C),
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFFFE6E6),
                        child: Text(
                          post.userName.isNotEmpty
                              ? post.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF25C5C),
                            fontSize: 16,
                          ),
                        ),
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName.isNotEmpty ? post.userName : "User",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.category,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Post Content
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),

          // Post Images
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.imageUrls.length == 1
                  ? SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        _formatImageUrl(post.imageUrls[0]),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        headers: _imageHeaders(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              "assets/truck.png",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Image not available",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: post.imageUrls.length > 4
                          ? 4
                          : post.imageUrls.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            child: Image.network(
                              _formatImageUrl(post.imageUrls[index]),
                              fit: BoxFit.cover,
                              headers: _imageHeaders(),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],

          // If no content and no images, show placeholder image
          if (post.content.isEmpty && post.imageUrls.isEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset("assets/truck.png"),
            ),
          ],

          const SizedBox(height: 10),

          // Reactions - Now Functional!
          Obx(() {
            final feedsController = Get.find<FeedsController>();
            final isLiked = feedsController.isLiked(post.postId);

            return Row(
              children: [
                // Like Button - Functional
                GestureDetector(
                  onTap: () {
                    feedsController.toggleLike(post.postId);
                  },
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 28,
                    color: isLiked
                        ? const Color(0xFFF36969)
                        : const Color(0xFFFCACAC),
                  ),
                ),
                const SizedBox(width: 10),
                // Share Button - Functional
                GestureDetector(
                  onTap: () {
                    ShareService.sharePost(
                      postId: post.postId,
                      content: post.content,
                      userName: post.userName,
                      category: post.category,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/share.svg',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                // View Button - Navigate to Feed Screen
                GestureDetector(
                  onTap: () {
                    Get.to(() => const FeedScreen());
                  },
                  child: SvgPicture.asset(
                    'assets/eye.svg',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: post.status == 'Pending'
                        ? Colors.orange[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: post.status == 'Pending'
                          ? Colors.orange[800]
                          : Colors.green[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(post.timeAgo, style: const TextStyle(color: Colors.grey)),
              if (post.content.length > 100)
                const Text(
                  "Read More",
                  style: TextStyle(color: Colors.blueAccent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIconBgColor(int index) {
    // Color mapping for menu items based on Figma design
    switch (index) {
      case 0:
        return const Color(0xFFE3F2FD); // Vehicles - Light blue
      case 1:
        return const Color(0xFFE0F7FA); // Professional - Light teal
      case 2:
        return const Color(0xFFFFF3E0); // Expenses - Light orange
      case 3:
        return const Color(0xFFFCE4EC); // Hire - Light pink
      case 4:
        return const Color(0xFFFFF8E1); // Services - Light yellow
      case 5:
        return const Color(0xFFE0E0E0); // Dashboard - Light grey
      default:
        return Colors.grey;
    }
  }

  String _formatImageUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Uri.encodeFull(url);
    }
    return Uri.encodeFull(ApiConstants.baseUrl + url);
  }

  Map<String, String>? _imageHeaders() {
    final token = AuthService.to.currentToken;
    if (token.isEmpty) return null;
    return {'Authorization': 'Bearer $token', 'Accept': '*/*'};
  }
}

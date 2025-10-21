import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/dashboard.dart';
import 'package:wheelboard/screens/notification.dart';
import 'banner_carousel.dart';
import 'fleet_userprofile.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'companyuser_profile_screen.dart';
import 'services_screen.dart';
import 'driver_profile.dart';
import 'package:share_plus/share_plus.dart';
import 'bottom_navigation.dart';

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
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(CompanyProfileScreen());
                      },
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=4',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Delhi Transport.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(NotificationsScreen());
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

                          // Small teal-green badge
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF317873), // AppColors.badge
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stack(
                    //   clipBehavior: Clip.none,
                    //   children: [
                    //     // Red square with rounded corners and white bell
                    //     Container(
                    //       padding: EdgeInsets.all(8),
                    //       decoration: BoxDecoration(
                    //         color:
                    //             AppColors.buttonBg, // AppColors.buttonBg (red)
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       child: Icon(
                    //         Icons.notifications,
                    //         color: Colors.white,
                    //         size: 26,
                    //       ),
                    //     ),

                    //     // Small teal-green badge
                    //     Positioned(
                    //       top: 4,
                    //       right: 4,
                    //       child: Container(
                    //         width: 10,
                    //         height: 10,
                    //         decoration: BoxDecoration(
                    //           color: Color(
                    //             0xFF317873,
                    //           ), // Example: AppColors.badge (teal green)
                    //           shape: BoxShape.circle,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Banner Image
                BannerCarousel(),
                const SizedBox(height: 20),

                /// Menu Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: menuItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return GestureDetector(
                          onTap: () {
                            // Handle tap here
                            print(
                              'Tapped on item: ${item['label']} (Index: $index)',
                            );

                            // Example: If second item tapped
                            if (index == 1) {
                              // Navigate, show dialog, etc.
                              Get.to(() => const BottomNavScreen(initialIndex: 1));
                            }
                            if (index == 2) {
                              // Navigate, show dialog, etc.
                              Get.to(DriverProfileScreen());
                            }

                            if (index == 4) {
                              // Navigate, show dialog, etc.
                              Get.to(ServicesScreen());
                            }

                            if (index == 5) {
                              // Navigate, show dialog, etc.
                              Get.to(DashboardScreen());
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  item['icon'],
                                  height: 32,
                                  width: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['label'],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
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
                Text(
                  "My Services",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                /// Job Card
                Container(
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
                            child: Text(
                              "Concor Bangalore",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.buttonBg,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Call Now",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.buttonBg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      /// Likes + Applicants
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text("35 Likes", style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(width: 12),
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 4),
                          Text("0 Applicants", style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// Share + Services
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Share.share("WheelBoard");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00AEEF),
                                shape: const StadiumBorder(),
                              ),
                              icon: const Icon(Icons.share, color: Colors.white),
                              label: Text(
                                "Share",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD1E5E2),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                "Edit",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.buttonBg,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
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
                        // handle navigation or callback
                      },
                      child: Text(
                        "View More",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildPostCard(context),

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
              Get.to(ServicesScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD6C6C),
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              "Services",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Get.to(ServicesScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg,
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              "+ Post Job",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),

      /// Bottom Nav Bar
    );
  }

  Widget buildPostCard(BuildContext context) {
    return Container(
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
              // handle tap here
              Get.to(FleetUserprofile());
            },
            borderRadius: BorderRadius.circular(50), // optional ripple radius
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(profileImage)),
                const SizedBox(width: 10),
                Text(
                  "Delhi Transport",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset("assets/truck.png"),
          ),
          const SizedBox(height: 10),

          // Reactions
          Row(
            children: [
              SvgPicture.asset(
                'assets/heart.svg',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              SvgPicture.asset(
                'assets/share.svg',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              SvgPicture.asset(
                'assets/eye.svg',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title + Description
          Text(
            "Tips For Fleet Management",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Learn how to optimize your fleet operations and reduce costs",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Posted 2 days ago", 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              Text(
                "Read More", 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../TransactionSummary/TransactionSummaryScreen.dart';
import '../TrackTrip/TrackTripScreen.dart';
import '../widgets/professional_header_widget.dart';
import '../widgets/banner_header_widget.dart';
import '../widgets/quick_action_button_widget.dart';
import '../widgets/trip_card_widget.dart';
import '../widgets/job_card_widget.dart';
import '../Calendar/CalendarScreen.dart';

import '../EarningSummary/EarningSummaryScreen.dart';
import '../MyLearning/MyLearningScreen.dart';
import '../TripDashboard/TripDashboardScreen.dart';
import '../TripProgress/TripProgressScreen.dart';
import '../SOS/SOSScreen.dart';
import '../../../controllers/Professional/open_jobs_controller.dart';
import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../widgets/custom_loader.dart';

/// Professional Homepage Screen
/// Main screen matching Figma design exactly
class ProfessionalHomePageScreen extends StatelessWidget {
  const ProfessionalHomePageScreen({super.key});

  String _formatDate(DateTime? date, String time) {
    if (date == null) return time;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    final timeStr = time.isNotEmpty
        ? ' – ${time.substring(0, time.length > 5 ? 5 : time.length)}'
        : '';
    return "$dateStr$timeStr";
  }

  @override
  Widget build(BuildContext context) {
    final AssignedTripController assignedTripController = Get.put(
      AssignedTripController(),
    );
    final notificationController = Get.put(NotificationController());

    // Fetch notifications on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationController.fetchNotifications();
    });

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavBarHeight =
        bottomPadding + 76; // Bottom nav height (76) + safe area padding

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Top Header (Red) - Responsive
                  const ProfessionalHeaderWidget(),

                  // Banner Section with overlapping elements - Responsive
                  Stack(
                    clipBehavior:
                        Clip.none, // Allow overflow - don't clip trip card
                    children: [
                      // Banner background - Responsive height
                      SizedBox(
                        height: screenHeight * 0.23, // ~23% of screen height
                        child: const BannerHeaderWidget(),
                      ),
                      // Quick Action Buttons - Overlapping on banner - Responsive
                      Positioned(
                        top: screenHeight * 0.02, // Responsive top position
                        left: screenWidth * 0.025, // Responsive left padding
                        right: screenWidth * 0.025, // Responsive right padding
                        height: screenHeight * 0.11, // Responsive height
                        child: _buildQuickActions(
                          context,
                          assignedTripController,
                        ),
                      ),
                      // Next Scheduled Trip Card - Overlapping on banner - Responsive
                      Positioned(
                        top: screenHeight * 0.16, // Responsive top position
                        left: screenWidth * 0.04, // Responsive left padding
                        right: screenWidth * 0.04, // Responsive right padding
                        child: Obx(() {
                          if (assignedTripController.isLoading.value) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const CustomLoader.small(),
                            );
                          }

                          // Filter trips to only show those that are NOT completed or cancelled
                          final activeTrips = assignedTripController
                              .assignedTrips
                              .where((trip) {
                                final status = trip.tripStatus.toLowerCase();
                                return status != 'completed' &&
                                    status != 'cancelled';
                              })
                              .toList();

                          if (activeTrips.isEmpty) {
                            return const TripCardWidget(
                              pickupAddress: "No trips available",
                              destinationAddress:
                                  "Check back later for new trips",
                              dateTime: "",
                              tags: [],
                            );
                          }

                          final trip = activeTrips.first;
                          final tags = [
                            trip.tripStatus.capitalizeFirst ?? 'Assigned',
                          ].where((t) => t.isNotEmpty).toList();

                          return GestureDetector(
                            onTap: () {
                              final trips =
                                  assignedTripController.assignedTrips;

                              final active = trips.firstWhereOrNull((t) {
                                final s = t.tripStatus.toLowerCase();
                                return [
                                  'in progress',
                                  'inprogress',
                                  'active',
                                  'ongoing',
                                  'en route',
                                ].contains(s);
                              });

                              if (active != null) {
                                Get.to(
                                  () => TrackTripScreen(tripId: active.tripId),
                                );
                                return;
                              }

                              final next = trips.firstWhereOrNull((t) {
                                final s = t.tripStatus.toLowerCase();
                                return s != 'completed' && s != 'cancelled';
                              });

                              if (next != null) {
                                Get.to(() => TripProgressScreen(trip: next));
                              } else {
                                Get.to(() => const TripDashboardScreen());
                              }
                            },
                            child: TripCardWidget(
                              pickupAddress: trip.pickupLocation,
                              destinationAddress: trip.deliveryLocation,
                              dateTime: _formatDate(
                                trip.pickupDate,
                                trip.pickupTime,
                              ),
                              tags: tags,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Spacing to push jobs section below trip card - Calculate properly
                  // Trip card starts at: screenHeight * 0.16 (within banner)
                  // Banner ends at: screenHeight * 0.23
                  // Trip card extends below banner - we need to account for full card height
                  // Using generous spacing to ensure no overlap: banner end + card extension + margin
                  SizedBox(
                    height: (screenHeight * 0.20) + 40,
                  ), // Generous spacing to ensure trip card ends before jobs section
                  // Jobs Section - Below banner and cards
                  _buildJobsSection(context),

                  // Bottom padding for floating buttons + bottom nav bar - Responsive
                  SizedBox(
                    height: bottomNavBarHeight + 100,
                  ), // Space for floating buttons + bottom nav
                ],
              ),
            ),

            // Fixed Bottom Action Button - SOS only (Invite moved to Profile)
            Positioned(
              right: screenWidth * 0.04, // Responsive right padding
              bottom:
                  bottomNavBarHeight -
                  50, // Much closer to bottom navigation bar - Responsive
              child:
                  // SOS Button - Responsive
                  GestureDetector(
                    onTap: () {
                      Get.to(const SOSScreen());
                    },
                    child: Container(
                      width:
                          screenWidth * 0.3, // Responsive width (30% of screen)
                      height: 43.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5E5E),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "SOS",
                          style: GoogleFonts.poppins(
                            fontSize:
                                screenWidth * 0.04, // Responsive font size
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.325,
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Actions Row - Responsive
  Widget _buildQuickActions(
    BuildContext context,
    AssignedTripController assignedTripController,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSpacing =
        screenWidth * 0.02; // Responsive spacing between buttons

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: QuickActionButtonWidget(
            icon: Icons.calendar_today,
            title: "My\ncalendar",
            onTap: () => Get.to(const CalendarScreen()),
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: QuickActionButtonWidget(
            icon: Icons.my_location,
            title: "Track\nMy Trip",
            onTap: () async {
              await assignedTripController.fetchAssignedTrips();
              final trips = assignedTripController.assignedTrips;

              final active = trips.firstWhereOrNull((t) {
                final s = t.tripStatus.toLowerCase();
                return [
                  'in progress',
                  'inprogress',
                  'active',
                  'ongoing',
                  'en route',
                ].contains(s);
              });

              if (active != null) {
                Get.to(() => TrackTripScreen(tripId: active.tripId));
                return;
              }

              final next = trips.firstWhereOrNull((t) {
                final s = t.tripStatus.toLowerCase();
                return s != 'completed' && s != 'cancelled';
              });

              if (next != null) {
                Get.to(() => TripProgressScreen(trip: next));
              } else {
                Get.to(() => const TripDashboardScreen());
              }
            },
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: QuickActionButtonWidget(
            icon: Icons.attach_money,
            title: "Earning",
            onTap: () => Get.to(const EarningSummaryScreen()),
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: QuickActionButtonWidget(
            icon: Icons.add_circle_outline,
            title: "Add\nExpenses",
            onTap: () => Get.to(() => TransactionSummaryScreen()),
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: QuickActionButtonWidget(
            icon: Icons.school_outlined,
            title: "My\nLearning",
            onTap: () => Get.to(const MyLearningScreen()),
          ),
        ),
      ],
    );
  }

  /// Builds the jobs section with a title and a list of job cards
  Widget _buildJobsSection(BuildContext context) {
    final OpenJobsController jobsController = Get.put(OpenJobsController());
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
      ), // Responsive padding (5% of screen width)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header - Responsive
          Text(
            "Jobs",
            style: GoogleFonts.poppins(
              fontSize:
                  screenWidth *
                  0.04, // Responsive font size (4% of screen width)
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          SizedBox(height: screenWidth * 0.03), // Responsive spacing
          // Job Cards - Using Obx to reactively update when jobs are loaded
          Obx(() {
            if (jobsController.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CustomLoader(message: "Loading jobs..."),
                ),
              );
            }

            if (jobsController.openJobs.isEmpty) {
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
                        "No jobs available",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Check back later for new opportunities",
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
              children: jobsController.openJobs.asMap().entries.map((entry) {
                final index = entry.key;
                final job = entry.value;

                // Use companyName from API, fallback to role or city
                final displayCompanyName =
                    (job.companyName != null && job.companyName!.isNotEmpty)
                    ? job.companyName!
                    : (job.role.isNotEmpty ? job.role : "Company");

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < jobsController.openJobs.length - 1 ? 12 : 0,
                  ),
                  child: JobCardWidget(
                    companyName: displayCompanyName,
                    role: job.role, // Show role like Driver, Helper
                    city: job.city, // Show city
                    jobId: job.jobId,
                    likes: job.likeCount,
                    applicants:
                        job.openings, // This shows as "Openings" in widget
                    isApplying: jobsController.isApplying(job.jobId),
                    isApplied: job.isApplied,
                    isLiked: job.isLiked,

                    onLikeToggle: () async {
                      if (job.jobId.isNotEmpty) {
                        await jobsController.toggleJobLike(job.jobId);
                      }
                    },
                    onApplyNow: () async {
                      if (job.jobId.isNotEmpty && !job.isApplied) {
                        final success = await jobsController.applyForJob(
                          job.jobId,
                        );
                        if (success) {
                          // Refresh jobs after applying to update isApplied status
                          await jobsController.refreshOpenJobs();
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }
}

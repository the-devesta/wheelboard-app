import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/professional_header_widget.dart';
import '../widgets/banner_header_widget.dart';
import '../widgets/quick_action_button_widget.dart';
import '../widgets/trip_card_widget.dart';
import '../widgets/job_card_widget.dart';
import '../Calendar/CalendarScreen.dart';
import '../TrackTrip/TrackTripScreen.dart';
import '../EarningSummary/EarningSummaryScreen.dart';
import '../AddExpense/AddExpenseScreen.dart';
import '../MyLearning/MyLearningScreen.dart';
import '../SOS/SOSScreen.dart';
import '../AddReferral/AddReferralScreen.dart';
import '../../../controllers/Professional/open_jobs_controller.dart';

/// Professional Homepage Screen
/// Main screen matching Figma design exactly
class ProfessionalHomePageScreen extends StatelessWidget {
  const ProfessionalHomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(OpenJobsController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Top Header (Red)
                const ProfessionalHeaderWidget(),

                // Banner Section with overlapping elements
                Stack(
                  clipBehavior: Clip.none, // Allow overflow - don't clip trip card
                  children: [
                    // Banner background
                    const SizedBox(
                      height: 184,
                      child: BannerHeaderWidget(),
                    ),
                    // Quick Action Buttons - Overlapping on banner
                    Positioned(
                      top: 15, // 71 - 56 = 15 (offset from banner top)
                      left: 10,
                      right: 10,
                      height: 90,
                      child: _buildQuickActions(context),
                    ),
                    // Next Scheduled Trip Card - Overlapping on banner (will overflow below)
                    Positioned(
                      top: 127, // 183 - 56 = 127 (offset from banner top)
                      left: 16,
                      right: 16,
                      child: const TripCardWidget(
                        pickupAddress: "123 Main Street, AnyTown, CA 32132",
                        destinationAddress: "456 Oak Avenue, OtherTown, NY 100001",
                        dateTime: "Oct 26, 2024 – 10:00 AM",
                        tags: ["Cargo", "Fragile", "Lift Gate"],
                      ),
                    ),
                  ],
                ),

                // Spacing to push jobs section below trip card (trip card extends beyond banner)
                // Trip card starts at top: 127, height ~223px, so ends around 350px
                // Banner is 184px, so card overflows by ~166px
                // Need extra space for proper separation
                const SizedBox(height: 200), // Space for trip card to fully display + margin

                // Jobs Section - Below banner and cards
                _buildJobsSection(context),

                const SizedBox(height: 200), // Bottom padding for floating buttons
              ],
            ),
          ),

          // Fixed Floating Action Buttons - Invite and SOS (fixed bottom right)
          Positioned(
            right: 16,
            bottom: 20, // Above bottom navigation bar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Invite Button
                GestureDetector(
                  onTap: () {
                    Get.to(const AddReferralScreen());
                  },
                  child: Container(
                    width: 120,
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
                        "Invite",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.325,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // SOS Button
                GestureDetector(
                  onTap: () {
                    Get.to(const SOSScreen());
                  },
                  child: Container(
                    width: 120,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.325,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Actions Row
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        QuickActionButtonWidget(
          icon: Icons.calendar_today,
          title: "My\ncalendar",
          onTap: () => Get.to(const CalendarScreen()),
        ),
        QuickActionButtonWidget(
          icon: Icons.my_location,
          title: "Track\nMy Trip",
          onTap: () => Get.to(const TrackTripScreen()),
        ),
        QuickActionButtonWidget(
          icon: Icons.attach_money,
          title: "Earning",
          onTap: () => Get.to(const EarningSummaryScreen()),
        ),
        QuickActionButtonWidget(
          icon: Icons.add_circle_outline,
          title: "Add\nExpenses",
          onTap: () => Get.to(const AddExpenseScreen()),
        ),
        QuickActionButtonWidget(
          icon: Icons.school_outlined,
          title: "My\nLearning",
          onTap: () => Get.to(const MyLearningScreen()),
        ),
      ],
    );
  }

  /// Jobs Section
  Widget _buildJobsSection(BuildContext context) {
    final jobsController = Get.find<OpenJobsController>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Jobs",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune, size: 16, color: Color(0xFF003366)),
                    const SizedBox(width: 4),
                    Text(
                      "Filter",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF003366),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Job Cards - Using Obx to reactively update when jobs are loaded
          Obx(() {
            if (jobsController.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
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
                
                // Use role as company name, or city if role is empty
                final displayName = job.role.isNotEmpty 
                    ? job.role 
                    : (job.city.isNotEmpty ? job.city : "Job Opening");
                
                return Padding(
                  padding: EdgeInsets.only(bottom: index < jobsController.openJobs.length - 1 ? 12 : 0),
                  child: JobCardWidget(
                    companyName: displayName,
                    jobId: job.jobId,
                    likes: 0, // API doesn't provide likes, can be updated later
                    applicants: job.openings, // Using openings as applicants count
                    isApplying: jobsController.isApplying(job.jobId),
                    onCallNow: () {
                      // TODO: Implement call functionality
                      Get.snackbar("Info", "Call functionality coming soon");
                    },
                    onApplyNow: () async {
                      if (job.jobId.isNotEmpty) {
                        final success = await jobsController.applyForJob(job.jobId);
                        if (success) {
                          // Optionally refresh jobs after applying
                          // await jobsController.refreshOpenJobs();
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

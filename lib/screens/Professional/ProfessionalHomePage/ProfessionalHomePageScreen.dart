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
import '../FindJobs/FindJobsScreen.dart';
import '../SOS/SOSScreen.dart';
import '../AddReferral/AddReferralScreen.dart';

/// Professional Homepage Screen
/// Main screen matching Figma design exactly
class ProfessionalHomePageScreen extends StatelessWidget {
  const ProfessionalHomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Top Header (Red)
                  const ProfessionalHeaderWidget(),

                  // Banner Section
                  const BannerHeaderWidget(),

                  // Quick Action Buttons
                  _buildQuickActions(context),

                  const SizedBox(height: 12),

                  // Next Scheduled Trip Card
                  const TripCardWidget(
                    pickupAddress: "123 Main Street, AnyTown, CA 32132",
                    destinationAddress: "456 Oak Avenue, OtherTown, NY 100001",
                    dateTime: "Oct 26, 2024 – 10:00 AM",
                    tags: ["Cargo", "Fragile", "Lift Gate"],
                  ),

                  const SizedBox(height: 20),

                  // Jobs Section
                  _buildJobsSection(context),

                  // Bottom padding for floating buttons
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Floating Action Buttons - Invite and SOS
            Positioned(
              right: 16,
              bottom: 0, // Position above bottom nav
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
      ),
    );
  }

  /// Quick Actions Row
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            QuickActionButtonWidget(
              icon: Icons.calendar_today,
              title: "My\ncalendar",
              onTap: () => Get.to(const CalendarScreen()),
            ),
            const SizedBox(width: 15),
            QuickActionButtonWidget(
              icon: Icons.my_location,
              title: "Track\nMy Trip",
              onTap: () => Get.to(const TrackTripScreen()),
            ),
            const SizedBox(width: 15),
            QuickActionButtonWidget(
              icon: Icons.attach_money,
              title: "Earning",
              onTap: () => Get.to(const EarningSummaryScreen()),
            ),
            const SizedBox(width: 15),
            QuickActionButtonWidget(
              icon: Icons.add_circle_outline,
              title: "Add\nExpenses",
              onTap: () => Get.to(const AddExpenseScreen()),
            ),
            const SizedBox(width: 15),
            QuickActionButtonWidget(
              icon: Icons.school_outlined,
              title: "My\nLearning",
              onTap: () => Get.to(const MyLearningScreen()),
            ),
          ],
        ),
      ),
    );
  }

  /// Jobs Section
  Widget _buildJobsSection(BuildContext context) {
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF003366),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Fixed: Non-scrollable List inside SingleChildScrollView
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              JobCardWidget(
                companyName: "Concor Bangalore",
                likes: 35,
                applicants: 0,
                onCallNow: () {},
                onApplyNow: () => Get.to(const FindJobsScreen()),
              ),
              const SizedBox(height: 12),
              JobCardWidget(
                companyName: "Delhi Transport",
                likes: 20,
                applicants: 5,
             
                onCallNow: () {},
                onApplyNow: () => Get.to(const FindJobsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

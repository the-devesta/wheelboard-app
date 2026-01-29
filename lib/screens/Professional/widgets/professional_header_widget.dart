import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../CompanyTransport/notification_screen.dart';
import '../../../controllers/Transport/notification_controller.dart';
import '../YourProfile/YourProfileScreen.dart';

/// Professional Header Widget
/// Red header with back button, title, and notification bell
class ProfessionalHeaderWidget extends StatelessWidget {
  const ProfessionalHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.07, // Responsive height (~7% of screen height)
      decoration: const BoxDecoration(
        color: Color(0xFFFF5E5E), // Exact Figma red color
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
          ), // Responsive padding (4% of screen width)
          child: Row(
            children: [
              // Menu Icon (Left) - Responsive
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.to(const YourProfileScreen());
                },
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size:
                        screenWidth *
                        0.06, // Responsive icon size (6% of screen width)
                  ),
                ),
              ),
              const Spacer(),
              // Title - Centered - Responsive
              Text(
                "WHEELBOARD",
                style: GoogleFonts.poppins(
                  fontSize:
                      screenWidth *
                      0.06, // Responsive font size (6% of screen width)
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              // Notification Bell - Responsive
              Obx(() {
                final notificationController = Get.put(
                  NotificationController(),
                );
                final unreadCount = notificationController.unreadCount;

                return GestureDetector(
                  onTap: () {
                    Get.to(const NotificationScreen());
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width:
                            screenWidth *
                            0.1, // Responsive width (10% of screen width)
                        height: screenWidth * 0.1, // Responsive height
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size:
                              screenWidth *
                              0.06, // Responsive icon size (6% of screen width)
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF317873),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
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
          ),
        ),
      ),
    );
  }
}

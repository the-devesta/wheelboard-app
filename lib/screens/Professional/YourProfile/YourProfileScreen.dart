import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheelboard/widgets/common_delete_button.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../controllers/Transport/user_profile_controller.dart';
import '../../../models/user_profile_model.dart';
import '../../auth/onboarding_screen.dart' show RegisterScreen;
import '../EditYourProfile01/EditYourProfile01Screen.dart';
import '../../../widgets/custom_loader.dart';
import '../AddReferral/AddReferralScreen.dart';
import '../../../utils/app_logger.dart';
import '../../../controllers/Transport/driver_details_controller.dart';

class YourProfileScreen extends StatelessWidget {
  const YourProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(UserProfileController());
    final driverController = Get.put(DriverDetailsController());

    // Fetch profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchCurrentUserProfile();

      // Fetch driver details if user is a driver
      final profile = controller.userProfile.value;
      if (profile != null &&
          (profile.professionalType?.toLowerCase().contains('driver') ??
              false)) {
        driverController.fetchDriverDetails(profile.userId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3), // Pink background like Figma
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CustomLoader(message: "Loading profile..."),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage.value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchCurrentUserProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = controller.userProfile.value;

          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildProfileCard(profile),
                      const SizedBox(height: 24),
                      _buildKycBanner(),
                      const SizedBox(height: 20),

                      const SizedBox(height: 20),
                      _buildPersonalDetails(profile),
                      const SizedBox(height: 16),
                      _buildContactInfo(profile),
                      const SizedBox(height: 16),
                      // _buildWorkOverview(),
                      const SizedBox(height: 16),
                      _buildCompleteKyc(),
                      const SizedBox(height: 16),
                      _buildPlatformPreferences(),
                      const SizedBox(height: 16),
                      _buildSubscriptionPlans(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: Colors.white,
                        ),
                        child: CommonDeleteButton(
                          onConfirm: () {
                            AuthService().deleteAccount();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHelpCard(),
                      const SizedBox(height: 16),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back_ios, size: 16),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Your Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF36969),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(const EditYourProfile01Screen());
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.edit, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfileModel? profile) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.to(const EditYourProfile01Screen()),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF36969),
                      width: 4,
                    ),
                    image:
                        profile?.profileImagePath != null &&
                            profile!.profileImagePath!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile.profileImagePath!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle image load error
                            },
                          )
                        : null,
                    color:
                        profile?.profileImagePath == null ||
                            profile!.profileImagePath!.isEmpty
                        ? Colors.grey[300]
                        : null,
                  ),
                  child:
                      profile?.profileImagePath == null ||
                          profile!.profileImagePath!.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.to(const EditYourProfile01Screen()),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF36969),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile?.name ?? 'N/A',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
            ),
          ),
          const SizedBox(height: 8),
          if (profile?.professionalType != null &&
              profile!.professionalType!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8B8B), // Salmon/pink color like Figma
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                profile.professionalType!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 14, color: Color(0xFFF36969)),
              const SizedBox(width: 4),
              Text(
                '4.7 / 5',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF36969),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKycBanner() {
    // ✅ Check AuthService first (has login data)
    bool isKycComplete = false;
    try {
      final authService = AuthService.to;
      isKycComplete = authService.isUserKYCCompleted;
      AppLogger.d("🔐 KYC Status from AuthService in Profile: $isKycComplete");
    } catch (e) {
      // ✅ Fallback to profile controller
      final controller = Get.find<UserProfileController>();
      final profile = controller.userProfile.value;
      isKycComplete = profile?.isKYCCompleted ?? false;
      AppLogger.d("👤 KYC Status from Profile Controller: $isKycComplete");
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isKycComplete ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isKycComplete ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isKycComplete ? Icons.verified : Icons.warning_rounded,
            color: isKycComplete ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKycComplete ? 'KYC Verified' : '⚠️ Complete Your KYC',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isKycComplete
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isKycComplete
                      ? 'You can now apply for jobs and submit bids'
                      : 'Complete KYC to apply for jobs and submit bids',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isKycComplete
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isKycComplete ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}

Widget _buildPersonalDetails(UserProfileModel? profile) {
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String location = 'N/A';
  if (profile?.city != null && profile?.state != null) {
    location = '${profile!.city}, ${profile.state}';
  } else if (profile?.city != null) {
    location = profile!.city!;
  } else if (profile?.state != null) {
    location = profile!.state!;
  }

  return _buildCard(
    title: 'Personal Details',
    trailing: GestureDetector(
      onTap: () => Get.to(const EditYourProfile01Screen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, size: 14),
            const SizedBox(width: 4),
            Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
    children: [
      _buildInfoItem(Icons.person_outline, 'Name', profile?.name ?? 'N/A'),
      if (profile?.fatherName != null && profile!.fatherName!.isNotEmpty)
        _buildInfoItem(
          Icons.person_outline,
          'Father\'s Name',
          profile.fatherName!,
        ),
      if (profile?.dateOfBirth != null)
        _buildInfoItem(
          Icons.calendar_today,
          'Date of Birth',
          formatDate(profile?.dateOfBirth),
        ),
      _buildInfoItem(Icons.location_on, 'Address/Location', location),
    ],
  );
}

String _getMonthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

Widget _buildContactInfo(UserProfileModel? profile) {
  return _buildCard(
    title: 'Contact Information',
    children: [
      if (profile?.mobileNo != null)
        _buildEditableItem(Icons.phone, 'Mobile Number', profile!.mobileNo!),
      if (profile?.email != null && profile!.email!.isNotEmpty)
        _buildEditableItem(Icons.email, 'Email Address', profile.email!),
      if (profile?.mobileNo != null)
        _buildEditableItem(
          Icons.message,
          'WhatsApp Number',
          profile!.mobileNo!,
        ),
    ],
  );
}

Widget _buildWorkOverview() {
  return _buildCard(
    title: 'Work Overview',
    children: [
      Row(
        children: [
          Expanded(
            child: _buildStatCard(Icons.check_circle, '128', 'Jobs Completed'),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(Icons.star, '4.7', 'Current Rating')),
        ],
      ),
      const SizedBox(height: 16),
      _buildStatCard(
        Icons.event_available,
        'Available Today',
        '',
        isWide: true,
      ),
    ],
  );
}

Widget _buildStatCard(
  IconData icon,
  String value,
  String label, {
  bool isWide = false,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF535353)),
        const SizedBox(height: 12),
        if (isWide)
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF424242),
            ),
          )
        else if (value.isNotEmpty)
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        if (label.isNotEmpty && !isWide) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF757575),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildCompleteKyc() {
  // ✅ Check if KYC is already completed
  bool isKycComplete = false;
  try {
    final authService = AuthService.to;
    isKycComplete = authService.isUserKYCCompleted;
  } catch (e) {
    final controller = Get.find<UserProfileController>();
    final profile = controller.userProfile.value;
    isKycComplete = profile?.isKYCCompleted ?? false;
  }

  // ✅ If KYC is complete, don't show this section
  if (isKycComplete) {
    return const SizedBox.shrink();
  }

  final controller = Get.find<UserProfileController>();
  final profile = controller.userProfile.value;
  final professionalType = profile?.professionalType?.toLowerCase() ?? '';
  final isDriver = professionalType.contains('driver');

  return _buildCard(
    title: 'Complete KYC',
    titleTrailing: Text(
      'Required',
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF757575),
      ),
    ),
    children: [
      // Show Driving License for Drivers only
      if (isDriver)
        Obx(() {
          final driverController = Get.find<DriverDetailsController>();
          final driver = driverController.driverDetails.value;

          String status = 'Missing';
          Color statusColor = Colors.red;

          if (driver?.dlNumber != null && driver!.dlNumber!.isNotEmpty) {
            if (driver.isVerified) {
              status = 'Verified';
              statusColor = Colors.green;
            } else {
              status = 'Pending';
              statusColor = Colors.orange;
            }
          }

          return Builder(
            builder: (context) {
              return _buildKycItem(
                'Driving License',
                status,
                statusColor,
                onTap: () => _showDrivingLicenseDialog(context),
              );
            },
          );
        }),

      // Show PAN Card for Technician/Helper
      if (!isDriver)
        Builder(
          builder: (context) {
            return _buildKycItem(
              'PAN Card',
              'Missing',
              Colors.red,
              onTap: () => _showPanCardDialog(context),
            );
          },
        ),

      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'KYC Incomplete',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildKycItem(
  String title,
  String status,
  Color statusColor, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF424242),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 12),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: status == 'Verified'
                    ? Colors.green
                    : status == 'Pending'
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: status == 'Missing'
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'Missing' ? Icons.add : Icons.visibility_outlined,
              size: 16,
              color: status == 'Missing' ? Colors.red : const Color(0xFF424242),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPlatformPreferences() {
  final controller = Get.find<UserProfileController>();
  return _buildCard(
    title: 'Platform Preferences',
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.language, size: 22, color: Color(0xFF424242)),
              const SizedBox(width: 14),
              Text(
                'Language',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF424242),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'English',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF424242),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Obx(
        () => _buildToggleRow(
          Icons.sms,
          'SMS Notifications',
          controller.smsNotifications.value,
          controller.toggleSmsNotifications,
        ),
      ),
      const SizedBox(height: 24),
      Obx(
        () => _buildToggleRow(
          Icons.email,
          'Email Notifications',
          controller.emailNotifications.value,
          controller.toggleEmailNotifications,
        ),
      ),
      const SizedBox(height: 24),
      Obx(
        () => _buildToggleRow(
          Icons.message,
          'WhatsApp Notifications',
          controller.whatsappNotifications.value,
          controller.toggleWhatsappNotifications,
        ),
      ),
    ],
  );
}

Widget _buildToggleRow(
  IconData icon,
  String title,
  bool value,
  ValueChanged<bool> onChanged,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF424242)),
          const SizedBox(width: 18),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF424242),
            ),
          ),
        ],
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF30DB5B),
      ),
    ],
  );
}

Widget _buildSubscriptionPlans() {
  return _buildCard(
    title: 'Subscription Plans',
    children: [
      Row(
        children: [
          Expanded(child: _buildPlanCard('Starter')),
          const SizedBox(width: 12),
          Expanded(child: _buildPlanCard('Pro')),
          const SizedBox(width: 12),
          Expanded(child: _buildPlanCard('Enterprise')),
        ],
      ),
    ],
  );
}

Widget _buildPlanCard(String plan) {
  return Container(
    height: 88,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFEF5350)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.credit_card, size: 26, color: Color(0xFFEF5350)),
        const SizedBox(height: 8),
        Text(
          plan,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFEF5350),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _buildQuickActions() {
  return _buildCard(
    title: 'Quick Actions',
    children: [
      // First row - Invite & Contact Us
      Row(
        children: [
          // Invite button (moved from Home page)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.to(() => AddReferralScreen());
              },
              child: Container(
                height: 88,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5E5E).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFFF5E5E)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 24,
                      color: Color(0xFFFF5E5E),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invite & Earn',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF5E5E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _contactUs(),
              child: _buildActionCard(Icons.phone, 'Contact Us'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Second row - Sync Profile & Logout
      Row(
        children: [
          Expanded(child: _buildActionCard(Icons.sync, 'Sync Profile')),
          const SizedBox(width: 12),
          Expanded(
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  _showLogoutDialog(context);
                },
                child: Container(
                  height: 88,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEF5350)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 24,
                        color: Color(0xFFEF5350),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF5350),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildActionCard(dynamic icon, String title) {
  return SizedBox(
    height: 100,

    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (icon is String)
          Text(icon, style: const TextStyle(fontSize: 24))
        else
          Icon(icon, size: 24, color: const Color(0xFF424242)),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _buildHelpCard() {
  return GestureDetector(
    onTap: () {
      SnackBarHelper.info('Coming Soon! Chat support will be available soon.');
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF36969),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Having issues with your profile?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our team is here to help',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chat',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Soon',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF856404),
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

Widget _buildFooter() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      children: [
        Text(
          'App v1.3.2',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFBDBDBD),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Terms & Conditions',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFBDBDBD),
              ),
            ),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Color(0xFFBDBDBD))),
            const SizedBox(width: 8),
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildCard({
  required String title,
  Widget? trailing,
  Widget? titleTrailing,
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            if (titleTrailing != null) titleTrailing,
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

Widget _buildInfoItem(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF424242)),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEditableItem(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF424242)),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Edit',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Contact support via phone
void _contactUs() async {
  try {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+917420861942');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      SnackBarHelper.error('Cannot make phone call');
    }
  } catch (e) {
    AppLogger.d('Error launching phone dialer: $e');
    SnackBarHelper.error('Failed to open phone dialer');
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performLogout();
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
}

/// Perform proper logout using AuthService
Future<void> _performLogout() async {
  try {
    AppLogger.d("🚪 Starting logout process...");

    // Call AuthService logout
    final success = await AuthService.to.logout();

    if (success) {
      AppLogger.d("✅ Logout successful, navigating to onboarding");
      // Navigate to onboarding screen after successful logout
      Get.offAll(() => const RegisterScreen());
    } else {
      AppLogger.d("❌ Logout failed");
      SnackBarHelper.error("Logout failed. Please try again.");
    }
  } catch (e) {
    AppLogger.d("❌ Error during logout: $e");
    SnackBarHelper.error("An error occurred during logout.");
  }
}

/// Show Driving License Verification Dialog
void _showDrivingLicenseDialog(BuildContext context) {
  final dlNumberController = TextEditingController();
  final dobController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final controller = Get.find<UserProfileController>();
  DateTime? selectedDob;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Verify Driving License',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: dlNumberController,
                    decoration: InputDecoration(
                      labelText: 'Driving License Number',
                      hintText: 'Enter your DL number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your DL number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dobController,
                    readOnly:
                        true, // ✅ Make it readonly to only allow calendar selection
                    onTap: () async {
                      // ✅ Open calendar picker
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDob ?? DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        helpText: 'Select Date of Birth',
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFFF36969),
                                onPrimary: Colors.white,
                                onSurface: Color(0xFF1E1E1E),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDob = picked;
                          // Format as yyyy-MM-dd for API (2000-05-15)
                          dobController.text =
                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop();
                    await _verifyDrivingLicense(
                      controller.userProfile.value?.userId ?? '',
                      dlNumberController.text.trim(),
                      dobController.text.trim(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36969),
                ),
                child: Text(
                  'Verify',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Verify Driving License via API
Future<void> _verifyDrivingLicense(
  String userId,
  String dlNumber,
  String dob,
) async {
  try {
    SnackBarHelper.info('Verifying Driving License...');

    final profileService = ProfileService();
    final result = await profileService.verifyDrivingLicence(
      userId: userId,
      dlNumber: dlNumber,
      dob: dob,
    );

    if (result['success'] == true) {
      SnackBarHelper.success(result['message'] ?? 'Verification successful');
      // Refresh profile to get updated KYC status
      final controller = Get.find<UserProfileController>();
      await controller.fetchCurrentUserProfile();

      // Also refresh driver details to show updated status
      try {
        final driverController = Get.find<DriverDetailsController>();
        await driverController.fetchDriverDetails(userId);
      } catch (e) {
        AppLogger.d("Error refreshing driver details: $e");
      }
    } else {
      SnackBarHelper.error('Verification failed');
    }
  } catch (e) {
    AppLogger.d('Error verifying driving license: $e');

    String errorMessage = e.toString();
    // Sanitize huge HTML errors
    if (errorMessage.contains("<!DOCTYPE html>") ||
        errorMessage.contains("<html>")) {
      errorMessage = "Server error occurred. Please check your inputs.";
    } else if (errorMessage.length > 200) {
      errorMessage = errorMessage.substring(0, 200) + "...";
    }

    SnackBarHelper.error('Failed to verify: $errorMessage');
  }
}

/// Show PAN Card Verification Dialog
/// For Technical and Helper professional types
void _showPanCardDialog(BuildContext context) {
  final panNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final controller = Get.find<UserProfileController>();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Verify PAN Card',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: panNumberController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'PAN Card Number',
                      hintText: 'Enter your PAN number (e.g., ABCDE1234F)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your PAN number';
                      }
                      // Basic PAN format validation: 5 letters + 4 digits + 1 letter
                      final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                      if (!panRegex.hasMatch(value.toUpperCase())) {
                        return 'Please enter a valid PAN number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PAN format: ABCDE1234F',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop();
                    await _verifyPanCard(
                      controller.userProfile.value?.userId ?? '',
                      panNumberController.text.trim().toUpperCase(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36969),
                ),
                child: Text(
                  'Verify',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Verify PAN Card via API
Future<void> _verifyPanCard(String userId, String panNumber) async {
  try {
    AppLogger.d(
      '🔐 Starting PAN verification - userId: $userId, pan: $panNumber',
    );

    if (userId.isEmpty) {
      SnackBarHelper.error('User ID not found. Please try again.');
      return;
    }

    SnackBarHelper.info('Verifying PAN Card...');

    final profileService = ProfileService();
    final result = await profileService.verifyPanKYC(
      userId: userId,
      panNumber: panNumber,
    );

    if (result['success'] == true) {
      SnackBarHelper.success(
        result['message'] ?? 'PAN Card verified successfully!',
      );
      // Refresh profile to get updated KYC status
      final controller = Get.find<UserProfileController>();
      await controller.fetchCurrentUserProfile();
    } else {
      SnackBarHelper.error('Verification failed');
    }
  } catch (e) {
    AppLogger.d('Error verifying PAN card: $e');
    // Extract clean error message
    String errorMsg = e.toString();
    if (errorMsg.contains('Exception:')) {
      errorMsg = errorMsg.replaceAll('Exception:', '').trim();
    }
    SnackBarHelper.error(errorMsg);
  }
}

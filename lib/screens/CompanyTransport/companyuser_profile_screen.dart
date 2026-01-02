import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheelboard/constants/apps_colors.dart';

import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';
import 'package:wheelboard/controllers/user_profile_controller.dart';
import 'package:wheelboard/models/user_profile_model.dart';
import '../auth/onboarding_screen.dart';
import 'edit_company_profile.dart';
import 'switch_profile_popup.dart';
import '../../utils/app_logger.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  // Switch states
  bool isDarkTheme = false;
  bool smsNotifications = true;
  bool emailNotifications = false;
  bool whatsappNotifications = true;

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(UserProfileController());

    // Fetch profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCurrentUserProfile();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3), // Pink background
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.buttonBg),
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      _buildProfileHeader(profile),
                      const SizedBox(height: 16),
                      // _buildKycBanner(),
                      const SizedBox(height: 16),
                      _buildPersonalDetailsCard(profile),
                      const SizedBox(height: 16),
                      _buildContactInfoCard(profile),
                      const SizedBox(height: 16),
                      _buildPlatformPreferencesCard(),
                      const SizedBox(height: 16),
                      _buildSubscriptionPlanCard(),
                      const SizedBox(height: 16),
                      _buildQuickActionsCard(),
                      const SizedBox(height: 16),
                      _buildSupportCard(),
                      const SizedBox(height: 12),
                      Text(
                        "App v1.3.2",
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
                            "Terms & Conditions",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFBDBDBD),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: Color(0xFFBDBDBD)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Privacy Policy",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildHeader() {
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
            onTap: () => Get.to(EditCompanyProfileScreen()),
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

  Widget _buildProfileHeader(UserProfileModel? profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.to(const EditCompanyProfileScreen()),
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
                        profile?.companyLogoPath != null &&
                            profile!.companyLogoPath!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile.companyLogoPath!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle image load error
                            },
                          )
                        : null,
                    color:
                        profile?.companyLogoPath == null ||
                            profile!.companyLogoPath!.isEmpty
                        ? Colors.grey[300]
                        : null,
                  ),
                  child:
                      profile?.companyLogoPath == null ||
                          profile!.companyLogoPath!.isEmpty
                      ? const Icon(Icons.business, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.to(const EditCompanyProfileScreen()),
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
          // Company tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF36969),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_shipping, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  profile?.companyName ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            profile?.fullName ?? profile?.name ?? 'N/A',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Widget _buildKycBanner() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(999),
  //       border: Border.all(color: const Color(0xFFE0E0E0)),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.lock_outline, size: 18, color: Color(0xFF424242)),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             'Complete your KYC to unlock full access',
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: const Color(0xFF424242),
  //             ),
  //           ),
  //         ),
  //         const Icon(Icons.chevron_right, size: 16),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPersonalDetailsCard(UserProfileModel? profile) {
    return _buildCard(
      title: 'Personal Details',
      trailing: GestureDetector(
        onTap: () => Get.to(EditCompanyProfileScreen()),
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
        _buildInfoItem(
          Icons.person_outline,
          'Name',
          profile?.fullName ?? profile?.name ?? 'N/A',
        ),
        _buildInfoItem(Icons.lock_outline, 'Change Password', '************'),
        _buildInfoItem(
          Icons.location_on,
          'Location',
          profile?.address ?? profile?.city ?? profile?.state ?? 'N/A',
        ),
        _buildInfoItem(
          Icons.business,
          'Company Name',
          profile?.companyName ?? 'N/A',
        ),
        _buildInfoItem(
          Icons.category,
          'Business Category',
          profile?.businessCategory ?? 'N/A',
        ),
        _buildInfoItem(
          Icons.local_shipping,
          'Fleet Size',
          profile?.fleetSize ?? 'N/A',
        ),
        _buildInfoItem(
          Icons.account_balance,
          'GST number',
          profile?.gstNumber ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildContactInfoCard(UserProfileModel? profile) {
    return _buildCard(
      title: 'Contact Information',
      children: [
        _buildEditableItem(
          Icons.phone,
          'Mobile Number',
          profile?.mobileNo ?? 'N/A',
        ),
        _buildEditableItem(
          Icons.email,
          'Email Address',
          profile?.email ?? 'N/A',
        ),
        _buildEditableItem(
          Icons.message,
          'WhatsApp Number',
          profile?.mobileNo ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildPlatformPreferencesCard() {
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
        _buildToggleRow(Icons.dark_mode, 'Dark Theme', isDarkTheme, (val) {
          setState(() {
            isDarkTheme = val;
            Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
          });
        }),
        const SizedBox(height: 24),
        _buildToggleRow(Icons.sms, 'SMS Notifications', smsNotifications, (
          val,
        ) {
          setState(() => smsNotifications = val);
        }),
        const SizedBox(height: 24),
        _buildToggleRow(
          Icons.email,
          'Email Notifications',
          emailNotifications,
          (val) {
            setState(() => emailNotifications = val);
          },
        ),
        const SizedBox(height: 24),
        _buildToggleRow(
          Icons.message,
          'WhatsApp Notifications',
          whatsappNotifications,
          (val) {
            setState(() => whatsappNotifications = val);
          },
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
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

  Widget _buildSubscriptionPlanCard() {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.credit_card, size: 24, color: Color(0xFFEF5350)),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              plan,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEF5350),
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

  Widget _buildQuickActionsCard() {
    return _buildCard(
      title: 'Quick Actions',
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _contactUs(),
                child: _buildActionCard(Icons.phone, 'Contact Us'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showSwitchProfilePopup(
                    context,
                    onSwitchToBusiness: () {
                      AppLogger.d("Switching to Business Account...");
                    },
                    onLogout: () async {
                      await _performLogout();
                    },
                  );
                },
                child: _buildActionCard(Icons.sync, 'Switch Profile'),
              ),
            ),
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
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
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

  Widget _buildSupportCard() {
    return GestureDetector(
      onTap: () {
        SnackBarHelper.info(
          'Coming Soon! Chat support will be available soon.',
        );
      },
      child: Container(
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

  Widget _buildCard({
    required String title,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
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
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: '+919876543210', // Replace with actual support number
      );

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
}

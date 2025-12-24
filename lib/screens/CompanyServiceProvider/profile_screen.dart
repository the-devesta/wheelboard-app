import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../controllers/user_profile_controller.dart';
import '../../models/user_profile_model.dart';
import '../auth/onboarding_screen.dart';
import '../../widgets/custom_loader.dart';
import '../auth/service_provider_login.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen> {
  String selectedService = 'Tyre Services';
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(UserProfileController());

    // Fetch profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCurrentUserProfile();
    });

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4E3E3,
      ), // Pink background like Professional
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
                      const SizedBox(height: 20),
                      _buildServicesOfferedSection(),
                      const SizedBox(height: 20),
                      _buildBusinessInfoCard(profile),
                      const SizedBox(height: 20),
                      _buildDescriptionCard(),
                      const SizedBox(height: 20),
                      _buildSubscriptionPlans(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
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
                'Business Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF36969),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final controller = Get.find<UserProfileController>();
              final profile = controller.userProfile.value;

              if (profile != null && profile.userId.isNotEmpty) {
                final result = await Get.to(
                  () => const AlliedBusinessRegistrationScreen(),
                  arguments: {
                    'userId': profile.userId,
                    'isUpdate': true,
                    'businessName': profile.businessName,
                    'gstNumber': profile.gstNumber,
                    'businessType': profile.businessType,
                    'city': profile.city,
                    'phoneNumber': profile.mobileNo,
                    'email': profile.email,
                    'businessLogoPath': profile.businessLogoPath,
                  },
                ); // Refresh profile if update was successful
                if (result == true) {
                  controller.fetchCurrentUserProfile();
                }
              } else {
                SnackBarHelper.error(
                  'Unable to edit profile. User ID not found.',
                );
              }
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
                onTap: () {
                  // Handle profile picture edit
                },
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
                        profile?.businessLogoPath != null &&
                            profile!.businessLogoPath!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile.businessLogoPath!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                    color:
                        profile?.businessLogoPath == null ||
                            profile!.businessLogoPath!.isEmpty
                        ? Colors.grey[300]
                        : null,
                  ),
                  child:
                      profile?.businessLogoPath == null ||
                          profile!.businessLogoPath!.isEmpty
                      ? const Icon(Icons.business, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // Handle profile picture edit
                  },
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
            profile?.businessName ?? 'Business Name',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
            ),
          ),
          const SizedBox(height: 8),
          if (profile?.businessCategory != null &&
              profile!.businessCategory!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8B8B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                profile.businessCategory!,
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
                '4.5 / 5',
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

  Widget _buildServicesOfferedSection() {
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
          Text(
            'Services Offered',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildServiceButton(
                'Tyre Services',
                isSelected: selectedService == 'Tyre Services',
              ),
              _buildServiceButton(
                'Vehicle Services',
                isSelected: selectedService == 'Vehicle Services',
              ),
              _buildServiceButton(
                'Tyre Retreader',
                isSelected: selectedService == 'Tyre Retreader',
              ),
              _buildServiceButton(
                'Other',
                isSelected: selectedService == 'Other',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(String text, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF36969) : Colors.transparent,
          border: Border.all(color: const Color(0xFFF36969), width: 2),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFFF36969),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfoCard(UserProfileModel? profile) {
    String? profileCity = profile?.city;

    return _buildCard(
      title: 'Business Information',
      children: [
        _buildInfoItem(
          Icons.location_on,
          'Business Address',
          profileCity != null && profileCity.isNotEmpty
              ? profileCity
              : 'Address not available',
        ),
        _buildInfoItem(
          Icons.location_city,
          'City',
          profileCity != null && profileCity.isNotEmpty ? profileCity : 'N/A',
        ),
        _buildInfoItem(
          Icons.phone,
          'Phone',
          profile?.mobileNo != null && profile!.mobileNo!.isNotEmpty
              ? '+91 ${profile.mobileNo}'
              : 'N/A',
        ),
        _buildInfoItem(
          Icons.chat,
          'WhatsApp',
          profile?.mobileNo != null && profile!.mobileNo!.isNotEmpty
              ? '+91 ${profile.mobileNo}'
              : 'N/A',
        ),
        _buildInfoItem(
          Icons.email,
          'Email Address',
          profile?.email != null && profile!.email!.isNotEmpty
              ? profile.email!
              : 'N/A',
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
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
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'TechCorp Solutions is a leading provider of automotive services and solutions. We specialize in comprehensive tyre services, vehicle maintenance, and advanced retreading technologies. Our commitment to quality and customer satisfaction has made us a trusted partner for businesses across Karnataka.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey[700],
              height: 1.6,
            ),
            maxLines: isDescriptionExpanded ? null : 3,
            overflow: isDescriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                isDescriptionExpanded = !isDescriptionExpanded;
              });
            },
            child: Text(
              isDescriptionExpanded ? 'Read less' : 'Read more',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return _buildCard(
      title: 'Subscription Plans',
      children: [_buildPlanCard('Gold Member')],
    );
  }

  Widget _buildPlanCard(String plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA500), Color(0xFFFFD700)],
              ),
              borderRadius: BorderRadius.circular(28.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              plan,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to subscription plans
            },
            child: Text(
              'View Plans',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF407BFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _buildCard(
      title: 'Quick Actions',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(Icons.edit, 'Edit Profile', () async {
                final controller = Get.find<UserProfileController>();
                final profile = controller.userProfile.value;

                if (profile != null && profile.userId.isNotEmpty) {
                  final result = await Get.to(
                    () => const AlliedBusinessRegistrationScreen(),
                    arguments: {
                      'userId': profile.userId,
                      'isUpdate': true,
                      'businessName': profile.businessName,
                      'gstNumber': profile.gstNumber,
                      'businessType': profile.businessType,
                      'city': profile.city,
                      'phoneNumber': profile.mobileNo,
                      'email': profile.email,
                      'businessLogoPath': profile.businessLogoPath,
                    },
                  ); // Refresh profile if update was successful
                  if (result == true) {
                    controller.fetchCurrentUserProfile();
                  }
                } else {
                  SnackBarHelper.error(
                    'Unable to edit profile. User ID not found.',
                  );
                }
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(Icons.swap_horiz, 'Switch Profile', () {
                // Navigate to switch profile
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: const Color(0xFFF36969)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF535353),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              final success = await AuthService.to.logout();
              if (success) {
                Get.offAll(() => const RegisterScreen());
              } else {
                SnackBarHelper.error('Logout failed. Please try again.');
              }
            } catch (e) {
              SnackBarHelper.error('An error occurred during logout.');
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF36969), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: Transform.rotate(
          angle: 3.14159,
          child: const Icon(Icons.logout, color: Color(0xFFF36969), size: 20),
        ),
        label: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF757575)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../controllers/user_profile_controller.dart';
import '../../models/user_profile_model.dart';
import '../auth/onboarding_screen.dart';
import '../../widgets/custom_loader.dart';

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
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: const CustomLoader(message: "Loading profile..."),
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
              // Header
              _buildHeader(),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Profile Card
                      _buildProfileCard(profile),
                      const SizedBox(height: 20),
                      // Services Offered Section
                      _buildServicesOfferedSection(),
                      const SizedBox(height: 20),
                      // Business Information Card
                      _buildBusinessInfoCard(profile),
                      const SizedBox(height: 20),
                      // Description Card
                      _buildDescriptionCard(),
                      const SizedBox(height: 20),
                      // View Subscription Plans Button
                      _buildSubscriptionButton(),
                      const SizedBox(height: 20),
                      // Edit Profile Button
                      _buildEditProfileButton(),
                      const SizedBox(height: 12),
                      // Switch Profile Button
                      _buildSwitchProfileButton(),
                      const SizedBox(height: 12),
                      // Log Out Button (moved inside scrollview)
                      _buildLogOutButton(),
                      const SizedBox(height: 20),
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
      height: 69,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          Expanded(
            child: Center(
              child: Text(
                'My Profile',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Navigate to edit profile - TODO: Add edit profile screen
              // Get.to(() => EditServiceProviderProfileScreen());
            },
            icon: const Icon(Icons.edit, color: Color(0xFFF36969)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfileModel? profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image with Camera Icon
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: ClipOval(
                  child:
                      profile?.businessLogoPath != null &&
                          profile!.businessLogoPath!.isNotEmpty
                      ? Image.network(
                          profile.businessLogoPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.business, size: 40),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.business, size: 40),
                        ),
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
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF36969),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Company Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.businessName ?? 'Business Name',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (profile?.businessType != null &&
                    profile!.businessType!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${profile.businessType}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (profile?.businessCategory != null &&
                    profile!.businessCategory!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Tags
                  Row(children: [_buildTag(profile.businessCategory!)]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF36969),
        ),
      ),
    );
  }

  Widget _buildServicesOfferedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        // Service Filter Buttons
        // Service Filter Buttons
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
    );
  }

  Widget _buildServiceButton(
    String text, {
    bool isSelected = false,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected && !isOutlined
              ? const Color(0xFFF36969)
              : Colors.transparent,
          border: Border.all(color: const Color(0xFFF36969), width: 2),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected && !isOutlined
                ? Colors.white
                : const Color(0xFFF36969),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfoCard(UserProfileModel? profile) {
    String? profileCity = profile?.city;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Address
          _buildLabel('Business Address'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileCity != null && profileCity.isNotEmpty
                      ? profileCity
                      : 'Address not available',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // City
          _buildLabel('City'),
          const SizedBox(height: 8),
          _buildInputField(
            profileCity != null && profileCity.isNotEmpty ? profileCity : 'N/A',
          ),
          const SizedBox(height: 20),
          // Phone and WhatsApp
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelWithIcon('Phone', Icons.phone),
                    const SizedBox(height: 8),
                    _buildInputField(
                      profile?.mobileNo != null && profile!.mobileNo!.isNotEmpty
                          ? '+91 ${profile.mobileNo}'
                          : 'N/A',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelWithIcon('WhatsApp', Icons.chat),
                    const SizedBox(height: 8),
                    _buildInputField(
                      profile?.mobileNo != null && profile!.mobileNo!.isNotEmpty
                          ? '+91 ${profile.mobileNo}'
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Email
          _buildLabelWithIcon('Email Address', Icons.email),
          const SizedBox(height: 8),
          _buildInputField(
            profile?.email != null && profile!.email!.isNotEmpty
                ? profile.email!
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildLabelWithIcon(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4F4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF36969),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDescriptionExpanded
                      ? 'TechCorp Solutions is a leading provider of automotive services and solutions. We specialize in comprehensive tyre services, vehicle maintenance, and advanced retreading technologies. Our commitment to quality and customer satisfaction has made us a trusted partner for businesses across Karnataka.'
                      : 'TechCorp Solutions is a leading provider of automotive services and solutions. We specialize in comprehensive tyre services, vehicle maintenance, and advanced retreading technologies. Our commitment to quality and customer satisfaction has made us a trusted partner for businesses across Karnataka.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDescriptionExpanded = !isDescriptionExpanded;
                    });
                  },
                  child: Text(
                    'Read more',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF36969),
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

  Widget _buildSubscriptionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to subscription plans
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'View Subscription Plans',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
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
        ),
        icon: Transform.rotate(
          angle: 3.14159, // 180 degrees
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

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          // Navigate to edit profile - TODO: Add edit profile screen
          // Get.to(() => EditServiceProviderProfileScreen());
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF36969), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.edit, color: Color(0xFFF36969), size: 18),
        label: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // Navigate to switch profile - TODO: Add switch profile functionality
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF36969), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Switch Profile',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../auth/onboarding_screen.dart' show RegisterScreen;

class YourProfileScreen extends StatelessWidget {
  const YourProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildKycBanner(),
                    const SizedBox(height: 20),
                    _buildGoldMemberCard(),
                    const SizedBox(height: 20),
                    _buildPersonalDetails(),
                    const SizedBox(height: 16),
                    _buildContactInfo(),
                    const SizedBox(height: 16),
                    _buildWorkOverview(),
                    const SizedBox(height: 16),
                    _buildCompleteKyc(),
                    const SizedBox(height: 16),
                    _buildPlatformPreferences(),
                    const SizedBox(height: 16),
                    _buildSubscriptionPlans(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildHelpCard(),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: const Icon(Icons.more_vert, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
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
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF36969), width: 4),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/96'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
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
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rohit Sharma',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF36969),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'Role',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Complete your KYC to unlock full access',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }

  Widget _buildGoldMemberCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Gold Member',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            'View Rewards',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF407BFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return _buildCard(
      title: 'Personal Details',
      trailing: GestureDetector(
        onTap: () {},
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
        _buildInfoItem(Icons.person_outline, 'Name', 'Rohit Sharma'),
        _buildInfoItem(Icons.person_outline, 'Father\'s Name', 'Jitendra Sharma'),
        _buildInfoItem(Icons.calendar_today, 'Date of Birth', '17 June 1990'),
        _buildInfoItem(Icons.location_on, 'Address/Location', 'Pune, Maharashtra'),
        _buildInfoItem(Icons.work_outline, 'Years of Experience', '4 Years'),
      ],
    );
  }

  Widget _buildContactInfo() {
    return _buildCard(
      title: 'Contact Information',
      children: [
        _buildEditableItem(Icons.phone, 'Mobile Number', '+91 98765 43210'),
        _buildEditableItem(Icons.email, 'Email Address', 'rohit.sharma@email.com'),
        _buildEditableItem(Icons.message, 'WhatsApp Number', '+91 98765 43210'),
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
            Expanded(
              child: _buildStatCard(Icons.star, '4.7', 'Current Rating'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard(Icons.event_available, 'Available Today', '', isWide: true),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, {bool isWide = false}) {
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
        _buildKycItem('Aadhar Card', 'Verified', Colors.green),
        _buildKycItem('PAN Card', 'Pending', Colors.orange),
        _buildKycItem('Driving License', 'Missing', Colors.red),
        _buildKycItem('Bank Account', 'Pending', Colors.orange),
        _buildKycItem('Profile Photo', 'Verified', Colors.green),
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
                  widthFactor: 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'KYC Progress: 60%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF424242),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKycItem(String title, String status, Color statusColor) {
    return Container(
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
              color: status == 'Missing' ? Colors.red.withOpacity(0.1) : const Color(0xFFF5F5F5),
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
    );
  }

  Widget _buildPlatformPreferences() {
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
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF424242)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildToggleRow(Icons.dark_mode, 'Dark Theme', false),
        const SizedBox(height: 24),
        _buildToggleRow(Icons.sms, 'SMS Notifications', true),
        const SizedBox(height: 24),
        _buildToggleRow(Icons.email, 'Email Notifications', false),
        const SizedBox(height: 24),
        _buildToggleRow(Icons.message, 'WhatsApp Notifications', true),
      ],
    );
  }

  Widget _buildToggleRow(IconData icon, String title, bool value) {
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
          onChanged: (_) {},
          activeColor: const Color(0xFF30DB5B),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEF5350),
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
            Expanded(child: _buildActionCard('📞', 'Contact Us')),
            const SizedBox(width: 12),
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
                        const Icon(Icons.logout, size: 24, color: Color(0xFFEF5350)),
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
      height: 88,
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

  Widget _buildHelpCard() {
    return Container(
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
            child: Text(
              'Chat',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
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
      print("🚪 Starting logout process...");
      
      // Show loading snackbar
      SnackBarHelper.loading("Logging out...");
      
      // Call AuthService logout
      final success = await AuthService.to.logout();
      
      if (success) {
        print("✅ Logout successful, navigating to onboarding");
        // Navigate to onboarding screen after successful logout
        Get.offAll(() => const RegisterScreen());
      } else {
        print("❌ Logout failed");
        SnackBarHelper.error("Logout failed. Please try again.");
      }
    } catch (e) {
      print("❌ Error during logout: $e");
      SnackBarHelper.error("An error occurred during logout.");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'edit_company_profile.dart';

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
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Your Profile',
          style: TextStyle(
            color: AppColors.buttonBg,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/redBackBtn.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SvgPicture.asset(
              'assets/editBtn.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 12),
            _buildKycBanner(),
            const SizedBox(height: 16),
            _buildPersonalDetailsCard(),
            const SizedBox(height: 16),
            _buildContactInfoCard(),
            const SizedBox(height: 16),
            _buildPlatformPreferencesCard(),
            const SizedBox(height: 16),
            _buildSubscriptionPlanCard(),
            const SizedBox(height: 16),
            _buildQuickActionsCard(),
            const SizedBox(height: 16),
            _buildSupportCard(),
            const SizedBox(height: 12),
            const Text("App v1.3.2"),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Terms & Conditions"),
                SizedBox(width: 8),
                Text("•"),
                SizedBox(width: 8),
                Text("Privacy Policy"),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.buttonBg, width: 2.0),
                ),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt, size: 16, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.buttonBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text("Delhi Transport", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Deepak Kumar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              SizedBox(width: 4),
              Text("4.7 / 5"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKycBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/google.png',
            height: 24,
            width: 24,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 10),
          Expanded(child: Text("Complete your KYC to unlock full access")),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return _buildCard(
      title: "Personal Details",
      trailing: GestureDetector(
        onTap: () => Get.to(EditCompanyProfileScreen()),
        child: const Icon(Icons.edit),
      ),
      children: [
        _ProfileItem(
          icon: SvgPicture.asset('assets/person.svg', width: 20, height: 20),
          title: "Name",
          value: "Deepak Kumar",
        ),
        _ProfileItem(
          icon: SvgPicture.asset(
            'assets/mdi_password.svg',
            width: 20,
            height: 20,
          ),
          title: "Change Password",
          value: "***********",
        ),
        _ProfileItem(
          icon: SvgPicture.asset('assets/location.svg', width: 20, height: 20),
          title: "Location",
          value: "Block C, Street 12, Noida, UP",
        ),
        _ProfileItem(
          icon: SvgPicture.asset('assets/bus.svg', width: 20, height: 20),
          title: "Company Name",
          value: "Delhi Transport",
        ),
        _ProfileItem(
          icon: SvgPicture.asset('assets/transport.svg', width: 20, height: 20),
          title: "Business Category",
          value: "Transport",
        ),
        _ProfileItem(
          icon: SvgPicture.asset(
            'assets/pickuptruck.svg',
            width: 20,
            height: 20,
          ),
          title: "Fleet Size",
          value: "42",
        ),
        _ProfileItem(
          icon: SvgPicture.asset('assets/homegst.svg', width: 20, height: 20),
          title: "GST number",
          value: "43464984931316",
        ),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return _buildCard(
      title: "Contact Information",
      children: [
        _ProfileItem(
          icon: SvgPicture.asset('assets/phone.svg', width: 20, height: 20),
          title: "Mobile Number",
          value: "+91 98765 43210",
          trailing: Text("Edit"),
        ),
        _ProfileItem(
          icon: SvgPicture.asset('assets/email.svg', width: 20, height: 20),
          title: "Email Address",
          value: "deepak.kumar@email.com",
          trailing: Text("Edit"),
        ),
        _ProfileItem(
          icon: SvgPicture.asset('assets/whatsapp.svg', width: 20, height: 20),
          title: "WhatsApp Number",
          value: "+91 98765 43210",
          trailing: Text("Edit"),
        ),
      ],
    );
  }

  Widget _buildPlatformPreferencesCard() {
    return _buildCard(
      title: "Platform Preferences",
      children: [
        Row(
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 12),
            const Text("Language"),
            const Spacer(),
            DropdownButton<String>(
              value: "English",
              items: const [
                DropdownMenuItem(value: "English", child: Text("English")),
              ],
              onChanged: (val) {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(Icons.dark_mode, "Dark Theme", isDarkTheme, (val) {
          setState(() {
            isDarkTheme = val;
            Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
          });
        }),
        _buildSwitchTile(
          Icons.notifications,
          "SMS Notifications",
          smsNotifications,
          (val) {
            setState(() => smsNotifications = val);
          },
        ),
        _buildSwitchTile(
          Icons.email,
          "Email Notifications",
          emailNotifications,
          (val) {
            setState(() => emailNotifications = val);
          },
        ),
        _buildSwitchTile(
          Icons.abc,
          "WhatsApp Notifications",
          whatsappNotifications,
          (val) {
            setState(() => whatsappNotifications = val);
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color.fromARGB(255, 112, 246, 117),
            // inactiveThumbColor: Colors.grey.shade300,
            inactiveTrackColor: Color(0xFF787880).withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlanCard() {
    return _buildCard(
      title: "Subscription Plans",
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPlanButton("Starter"),
              const SizedBox(width: 16),
              _buildPlanButton("Pro"),
              const SizedBox(width: 16),
              _buildPlanButton("Enterprise"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanButton(String title) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 140),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description, size: 36, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return _buildCard(
      title: "Quick Actions",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickAction(Icons.phone, "Contact Us"),
            _buildQuickAction(Icons.sync, "Sync Profile"),
            _buildQuickAction(Icons.logout, "Logout", color: Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Having issues with your profile?\nOur team is here to help",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.redAccent,
            ),
            child: const Text("Chat"),
          ),
        ],
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color ?? Colors.black),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color ?? Colors.black)),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String value;
  final Widget? trailing;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'edit_company_profile.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        leading: BackButton(),

        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.edit, color: Colors.black),
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
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 6),
        const Text(
          "Deepak Kumar",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 18),
            SizedBox(width: 4),
            Text("4.7 / 5"),
          ],
        ),
      ],
    );
  }

  Widget _buildKycBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock, color: Colors.amber),
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
        onTap: () {
          Get.to(EditCompanyProfileScreen());
          print('Edit icon tapped!');
        },
        child: const Icon(Icons.edit),
      ),
      children: const [
        _ProfileItem(icon: Icons.person, title: "Name", value: "Deepak Kumar"),
        _ProfileItem(
          icon: Icons.lock,
          title: "Change Password",
          value: "***********",
        ),
        _ProfileItem(
          icon: Icons.location_on,
          title: "Location",
          value: "Block C, Street 12, Noida, UP",
        ),
        _ProfileItem(
          icon: Icons.apartment,
          title: "Company Name",
          value: "Delhi Transport",
        ),
        _ProfileItem(
          icon: Icons.category,
          title: "Business Category",
          value: "Transport",
        ),
        _ProfileItem(icon: Icons.fire_truck, title: "Fleet Size", value: "42"),
        _ProfileItem(
          icon: Icons.numbers,
          title: "GST number",
          value: "43464984931316",
        ),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return _buildCard(
      title: "Contact Information",
      children: const [
        _ProfileItem(
          icon: Icons.phone,
          title: "Mobile Number",
          value: "+91 98765 43210",
          trailing: Text("Edit"),
        ),
        _ProfileItem(
          icon: Icons.email,
          title: "Email Address",
          value: "deepak.kumar@email.com",
          trailing: Text("Edit"),
        ),
        _ProfileItem(
          icon: Icons.abc,
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
        _buildSwitchTile(Icons.dark_mode, "Dark Theme", false),
        _buildSwitchTile(Icons.notifications, "SMS Notifications", true),
        _buildSwitchTile(Icons.email, "Email Notifications", false),
        _buildSwitchTile(Icons.abc, "WhatsApp Notifications", true),
      ],
    );
  }

  Widget _buildSubscriptionPlanCard() {
    return _buildCard(
      title: "Subscription Plans",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPlanButton("Starter"),
            _buildPlanButton("Pro"),
            _buildPlanButton("Enterprise"),
          ],
        ),
      ],
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

  Widget _buildSwitchTile(IconData icon, String title, bool value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Switch(value: value, onChanged: (_) {}),
      ],
    );
  }

  Widget _buildPlanButton(String title) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.file_copy),
      label: Text(title),
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
  final IconData icon;
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
          Icon(icon, size: 20),
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

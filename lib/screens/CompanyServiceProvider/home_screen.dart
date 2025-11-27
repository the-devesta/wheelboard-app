import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:get/get.dart';
import '../CompanyTransport/banner_carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile_screen.dart';
import 'earnings_screen.dart';
import 'add_service_screen.dart';
import 'service_details_screen.dart';
import '../CompanyTransport/service_dashboard.dart';
import '../CompanyTransport/job_screen.dart';

class ServiceProviderHomeScreen extends StatelessWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const ServiceProviderProfileScreen());
                      },
                      child: CircleAvatar(
                        radius: 33,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=4',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Welcome Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF333333),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Patel Services',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification Bell
                    GestureDetector(
                      onTap: () {
                        // Navigate to notifications
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF36969),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Banner Carousel
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: BannerCarousel(),
              ),
              const SizedBox(height: 20),

              // Stats Cards (Services & Leads)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const ServiceDashboardScreen());
                        },
                        child: _buildStatCard(
                          context,
                          icon: Icons.work_outline,
                          iconBgColor: const Color(0xFFFFE5C2),
                          iconColor: const Color(0xFFFBAE4B),
                          label: 'Services',
                          value: '5',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.show_chart,
                        iconBgColor: const Color(0xFFD0FAE6),
                        iconColor: const Color(0xFF00B894),
                        label: 'Leads',
                        value: '12',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Action Buttons (Earnings, Hire, Active Listing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const EarningsScreen());
                        },
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.account_balance_wallet,
                          iconBgColor: const Color(0xFFE3F2FD),
                          label: 'Earnings',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const JobsScreen());
                        },
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.handshake,
                          iconBgColor: const Color(0xFFFCE4EC),
                          label: 'Hire',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const ServiceDashboardScreen());
                        },
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.list_alt,
                          iconBgColor: const Color(0xFFFFF3E0),
                          label: 'Active\nListing',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // My Services Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Services',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Get.to(() => const ServiceDetailsScreen()),
                      child: _buildServiceCard(
                        context,
                        imageUrl: 'https://i.pravatar.cc/60?img=1',
                        title: 'Tyre Replacement',
                        tag: 'Tyre Repair',
                        description: 'Puncture and flat tyre repair service.\nQuick turnaround and warranty\nincluded for every job.',
                        onEdit: () {},
                        onUnpublish: () {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Get.to(() => const ServiceDetailsScreen()),
                      child: _buildServiceCard(
                        context,
                        imageUrl: '',
                        title: 'Oil Change',
                        tag: 'Lubrication',
                        description: 'High-quality engine oil replacement\nwith filter change. Fast and reliable\nservice every time.',
                        onEdit: () {},
                        onUnpublish: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Popular Feeds Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Feeds',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: const Color(0xFF535353),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to feeds
                      },
                      child: Text(
                        'view more',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF00AAFF),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Feed Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFeedCard(context),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFeedCard(context),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: ElevatedButton.icon(
          onPressed: () {
            Get.to(() => const AddServiceScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5252),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 16),
          label: const Text(
            'Add Service',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: const Color(0xFF535353),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: const Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF535353), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: const Color(0xFF535353),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String tag,
    required String description,
    required VoidCallback onEdit,
    required VoidCallback onUnpublish,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: imageUrl.isEmpty ? const Color(0xFFF0F0F0) : null,
              border: imageUrl.isEmpty
                  ? Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid)
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'IMG',
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF999999),
                          ),
                        ),
                        Text(
                          '60×60',
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Icon(Icons.image, color: Color(0xFF999999)),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Service Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Tag
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0FAE6),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF00B894),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF828282),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00B894)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.edit, size: 13, color: Color(0xFF00B894)),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF00B894),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onUnpublish,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF4D4F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.visibility_off, size: 13, color: Color(0xFFFF4D4F)),
                        label: Text(
                          'Unpublish',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFFFF4D4F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundImage: NetworkImage('https://i.pravatar.cc/34?img=5'),
              ),
              const SizedBox(width: 12),
              Text(
                'Delhi Transport',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF535353),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/truck.png',
              width: double.infinity,
              height: 152,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 152,
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.image, size: 48, color: Color(0xFF999999)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/heart.svg',
                  width: 25,
                  height: 25,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFF36969),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/share.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/eye.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          // Title
          Text(
            'Tips for fleet management',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            'Learn how to optimize your fleet operations and reduce costs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posted 2 days Ago',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF666666),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Read more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 15,
                    color: const Color(0xFF375DFB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


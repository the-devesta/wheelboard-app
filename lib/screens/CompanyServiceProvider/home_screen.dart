import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:get/get.dart';
import '../CompanyTransport/banner_carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile_screen.dart';
import 'earnings_screen.dart';
import 'add_service_screen.dart';
import 'my_listings_screen.dart';
import 'service_details_screen.dart';
import 'booking_details_screen.dart';
import '../CompanyTransport/job_screen.dart';
import '../CompanyTransport/notification_screen.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/user_profile_controller.dart';
import '../../controllers/Professional/feeds_controller.dart';
import '../../controllers/post_controller.dart';
import '../CompanyTransport/feed_screen.dart';
import '../../widgets/custom_loader.dart';
import '../../models/service_model.dart';
import '../../utils/session_manager.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../utils/share_service.dart';
import '../CompanyTransport/fleet_userprofile.dart';
import 'dart:convert';

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() =>
      _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {
  final notificationController = Get.put(NotificationController());
  final userProfileController = Get.put(UserProfileController());
  final feedsController = Get.put(FeedsController());
  List<ServiceModel> _services = [];
  bool _isLoadingServices = false;
  final Map<String, String> _serviceImages =
      {}; // Store service images by serviceId

  @override
  void initState() {
    super.initState();
    // Fetch notifications and profile on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationController.fetchNotifications();
      userProfileController.fetchCurrentUserProfile();
      _fetchMyServices();
    });
  }

  Future<void> _fetchMyServices() async {
    setState(() {
      _isLoadingServices = true;
    });

    try {
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString("userId");
      final token = await sessionManager.getString("authToken");

      if (userId == null || userId.isEmpty) {
        return;
      }

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceListByUser}$userId',
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        // API returns array directly, not wrapped in data object
        final List<dynamic> data =
            jsonDecode(response.body) as List<dynamic>? ?? [];

        // Map API response to ServiceModel
        setState(() {
          _services = data.map((e) {
            final json = e as Map<String, dynamic>;
            return ServiceModel(
              serviceId: json['serviceId'] ?? '',
              serviceTitle: json['title'] ?? json['serviceTitle'] ?? '',
              city: json['city'] ?? '',
              fullAddress: json['fullAddress'] ?? '',
              isAvailable: json['isVisible'] ?? false,
              businessName: json['businessName'] ?? '',
              businessType: json['businessType'] ?? '',
              serviceCategory: json['serviceCategory'],
              contactNumber: json['contactNumber'],
              whatsappNumber: json['whatsappNumber'],
              description: json['description'],
              pricingOption: json['isFlatPrice'] == true
                  ? 'Flat Price'
                  : 'Per Hour',
              amount: json['price'],
              businessHoursFrom: json['businessFrom'],
              businessHoursTo: json['businessTo'],
              daysOpen: json['daysOpen'],
            );
          }).toList();

          // Store images separately for each service
          for (int i = 0; i < data.length && i < _services.length; i++) {
            final json = data[i] as Map<String, dynamic>;
            final images = json['images'] as List<dynamic>? ?? [];
            if (images.isNotEmpty) {
              // Store first image URL in a way we can access it
              // We'll use a Map to store service images
              _serviceImages[_services[i].serviceId] = images[0].toString();
            }
          }
        });
      }
    } catch (e) {
      // Silently handle errors for home screen
      print('Error fetching services: $e');
    } finally {
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    Obx(() {
                      final profile = userProfileController.userProfile.value;
                      final profileImage = profile?.profileImage;

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => const ServiceProviderProfileScreen());
                        },
                        child: profileImage != null && profileImage.isNotEmpty
                            ? CircleAvatar(
                                radius: 33,
                                backgroundImage: NetworkImage(profileImage),
                                onBackgroundImageError:
                                    (exception, stackTrace) {
                                      // Handle image error
                                    },
                                child: const Icon(
                                  Icons.person,
                                  size: 33,
                                  color: Color(0xFF333333),
                                ),
                              )
                            : const CircleAvatar(
                                radius: 33,
                                backgroundColor: Color(0xFFE0E0E0),
                                child: Icon(
                                  Icons.person,
                                  size: 33,
                                  color: Color(0xFF333333),
                                ),
                              ),
                      );
                    }),
                    const SizedBox(width: 12),
                    // Welcome Text
                    Expanded(
                      child: Obx(() {
                        final profile = userProfileController.userProfile.value;
                        final businessName =
                            profile?.businessName ??
                            profile?.displayName ??
                            'Welcome';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome!',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF333333),
                                    fontSize: 16,
                                  ),
                            ),
                            Text(
                              businessName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                    fontSize: 20,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }),
                    ),
                    // Notification Bell
                    Obx(() {
                      final unreadCount = notificationController.unreadCount;

                      return GestureDetector(
                        onTap: () {
                          Get.to(const NotificationScreen());
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
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
                          Get.to(() => const MyListingsScreen());
                        },
                        child: _buildStatCard(
                          context,
                          icon: Icons.work_outline,
                          iconBgColor: const Color(0xFFFFE5C2),
                          iconColor: const Color(0xFFFBAE4B),
                          label: 'Services',
                          value: '${_services.length}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            () => BookingDetailsScreen(
                              serviceId: _services.isNotEmpty
                                  ? _services.first.serviceId
                                  : '',
                            ),
                          ); // Navigate to booking details
                        },
                        child: _buildStatCard(
                          context,
                          icon: Icons.show_chart,
                          iconBgColor: const Color(0xFFD0FAE6),
                          iconColor: const Color(0xFF00B894),
                          label: 'Leads',
                          value: '12',
                        ),
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
                          Get.to(() => const MyListingsScreen());
                        },
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.list_alt,
                          iconBgColor: const Color(0xFFFFF3E0),
                          label: 'Listing',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Services',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xFF2D3436),
                              ),
                        ),
                        if (_services.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Get.to(() => const MyListingsScreen());
                            },
                            child: Text(
                              'View All',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF00AAFF),
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingServices)
                      const Center(
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CustomLoader.small(),
                        ),
                      )
                    else if (_services.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No services yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first service to get started',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(
                        _services.length > 2 ? 2 : _services.length,
                        (index) {
                          final service = _services[index];
                          // Get first image from stored images map
                          final serviceImage =
                              _serviceImages[service.serviceId] ?? '';

                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => ServiceDetailsScreen(
                                      serviceId: service.serviceId,
                                    ),
                                  );
                                },
                                child: _buildServiceCardFromModel(
                                  context,
                                  service: service,
                                  imageUrl: serviceImage,
                                ),
                              ),
                              if (index <
                                  (_services.length > 2
                                      ? 1
                                      : _services.length - 1))
                                const SizedBox(height: 12),
                            ],
                          );
                        },
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
                        Get.to(() => const FeedScreen());
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

              // Feed Cards - Dynamic from API
              Obx(() {
                if (feedsController.isLoading.isTrue) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomLoader(message: "Loading feeds..."),
                  );
                }

                if (feedsController.feeds.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(child: Text("No popular feeds.")),
                  );
                }

                // Display first 3 feeds
                final popularFeeds = feedsController.feeds.take(3).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: popularFeeds.length,
                  itemBuilder: (context, index) {
                    final feed = popularFeeds[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < popularFeeds.length - 1 ? 12 : 0,
                      ),
                      child: _buildFeedPostCard(context, feed),
                    );
                  },
                );
              }),
              const SizedBox(height: 100), // Space for bottom nav and FAB
            ],
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
      height: 110, // Fixed height for uniformity
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        children: [
          Container(
            width: 40, // Slightly smaller icon container
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF535353), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13, // Slightly smaller font
              color: const Color(0xFF535353),
            ),
            maxLines: 2, // Allow 2 lines
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCardFromModel(
    BuildContext context, {
    required ServiceModel service,
    String imageUrl = '',
  }) {
    final title = service.serviceTitle.isNotEmpty
        ? service.serviceTitle
        : 'Untitled Service';
    // Use serviceCategory if available, otherwise fallback to businessType or city
    final tag =
        (service.serviceCategory != null && service.serviceCategory!.isNotEmpty)
        ? service.serviceCategory!
        : (service.businessType.isNotEmpty
              ? service.businessType
              : (service.city.isNotEmpty ? service.city : 'Service'));
    final description = service.description ?? 'No description available';

    // Try to get image from API response if available
    String serviceImage = imageUrl;

    return _buildServiceCard(
      context,
      imageUrl: serviceImage,
      title: title,
      tag: tag,
      description: description.length > 100
          ? '${description.substring(0, 100)}...'
          : description,
      onEdit: () {
        Get.to(() => AddServiceScreen(service: service));
      },
      onUnpublish: () {
        // Handle unpublish action - can be implemented later
      },
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
      child: Column(
        children: [
          Row(
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
                      ? Border.all(
                          color: const Color(0xFFE0E0E0),
                          style: BorderStyle.solid,
                        )
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
                              child: const Icon(
                                Icons.image,
                                color: Color(0xFF999999),
                              ),
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: const Color(0xFF2D3436),
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD0FAE6),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons - Edit and Unpublish
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFF00B894)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF00B894),
                  ),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFF00B894),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onUnpublish,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFF808080)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(
                    Icons.visibility_off_outlined,
                    size: 16,
                    color: Color(0xFF808080),
                  ),
                  label: const Text(
                    'Unpublish',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
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
                  child: const Icon(
                    Icons.image,
                    size: 48,
                    color: Color(0xFF999999),
                  ),
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
                icon: Icon(
                  Icons.favorite,
                  size: 25,
                  color: const Color(0xFFF36969),
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
                icon: SvgPicture.asset('assets/eye.svg', width: 20, height: 20),
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

  /// Build feed post card - same style as Transport home screen
  Widget _buildFeedPostCard(BuildContext context, Post post) {
    final profile = userProfileController.userProfile.value;
    final profileImageUrl =
        profile?.profileImage != null && profile!.profileImage!.isNotEmpty
        ? (profile.profileImage!.startsWith('http://') ||
                  profile.profileImage!.startsWith('https://')
              ? profile.profileImage!
              : ApiConstants.baseUrl + profile.profileImage!)
        : 'https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 70}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              Get.to(FleetUserprofile(companyId: post.companyId));
            },
            borderRadius: BorderRadius.circular(50),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF25C5C),
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName.isNotEmpty
                            ? post.userName
                            : (profile?.displayName ?? "User"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.category,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Post Content
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),

          // Post Images
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _formatImageUrl(post.imageUrls[0]),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // If no content and no images, show placeholder
          if (post.content.isEmpty && post.imageUrls.isEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/truck.png",
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Reactions
          Obx(() {
            final isLiked = feedsController.isLiked(post.postId);
            return Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: () => feedsController.toggleLike(post.postId),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 28,
                    color: isLiked
                        ? const Color(0xFFF36969)
                        : const Color(0xFFFCACAC),
                  ),
                ),
                const SizedBox(width: 10),
                // Share Button
                GestureDetector(
                  onTap: () {
                    ShareService.sharePost(
                      postId: post.postId,
                      content: post.content,
                      userName: post.userName,
                      category: post.category,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/share.svg',
                    width: 26,
                    height: 26,
                  ),
                ),
                const SizedBox(width: 10),
                // View Button
                GestureDetector(
                  onTap: () => Get.to(() => const FeedScreen()),
                  child: SvgPicture.asset(
                    'assets/eye.svg',
                    width: 26,
                    height: 26,
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: post.status == 'Pending'
                        ? Colors.orange[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: post.status == 'Pending'
                          ? Colors.orange[800]
                          : Colors.green[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(post.timeAgo, style: const TextStyle(color: Colors.grey)),
              if (post.content.length > 100)
                const Text(
                  "Read More",
                  style: TextStyle(color: Colors.blueAccent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format image URL helper
  String _formatImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    String cleanPath = url.replaceAll('\\', '/');
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '${ApiConstants.baseUrl}/$cleanPath';
  }
}

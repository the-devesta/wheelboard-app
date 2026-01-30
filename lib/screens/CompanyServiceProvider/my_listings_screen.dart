import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../controllers/Transport/service_provider_controller.dart';
import '../../controllers/ServiceProvider/service_provider_home_controller.dart';
import 'add_service_screen.dart';
import 'service_details_screen.dart';
import '../../widgets/custom_loader.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceProviderController _serviceProviderController = Get.put(
    ServiceProviderController(),
    permanent: false,
  );
  late final ServiceProviderHomeController _homeController;
  String _selectedFilter = 'All';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<ServiceProviderHomeController>();
    // Refresh services on screen open - delayed to avoid 'setState() during build' error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.fetchMyServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Getters for controller data
  bool get _isLoading => _homeController.isLoadingServices.value;
  List<ServiceModel> get _services => _homeController.services;

  List<ServiceModel> get _filteredServices {
    List<ServiceModel> result = List.from(_services);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      result = result.where((service) {
        final titleMatch = service.serviceTitle.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        final descMatch =
            service.description != null &&
            service.description!.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
        return titleMatch || descMatch;
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      final isVisible = _selectedFilter == 'Published';
      result = result
          .where((service) => service.isAvailable == isVisible)
          .toList();
    }

    return result;
  }

  void _filterServices(String query) {
    setState(() {}); // Trigger rebuild with new search query
  }

  void _onFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedFilter = value;
      });
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tyre repair':
      case 'tyre':
        return const Color(0xFFDBEAFE);
      case 'engine':
        return const Color(0xFFE9D5FF);
      case 'oil':
        return const Color(0xFFFEF3C7);
      case 'brake':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category.toLowerCase()) {
      case 'tyre repair':
      case 'tyre':
        return const Color(0xFF1E40AF);
      case 'engine':
        return const Color(0xFF6B21A8);
      case 'oil':
        return const Color(0xFF92400E);
      case 'brake':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF374151);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            _buildAppBar(),
            // Search and Filter Section
            _buildSearchAndFilter(),
            // Services List
            Expanded(
              child: Obx(() {
                if (_isLoading) {
                  return const CustomLoader(message: "Loading services...");
                }

                final services = _filteredServices;
                if (services.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildServicesList();
              }),
            ),
          ],
        ),
      ),
      // FAB is now handled by main_wrapper.dart
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFF5E5E),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Get.back(),
          ),
          // Title
          const Expanded(
            child: Text(
              'My Listings',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Notification Icon
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                // Navigate to notifications
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Created Services',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your Services here',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Search Bar
              Expanded(
                child: Container(
                  height: 31,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F2937).withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterServices,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFFADAEBC),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.search,
                          size: 14,
                          color: Color(0xFFADAEBC),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7.5,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter Dropdown
              Container(
                height: 31,
                width: 95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F2937).withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 19),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF1F2937),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('All'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Published',
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('Published'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Draft',
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('Draft'),
                      ),
                    ),
                  ],
                  onChanged: _onFilterChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return RefreshIndicator(
      onRefresh: _homeController.fetchMyServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredServices.length,
        itemBuilder: (context, index) {
          final service = _filteredServices[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    // Use serviceCategory if available, otherwise fallback to businessType or city
    final category =
        (service.serviceCategory != null && service.serviceCategory!.isNotEmpty)
        ? service.serviceCategory!
        : (service.businessType.isNotEmpty
              ? service.businessType
              : (service.city.isNotEmpty ? service.city : 'Service'));
    final categoryColor = _getCategoryColor(category);
    final categoryTextColor = _getCategoryTextColor(category);
    final isPublished =
        service.isAvailable; // Assuming isAvailable means published

    return InkWell(
      onTap: () {
        Get.to(() => ServiceDetailsScreen(serviceId: service.serviceId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Category Tag
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.serviceTitle.isNotEmpty
                        ? service.serviceTitle
                        : 'Untitled Service',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                if (category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: categoryTextColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Description and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    service.description ?? 'No description available',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.43,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPublished
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPublished)
                        const Icon(
                          Icons.check_circle,
                          size: 12,
                          color: Color(0xFF065F46),
                        )
                      else
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Color(0xFF374151),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        isPublished ? 'Published' : 'Draft',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: isPublished
                              ? const Color(0xFF065F46)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Updated Date and Actions
            Row(
              children: [
                Text(
                  'Updated ${_getTimeAgo(service)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                // Edit Button
                InkWell(
                  onTap: () {
                    Get.to(() => AddServiceScreen(service: service));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                InkWell(
                  onTap: () => _showDeleteDialog(service),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.delete_outline,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first service to get started',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // FAB is now handled by main_wrapper.dart

  String _getTimeAgo(ServiceModel service) {
    // This is a placeholder - implement actual time calculation based on your data
    return '2 days ago';
  }

  void _showDeleteDialog(ServiceModel service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Are you sure you want to delete "${service.serviceTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.of(dialogContext).pop();

              if (_userId == null || _userId!.isEmpty) {
                if (mounted) {
                  SnackBarHelper.error(
                    "User ID not found. Please login again.",
                  );
                }
                return;
              }

              // Show loading indicator
              if (!mounted) return;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) =>
                    const Center(child: CustomLoader.small()),
              );

              try {
                // Call delete API
                final success = await _serviceProviderController.deleteService(
                  service.serviceId,
                  _userId!,
                );

                // Close loading dialog
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }

                // Refresh the list if delete was successful
                if (success && mounted) {
                  // Wait a bit for backend to process, then refresh from server
                  await Future.delayed(const Duration(milliseconds: 500));

                  // Refresh from server - backend should return updated list without deleted service
                  if (mounted) {
                    await _homeController.fetchMyServices();
                  }
                }
              } catch (e) {
                // Close loading dialog on error
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                if (mounted) {
                  SnackBarHelper.error(
                    "Failed to delete service: ${e.toString()}",
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

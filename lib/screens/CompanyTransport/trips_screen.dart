import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheelboard/screens/CompanyTransport/newtripscreen.dart';
import 'package:wheelboard/screens/CompanyTransport/schedulescreen.dart';
import 'package:wheelboard/screens/CompanyTransport/bids_screen.dart';
import 'package:wheelboard/screens/CompanyTransport/trip_details_screen.dart';
import 'package:wheelboard/controllers/Transport/add_trip_controller.dart';
import 'package:wheelboard/controllers/Transport/trip_page_controller.dart';
import 'package:wheelboard/utils/session_manager.dart';

import 'package:wheelboard/models/add_new_trip_model.dart';
import '../../widgets/custom_loader.dart';
import 'TripExpenses/TripExpensesScreen.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

// ---------------------------------------------------------------------------
// Reusable safe avatar widget – handles null/empty URL and network errors.
// Uses CachedNetworkImage to handle extension-less URLs (e.g. from API).
// Falls back to asset, and if asset also fails, shows a person icon.
// ---------------------------------------------------------------------------
class _SafeAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String fallbackAsset;

  const _SafeAvatar({
    this.imageUrl,
    this.radius = 12,
    this.fallbackAsset = 'assets/driver.png',
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    // Ultimate fallback widget — shown when both network and asset fail
    final Widget iconFallback = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      child: Icon(Icons.person, size: radius, color: Colors.grey.shade600),
    );

    if (hasUrl) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
          backgroundColor: Colors.grey.shade200,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: SizedBox(
            width: radius,
            height: radius,
            child: const CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: Image.asset(
              fallbackAsset,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => iconFallback,
            ),
          ),
        ),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
      );
    }

    // No URL → try asset with safe fallback to icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.asset(
          fallbackAsset,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => iconFallback,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class TripPage extends StatefulWidget {
  final int initialTabIndex;

  const TripPage({super.key, this.initialTabIndex = 0});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with SingleTickerProviderStateMixin {
  final TripController tripController = Get.put(TripController());
  final TripPageTabController tabPageController = Get.put(
    TripPageTabController(),
    permanent: true,
  );
  late TabController _tabController;

  // Search and Filter Controllers
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _destinationFilter = '';
  String _bidsFilter = ''; // 'available', 'awaiting', or ''

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    // Register tab controller with GetX controller
    tabPageController.setTabController(_tabController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTrips();
    });

    // Listen to tab changes from GetX controller
    ever(tabPageController.currentTabIndex, (int index) {
      if (_tabController.index != index && mounted) {
        _tabController.animateTo(index);
      }
    });

    // Listen to search changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void didUpdateWidget(covariant TripPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      if (_tabController.index != widget.initialTabIndex) {
        _tabController.animateTo(widget.initialTabIndex);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrips() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getString("userId");
    if (userId != null && userId.isNotEmpty) {
      tripController.fetchTrips(userId);
    }
  }

  /// Filter trips based on search query and filters
  List<Trip> _filterTrips(List<Trip> trips) {
    return trips.where((trip) {
      // Search filter - search in pickup, delivery location, and trip code
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            trip.pickupLocation.toLowerCase().contains(_searchQuery) ||
            trip.deliveryLocation.toLowerCase().contains(_searchQuery) ||
            trip.tripCode.toLowerCase().contains(_searchQuery) ||
            (trip.vehicleType?.toLowerCase().contains(_searchQuery) ?? false);

        if (!matchesSearch) return false;
      }

      // Destination filter
      if (_destinationFilter.isNotEmpty) {
        if (!trip.deliveryLocation.toLowerCase().contains(
          _destinationFilter.toLowerCase(),
        )) {
          return false;
        }
      }

      // Bids filter
      if (_bidsFilter == 'available') {
        // Show trips with bids (totalBidCount > 0)
        if (trip.totalBidCount == 0) return false;
      } else if (_bidsFilter == 'awaiting') {
        // Show trips without bids (totalBidCount == 0)
        if (trip.totalBidCount > 0) return false;
      }

      return true;
    }).toList();
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _destinationFilter = '';
      _bidsFilter = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Header + search + recent trips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/headingImg.png', height: 40),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search + filter
                    Row(
                      children: [
                        // Search Bar with Shadow
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: "Search Trips",
                                  border: InputBorder.none,
                                  icon: Icon(Icons.search),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Icon with Shadow
                        GestureDetector(
                          onTap: () => _showFilterDialog(context),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.tune),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Trips
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Trips",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      // Apply filters to trips
                      final filteredTrips = _filterTrips(tripController.trips);
                      final recentTrips = filteredTrips.take(2).toList();

                      if (tripController.isTripsLoading.value) {
                        return const SizedBox(
                          height: 280,
                          child: CustomLoader.small(),
                        );
                      }
                      if (recentTrips.isEmpty) {
                        return SizedBox(
                          height: 280,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty ||
                                          _destinationFilter.isNotEmpty ||
                                          _bidsFilter.isNotEmpty
                                      ? "No trips match your filters"
                                      : "No recent trips",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 280,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: recentTrips.asMap().entries.map((entry) {
                            final trip = entry.value;
                            final index = entry.key;
                            final statusColor = _getStatusColor(
                              trip.tripStatus,
                            );
                            final dateStr = trip.pickupDate != null
                                ? _formatDate(trip.pickupDate!)
                                : '';
                            final timeStr = trip.pickupTime.isNotEmpty
                                ? ' – ${trip.pickupTime.substring(0, trip.pickupTime.length > 5 ? 5 : trip.pickupTime.length)}'
                                : '';

                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < recentTrips.length - 1 ? 16 : 0,
                              ),
                              child: tripCard(
                                title:
                                    "Trip to ${_getLocationName(trip.deliveryLocation)}",
                                subtitle:
                                    "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
                                tag: trip.tripStatus,
                                label: trip.vehicleType ?? "Standard",
                                date: "$dateStr$timeStr",
                                tagColor: statusColor,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Pinned TabBar (styled like your filter pills)
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeader(
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    // vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCF6DE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.autorenew,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'In-Process',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Upcoming',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Tab content
          body: _TripsTabViews(
            tripController: tripController,
            tabController: _tabController,
          ),
        ),
      ),

      // FAB column - matching Figma design
      floatingActionButton: Obx(() {
        if (AuthService.to.userType.value.toLowerCase().trim() ==
            'professional') {
          return const SizedBox.shrink();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // New Trip Button
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(const Newtripscreen());
                },
                icon: const Icon(Icons.add_circle, size: 24),
                label: const Text(
                  "Post  Trip",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF26868),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(117, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFDFF5EB), width: 2),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            // Schedule Button
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(const ScheduleTripScreen());
                },
                icon: const Icon(Icons.calendar_today, size: 24),
                label: const Text(
                  "Schedule",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF26868),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(117, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFDFF5EB), width: 2),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Helpers from your original code ---

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('complete')) {
      return Colors.green;
    } else if (lowerStatus.contains('process') ||
        lowerStatus.contains('progress') ||
        lowerStatus.contains('ongoing')) {
      return Colors.blue;
    } else if (lowerStatus.contains('upcoming') ||
        lowerStatus.contains('pending')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String _getLocationName(String location) {
    if (location.isEmpty) return 'Unknown';
    final parts = location.split(',');
    return parts.isNotEmpty ? parts[0].trim() : location;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  static Widget tripCard({
    required String title,
    required String subtitle,
    required String tag,
    required String label,
    required String date,
    required Color tagColor,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppImages.trip,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),

          // ✔ Completed pill with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tagColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: tagColor, size: 11),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: tagColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          Row(
            children: [
              const Icon(Icons.location_on, size: 11, color: Colors.grey),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 11, color: Colors.black54),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Initialize with current filter values
          final destinationController = TextEditingController(
            text: _destinationFilter,
          );
          String tempBidsFilter = _bidsFilter;

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Filter By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF36969),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Destination Field
                const Text(
                  'Destination',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: destinationController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Enter destination city...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status Section
                const Text(
                  'Status :',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _filterChip('Completed', false, () {
                      Navigator.pop(context);
                      _tabController.animateTo(0);
                    }),
                    _filterChip('In-progress', false, () {
                      Navigator.pop(context);
                      _tabController.animateTo(1);
                    }),
                    _filterChip('Upcoming', false, () {
                      Navigator.pop(context);
                      _tabController.animateTo(2);
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Bids Section
                const Text(
                  'Bids :',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _filterChip(
                      'Bids Available',
                      tempBidsFilter == 'available',
                      () {
                        setModalState(() {
                          tempBidsFilter = tempBidsFilter == 'available'
                              ? ''
                              : 'available';
                        });
                      },
                    ),
                    _filterChip(
                      'Bids Awaiting',
                      tempBidsFilter == 'awaiting',
                      () {
                        setModalState(() {
                          tempBidsFilter = tempBidsFilter == 'awaiting'
                              ? ''
                              : 'awaiting';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _destinationFilter = destinationController.text.trim();
                        _bidsFilter = tempBidsFilter;
                      });
                      Navigator.pop(context);
                      Get.snackbar(
                        '✅ Filters Applied',
                        'Showing filtered trips',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.withOpacity(0.8),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF36969),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF36969) : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFF36969) : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// Pinned TabBar header delegate
class _TabBarHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarHeader({required this.child});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarHeader oldDelegate) => false;
}

/// The 3 tab lists
class _TripsTabViews extends StatelessWidget {
  final TripController tripController;
  final TabController tabController;

  const _TripsTabViews({
    required this.tripController,
    required this.tabController,
  });

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('complete')) {
      return Colors.green;
    } else if (lowerStatus.contains('process') ||
        lowerStatus.contains('progress') ||
        lowerStatus.contains('ongoing')) {
      return Colors.blue;
    } else if (lowerStatus.contains('upcoming') ||
        lowerStatus.contains('pending')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String _getLocationName(String location) {
    if (location.isEmpty) return 'Unknown';
    final parts = location.split(',');
    return parts.isNotEmpty ? parts[0].trim() : location;
  }

  String _formatDate(DateTime? date, String time) {
    if (date == null) return time;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    final timeStr = time.isNotEmpty
        ? ' – ${time.substring(0, time.length > 5 ? 5 : time.length)}'
        : '';
    return "$dateStr$timeStr";
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        // Completed
        Obx(() {
          final completedTrips = tripController.getTripsByStatus('Completed');
          if (tripController.isTripsLoading.value) {
            return const CustomLoader(message: "Loading trips...");
          }
          if (completedTrips.isEmpty) {
            return const Center(child: Text("No completed trips"));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: completedTrips.map((trip) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => TripExpensesScreen(tripId: trip.tripId));
                },
                child: _TripTile(
                  tripId: trip.tripId,
                  userId: trip.userId,
                  title: "Trip to ${_getLocationName(trip.deliveryLocation)}",
                  subtitle:
                      "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
                  statusColor: _getStatusColor(trip.tripStatus),
                  statusText: trip.tripStatus,
                  date: _formatDate(trip.pickupDate, trip.pickupTime),
                  chip: trip.vehicleType ?? "Standard",
                  vehicle: trip.vehicleNumber ?? '',
                  driver: trip.driverName ?? 'Not assigned',
                  driverContact: trip.driverContact ?? '',
                ),
              );
            }).toList(),
          );
        }),

        // In-Process
        Obx(() {
          final inProcessTrips = tripController.getTripsByStatus('In-Process');
          if (tripController.isTripsLoading.value) {
            return const CustomLoader(message: "Loading trips...");
          }
          if (inProcessTrips.isEmpty) {
            return const Center(child: Text("No in-process trips"));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: inProcessTrips.map((trip) {
              return _TripTile(
                tripId: trip.tripId,
                userId: trip.userId,
                title: "Trip to ${_getLocationName(trip.deliveryLocation)}",
                subtitle:
                    "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
                statusColor: _getStatusColor(trip.tripStatus),
                statusText: trip.tripStatus,
                date: _formatDate(trip.pickupDate, trip.pickupTime),
                chip: trip.vehicleType ?? "Standard",
                vehicle: trip.vehicleNumber ?? '',
                driver: trip.driverName ?? 'Not assigned',
                driverContact: trip.driverContact ?? '',
                onComplete: () {
                  tripController.completeTrip(trip.tripId, trip.userId);
                },
              );
            }).toList(),
          );
        }),

        // Upcoming
        Obx(() {
          final upcomingTrips = tripController.getTripsByStatus('Upcoming');
          if (tripController.isTripsLoading.value) {
            return const CustomLoader(message: "Loading trips...");
          }
          if (upcomingTrips.isEmpty) {
            return const Center(child: Text("No upcoming trips"));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: upcomingTrips.map((trip) {
              print('Driver Image Path: ${trip.driverImagePath}'); 
              return _UpcomingTripCard(
                trip: trip,
                tripId: trip.tripId,
                title: "Trip to ${_getLocationName(trip.deliveryLocation)}",
                subtitle:
                    "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
                statusColor: _getStatusColor(trip.tripStatus),
                statusText: trip.tripStatus,
                date: _formatDate(trip.pickupDate, trip.pickupTime),
                chip: trip.vehicleType ?? "Standard",
                assignedTo: trip.driverName ?? 'Not assigned',
                // assignedToImage: "https://i.pravatar.cc/150?img=4",
                assignedToImage: trip.driverImagePath,
                bidsAvailable: trip.totalBidCount,
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

/// Upcoming Trip Card with View Bids functionality
class _UpcomingTripCard extends StatelessWidget {
  final Trip trip;
  final String tripId;
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final String date;
  final String chip;
  final String assignedTo;
  // final String assignedToImage;
  final int bidsAvailable;
  final String? assignedToImage;

  const _UpcomingTripCard({
    required this.trip,
    required this.tripId,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.date,
    required this.chip,
    required this.assignedTo,
    required this.assignedToImage,
    required this.bidsAvailable,
  });

  @override
  Widget build(BuildContext context) {
    // Determine whether the driver is truly assigned
    final bool isDriverAssigned =
        assignedTo.isNotEmpty && assignedTo != 'Not assigned';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  AppImages.trip,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chip,
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    const Text(
                      "Assigned to:",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(width: 6),
                    // Safe avatar using CachedNetworkImage –
                    // handles extension-less URLs and network failures gracefully
                    _SafeAvatar(
                      imageUrl: isDriverAssigned ? assignedToImage : null,
                      radius: 12,
                      fallbackAsset: 'assets/driver.png',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isDriverAssigned ? assignedTo : 'Unassigned',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDriverAssigned
                              ? Colors.black87
                              : Colors.orange,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (trip.driverId.isEmpty &&
                    (trip.driverName == null || trip.driverName!.isEmpty)) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$bidsAvailable ${bidsAvailable == 1 ? 'Bid' : 'Bids'} Available",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Share Trip + View Bids row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Share Trip Button
                    _actionButton(
                      icon: Icons.share,
                      label: 'Share',
                      color: const Color(0xFFF36969),
                      onTap: () => _shareTrip(trip),
                    ),
                    if (trip.driverId.isEmpty &&
                        (trip.driverName == null || trip.driverName!.isEmpty))
                      // View Bids Button
                      _actionButton(
                        icon: Icons.description,
                        label: 'View Bids',
                        color: bidsAvailable > 0 ? Colors.blue : Colors.grey,
                        onTap: bidsAvailable > 0
                            ? () => Get.to(() => BidsScreen(tripId: tripId))
                            : null,
                      ),
                    // Details Button
                    _actionButton(
                      icon: Icons.arrow_forward,
                      label: 'Details',
                      color: Colors.green,
                      onTap: () => Get.to(() => TripDetailsScreen(trip: trip)),
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

  void _shareTrip(Trip trip) {
    final pickupShort = trip.pickupLocation.split(',').first.trim();
    final deliveryShort = trip.deliveryLocation.split(',').first.trim();

    final dateStr = trip.pickupDate != null
        ? '${trip.pickupDate!.day}/${trip.pickupDate!.month}/${trip.pickupDate!.year}'
        : 'Not scheduled';

    final shareText =
        '''
🚚 Trip Details from Wheelboard

📍 From: $pickupShort
📍 To: $deliveryShort
📅 Date: $dateStr
⏰ Time: ${trip.pickupTime.isNotEmpty ? trip.pickupTime : 'Not specified'}
🚗 Driver: ${trip.driverName ?? 'Not assigned'}

🔗 View on Wheelboard: https://wheelboard.in/trips/${trip.tripId}
''';

    Share.share(shareText.trim());
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple card row for Completed and In-Process trips
class _TripTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final String date;
  final String chip;
  final String vehicle;
  final String driver;
  final String driverContact;

  final String tripId;
  final String userId;
  final VoidCallback? onComplete;

  const _TripTile({
    required this.tripId,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.date,
    required this.chip,
    this.vehicle = '',
    this.driver = '',
    this.driverContact = '',
    this.onComplete,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF4CAF50), width: 4),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                AppImages.trip,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            // Status pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusText.toLowerCase().contains('complete')
                        ? Icons.check_circle
                        : statusText.toLowerCase().contains('process') ||
                              statusText.toLowerCase().contains('progress')
                        ? Icons.autorenew
                        : Icons.access_time,
                    color: statusColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Trip Title
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Subtitle (Route)
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Date Row
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),

            // Vehicle Row
            if (vehicle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 14,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      vehicle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Driver Row
            if (driver.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      driver,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (driverContact.isNotEmpty)
                    GestureDetector(
                      onTap: () => _makePhoneCall(driverContact),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            // Complete Trip Button (Only for In-Process trips)
            if (statusText.toLowerCase().contains('process') ||
                statusText.toLowerCase().contains('progress') ||
                statusText.toLowerCase().contains('ongoing')) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text("Complete Trip"),
                        content: const Text(
                          "Are you sure you want to end this trip?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              if (onComplete != null) {
                                onComplete!();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Confirm"),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    "Complete Trip",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
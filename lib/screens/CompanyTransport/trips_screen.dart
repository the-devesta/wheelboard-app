import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/screens/CompanyTransport/newtripscreen.dart';
import 'package:wheelboard/screens/CompanyTransport/schedulescreen.dart';
import 'package:wheelboard/screens/CompanyTransport/bids_screen.dart';
import 'package:wheelboard/controllers/add_trip_controller.dart';
import 'package:wheelboard/controllers/trip_page_controller.dart';
import 'package:wheelboard/utils/session_manager.dart';
import 'package:wheelboard/utils/navigation_helper.dart';

class TripPage extends StatefulWidget {
  final int initialTabIndex;
  
  const TripPage({super.key, this.initialTabIndex = 0});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with SingleTickerProviderStateMixin {
  final TripController tripController = Get.put(TripController());
  final TripPageTabController tabPageController = Get.put(TripPageTabController(), permanent: true);
  late TabController _tabController;

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
    _fetchTrips();
    
    // Listen to tab changes from GetX controller
    ever(tabPageController.currentTabIndex, (int index) {
      if (_tabController.index != index && mounted) {
        _tabController.animateTo(index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrips() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getString("userId");
    if (userId != null && userId.isNotEmpty) {
      tripController.fetchTrips(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update tab controller if initialTabIndex changed
    if (_tabController.index != widget.initialTabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index != widget.initialTabIndex) {
          _tabController.animateTo(widget.initialTabIndex);
        }
      });
    }

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
                                child: const TextField(
                                  decoration: InputDecoration(
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
                          Container(
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Trips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Recent Trips",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("See all", style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Obx(() {
                        final recentTrips = tripController.trips.take(2).toList();
                        if (tripController.isTripsLoading.value) {
                          return const SizedBox(
                            height: 185,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (recentTrips.isEmpty) {
                          return const SizedBox(
                            height: 185,
                            child: Center(
                              child: Text("No recent trips"),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 185,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: recentTrips.asMap().entries.map((entry) {
                              final trip = entry.value;
                              final index = entry.key;
                              final statusColor = _getStatusColor(trip.tripStatus);
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
                                  title: "Trip to ${_getLocationName(trip.deliveryLocation)}",
                                  subtitle: "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
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
                        color: Color(0xFFCCF6DE),
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
                        labelColor: Colors.green[700],
                        unselectedLabelColor: Colors.green[400],
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.check_circle, size: 18),
                            text: "Completed",
                          ),
                          Tab(
                            icon: Icon(Icons.autorenew, size: 18),
                            text: "In-Process",
                          ),
                          Tab(
                            icon: Icon(Icons.access_time, size: 18),
                            text: "Upcoming",
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
        floatingActionButton: Column(
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
                  "New Trip",
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
                    side: const BorderSide(
                      color: Color(0xFFDFF5EB),
                      width: 2,
                    ),
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
                    side: const BorderSide(
                      color: Color(0xFFDFF5EB),
                      width: 2,
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            // Manage Trips Button
            ElevatedButton(
              onPressed: () {
                // Check if TripPage is already in the navigation stack
                final tabController = Get.find<TripPageTabController>();
                tabController.switchToUpcoming(); // Switch to Upcoming tab (index 2)
                
                // Navigate to trips tab in bottom nav if not already there
                NavigationHelper.navigateToTripsTab();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF26868),
                foregroundColor: Colors.white,
                minimumSize: const Size(117, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFDFF5EB),
                    width: 2,
                  ),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Manage Trips",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
    );
  }

  // --- Helpers from your original code ---

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('complete')) {
      return Colors.green;
    } else if (lowerStatus.contains('process') || lowerStatus.contains('ongoing')) {
      return Colors.blue;
    } else if (lowerStatus.contains('upcoming') || lowerStatus.contains('pending')) {
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
          const SizedBox(height: 3),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 3),

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
    } else if (lowerStatus.contains('process') || lowerStatus.contains('ongoing')) {
      return Colors.blue;
    } else if (lowerStatus.contains('upcoming') || lowerStatus.contains('pending')) {
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
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
            return const Center(child: CircularProgressIndicator());
          }
          if (completedTrips.isEmpty) {
            return const Center(
              child: Text("No completed trips"),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: completedTrips.map((trip) {
              return _TripTile(
                title: "Trip to ${_getLocationName(trip.deliveryLocation)}",
                subtitle: "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
                statusColor: _getStatusColor(trip.tripStatus),
                statusText: trip.tripStatus,
                date: _formatDate(trip.pickupDate, trip.pickupTime),
                chip: trip.vehicleType ?? "Standard",
                vehicle: trip.vehicleNumber ?? '',
                driver: trip.driverName ?? 'Not assigned',
              );
            }).toList(),
          );
        }),

        // In-Process
        Obx(() {
          final inProcessTrips = tripController.getTripsByStatus('In-Process');
          if (tripController.isTripsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (inProcessTrips.isEmpty) {
            return const Center(
              child: Text("No in-process trips"),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: inProcessTrips.map((trip) {
              return _TripTile(
                title: "Trip to ${_getLocationName(trip.deliveryLocation)}",
                subtitle: "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
                statusColor: _getStatusColor(trip.tripStatus),
                statusText: trip.tripStatus,
                date: _formatDate(trip.pickupDate, trip.pickupTime),
                chip: trip.vehicleType ?? "Standard",
                vehicle: trip.vehicleNumber ?? '',
                driver: trip.driverName ?? 'Not assigned',
              );
            }).toList(),
          );
        }),

        // Upcoming
        Obx(() {
          final upcomingTrips = tripController.getTripsByStatus('Upcoming');
          if (tripController.isTripsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (upcomingTrips.isEmpty) {
            return const Center(
              child: Text("No upcoming trips"),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: upcomingTrips.map((trip) {
              return _UpcomingTripCard(
                tripId: trip.tripId,
                title: "Trip to ${_getLocationName(trip.deliveryLocation)}",
                subtitle: "${_getLocationName(trip.pickupLocation)} → ${_getLocationName(trip.deliveryLocation)}",
                statusColor: _getStatusColor(trip.tripStatus),
                statusText: trip.tripStatus,
                date: _formatDate(trip.pickupDate, trip.pickupTime),
                chip: trip.vehicleType ?? "Standard",
                assignedTo: trip.driverName ?? 'Not assigned',
                assignedToImage: "https://i.pravatar.cc/150?img=4",
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
  final String tripId;
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final String date;
  final String chip;
  final String assignedTo;
  final String assignedToImage;
  final int bidsAvailable;

  const _UpcomingTripCard({
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
                  'assets/tripImage.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 14),
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
                    const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
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
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(assignedToImage),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        assignedTo,
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: bidsAvailable > 0
                            ? () {
                                Get.to(() => BidsScreen(tripId: tripId));
                              }
                            : null,
                        icon: const Icon(Icons.description, size: 16),
                        label: const Text("View Bids"),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: bidsAvailable > 0 ? Colors.blue : Colors.grey,
                          ),
                          foregroundColor: bidsAvailable > 0 ? Colors.blue : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // View Details
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text("View Details"),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          foregroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
}

/// Simple card row for non-TripInfoCard examples
class _TripTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final String date;
  final String chip;
  final String vehicle;
  final String driver;

  const _TripTile({
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.date,
    required this.chip,
    this.vehicle = '',
    this.driver = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
                  statusText == "Completed"
                      ? Icons.check_circle
                      : statusText == "In-Process"
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

          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              chip,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          if (vehicle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  vehicle,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ],
          if (driver.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  driver,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

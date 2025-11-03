import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/CompanyTransport/newtripscreen.dart';
import 'package:wheelboard/screens/CompanyTransport/schedulescreen.dart';
import 'trips_info_widget.dart';
import 'trip_confirmation.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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

                      SizedBox(
                        height: 185,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            tripCard(
                              title: "Trip to Ahmedabad",
                              subtitle: "From Surat → Ahmedabad",
                              tag: "Completed",
                              label: "Cold Storage",
                              date: "June 30, 2024 – 9:00 AM",
                              tagColor: Colors.green,
                            ),
                            const SizedBox(width: 16),
                            tripCard(
                              title: "Trip to Bhopal",
                              subtitle: "Indore → Bhopal",
                              tag: "Upcoming",
                              label: "Express Delivery",
                              date: "July 10, 2024",
                              tagColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),
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
            body: const _TripsTabViews(),
          ),
        ),

        // Your FAB column
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(ConfirmTripPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD6C6C),
                minimumSize: const Size(140, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Manage Trips",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                Get.to(const ScheduleTripScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg,
                minimumSize: const Size(140, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Schedule",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                Get.to(Newtripscreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg,
                minimumSize: const Size(140, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                "+ New Trip",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers from your original code ---

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
          // ✔ Completed pill with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tagColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: tagColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
  const _TripsTabViews({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        // Completed
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: const [
            TripInfoCard(
              imagePath: 'assets/tripImage.png',
              status: 'Completed',
              badge: 'Standard',
              title: 'Trip to Los Angeles',
              tag: 'Package Delivery',
              destination: 'Los Angeles',
              departureDate: '2024-06-01',
              vehicle: 'shipment truck-GJ 06 K9 1442',
              driver: 'Deepak kumar',
            ),
          ],
        ),

        // In-Process
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _TripTile(
              title: "Trip to Pune",
              subtitle: "Mumbai → Pune",
              statusColor: Colors.blue,
              statusText: "In-Process",
              date: "Aug 6, 2025 – 11:10 AM",
              chip: "Express Delivery",
            ),
          ],
        ),

        // Upcoming
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _TripTile(
              title: "Trip to Bhopal",
              subtitle: "Indore → Bhopal",
              statusColor: Colors.orange,
              statusText: "Upcoming",
              date: "Aug 9, 2025",
              chip: "Express Delivery",
            ),
          ],
        ),
      ],
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

  const _TripTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.date,
    required this.chip,
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
        ],
      ),
    );
  }
}

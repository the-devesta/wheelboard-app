import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../controllers/Professional/trip_dashboard_controller.dart';
import '../../../models/assigned_trip_model.dart';
import '../TripDetails/TripDetailsScreen.dart';
import '../TrackTrip/TrackTripScreen.dart';
import '../TripProgress/TripProgressScreen.dart';
import '../../../widgets/custom_loader.dart';
import '../../../apihelperclass/api_helper.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> {
  String _selectedChartType = 'Trips'; // 'Trips', 'Earnings', 'Distance'

  // Use Get.find to access the existing controller from wrapper
  final AssignedTripController tripController =
      Get.find<AssignedTripController>();
  final TripDashboardController dashboardController = Get.put(
    TripDashboardController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Trips Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(
            child: CustomLoader(message: "Loading dashboard..."),
          );
        }

        final data = dashboardController.dashboardData.value;
        if (data == null) {
          return const Center(child: Text("No dashboard data available"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await dashboardController.fetchDashboardData();
            await tripController.fetchAssignedTrips();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle,
                        iconBgColor: const Color(0xFFEEF2FB),
                        iconColor: const Color(0xFF375DFB),
                        value: data.summary.completedTrips.toString(),
                        label: 'Completed\nTrips',
                        valueColor: const Color(0xFF375DFB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.currency_rupee,
                        iconBgColor: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF27AE60),
                        value: HttpHelper.formatAmount(
                          data.summary.monthlyEarnings,
                        ),
                        label: 'This Month',
                        valueColor: const Color(0xFF27AE60),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star,
                        iconBgColor: Colors.transparent,
                        iconColor: Colors.transparent,
                        value: data.summary.avgRating.toStringAsFixed(1),
                        label: 'Avg. Rating',
                        valueColor: const Color(0xFFF39C12),
                        showStar: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Trip Completion Trend
                _buildChartSection(data.weeklyTrend),
                const SizedBox(height: 24),

                // Active Trips
                _buildActiveTripsSection(),
                const SizedBox(height: 24),

                // Completed Trips
                _buildCompletedTripsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    required String label,
    required Color valueColor,
    bool showStar = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!showStar)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            )
          else
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.star, size: 40, color: Color(0xFFF39C12)),
                  // Note: Removed the invisible text from original code as it was just for spacing
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: value.length > 8 ? 16 : 15,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          if (showStar)
            const Text(
              '★',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF39C12),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<dynamic> weeklyTrend) {
    List<double> dataPoints = [];
    String yLabelPrefix = '';
    double maxValue = 10;

    // Determine color and suffix based on selection
    Color chartColor;
    String yLabelSuffix = '';

    if (_selectedChartType == 'Trips') {
      dataPoints = weeklyTrend.map((e) => (e.trips as num).toDouble()).toList();
      maxValue = dataPoints.fold(
        5.0,
        (prev, element) => element > prev ? element : prev,
      );
      chartColor = const Color(0xFF375DFB); // Blue for Trips
    } else if (_selectedChartType == 'Earnings') {
      dataPoints = weeklyTrend
          .map((e) => (e.earnings as num).toDouble())
          .toList();
      yLabelPrefix = '₹';
      maxValue = dataPoints.fold(
        100.0,
        (prev, element) => element > prev ? element : prev,
      );
      chartColor = const Color(0xFF27AE60); // Green for Earnings
    } else {
      dataPoints = weeklyTrend
          .map((e) => (e.distance as num).toDouble())
          .toList();
      yLabelSuffix = 'km';
      maxValue = dataPoints.fold(
        10.0,
        (prev, element) => element > prev ? element : prev,
      );
      chartColor = const Color(0xFFF36969); // Red for Distance
    }

    // Round up maxValue to nearest "pretty" number
    maxValue = (maxValue / 5).ceil() * 5.0;
    if (maxValue == 0) maxValue = 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 20,
                    color: Color(0xFF535353),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trend',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF535353),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildChartToggleButton('Trips'),
                  const SizedBox(width: 4),
                  _buildChartToggleButton('Earnings'),
                  const SizedBox(width: 4),
                  _buildChartToggleButton('Distance'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDADADA).withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Y-Axis Labels
                    SizedBox(
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          double val = maxValue - (index * maxValue / 5);
                          String label = val >= 1000
                              ? '${(val / 1000).toStringAsFixed(1)}k'
                              : val.toStringAsFixed(0);
                          return Text(
                            '$yLabelPrefix$label$yLabelSuffix',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chart Area
                    Expanded(
                      child: Stack(
                        children: [
                          // Grid lines
                          Column(
                            children: List.generate(
                              6,
                              (index) => Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFF0F0F0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // The actual graph
                          CustomPaint(
                            size: const Size(double.infinity, double.infinity),
                            painter: TripChartPainter(
                              dataPoints: dataPoints,
                              maxValue: maxValue,
                              color: chartColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // X-Axis Labels (Days)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weeklyTrend
                      .map(
                        (e) => Text(
                          e.dayName.substring(0, 3),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartToggleButton(String label) {
    bool isSelected = _selectedChartType == label;

    // Determine button color based on label (active state)
    // Trips: Blue, Earnings: Green, Distance: Red
    Color activeColor;
    if (label == 'Trips') {
      activeColor = const Color(0xFF375DFB);
    } else if (label == 'Earnings') {
      activeColor = const Color(0xFF27AE60);
    } else {
      activeColor = const Color(0xFFF36969);
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF7B7B7B),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTripsSection() {
    return Obx(() {
      final activeTrips = tripController.assignedTrips.where((trip) {
        final status = trip.tripStatus.toLowerCase();
        return status == 'upcoming' ||
            status == 'active' ||
            status == 'in progress';
      }).toList();

      if (activeTrips.isEmpty && !tripController.isLoading.value)
        return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.local_shipping, 'Active Trips'),
            const SizedBox(height: 12),
            if (tripController.isLoading.value)
              const CustomLoader.small()
            else
              ...activeTrips.map((trip) => _buildTripCard(trip)),
          ],
        ),
      );
    });
  }

  Widget _buildCompletedTripsSection() {
    return Obx(() {
      final completedTrips = tripController.assignedTrips.where((trip) {
        final status = trip.tripStatus.toLowerCase();
        return status == 'completed' ||
            status == 'finished' ||
            status == 'done';
      }).toList();

      if (completedTrips.isEmpty && !tripController.isLoading.value)
        return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.check_circle, 'Recently Completed'),
            const SizedBox(height: 12),
            if (tripController.isLoading.value)
              const CustomLoader.small()
            else
              ...completedTrips.map(
                (trip) => _buildTripCard(trip, isCompleted: true),
              ),
          ],
        ),
      );
    });
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFF36969)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(AssignedTrip trip, {bool isCompleted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFFF36969)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${trip.pickupLocation} ➔ ${trip.deliveryLocation}",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ID: ${trip.tripCode}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              if (trip.calculatedDistance != null)
                Row(
                  children: [
                    const Icon(Icons.straighten, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${trip.calculatedDistance!.toStringAsFixed(1)} km",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      trip.estimatedEta ?? "--",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    if (trip.distance != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.distance!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              Text(
                HttpHelper.formatAmount(trip.bidAmount ?? 0),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27AE60),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Get.to(() => TripDetailsScreen(trip: trip)),
                child: const Text(
                  "View Details",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              if (!isCompleted)
                ElevatedButton(
                  onPressed: () {
                    final status = trip.tripStatus.toLowerCase();
                    final bool isInProgress = [
                      'in progress',
                      'active',
                      'ongoing',
                    ].contains(status);

                    if (isInProgress) {
                      Get.to(() => TrackTripScreen(tripId: trip.tripId));
                    } else {
                      Get.to(() => TripProgressScreen(trip: trip));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBF4FF),
                    foregroundColor: const Color(0xFF2F80ED),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Track Trip",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class TripChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double maxValue;
  final Color color;

  TripChartPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.01)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Handle single point or multiple points
    final double spacing = dataPoints.length > 1
        ? size.width / (dataPoints.length - 1)
        : 0;
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      // If single point, center it. Otherwise scale by spacing.
      final x = dataPoints.length > 1 ? i * spacing : size.width / 2;
      final y = size.height - (dataPoints[i] / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    for (int i = 0; i < dataPoints.length; i++) {
      final x = dataPoints.length > 1 ? i * spacing : size.width / 2;
      final y = size.height - (dataPoints[i] / maxValue) * size.height;
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(Offset(x, y), 5, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant TripChartPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../models/assigned_trip_model.dart';
import '../TripDetails/TripDetailsScreen.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> {
  String _selectedChartType = 'Trips';
  String _selectedCompletedFilter = 'Recent';
  final AssignedTripController tripController = Get.put(AssignedTripController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Navigate to home screen instead of going back
          Navigator.of(context).pushReplacementNamed('/professional-home');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Row(
                children: [
                  const SizedBox(width: 40), // Spacer to center title
                  Expanded(
                    child: Center(
                      child: Text(
                        'Trips Dashboard',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF36969),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    child: const Icon(Icons.more_vert, size: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                            value: '8',
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
                            value: '₹70,000',
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
                            value: '4.2',
                            label: 'Avg. Rating',
                            valueColor: const Color(0xFFF39C12),
                            showStar: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Trip Completion Trend
                    _buildChartSection(),
                    const SizedBox(height: 24),
                    // Active Trips
                    _buildActiveTripsSection(),
                    const SizedBox(height: 24),
                    // Completed Trips
                    _buildCompletedTripsSection(),
                    const SizedBox(height: 24),
                    // Ratings Breakdown
                    _buildRatingsSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
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
            Container(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.star, size: 40, color: Color(0xFFF39C12)),
                  Text(
                    '4.2',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          if (showStar)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '★',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF39C12),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, size: 20, color: Color(0xFF535353)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Trip Completion Trend',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF535353),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChartToggleButton('Trips', _selectedChartType == 'Trips'),
                    _buildChartToggleButton('Earnings', _selectedChartType == 'Earnings'),
                    _buildChartToggleButton('Distance', _selectedChartType == 'Distance'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 217,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDADADA)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 30,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('30', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('27', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('24', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('21', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('18', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('15', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('12', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('9', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('6', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('3', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                              Text('0', style: GoogleFonts.inter(fontSize: 10, color: Colors.black.withOpacity(0.7))),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Stack(
                        children: [
                          // Grid lines
                          Column(
                            children: List.generate(11, (index) => Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
                                ),
                              ),
                            )),
                          ),
                          // Chart line with data points
                          CustomPaint(
                            size: const Size(double.infinity, double.infinity),
                            painter: TripChartPainter(),
                          ),
                          // Data labels
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                  .map((day) => Text(
                                        day,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 16,
                    height: 2,
                    color: const Color(0xFFF25C5C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trips',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF4FF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFBFD8FF) : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFF2F80ED) : const Color(0xFF7B7B7B),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTripsSection() {
    return Obx(() {
      if (tripController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final activeTrips = tripController.assignedTrips.where((trip) {
        // Consider trips as active if pickup date is today or in the future
        final now = DateTime.now();
        final tripDate = trip.pickupDate;
        return tripDate.isAfter(now) || tripDate.isAtSameMomentAs(now);
      }).toList();

      if (activeTrips.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Color(0xFFF36969)),
                  const SizedBox(width: 8),
                  Text(
                    'Active Trips',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF36969),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No active trips',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 16, color: Color(0xFFF36969)),
                const SizedBox(width: 8),
                Text(
                  'Active Trips',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF36969),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activeTrips.map((trip) {
              final isToday = trip.pickupDate.day == DateTime.now().day &&
                  trip.pickupDate.month == DateTime.now().month &&
                  trip.pickupDate.year == DateTime.now().year;
              final timeStr = isToday
                  ? 'Today, ${trip.pickupTime.substring(0, trip.pickupTime.length > 5 ? 5 : trip.pickupTime.length)}'
                  : _formatDate(trip.pickupDate, trip.pickupTime);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTripCard(
                  trip: trip,
                  from: trip.pickupLocation,
                  to: trip.deliveryLocation,
                  time: timeStr,
                  vehicleNumber: 'N/A',
                  status: 'Active',
                  statusColor: const Color(0xFF2F80ED),
                  statusBgColor: const Color(0xFFEBF4FF),
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
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

  Widget _buildTripCard({
    AssignedTrip? trip,
    required String from,
    required String to,
    required String time,
    required String vehicleNumber,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Color(0xFFF36969)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  from,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF36969),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFF36969)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  to,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF36969),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              if (trip != null) ...[
                const Icon(Icons.currency_rupee, size: 12, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  '₹${trip.bidAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ] else ...[
                const Icon(Icons.local_shipping, size: 12, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  vehicleNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: trip != null
                    ? () {
                        Get.to(() => TripDetailsScreen(trip: trip));
                      }
                    : null,
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF375DFB),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTripsSection() {
    return Obx(() {
      if (tripController.isLoading.value) {
        return const SizedBox.shrink();
      }

      final completedTrips = tripController.assignedTrips.where((trip) {
        // Consider trips as completed if pickup date is in the past
        final now = DateTime.now();
        final tripDate = trip.pickupDate;
        return tripDate.isBefore(now);
      }).toList();

      // Sort based on filter
      List<AssignedTrip> sortedTrips = List.from(completedTrips);
      if (_selectedCompletedFilter == 'Highest Earning') {
        sortedTrips.sort((a, b) => b.bidAmount.compareTo(a.bidAmount));
      } else if (_selectedCompletedFilter == 'Recent') {
        sortedTrips.sort((a, b) => b.pickupDate.compareTo(a.pickupDate));
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Color(0xFFF36969)),
                const SizedBox(width: 8),
                Text(
                  'Completed Trips',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF36969),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCompletedFilterButton('Recent', _selectedCompletedFilter == 'Recent'),
                  const SizedBox(width: 8),
                  _buildCompletedFilterButton('Highest Rated', _selectedCompletedFilter == 'Highest Rated'),
                  const SizedBox(width: 8),
                  _buildCompletedFilterButton('Highest Earning', _selectedCompletedFilter == 'Highest Earning'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (sortedTrips.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No completed trips',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              )
            else
              ...sortedTrips.map((trip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCompletedTripItem(
                    trip: trip,
                    from: trip.pickupLocation,
                    to: trip.deliveryLocation,
                    earning: '+₹${trip.bidAmount.toStringAsFixed(0)}',
                  ),
                );
              }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildCompletedFilterButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCompletedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF4FF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFBFD8FF) : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF2F80ED) : const Color(0xFF7B7B7B),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedTripItem({
    AssignedTrip? trip,
    required String from,
    required String to,
    required String earning,
  }) {
    return GestureDetector(
      onTap: trip != null
          ? () {
              Get.to(() => TripDetailsScreen(trip: trip));
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 12, color: Color(0xFFF36969)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                from,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF36969),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFF36969)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                to,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF36969),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Text(
              earning,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27AE60),
              ),
            ),
            if (trip != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF6B7280)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsSection() {
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
          Text(
            'Ratings',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          _buildRatingRow('5★', 0.60, const Color(0xFFF39C12)),
          const SizedBox(height: 8),
          _buildRatingRow('4★', 0.25, const Color(0xFFF39C12).withOpacity(0.8)),
          const SizedBox(height: 8),
          _buildRatingRow('3★', 0.10, const Color(0xFFF39C12).withOpacity(0.6)),
          const SizedBox(height: 8),
          _buildRatingRow('2★', 0.03, const Color(0xFFF39C12).withOpacity(0.4)),
          const SizedBox(height: 8),
          _buildRatingRow('1★', 0.02, const Color(0xFFF39C12).withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String stars, double percentage, Color barColor) {
    final percentText = '${(percentage * 100).toInt()}%';
    return Row(
      children: [
        Text(
          stars,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFFF39C12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentText,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

// Custom painter for trip chart
class TripChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF25C5C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFFF25C5C).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Data points: [10, 12, 24, 16, 24, 8, 18] (scaled from 0-30)
    final dataPoints = [10, 12, 24, 16, 24, 8, 18];
    final maxValue = 30.0;
    final spacing = size.width / (dataPoints.length - 1);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * spacing;
      final y = size.height - (dataPoints[i] / maxValue) * size.height * 0.9;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw data point
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = const Color(0xFFF25C5C)..style = PaintingStyle.fill,
      );
    }

    // Complete fill path
    fillPath.lineTo((dataPoints.length - 1) * spacing, size.height);
    fillPath.close();

    // Draw filled area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> {
  String _selectedChartType = 'Trips';
  String _selectedCompletedFilter = 'Recent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.arrow_back_ios, size: 16),
                    ),
                  ),
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
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 20, color: Color(0xFF535353)),
                  const SizedBox(width: 8),
                  Text(
                    'Trip Completion Trend',
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
                  _buildChartToggleButton('Trips', _selectedChartType == 'Trips'),
                  const SizedBox(width: 8),
                  _buildChartToggleButton('Earnings', _selectedChartType == 'Earnings'),
                  const SizedBox(width: 8),
                  _buildChartToggleButton('Distance', _selectedChartType == 'Distance'),
                ],
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
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('30', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('27', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('24', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('21', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('18', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('15', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('12', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('9', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('6', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('3', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                          Text('0', style: GoogleFonts.inter(fontSize: 12, color: Colors.black.withOpacity(0.7))),
                        ],
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
          _buildTripCard(
            from: 'Warehouse A',
            to: 'Store Z',
            time: 'Today, 09:35 AM',
            vehicleNumber: 'MH12AB3456',
            status: 'In Transit',
            statusColor: const Color(0xFF2F80ED),
            statusBgColor: const Color(0xFFEBF4FF),
          ),
          const SizedBox(height: 12),
          _buildTripCard(
            from: 'Depot B',
            to: 'Outlet 21',
            time: 'Today, 10:20 AM',
            vehicleNumber: 'MH09NM1234',
            status: 'Pending',
            statusColor: const Color(0xFFF39C12),
            statusBgColor: const Color(0xFFFFF7E3),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard({
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
              Text(
                from,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF36969),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFF36969)),
              const SizedBox(width: 4),
              Text(
                to,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF36969),
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
                onPressed: () {},
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
          Row(
            children: [
              _buildCompletedFilterButton('Recent', _selectedCompletedFilter == 'Recent'),
              const SizedBox(width: 8),
              _buildCompletedFilterButton('Highest Rated', _selectedCompletedFilter == 'Highest Rated'),
              const SizedBox(width: 8),
              _buildCompletedFilterButton('Highest Earning', _selectedCompletedFilter == 'Highest Earning'),
            ],
          ),
          const SizedBox(height: 12),
          _buildCompletedTripItem('Warehouse A', 'Store Z', '+₹9,400'),
          const SizedBox(height: 8),
          _buildCompletedTripItem('Depot B', 'Outlet 21', '+₹7,800'),
        ],
      ),
    );
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

  Widget _buildCompletedTripItem(String from, String to, String earning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 12, color: Color(0xFFF36969)),
          const SizedBox(width: 4),
          Text(
            from,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF36969),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFF36969)),
          const SizedBox(width: 4),
          Text(
            to,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF36969),
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
        ],
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


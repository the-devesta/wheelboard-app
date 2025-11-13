import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String selectedPeriod = 'This Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Total Earnings Card
                    _buildTotalEarningsCard(),
                    const SizedBox(height: 20),
                    // Service Breakdown Section
                    _buildServiceBreakdownSection(),
                    const SizedBox(height: 20),
                    // Earnings Over Time Section
                    _buildEarningsOverTimeSection(),
                    const SizedBox(height: 20),
                    // Payment History Section
                    _buildPaymentHistorySection(),
                    const SizedBox(height: 20),
                    // Export as PDF Button
                    _buildExportButton(),
                    const SizedBox(height: 20),
                    // Register New Payment Button
                    _buildRegisterPaymentButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          Text(
            'Earnings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
    return Container(
      height: 152,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF36969), Color(0xFFF87171)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹12,480.00',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const Spacer(),
          // Filter Buttons
          Row(
            children: [
              _buildPeriodButton('This Week', selectedPeriod == 'This Week'),
              const SizedBox(width: 8),
              _buildPeriodButton('This Month', selectedPeriod == 'This Month'),
              const SizedBox(width: 8),
              _buildPeriodButton('Custom', selectedPeriod == 'Custom'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Breakdown',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          icon: Icons.help_outline,
          title: 'Tyre Replacement',
          subtitle: 'Last booking: 2 days ago',
          amount: '₹3,200',
          bookings: '6 bookings',
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          icon: Icons.build,
          title: 'Engine Repair',
          subtitle: 'Last booking: 1 week ago',
          amount: '₹4,800',
          bookings: '3 bookings',
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          icon: Icons.battery_charging_full,
          title: 'Battery Service',
          subtitle: 'Last booking: 3 days ago',
          amount: '₹2,480',
          bookings: '4 bookings',
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String bookings,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[100]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF36969).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amount,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    bookings,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsOverTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Earnings Over Time',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'By Month',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: EarningsChartPainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          title: 'Tyre Replacement',
          date: '2 June 2025',
          amount: '₹1,200',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          title: 'Engine Repair',
          date: '28 May 2025',
          amount: '₹2,400',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          title: 'Battery Service',
          date: '25 May 2025',
          amount: '₹1,800',
        ),
      ],
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String date,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[100]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle export as PDF
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF36969), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(
          Icons.download,
          color: Color(0xFFF36969),
          size: 16,
        ),
        label: Text(
          'Export as PDF',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF36969),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to register new payment
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF36969),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Register New Payment',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Custom painter for earnings chart
class EarningsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Data points for earnings (scaled to fit the chart)
    final dataPoints = [800, 950, 1100, 1050, 1230, 1000, 1150, 1080, 1200];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
    final maxValue = 1500.0;
    final spacing = size.width / (dataPoints.length - 1);
    final chartHeight = size.height - 40; // Space for labels

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw chart line
    final linePaint = Paint()
      ..color = const Color(0xFF438883)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF438883).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * spacing;
      final y = chartHeight - (dataPoints[i] / maxValue) * chartHeight * 0.8;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw data point
      if (i == 3) {
        // Highlight April point
        canvas.drawCircle(
          Offset(x, y),
          6,
          Paint()
            ..color = const Color(0xFF438883)
            ..style = PaintingStyle.fill,
        );
        // Draw dashed line to bottom
        final dashPaint = Paint()
          ..color = const Color(0xFF438883).withOpacity(0.3)
          ..strokeWidth = 1;
        final dashPath = Path()
          ..moveTo(x, y)
          ..lineTo(x, chartHeight + 20);
        canvas.drawPath(
          dashPath,
          dashPaint
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
        // Draw tooltip
        final tooltipRect = Rect.fromLTWH(
          x - 35,
          y - 30,
          70,
          25,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(tooltipRect, const Radius.circular(4)),
          Paint()..color = Colors.white,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(tooltipRect, const Radius.circular(4)),
          Paint()
            ..color = const Color(0xFF438883)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: '₹1,230',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF438883),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - 22),
        );
      } else {
        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()
            ..color = const Color(0xFF438883)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Complete fill path
    fillPath.lineTo((dataPoints.length - 1) * spacing, chartHeight);
    fillPath.close();

    // Draw filled area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, linePaint);

    // Draw month labels
    final textStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
      fontWeight: FontWeight.normal,
    );

    for (int i = 0; i < months.length; i++) {
      final x = i * spacing;
      final textPainter = TextPainter(
        text: TextSpan(
          text: months[i],
          style: i == 4
              ? textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF438883),
                )
              : textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


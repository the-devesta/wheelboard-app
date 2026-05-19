import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/controllers/ServiceProvider/service_earnings_controller.dart';
import 'package:wheelboard/models/ServiceProvider/service_earnings_model.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wheelboard/screens/CompanyServiceProvider/register_payment_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String selectedFilter = 'This Month';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceEarningsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: Text(
          'Earnings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.dashboardData.value;
        if (data == null) {
          return _buildEmptyState(controller);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchEarningsDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Total Earnings Card
                _buildTotalEarningsCard(data.totalEarnings),
                const SizedBox(height: 24),

                // Service Breakdown Section
                _buildSectionHeader("Service Breakdown"),
                const SizedBox(height: 16),
                ...data.serviceBreakdown
                    .map((s) => _buildServiceBreakdownCard(s))
                    ,

                const SizedBox(height: 24),

                // Earnings Over Time Section
                _buildSectionHeader(
                  "Earnings Over Time",
                  trailing: _buildChartFilterDropdown(),
                ),
                const SizedBox(height: 16),
                _buildEarningsChart(data.earningsChart),

                const SizedBox(height: 24),

                // Payment History Section
                _buildSectionHeader("Payment History"),
                const SizedBox(height: 16),
                ...data.paymentHistory
                    .map((p) => _buildPaymentHistoryCard(p))
                    ,

                const SizedBox(height: 24),

                // Action Buttons
                _buildOutlinedActionButton(
                  label: "Export as PDF",
                  icon: Icons.file_download_outlined,
                  onPressed: () {
                    // Logic to export as PDF
                  },
                ),
                const SizedBox(height: 12),
                _buildFilledActionButton(
                  label: "Register New Payment",
                  onPressed: () => Get.to(() => const RegisterPaymentScreen()),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(ServiceEarningsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text("No earnings data found"),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.fetchEarningsDashboard(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalEarningsCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF36969), Color(0xFFF87171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            HttpHelper.formatAmount(total),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildFilterTab("This Week"),
              const SizedBox(width: 8),
              _buildFilterTab("This Month"),
              const SizedBox(width: 8),
              _buildFilterTab("Custom"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildChartFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            "By Month",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF3B82F6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _buildServiceBreakdownCard(ServiceBreakdown service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getServiceIcon(service.serviceTitle),
              color: const Color(0xFFF36969),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  "Last booking: ${_getTimeAgo(service.lastBookingDate)}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      HttpHelper.formatAmount(service.totalAmount),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${service.bookingCount} bookings",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String title) {
    if (title.toLowerCase().contains("tyre")) {
      return Icons
          .help_outline; // Figma shows a question mark in a circle for tyre? Actually it looks like a help icon.
    } else if (title.toLowerCase().contains("engine")) {
      return Icons.build_outlined;
    } else if (title.toLowerCase().contains("battery")) {
      return Icons.battery_charging_full_outlined;
    }
    return Icons.settings_outlined;
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null) return "Never";
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) return "Today";
      if (difference.inDays == 1) return "Yesterday";
      if (difference.inDays < 7) return "${difference.inDays} days ago";
      if (difference.inDays < 30) {
        int weeks = (difference.inDays / 7).floor();
        return "$weeks week${weeks > 1 ? 's' : ''} ago";
      }
      return formatDateShort(dateString);
    } catch (_) {
      return "Recently";
    }
  }

  Widget _buildEarningsChart(List<EarningsChartData> chartData) {
    if (chartData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No data for chart")),
      );
    }

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, right: 10, left: 0, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        chartData[index].monthName.substring(0, 3),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF6B7280),
                          fontWeight: index == 4
                              ? FontWeight.w700
                              : FontWeight.w400, // May as active
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chartData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.totalAmount);
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF438883), Color(0xFF438883)],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  if (index == 3) {
                    // Highlight index 4 (April/May area)
                    return FlDotCirclePainter(
                      radius: 6,
                      color: const Color(0xFF438883),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF438883).withValues(alpha: 0.3),
                    const Color(0xFF438883).withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFFD1FAE5),
              tooltipBorder: const BorderSide(
                color: Color(0xFF438883),
                width: 1,
              ),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    HttpHelper.formatAmount(touchedSpot.y),
                    const TextStyle(
                      color: Color(0xFF438883),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryCard(PaymentHistory payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.serviceTitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                formatDateShort(payment.paymentDate),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Text(
            HttpHelper.formatAmount(payment.paymentAmount),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFFF36969)),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF36969)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilledActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF36969),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/controllers/ServiceProvider/service_earnings_controller.dart';
import 'package:wheelboard/models/ServiceProvider/service_earnings_model.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceEarningsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Service Earnings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFF5E5E),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.dashboardData.value;
        if (data == null) {
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

        return RefreshIndicator(
          onRefresh: () => controller.fetchEarningsDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Hero Earnings Card
                _buildHeroCard(data.totalEarnings),
                const SizedBox(height: 24),

                // Chart Section
                if (data.earningsChart.isNotEmpty) ...[
                  _sectionTitle("Monthly Trend"),
                  const SizedBox(height: 12),
                  _buildChartContainer(data.earningsChart),
                  const SizedBox(height: 24),
                ],

                // Service Breakdown
                if (data.serviceBreakdown.isNotEmpty) ...[
                  _sectionTitle("Service Breakdown"),
                  const SizedBox(height: 12),
                  ...data.serviceBreakdown
                      .map((s) => _buildServiceTile(s))
                      .toList(),
                  const SizedBox(height: 24),
                ],

                // Payment History
                if (data.paymentHistory.isNotEmpty) ...[
                  _sectionTitle("Recent Payments"),
                  const SizedBox(height: 12),
                  ...data.paymentHistory
                      .map((p) => _buildPaymentTile(p))
                      .toList(),
                  const SizedBox(height: 24),
                ],

                // Add Payment Button
                _buildActionButton(
                  context: context,
                  label: "RECORD NEW PAYMENT",
                  icon: Icons.add_circle_outline,
                  color: const Color(0xFFFF5E5E),
                  onPressed: () =>
                      _showRecordPaymentSheet(context, controller, data),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeroCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5E5E), Color(0xFFFF8E8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5E5E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL REVENUE',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            HttpHelper.formatAmount(total),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Overall Earnings",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildChartContainer(List<EarningsChartData> chartData) {
    double maxVal =
        chartData.fold(
          1.0,
          (prev, element) =>
              element.totalAmount > prev ? element.totalAmount : prev,
        ) *
        1.2;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((d) {
                double barHeight = (d.totalAmount / maxVal) * 120;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${(d.totalAmount / 1000).toStringAsFixed(1)}k",
                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 25,
                        height: barHeight + 5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF5E5E).withOpacity(0.8),
                              const Color(0xFFFF5E5E).withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d.monthName.substring(0, 3),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(ServiceBreakdown service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.miscellaneous_services,
                  color: Color(0xFFFF5E5E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      "${service.bookingCount} Bookings",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                HttpHelper.formatAmount(service.totalAmount),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          if (service.lastBookingDate != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "Last booking: ${formatDateShort(service.lastBookingDate)}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentTile(PaymentHistory payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward,
              size: 16,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.serviceTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  formatDateShort(payment.paymentDate),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "+${HttpHelper.formatAmount(payment.paymentAmount)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showRecordPaymentSheet(
    BuildContext context,
    ServiceEarningsController controller,
    ServiceEarningsModel data,
  ) {
    final amountController = TextEditingController();
    final purposeController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedServiceId;

    if (data.serviceBreakdown.isNotEmpty) {
      selectedServiceId = data.serviceBreakdown.first.serviceId;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Record Payment",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Manually record a payment receive for your services.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Service Dropdown
              const Text(
                "Service",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedServiceId,
                decoration: _inputDecoration("Select Service"),
                items: data.serviceBreakdown.map((s) {
                  return DropdownMenuItem(
                    value: s.serviceId,
                    child: Text(s.serviceTitle),
                  );
                }).toList(),
                onChanged: (val) => selectedServiceId = val,
              ),
              const SizedBox(height: 16),

              // Amount
              const Text(
                "Amount (₹)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Enter amount"),
              ),
              const SizedBox(height: 16),

              // Purpose
              const Text(
                "Purpose",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: purposeController,
                decoration: _inputDecoration("e.g. Final Payment"),
              ),
              const SizedBox(height: 16),

              // Notes
              const Text(
                "Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: _inputDecoration("Any additional details..."),
              ),
              const SizedBox(height: 32),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: controller.isRecordingPayment.value
                        ? null
                        : () async {
                            if (selectedServiceId == null ||
                                amountController.text.isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please fill required fields",
                                backgroundColor: Colors.orange.withOpacity(0.1),
                              );
                              return;
                            }
                            final ok = await controller.recordPayment(
                              serviceId: selectedServiceId!,
                              amount:
                                  double.tryParse(amountController.text) ?? 0.0,
                              purpose: purposeController.text,
                              notes: notesController.text,
                            );
                            if (ok) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5E5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isRecordingPayment.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SUBMIT PAYMENT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

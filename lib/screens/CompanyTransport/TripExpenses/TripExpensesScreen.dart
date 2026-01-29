import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wheelboard/controllers/Transport/trip_expenses_controller.dart';
import 'package:wheelboard/models/trip_expenses_model.dart';

class TripExpensesScreen extends StatefulWidget {
  final String tripId;

  const TripExpensesScreen({super.key, required this.tripId});

  @override
  State<TripExpensesScreen> createState() => _TripExpensesScreenState();
}

class _TripExpensesScreenState extends State<TripExpensesScreen> {
  final TripExpensesController controller = Get.put(TripExpensesController());

  @override
  void initState() {
    super.initState();
    controller.fetchTripExpenses(widget.tripId);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return '₹0';
    return NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "Trip Expenses",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final data = controller.tripExpenses.value;
        if (data == null) {
          return const Center(child: Text("No data available"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTripSummaryCard(data.tripInfo),
              const SizedBox(height: 20),

              _buildTotalExpenseCard(data.totalExpenses),
              const SizedBox(height: 20),

              if (data.expenseBreakdown != null &&
                  data.expenseBreakdown!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Breakdown",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBreakdownList(data.expenseBreakdown!),
                    const SizedBox(height: 24),
                  ],
                ),

              Text(
                "Expenses History",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildExpensesList(data.expenses),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTripSummaryCard(TripInfo? info) {
    if (info == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                "Trip Info",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (info.status?.toLowerCase() == 'completed')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  info.status ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (info.status?.toLowerCase() == 'completed')
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            info.vehicle ?? 'No Vehicle',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Code: ${info.tripCode ?? 'N/A'}",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                Icons.calendar_today_outlined,
                "Start",
                _formatDate(info.startDate),
              ),
              const Spacer(),
              _buildInfoItem(
                Icons.calendar_month_outlined,
                "End",
                _formatDate(info.endDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(
                Icons.route_outlined,
                "Distance",
                "${info.distanceKm ?? 0} km",
              ),
              const Spacer(),
              _buildInfoItem(
                Icons.speed_outlined,
                "Efficiency",
                "₹${info.efficiencyPerKm?.toStringAsFixed(2) ?? '0'}/km",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalExpenseCard(double? total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Expenses",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(total),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownList(List<ExpenseBreakdown> breakdown) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: breakdown.map((item) {
        return Container(
          width: (Get.width - 44) / 2, // 2 items per row approx
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.purpose ?? 'Other',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(item.total),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpensesList(List<Expense>? expenses) {
    if (expenses == null || expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No expenses recorded",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long, color: Colors.blueGrey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.purpose ?? 'Expense',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      Text(
                        expense.description!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      _formatDate(expense.expenseDate),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(expense.amount),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),
                  if (expense.hasReceipt == true)
                    const Icon(Icons.attachment, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/earning_stat_card_widget.dart';
import '../widgets/transaction_item_widget.dart';
import '../../../controllers/Professional/earning_summary_controller.dart';
import '../../../utils/format_utils.dart';

class EarningSummaryScreen extends StatelessWidget {
  const EarningSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EarningSummaryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderWidget(
              title: 'Earning Summary',
              showMenu: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchEarningsData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: EarningStatCardWidget(
                                icon: Icons.account_balance_wallet,
                                value: FormatUtils.formatAmount(
                                  controller.totalIncome.value,
                                ),
                                label: 'Total income earned',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: EarningStatCardWidget(
                                icon: Icons.local_shipping,
                                value: controller.tripsCompleted.value
                                    .toString(),
                                label: 'Trips Completed',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: EarningStatCardWidget(
                                icon: Icons.trending_up,
                                value: FormatUtils.formatAmount(
                                  controller.avgEarningPerTrip.value,
                                ),
                                label: 'Avg. Earning / Trip',
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Earnings Over Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Earnings Over Time',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
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
                        const SizedBox(height: 16),
                        // Chart Placeholder or Simple Custom View
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: controller.earningsChart.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.show_chart,
                                        size: 48,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No data available',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: controller.earningsChart.map((e) {
                                    final maxAmount = controller.earningsChart
                                        .map(
                                          (item) => (item['amount'] as num)
                                              .toDouble(),
                                        )
                                        .reduce((a, b) => a > b ? a : b);
                                    final heightFactor = maxAmount > 0
                                        ? (e['amount'] as num).toDouble() /
                                              maxAmount
                                        : 0.0;

                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 140 * heightFactor,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF2F80ED),
                                                Color(0xFF56CCF2),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          e['month'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: 32),
                        // Transaction History Header
                        Text(
                          'Transaction History',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Transaction List
                        if (controller.transactions.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'No transactions found',
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.transactions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final transaction =
                                  controller.transactions[index];
                              return TransactionItemWidget(
                                date: FormatUtils.formatDate(
                                  transaction['date'],
                                  format: 'dd MMM yyyy',
                                ),
                                companyName:
                                    '${transaction['tripCode'] ?? ''} - ${transaction['vehicleNumber'] ?? ''}',
                                amount: FormatUtils.formatAmount(
                                  transaction['amount'],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

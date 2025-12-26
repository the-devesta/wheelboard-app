import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/controllers/transaction_summary_controller.dart';
import 'package:wheelboard/models/trip_expense_detail_model.dart';
import 'dart:math' as math;
import '../../CompanyTransport/add_expense_screen.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_logger.dart';

class TransactionSummaryScreen extends StatelessWidget {
  TransactionSummaryScreen({super.key});
  TransactionSummaryController controller = Get.put(
    TransactionSummaryController(),
  );
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Transactions',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF36969),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.more_vert, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search and Filter Row
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Search TextField
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: TextField(
                                controller: controller.searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search transactions...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFFADAEBC),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Color(0xFFADAEBC),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Filter Button
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.filter_list,
                                  size: 18,
                                  color: Color(0xFF2F80ED),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Filter',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2F80ED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Recent Transactions Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Recent Transactions',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF535353),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Transaction Items
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: Column(
                    //     children: [
                    //       _buildTransactionItem(
                    //         date: '06.05.2025',
                    //         tripId: 'TRIP-1029',
                    //         category: 'Vehicle Repair',
                    //         description: 'Brake Service',
                    //         amount: '₹1,500',
                    //       ),
                    //       const SizedBox(height: 10),
                    //       _buildTransactionItem(
                    //         date: '04.05.2025',
                    //         tripId: 'TRIP-1025',
                    //         category: 'Fuel',
                    //         description: 'Diesel',
                    //         amount: '₹2,300',
                    //       ),
                    //       const SizedBox(height: 10),
                    //       _buildTransactionItem(
                    //         date: '03.05.2025',
                    //         tripId: 'TRIP-1019',
                    //         category: 'Food',
                    //         description: 'Lunch Stop',
                    //         amount: '₹450',
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.filteredExpenses.isEmpty) {
                        return const Center(
                          child: Text('No transactions found'),
                        );
                      }

                      return Column(
                        children: controller.filteredExpenses.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            child: _buildTransactionItem(
                              date: HttpHelper.formatDate(
                                e.dateEntered,
                                format: 'dd.MM.yy',
                              ),
                              tripId: 'TRIP',
                              category: e.expenseType,
                              description: e.expenseType,
                              amount: '₹${e.amount}',
                            ),
                          );
                        }).toList(),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Distribution of Expenses Chart
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Distribution Of Expenses',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Pie Chart with Legend
                          Obx(() {
                            return Row(
                              children: [
                                // Pie Chart
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 180,
                                    child: CustomPaint(
                                      painter: PieChartPainter(
                                        data: controller.pieData,
                                      ),

                                      child: Center(
                                        child: Text(
                                          HttpHelper.formatAmount(
                                            controller.totalExpenses.value,
                                          ),
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF3D5A73),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Legend
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildLegendItem(
                                        const Color(0xFF2D9CDB),
                                        'Advance',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLegendItem(
                                        const Color(0xFF27AE60),
                                        'Fuel',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLegendItem(
                                        const Color(0xFFF2994A),
                                        'Challan',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLegendItem(
                                        const Color(0xFFEB5757),
                                        'Food',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLegendItem(
                                        const Color(0xFF9B51E0),
                                        'Salary',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLegendItem(
                                        const Color(0xFFF2C94C),
                                        'Enroute',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 20),

                          // Bottom Category Legend
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //   children: [
                          //     _buildCategoryDot(
                          //       const Color(0xFF2D9CDB),
                          //       'Fuel',
                          //     ),
                          //     _buildCategoryDot(
                          //       const Color(0xFF27AE60),
                          //       'Food',
                          //     ),
                          //     _buildCategoryDot(
                          //       const Color(0xFFF2994A),
                          //       'Enroute',
                          //     ),
                          //     _buildCategoryDot(
                          //       const Color(0xFFEB5757),
                          //       'Misc',
                          //     ),
                          //   ],
                          // ),

                          // const SizedBox(height: 16),

                          // Top 3 Section
                          Container(
                            padding: const EdgeInsets.only(top: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Top 3: ',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Expanded(
                                  child: Obx(() {
                                    if (controller.pieData.isEmpty)
                                      return const SizedBox();

                                    // Sort by amount descending and take top 3
                                    final top3 =
                                        controller.pieData
                                            .toList() // convert RxList to regular list
                                          ..sort(
                                            (a, b) =>
                                                b.amount.compareTo(a.amount),
                                          );

                                    final display = top3
                                        .take(3)
                                        .map(
                                          (e) =>
                                              '${e.expenseType} (₹${e.amount.toInt()})',
                                        )
                                        .join(', ');

                                    return Text(
                                      display,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),

            // New Expense Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // 🔧 FIX: Dynamically determine user type instead of hardcoding
                      // Check if user is Professional/Driver or Transport Company
                      final userType = Get.find<AuthService>().userType;
                      final isProfessional =
                          userType == 'Professional' || userType == 'Driver';

                      AppLogger.d("🔍 Opening Add Expense Screen");
                      AppLogger.d("🔍 User Type: $userType");
                      AppLogger.d("🔍 isProfessional: $isProfessional");

                      Get.to(
                        () => AddExpenseScreen(isProfessional: isProfessional),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5E5E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'NEW EXPENSE',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String date,
    required String tripId,
    required String category,
    required String description,
    required String amount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Date Column
          Container(
            width: 85,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              border: Border(right: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2F80ED),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tripId,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          // Details Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Amount Column
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Paid',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF27AE60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

// Custom Pie Chart Painter (No external URL needed)
// class PieChartPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = math.min(size.width, size.height) / 2 - 10;
//     final innerRadius = radius * 0.55;

//     // Pie chart segments with colors and percentages
//     final segments = [
//       {'color': const Color(0xFF2D9CDB), 'percent': 0.25}, // Advance - Blue
//       {'color': const Color(0xFF27AE60), 'percent': 0.20}, // Fuel - Green
//       {'color': const Color(0xFFF2994A), 'percent': 0.15}, // Challan - Orange
//       {'color': const Color(0xFFEB5757), 'percent': 0.15}, // Food - Red
//       {'color': const Color(0xFF9B51E0), 'percent': 0.15}, // Salary - Purple
//       {'color': const Color(0xFFF2C94C), 'percent': 0.10}, // Enroute - Yellow
//     ];

//     double startAngle = -math.pi / 2; // Start from top

//     for (var segment in segments) {
//       final sweepAngle = 2 * math.pi * (segment['percent'] as double);
//       final paint = Paint()
//         ..color = segment['color'] as Color
//         ..style = PaintingStyle.fill;

//       // Draw arc
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         startAngle,
//         sweepAngle,
//         true,
//         paint,
//       );

//       startAngle += sweepAngle;
//     }

//     // Draw inner circle (donut hole)
//     final innerPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(center, innerRadius, innerPaint);

//     // Draw thin white borders between segments
//     startAngle = -math.pi / 2;
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;

//     for (var segment in segments) {
//       final sweepAngle = 2 * math.pi * (segment['percent'] as double);
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         startAngle,
//         sweepAngle,
//         true,
//         borderPaint,
//       );
//       startAngle += sweepAngle;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class PieChartPainter extends CustomPainter {
  final List<ExpenseDistribution> data;

  PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final innerRadius = radius * 0.55;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];

      final sweepAngle = 2 * math.pi * (item.percentage / 100);

      final paint = Paint()
        ..color = _getColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Donut hole
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  /// Auto color assign
  Color _getColor(int index) {
    const colors = [
      Color(0xFF2D9CDB), // Blue
      Color(0xFF27AE60), // Green
      Color(0xFFF2994A), // Orange
      Color(0xFFEB5757), // Red
      Color(0xFF9B51E0), // Purple
      Color(0xFFF2C94C), // Yellow
    ];

    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

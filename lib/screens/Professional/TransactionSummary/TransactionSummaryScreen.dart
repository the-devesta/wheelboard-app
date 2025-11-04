import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionSummaryScreen extends StatelessWidget {
  const TransactionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Asset URLs from Figma
    const String pieChartUrl = 'https://www.figma.com/api/mcp/asset/9b3ff472-8368-4222-a0e6-264d3ce5a591';

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
                        'Transactions',
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.more_vert, size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Search and Filter
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFF9FAFB),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, size: 16, color: Color(0xFFADAEBC)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Search transactions...',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFADAEBC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.filter_list, size: 14, color: Color(0xFF2F80ED)),
                                const SizedBox(width: 4),
                                Text(
                                  'Filter',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: const Color(0xFFF9FAFB),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF535353),
                              letterSpacing: -0.97,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTransactionItem(
                            date: '06.05.2025',
                            tripId: 'TRIP-1029',
                            category: 'Vehicle Repair',
                            description: 'Brake Service',
                            amount: '₹1,500',
                            isHighlighted: true,
                          ),
                          const SizedBox(height: 8),
                          _buildTransactionItem(
                            date: '04.05.2025',
                            tripId: 'TRIP-1025',
                            category: 'Fuel',
                            description: 'Diesel',
                            amount: '₹2,300',
                            isHighlighted: false,
                          ),
                          const SizedBox(height: 8),
                          _buildTransactionItem(
                            date: '03.05.2025',
                            tripId: 'TRIP-1019',
                            category: 'Food',
                            description: 'Lunch Stop',
                            amount: '₹450',
                            isHighlighted: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Distribution of Expenses Chart
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Distribution Of Expenses',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                              letterSpacing: -0.95,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              // Pie Chart
                              Expanded(
                                child: SizedBox(
                                  height: 226,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.network(
                                        pieChartUrl,
                                        width: 218,
                                        height: 218,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 218,
                                            height: 218,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[200],
                                            ),
                                            child: const Center(
                                              child: Icon(Icons.pie_chart, size: 64),
                                            ),
                                          );
                                        },
                                      ),
                                      Text(
                                        '12340',
                                        style: GoogleFonts.inter(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Legend
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLegendItem(const Color(0xFF2D9CDB), 'Advance'),
                                    const SizedBox(height: 8),
                                    _buildLegendItem(const Color(0xFF27AE60), 'Fuel'),
                                    const SizedBox(height: 8),
                                    _buildLegendItem(const Color(0xFFF2994A), 'Challan'),
                                    const SizedBox(height: 8),
                                    _buildLegendItem(const Color(0xFFEB5757), 'Food'),
                                    const SizedBox(height: 8),
                                    _buildLegendItem(const Color(0xFF9B51E0), 'Salary'),
                                    const SizedBox(height: 8),
                                    _buildLegendItem(const Color(0xFFF2C94C), 'Enroute'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Category Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCategoryDot(const Color(0xFF2D9CDB), 'Fuel'),
                              const SizedBox(width: 16),
                              _buildCategoryDot(const Color(0xFF27AE60), 'Food'),
                              const SizedBox(width: 16),
                              _buildCategoryDot(const Color(0xFFF2994A), 'Enroute'),
                              const SizedBox(width: 16),
                              _buildCategoryDot(const Color(0xFFEB5757), 'Misc'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Top 3:',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Fuel (₹2,300), Vehicle Repair (₹1,500), Food (₹450)',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // New Expense Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle new expense
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5E5E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'NEW EXPENSE',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 91,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFF5F5F5) : Colors.white,
              border: const Border(
                right: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2F80ED),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tripId,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF858585),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF535353),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF535353),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}


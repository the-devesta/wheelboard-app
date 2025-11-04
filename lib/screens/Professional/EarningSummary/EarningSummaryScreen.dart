import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/earning_stat_card_widget.dart';
import '../widgets/transaction_item_widget.dart';
import '../PaymentVerification/PaymentVerificationScreen.dart';

class EarningSummaryScreen extends StatelessWidget {
  const EarningSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderWidget(title: 'Earning Summary'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // Payment Verification Banner
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentVerificationScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE74C3C), Color(0xFFFF7E5F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '⚠️',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Payment Verifications Required',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Verify',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE74C3C),
                                    ),
                                  ),
                                  Text(
                                    'Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE74C3C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: EarningStatCardWidget(
                            icon: Icons.account_balance_wallet,
                            value: '₹70,000',
                            label: 'Total income earned',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: EarningStatCardWidget(
                            icon: Icons.local_shipping,
                            value: '75',
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
                            value: '₹167',
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
                    const SizedBox(height: 16),
                    // Chart Placeholder
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
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
                              'Chart View',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Transaction History
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction History',
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
                            color: const Color(0xFF2F80ED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.filter_list,
                                size: 12,
                                color: Color(0xFF2F80ED),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Filter',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2F80ED),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Transaction List
                    Column(
                      children: [
                        TransactionItemWidget(
                          date: '2024-01-20',
                          companyName: 'ABC Logistics',
                          amount: '₹500',
                        ),
                        const SizedBox(height: 12),
                        TransactionItemWidget(
                          date: '2024-01-18',
                          companyName: 'XYZ Fleet',
                          amount: '₹320',
                          opacity: 0.9,
                        ),
                        const SizedBox(height: 12),
                        TransactionItemWidget(
                          date: '2024-01-18',
                          companyName: 'XYZ Fleet',
                          amount: '₹320',
                          opacity: 0.9,
                        ),
                        const SizedBox(height: 12),
                        TransactionItemWidget(
                          date: '2024-01-10',
                          companyName: 'QuickMove',
                          amount: '₹900',
                          opacity: 0.9,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Export Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle export
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F80ED),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Export as PDF',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
}


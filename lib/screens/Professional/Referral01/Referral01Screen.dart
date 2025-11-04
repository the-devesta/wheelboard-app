import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../NewReferral/newreferralscreen.dart';

class Referral01Screen extends StatefulWidget {
  const Referral01Screen({super.key});

  @override
  State<Referral01Screen> createState() => _Referral01ScreenState();
}

class _Referral01ScreenState extends State<Referral01Screen> {
  bool _isStatsExpanded = false;

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
                        'Your Referrals',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Referral Points Card
                    _buildReferralPointsCard(),
                    const SizedBox(height: 16),
                    // Recent Referrals
                    _buildRecentReferralsSection(),
                    const SizedBox(height: 16),
                    // Referral Stats
                    _buildReferralStatsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            // New Referral Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewReferralScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5E5E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'NEW REFERRAL',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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

  Widget _buildReferralPointsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Referral Points',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '75',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F80ED),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'PTS',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2F80ED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Earned from 3 accepted referrals',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 16),
          // Info Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100 PTS = ₹100',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                      Text(
                        'voucher',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Only 25 points to next',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                      Text(
                        'reward!',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.75, // 75 out of 100
                    child: Container(
                      height: 13,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF2C94C), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    '100',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9E9E9E),
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

  Widget _buildRecentReferralsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Referrals',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle view all
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F80ED),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF2F80ED),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 115,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildReferralCard(
                name: 'Ajay Verma',
                role: 'Driver',
                date: '22 May 2025',
                status: 'Accepted',
                points: 25,
                statusColor: const Color(0xFF27AE60),
              ),
              const SizedBox(width: 12),
              _buildReferralCard(
                name: 'Sonia Malik',
                role: 'Tyre Fitter',
                date: '20 May 2025',
                status: 'Pending',
                points: 0,
                statusColor: const Color(0xFFF2C94C),
              ),
              const SizedBox(width: 12),
              _buildReferralCard(
                name: 'Rahul Singh',
                role: 'Mechanic',
                date: '18 May 2025',
                status: 'Rejected',
                points: 0,
                statusColor: const Color(0xFFFF5E5E),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCard({
    required String name,
    required String role,
    required String date,
    required String status,
    required int points,
    required Color statusColor,
  }) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      status == 'Accepted'
                          ? Icons.check_circle
                          : status == 'Pending'
                              ? Icons.pending
                              : Icons.cancel,
                      size: 11,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E8E),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB0B0B0),
                ),
              ),
              Text(
                points > 0 ? '+$points PTS' : '+0 PTS',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: points > 0 ? const Color(0xFF27AE60) : const Color(0xFF2F80ED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralStatsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isStatsExpanded = !_isStatsExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart,
                        size: 18,
                        color: Color(0xFF111827),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Referral Stats',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isStatsExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: const Color(0xFF111827),
                  ),
                ],
              ),
            ),
          ),
          if (_isStatsExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow(Icons.send, 'Total Referrals Sent', '7', const Color(0xFF2F80ED)),
                  const SizedBox(height: 16),
                  _buildStatRow(Icons.check_circle, 'Accepted Referrals', '3', const Color(0xFF27AE60)),
                  const SizedBox(height: 16),
                  _buildStatRow(Icons.pending, 'Pending Referrals', '2', const Color(0xFFF2C94C)),
                  const SizedBox(height: 16),
                  _buildStatRow(Icons.stars, 'Total Points Earned', '75', const Color(0xFF2F80ED)),
                  const SizedBox(height: 16),
                  _buildStatRow(Icons.redeem, 'Points Redeemed', '50', const Color(0xFFF2C94C)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      // Handle view full summary
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Full Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2F80ED),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF2F80ED),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF111827)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF111827),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

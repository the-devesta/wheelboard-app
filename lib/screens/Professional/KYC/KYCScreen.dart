import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/kyc_document_card_widget.dart';
import '../widgets/kyc_faq_item_widget.dart';
import '../KycSteps/KycStepsScreen.dart';

class KYCScreen extends StatelessWidget {
  const KYCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderWidget(title: 'KYC'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // KYC Status Card
                    _buildKycStatusCard(context),
                    const SizedBox(height: 24),
                    // Your KYC Documents Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your KYC Documents',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle expand all
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.expand_more,
                                  size: 13,
                                  color: Color(0xFF2F80ED),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Expand all',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2F80ED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Document Cards
                    KycDocumentCardWidget(
                      documentName: 'Aadhar Card',
                      status: 'Pending',
                      icon: Icons.badge,
                      iconBackgroundColor: const Color(0xFFEEF4FF),
                      onUpload: () {
                        // Handle upload
                      },
                    ),
                    const SizedBox(height: 12),
                    KycDocumentCardWidget(
                      documentName: 'PAN Card',
                      status: 'Not Uploaded',
                      icon: Icons.credit_card,
                      iconBackgroundColor: const Color(0xFFFFF3F3),
                      onUpload: () {
                        // Handle upload
                      },
                    ),
                    const SizedBox(height: 12),
                    KycDocumentCardWidget(
                      documentName: 'Driving License',
                      status: 'Verified',
                      icon: Icons.drive_eta,
                      iconBackgroundColor: const Color(0xFFE3F2FD),
                    ),
                    const SizedBox(height: 12),
                    KycDocumentCardWidget(
                      documentName: 'Bank Details',
                      status: 'Pending',
                      icon: Icons.account_balance,
                      iconBackgroundColor: const Color(0xFFF3E5F5),
                      onUpload: () {
                        // Handle upload
                      },
                    ),
                    const SizedBox(height: 12),
                    KycDocumentCardWidget(
                      documentName: 'Profile Photo',
                      status: 'Verified',
                      icon: Icons.person,
                      iconBackgroundColor: const Color(0xFFFFF6E3),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 24),
                    // KYC FAQ
                    Row(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Color(0xFF2F80ED),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KYC FAQ',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2F80ED),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    KycFaqItemWidget(
                      question: 'Why is KYC required?',
                      answer:
                          'KYC helps protect your account and ensures compliance with legal regulations so you can use all platform features securely.',
                    ),
                    const SizedBox(height: 12),
                    KycFaqItemWidget(
                      question: 'What formats are supported?',
                      answer:
                          'Supported formats: PDF, JPG, PNG. Max size: 10MB per document.',
                    ),
                    const SizedBox(height: 12),
                    KycFaqItemWidget(
                      question: 'How long does verification take?',
                      answer:
                          'Most verifications are completed within 12–24 hours. You will be notified once your documents are verified.',
                    ),
                    const SizedBox(height: 24),
                    // Complete KYC Card
                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE3F2FD)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6FAE6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              size: 30,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete your KYC to start earning on this platform',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF222222),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Secure your account and unlock all features.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B6B6B),
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
            // Footer Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KycStepsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Proceed to KYC Steps',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildKycStatusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge and Progress Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'KYC',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    Text(
                      'Incomplete',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.info_outline,
                size: 15,
                color: Color(0xFF1976D2),
              ),
              const SizedBox(width: 4),
              Text(
                '2 of 5 documents uploaded',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Indicator
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: 0.4,
                      strokeWidth: 6,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  Text(
                    '40%',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete your KYC',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'To start earning on the platform',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Continue KYC Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KycStepsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5E5E),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                'Continue KYC',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

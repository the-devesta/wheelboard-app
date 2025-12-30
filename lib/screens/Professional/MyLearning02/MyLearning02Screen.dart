import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/learning_module_card_widget.dart';

class MyLearning02Screen extends StatefulWidget {
  const MyLearning02Screen({super.key});

  @override
  State<MyLearning02Screen> createState() => _MyLearning02ScreenState();
}

class _MyLearning02ScreenState extends State<MyLearning02Screen> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderWidget(title: 'Keep Your Tyre Safe'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Player
                    Container(
                      height: 219,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Placeholder for video
                          const Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          // Play button overlay
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Video Metadata
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF5F5F5)),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildMetadataItem(
                            Icons.play_circle_outline,
                            'Video',
                          ),
                          const SizedBox(width: 12),
                          _buildMetadataItem(Icons.access_time, '2.5 min'),
                          const SizedBox(width: 12),
                          _buildMetadataItem(Icons.calendar_today, 'May 2025'),
                          const SizedBox(width: 12),
                          _buildMetadataItem(Icons.person, 'Admin'),
                        ],
                      ),
                    ),
                    // Content Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Why Tyre Safety Matters
                          Text(
                            'Why Tyre Safety Matters',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tyres are the only point of contact between your vehicle and the road. Keeping them in good condition is crucial for your safety and the safety of others.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1F2937),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Key Tyre Safety Tips
                          Text(
                            'Key Tyre Safety Tips:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBulletPoint('Check tyre pressure weekly'),
                          _buildBulletPoint(
                            'Inspect for visible damage or uneven wear',
                          ),
                          _buildBulletPoint(
                            'Rotate tyres every 8,000-10,000 km',
                          ),
                          _buildBulletPoint(
                            'Replace tyres before tread wears to 1.6mm',
                          ),
                          const SizedBox(height: 24),
                          // Visual Inspection Guide
                          Text(
                            'Visual Inspection Guide',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Look for cuts, bulges, or embedded objects. If you spot any, get professional help immediately.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1F2937),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // When to Replace?
                          Text(
                            'When to Replace?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'If your tyre shows signs of aging, cracking, or you feel reduced grip on wet roads, replace them right away.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1F2937),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mark as Completed
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 19,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFF9FAFB)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mark as Completed',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Related Modules
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Related Modules',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle see all
                            },
                            child: Text(
                              'See all',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Related Modules List
                    SizedBox(
                      height: 161,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: const [
                          LearningModuleCardWidget(
                            title: 'How to Check Tyre Pressure',
                            type: 'Video',
                          ),
                          SizedBox(width: 16),
                          LearningModuleCardWidget(
                            title: 'Safe Braking Techniques',
                            type: 'Article',
                          ),
                          SizedBox(width: 16),
                          LearningModuleCardWidget(
                            title: 'Understanding Tyre Tread Patterns',
                            type: 'Video',
                          ),
                        ],
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

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF374151),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

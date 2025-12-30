import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Subscription3Screen extends StatefulWidget {
  const Subscription3Screen({super.key});

  @override
  State<Subscription3Screen> createState() => _Subscription3ScreenState();
}

class _Subscription3ScreenState extends State<Subscription3Screen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 39),
          child: Column(
            children: [
              const SizedBox(height: 33),
              Text(
                'Subscription Plans',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose the perfect plan for your fleet management needs',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Monthly/Yearly Toggle
              _buildToggle(),
              const SizedBox(height: 40),
              // Starter Plan
              _buildPlanCard(
                title: 'Starter',
                price: '₹2,999',
                period: '/year',
                description: 'Perfect for small fleets getting started',
                features: const [
                  'Up to 10 vehicles',
                  '15 Trips Creation',
                  '20 Job Posts',
                  '20 Hirings',
                  'Unlimited Post creation',
                ],
              ),
              const SizedBox(height: 20),
              // Pro Plan (Recommended)
              _buildPlanCard(
                title: 'Pro',
                price: '₹4,999',
                period: '/year',
                description: 'Ideal for growing businesses with medium fleets',
                features: const [
                  'Up to 50 vehicles',
                  '25 Trips Creation',
                  '50 Job Posts',
                  'Priority support',
                  '30  Hirings',
                  'Unlimited Post Creations',
                ],
                isRecommended: true,
              ),
              const SizedBox(height: 20),
              // Enterprise Plan
              _buildPlanCard(
                title: 'Enterprise',
                price: '₹9,999',
                period: '/year',
                description: 'Complete solution for large enterprises',
                features: const [
                  'Unlimited vehicles',
                  'Unlimited Job Posting',
                  'Unlimited Hiring',
                  '24/7 dedicated support',
                  'Unlimited Feed Posting',
                  'Unlimited  Trips Creation',
                ],
              ),
              const SizedBox(height: 20),
              // FAQ Section
              _buildFAQSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: _isYearly ? 116 : 0,
            child: Container(
              height: 47,
              width: 94,
              decoration: BoxDecoration(
                color: const Color(0xFF407BFF),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isYearly = false),
                  child: Center(
                    child: Text(
                      'Monthly',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isYearly
                            ? const Color(0xFF6B7280)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isYearly = true),
                  child: Center(
                    child: Text(
                      'Yearly',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isYearly
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    bool isRecommended = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isRecommended
                  ? const Color(0xFF407BFF)
                  : const Color(0xFFE5E7EB),
              width: isRecommended ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRecommended) const SizedBox(height: 13),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      period,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              ...features.map((feature) => _buildFeatureItem(feature)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4F4F),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Subscribe Now',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF407BFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isRecommended)
          Positioned(
            top: -13,
            left: 166,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF407BFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Recommended',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Get answers to common questions about our subscription plans',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildFAQItem(
            question: 'Can I change my plan anytime?',
            answer:
                'Yes, you can upgrade or downgrade your plan at any time. Changes will be reflected in your next billing cycle.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'Is there a free trial available?',
            answer:
                'We offer a 14-day free trial for all plans. No credit card required to get started.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'What payment methods do you accept?',
            answer:
                'We accept all major credit cards, UPI, net banking, and digital wallets for your convenience.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'Do you offer discounts for yearly plans?',
            answer:
                'Yes, yearly subscriptions come with a 20% discount compared to monthly billing.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'Can I cancel my subscription?',
            answer:
                'You can cancel your subscription at any time. Your access will continue until the end of your current billing period.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'Is customer support included?',
            answer:
                'All plans include customer support. Pro and Enterprise plans get priority and dedicated support respectively.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

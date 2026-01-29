import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    if (_isActivated) {
      setState(() => _isActivated = false);
      _controller.duration = const Duration(seconds: 2);
      _controller.repeat();
      return;
    }

    setState(() => _isActivated = true);
    _controller.duration = const Duration(milliseconds: 500); // Faster pulse
    _controller.repeat();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🚨 EMERGENCY SOS ACTIVATED! Banners and Alerts sent to all contacts.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch $launchUri');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          'Emergency SOS',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF222B45),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick access to emergency services",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF8F9BB3),
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Alert Section
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Determine card color: blinking if activated, static light red if not
                Color cardColor = const Color(0xFFFFF5F5);
                if (_isActivated) {
                  cardColor = _controller.value > 0.5
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFFFCDD2);
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: _isActivated
                        ? Border.all(color: Colors.red, width: 3)
                        : null,
                    boxShadow: _isActivated
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isActivated ? 'SOS ACTIVATED' : 'Emergency Alert',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _isActivated
                              ? Colors.red
                              : const Color(0xFF222B45),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Animated SOS Button
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: GestureDetector(
                          onTap: _triggerSOS,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ripple Effect 1
                              Container(
                                width: 140 + (_controller.value * 40),
                                height: 140 + (_controller.value * 40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFE53935,
                                  ).withOpacity(0.3 * (1 - _controller.value)),
                                ),
                              ),
                              // Ripple Effect 2 (Delayed)
                              Builder(
                                builder: (context) {
                                  double value =
                                      (_controller.value + 0.5) % 1.0;
                                  return Container(
                                    width: 140 + (value * 40),
                                    height: 140 + (value * 40),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFFE53935,
                                      ).withOpacity(0.3 * (1 - value)),
                                    ),
                                  );
                                },
                              ),
                              // Main Button
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFE53935,
                                      ).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isActivated
                                          ? Icons.notifications_active
                                          : Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'SOS',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      Text(
                        _isActivated
                            ? 'Calling Emergency Services...'
                            : 'Tap to activate emergency alert',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isActivated
                              ? Colors.red
                              : const Color(0xFF222B45),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will notify your company and emergency contacts',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF8F9BB3),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            Text(
              'Emergency Contacts',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF222B45),
              ),
            ),
            const SizedBox(height: 16),

            // Contacts List
            _buildContactCard(
              title: 'Police',
              number: '100',
              icon: Icons.local_police_outlined,
              color: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF1565C0),
              onTap: () => _makePhoneCall('100'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: 'Ambulance',
              number: '108',
              icon: Icons.medical_services_outlined,
              color: const Color(0xFFFFEBEE),
              iconColor: const Color(0xFFC62828),
              onTap: () => _makePhoneCall('108'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: 'Fire',
              number: '101',
              icon: Icons.local_fire_department_outlined,
              color: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFEF6C00),
              onTap: () => _makePhoneCall('101'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: 'Roadside Assistance',
              number: '1033',
              icon: Icons.car_crash_outlined,
              color: const Color(0xFFE0F2F1),
              iconColor: const Color(0xFF00695C),
              onTap: () => _makePhoneCall('1033'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: 'Roadside Assistance (Toll-Free)',
              number: '1800-123-4567',
              icon: Icons.car_repair_outlined,
              color: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF2E7D32),
              onTap: () => _makePhoneCall('1800-123-4567'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: 'Company Emergency',
              number: '+91 98765 43210',
              icon: Icons.business_outlined,
              color: const Color(0xFFF3E5F5),
              iconColor: const Color(0xFF6A1B9A),
              onTap: () => _makePhoneCall('+919876543210'),
            ),

            const SizedBox(height: 32),
            // Safety Tips Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security, color: Color(0xFF1565C0)),
                      const SizedBox(width: 12),
                      Text(
                        'Safety Tips',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSafetyTip('Always keep emergency contacts handy'),
                  _buildSafetyTip('Share your live location during trips'),
                  _buildSafetyTip('Keep first aid kit in your vehicle'),
                  _buildSafetyTip('Regular vehicle maintenance checks'),
                  _buildSafetyTip('Stay alert and take regular breaks'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF8F9BB3),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.call_outlined, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1565C0),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

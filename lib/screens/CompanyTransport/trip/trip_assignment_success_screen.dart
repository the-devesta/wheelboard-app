import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../main_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ── Design Tokens ──────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textMid = Color(0xFF374151);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _indigo = Color(0xFF6366F1);
const _blue = Color(0xFF3B82F6);

class TripAssignmentSuccessScreen extends StatefulWidget {
  final String tripId; // The trip row ID
  final String driverName;
  final String? driverAvatar;
  final double driverRating;
  final int driverTrips;
  final bool driverIsVerified;

  final String paymentId;
  final double paymentAmount;
  final String paymentOption; // 'platform' or 'total'

  final String? otp; // The LR Start Trip OTP

  final String from;
  final String to;
  final String? departureDate;
  final String? departureTime;
  final String? distance;
  final String? vehicleName;

  const TripAssignmentSuccessScreen({
    super.key,
    required this.tripId,
    required this.driverName,
    this.driverAvatar,
    required this.driverRating,
    required this.driverTrips,
    required this.driverIsVerified,
    required this.paymentId,
    required this.paymentAmount,
    required this.paymentOption,
    this.otp,
    required this.from,
    required this.to,
    this.departureDate,
    this.departureTime,
    this.distance,
    this.vehicleName,
  });

  @override
  State<TripAssignmentSuccessScreen> createState() =>
      _TripAssignmentSuccessScreenState();
}

class _TripAssignmentSuccessScreenState
    extends State<TripAssignmentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _copiedOtp = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start, double end) {
    return CurvedAnimation(
        parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut));
  }

  Animation<Offset> _slide(double start, double end) {
    return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut)));
  }

  Animation<double> _scale(double start, double end) {
    return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.elasticOut));
  }

  Future<void> _copyOtp() async {
    if (widget.otp == null) return;
    await Clipboard.setData(ClipboardData(text: widget.otp!));
    if (!mounted) return;
    setState(() {
      _copiedOtp = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedOtp = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              // Header animation
              _buildHeader(),
              const SizedBox(height: 30),

              // Transaction Details
              _buildTransactionCard(),
              const SizedBox(height: 20),

              // OTP Section
              _buildOtpSection(),
              const SizedBox(height: 20),

              // Trip Details
              _buildTripDetailsCard(),
              const SizedBox(height: 20),

              // Driver Card
              _buildDriverCard(),
              const SizedBox(height: 30),

              // Actions
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ScaleTransition(
          scale: _scale(0.0, 0.4),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check_circle, color: _green, size: 50),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: _fade(0.2, 0.6),
          child: SlideTransition(
            position: _slide(0.2, 0.6),
            child: Text(
              'Trip Assigned Successfully!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: _fade(0.3, 0.7),
          child: SlideTransition(
            position: _slide(0.3, 0.7),
            child: Text(
              'Your payment has been processed and driver has been assigned',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _textGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard() {
    return FadeTransition(
      opacity: _fade(0.4, 0.8),
      child: SlideTransition(
        position: _slide(0.4, 0.8),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _green.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  border: const Border(bottom: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 18, color: _green),
                    const SizedBox(width: 8),
                    Text(
                      'Transaction Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildRow('Payment ID', widget.paymentId),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: _border, height: 1),
                    ),
                    _buildRow(
                        'Amount Paid', '₹${widget.paymentAmount.toStringAsFixed(2)}',
                        isBold: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: _border, height: 1),
                    ),
                    _buildRow('Payment Type',
                        widget.paymentOption == 'platform' ? 'Advance (Platform Fee)' : 'Full Amount'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: _border, height: 1),
                    ),
                    _buildRow('Status', 'Successful', color: _green),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpSection() {
    return FadeTransition(
      opacity: _fade(0.5, 0.9),
      child: SlideTransition(
        position: _slide(0.5, 0.9),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _indigo.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _indigo.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  border: const Border(bottom: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key, size: 18, color: _indigo),
                    const SizedBox(width: 8),
                    Text(
                      'Start Trip OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: widget.otp == null || widget.otp!.isEmpty
                    ? Column(
                        children: [
                          Icon(Icons.notifications_active,
                              size: 40, color: _indigo.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'Open Notifications or Trip Details to get the Start Trip OTP code.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _textGrey,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            'Share this with the driver when they arrive for pickup',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _textGrey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _indigo.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _indigo.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: widget.otp!.split('').map((digit) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: 32,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: _indigo.withValues(
                                                alpha: 0.3)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _indigo.withValues(
                                                alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        digit,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: _indigo,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _copyOtp,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _indigo.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _copiedOtp ? Icons.check : Icons.copy,
                                    color: _copiedOtp ? _green : _indigo,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetailsCard() {
    return FadeTransition(
      opacity: _fade(0.6, 1.0),
      child: SlideTransition(
        position: _slide(0.6, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  border: const Border(bottom: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, size: 18, color: _primary),
                    const SizedBox(width: 8),
                    Text(
                      'Trip Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: _green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _green.withValues(alpha: 0.3),
                                        width: 3))),
                            Container(width: 2, height: 30, color: _border),
                            Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: _primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _primary.withValues(alpha: 0.3),
                                        width: 3))),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.from.isNotEmpty ? widget.from : 'Pickup Location',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 24),
                              Text(widget.to.isNotEmpty ? widget.to : 'Drop Location',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: _border, height: 1),
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        if (widget.departureDate != null &&
                            widget.departureDate!.isNotEmpty)
                          _buildInfoChip(Iconsax.calendar_1, widget.departureDate!),
                        if (widget.departureTime != null &&
                            widget.departureTime!.isNotEmpty)
                          _buildInfoChip(Iconsax.clock, widget.departureTime!),
                        if (widget.distance != null && widget.distance!.isNotEmpty)
                          _buildInfoChip(Icons.route, '${widget.distance} km'),
                        if (widget.vehicleName != null &&
                            widget.vehicleName!.isNotEmpty)
                          _buildInfoChip(Iconsax.truck, widget.vehicleName!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    return FadeTransition(
      opacity: _fade(0.7, 1.0),
      child: SlideTransition(
        position: _slide(0.7, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _blue.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  border: const Border(bottom: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: _blue),
                    const SizedBox(width: 8),
                    Text(
                      'Assigned Professional',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: _bg,
                          backgroundImage: widget.driverAvatar != null &&
                                  widget.driverAvatar!.isNotEmpty
                              ? CachedNetworkImageProvider(widget.driverAvatar!)
                              : null,
                          child: widget.driverAvatar == null ||
                                  widget.driverAvatar!.isEmpty
                              ? const Icon(Icons.person,
                                  color: _textGrey, size: 24)
                              : null,
                        ),
                        if (widget.driverIsVerified)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: _card,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: _blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    size: 10, color: Colors.white),
                              ),
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
                            widget.driverName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                widget.driverRating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: _textGrey, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.driverTrips} Trips',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return FadeTransition(
      opacity: _fade(0.8, 1.0),
      child: SlideTransition(
        position: _slide(0.8, 1.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAll(() => CompanyTransportMainWrapper(initialIndex: 2));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _bg,
                      foregroundColor: _textDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _border),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back to Trips',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Note: Because we use Get.offAll previously, here we just 
                      // navigate to the trips list, or you can implement a direct navigation
                      // to trip details if you have the full AssignedTrip object.
                      // For now, back to trips is the safest fallback.
                      Get.offAll(() => CompanyTransportMainWrapper(initialIndex: 2));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View Trip',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: _blue),
                  const SizedBox(width: 8),
                  Text(
                    'The driver will be notified and will contact you shortly',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _textMid,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color color = _textDark}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: _textGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _textGrey),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: _textMid,
          ),
        ),
      ],
    );
  }
}

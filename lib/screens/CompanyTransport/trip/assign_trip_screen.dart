import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../controllers/Transport/assign_trip_controller.dart';
import '../../../controllers/Transport/dashboard_controller.dart';
import '../../../controllers/Transport/user_profile_controller.dart';
import '../../../models/trip_bid_model.dart';
import '../../../services/razorpay_service.dart';
import '../../../services/trip_payment_service.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_loader.dart';
import '../../../utils/app_logger.dart';
import 'trip_assignment_success_screen.dart';

// ── Design tokens (match Home & Fleet) ────────────────────────────────────────
const _primary   = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg        = Color(0xFFF9FAFB);
const _card      = Colors.white;
const _textDark  = Color(0xFF111827);
const _textMid   = Color(0xFF374151);
const _textGrey  = Color(0xFF6B7280);
const _border    = Color(0xFFE5E7EB);
const _green     = Color(0xFF22C55E);

const double _platformFeeRate = 0.07; // 7% — matches web PLATFORM_FEE_RATE

enum _PayOption { platform, total }

class AssignTripScreen extends StatefulWidget {
  final String tripId;
  final String? bidId;
  const AssignTripScreen({super.key, required this.tripId, this.bidId});

  @override
  State<AssignTripScreen> createState() => _AssignTripScreenState();
}

class _AssignTripScreenState extends State<AssignTripScreen> {
  late final AssignTripController _controller;
  late final RazorpayService _razorpay;
  final _paymentService = TripPaymentService();

  _PayOption _option = _PayOption.total;
  bool _processing = false;

  // pending payment context (for the verify step)
  TripBid? _payingBid;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AssignTripController(), tag: widget.tripId);
    _razorpay = RazorpayService(
      onPaymentSuccess: _onPaymentSuccess,
      onPaymentError: _onPaymentError,
      onExternalWallet: _onExternalWallet,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchAssignTrip(widget.tripId);
    });
  }

  @override
  void dispose() {
    _razorpay.dispose();
    if (Get.isRegistered<AssignTripController>(tag: widget.tripId)) {
      Get.delete<AssignTripController>(tag: widget.tripId);
    }
    super.dispose();
  }

  // ── derived amounts (web parity) ──────────────────────────────────────────
  double _platformFee(TripBid b) => b.bidAmount * _platformFeeRate;
  double _total(TripBid b) => b.bidAmount + _platformFee(b);
  double _payable(TripBid b) =>
      _option == _PayOption.platform ? _platformFee(b) : _total(b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _primary, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text('Assignment & Payment',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w600, color: _textDark)),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const CustomLoader(message: 'Loading assignment…');
        }
        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.bids.isEmpty) {
          return _errorState(_controller.errorMessage.value);
        }
        final bid = _controller.getBidById(widget.bidId);
        if (bid == null) return _emptyState();
        return _content(bid);
      }),
    );
  }

  // ── main content ──────────────────────────────────────────────────────────
  Widget _content(TripBid bid) {
    return Stack(children: [
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _tripOverviewCard(),
          const SizedBox(height: 14),
          _professionalCard(bid),
          const SizedBox(height: 14),
          _paymentOptionCard(bid),
          const SizedBox(height: 14),
          _paymentSummaryCard(bid),
          const SizedBox(height: 20),
          _payButton(bid),
        ]),
      ),
      if (_processing)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const CustomLoader(message: 'Processing payment…'),
          ),
        ),
    ]);
  }

  // ── trip overview ───────────────────────────────────────────────────────
  Widget _tripOverviewCard() {
    return _sectionCard(
      title: 'Trip Overview',
      child: Column(children: [
        _routeRow(Iconsax.location, 'Pickup', _controller.from.value, _green),
        const SizedBox(height: 12),
        _routeRow(Iconsax.location_tick, 'Destination', _controller.to.value, _primary),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _miniInfo(Iconsax.calendar_1, 'Date', _dateStr())),
          const SizedBox(width: 12),
          Expanded(child: _miniInfo(Iconsax.clock, 'Time',
              _controller.pickupTime.value.isNotEmpty
                  ? _controller.pickupTime.value : 'TBD')),
        ]),
        if (_controller.vehicleName.value.isNotEmpty) ...[
          const SizedBox(height: 12),
          _miniInfo(Iconsax.truck, 'Vehicle', _controller.vehicleName.value),
        ],
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_primary, Color(0xFFE85555)]),
            borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text('Trip ID', style: GoogleFonts.poppins(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
            Text(_controller.tripCode.value.toUpperCase(),
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
      ]),
    );
  }

  // ── professional card ──────────────────────────────────────────────────
  Widget _professionalCard(TripBid bid) {
    return _sectionCard(
      title: 'Assigned Professional',
      child: Row(children: [
        Stack(children: [
          ClipOval(
            child: SizedBox(
              width: 60, height: 60,
              child: bid.avatar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: bid.avatar, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _avatarFallback(bid.name))
                  : _avatarFallback(bid.name),
            ),
          ),
          if (bid.isVerified)
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: _green, shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                child: const Icon(Icons.check, size: 10, color: Colors.white))),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bid.name, style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
          if (bid.phoneNumber.isNotEmpty && bid.phoneNumber != 'Not available')
            Text(bid.phoneNumber, style: GoogleFonts.poppins(
                fontSize: 12, color: _textGrey)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
            const SizedBox(width: 3),
            Text(bid.rating.toStringAsFixed(1), style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textMid)),
            const SizedBox(width: 10),
            Text('${bid.totalTrips} trips', style: GoogleFonts.poppins(
                fontSize: 12, color: _textGrey)),
            const SizedBox(width: 10),
            Flexible(child: Text(bid.experience, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: _textGrey))),
          ]),
        ])),
      ]),
    );
  }

  // ── payment option selector ─────────────────────────────────────────────
  Widget _paymentOptionCard(TripBid bid) {
    final fee = _platformFee(bid);
    final total = _total(bid);
    return _sectionCard(
      title: 'Select Payment Option',
      child: Column(children: [
        _optionTile(
          selected: _option == _PayOption.platform,
          onTap: () => setState(() => _option = _PayOption.platform),
          label: 'Platform Fee Only',
          sub: '${(_platformFeeRate * 100).round()}% platform fee',
          amount: fee,
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 10),
        _optionTile(
          selected: _option == _PayOption.total,
          onTap: () => setState(() => _option = _PayOption.total),
          label: 'Total Amount',
          sub: 'All fees included',
          amount: total,
          color: _green,
          recommended: true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE))),
          child: Row(children: [
            const Icon(Iconsax.shield_tick, size: 18, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Secure payment powered by Razorpay. All major methods supported.',
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF1D4ED8)))),
          ]),
        ),
      ]),
    );
  }

  // ── payment summary ──────────────────────────────────────────────────────
  Widget _paymentSummaryCard(TripBid bid) {
    final fee = _platformFee(bid);
    final total = _total(bid);
    final payable = _payable(bid);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primary, Color(0xFFE85555)]),
        borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Payment Summary', style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 14),
        _summaryRow('Bid Amount', bid.bidAmount),
        const SizedBox(height: 8),
        _summaryRow('Platform Fee (${(_platformFeeRate * 100).round()}%)', fee),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Colors.white.withValues(alpha: 0.25), height: 1)),
        _summaryRow('Total', total, bold: true),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("You're paying", style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
            Text('₹${payable.toStringAsFixed(2)}', style: GoogleFonts.poppins(
                fontSize: 26, fontWeight: FontWeight.w800, color: _primary)),
            Text(_option == _PayOption.platform ? 'Platform Fee' : 'Total Amount',
                style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
          ]),
        ),
      ]),
    );
  }

  Widget _payButton(TripBid bid) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _processing ? null : () => _startPayment(bid),
        icon: _processing
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Iconsax.wallet_check, size: 20),
        label: Text(_processing ? 'Processing…' : 'Pay Now & Confirm',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0),
      ),
    );
  }

  // ── payment flow ──────────────────────────────────────────────────────────
  Future<void> _startPayment(TripBid bid) async {
    if (_processing) return;
    setState(() => _processing = true);

    final option = _option == _PayOption.platform ? 'platform' : 'total';
    final amount = _payable(bid);

    try {
      AppLogger.d('[Assign] initiate trip=${widget.tripId} bid=${bid.bidId} '
          'option=$option amount=$amount');

      final init = await _paymentService.initiatePayment(
        tripId: widget.tripId,
        bidId: bid.bidId,
        paymentOption: option,
        amount: amount,
      );

      _payingBid = bid;
      _pendingOrderId = init.orderId;

      // prefill from current user profile if available
      String email = 'hello@wheelboard.in';
      String contact = '7420861942';
      if (Get.isRegistered<UserProfileController>()) {
        final p = Get.find<UserProfileController>().userProfile.value;
        if (p != null) {
          email = p.email ?? email;
          contact = p.mobileNo ?? contact;
        }
      }

      await _razorpay.openCheckout(
        amountInPaise: init.amountInPaise,
        orderId: init.orderId,
        keyOverride: init.razorpayKey.isNotEmpty ? init.razorpayKey : null,
        currency: init.currency,
        description: 'Trip ${_controller.tripCode.value} • ${bid.name}',
        prefillEmail: email,
        prefillContact: contact,
        notes: {
          'tripId': widget.tripId,
          'bidId': bid.bidId,
          'driverName': bid.name,
        },
      );
    } catch (e) {
      _resetPending();
      if (mounted) setState(() => _processing = false);
      SnackBarHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final bid = _payingBid;
    final orderId = response.orderId ?? _pendingOrderId ?? '';
    if (bid == null) {
      if (mounted) setState(() => _processing = false);
      return;
    }
    AppLogger.d('[Assign] razorpay success payment=${response.paymentId}');

    try {
      final verifyResult = await _paymentService.verifyPayment(
        paymentId: response.paymentId ?? '',
        tripId: widget.tripId,
        bidId: bid.bidId,
        orderId: orderId,
        signature: response.signature,
      ).timeout(const Duration(seconds: 20));

      SnackBarHelper.success('Payment successful! Trip assigned.');
      DashboardController.refreshIfActive();

      if (mounted) {
        Get.off(() => TripAssignmentSuccessScreen(
          tripId: _controller.tripCode.value.isNotEmpty
              ? _controller.tripCode.value : widget.tripId,
          driverName: bid.name,
          driverAvatar: bid.avatar,
          driverRating: bid.rating,
          driverTrips: bid.totalTrips,
          driverIsVerified: bid.isVerified,
          paymentId: response.paymentId ?? '',
          paymentAmount: _option == _PayOption.total
              ? _total(bid)
              : _platformFee(bid),
          paymentOption: _option == _PayOption.total ? 'total' : 'platform',
          otp: verifyResult.otp,
          from: _controller.from.value,
          to: _controller.to.value,
          departureDate: _dateStr(),
          departureTime: _controller.pickupTime.value,
          distance: null,
          vehicleName: _controller.vehicleName.value,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        _showVerifyIssueDialog(bid, e.toString(), response.paymentId ?? '');
      }
    } finally {
      _resetPending();
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _resetPending();
    if (mounted) setState(() => _processing = false);
    SnackBarHelper.error('Payment failed: ${response.message ?? 'Cancelled'}');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    SnackBarHelper.info('Wallet selected: ${response.walletName ?? 'Unknown'}');
  }

  void _resetPending() {
    _payingBid = null;
    _pendingOrderId = null;
  }

  void _showVerifyIssueDialog(TripBid bid, String error, String paymentId) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Payment Received', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      content: Text(
        'Your payment was processed but we had trouble confirming it. '
        'The trip status will update automatically.\n\n$error',
        style: GoogleFonts.poppins(fontSize: 13, color: _textMid)),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.off(() => TripAssignmentSuccessScreen(
              tripId: _controller.tripCode.value.isNotEmpty
                  ? _controller.tripCode.value : widget.tripId,
              driverName: bid.name,
              driverAvatar: bid.avatar,
              driverRating: bid.rating,
              driverTrips: bid.totalTrips,
              driverIsVerified: bid.isVerified,
              paymentId: paymentId,
              paymentAmount: _option == _PayOption.total
                  ? _total(bid)
                  : _platformFee(bid),
              paymentOption: _option == _PayOption.total ? 'total' : 'platform',
              otp: null,
              from: _controller.from.value,
              to: _controller.to.value,
              departureDate: _dateStr(),
              departureTime: _controller.pickupTime.value,
              distance: null,
              vehicleName: _controller.vehicleName.value,
            ));
          },
          child: const Text('OK')),
      ],
    ));
  }

  // ── small UI helpers ───────────────────────────────────────────────────
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _routeRow(IconData icon, String label, String addr, Color color) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
        Text(addr.isEmpty ? 'N/A' : addr, style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
      ])),
    ]);
  }

  Widget _miniInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _bg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border)),
      child: Row(children: [
        Icon(icon, size: 16, color: _textGrey),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: _textGrey)),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _textDark)),
        ])),
      ]),
    );
  }

  Widget _optionTile({
    required bool selected,
    required VoidCallback onTap,
    required String label,
    required String sub,
    required double amount,
    required Color color,
    bool recommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : _border, width: selected ? 1.5 : 1)),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? color : _textGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(label, style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _textDark))),
              if (recommended) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('Recommended', style: GoogleFonts.poppins(
                      fontSize: 8, fontWeight: FontWeight.w700, color: _green))),
              ],
            ]),
            Text(sub, style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
          ])),
          Text('₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.poppins(
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: Colors.white.withValues(alpha: bold ? 1 : 0.9))),
      Text('₹${amount.toStringAsFixed(2)}', style: GoogleFonts.poppins(
          fontSize: bold ? 20 : 14, fontWeight: FontWeight.w700, color: Colors.white)),
    ]);
  }

  Widget _avatarFallback(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase()
        : 'DR';
    return Container(
      color: _primaryLt,
      child: Center(child: Text(initials, style: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w700, color: _primary))));
  }

  String _dateStr() {
    final d = _controller.pickupDate.value;
    if (d == null) return 'Date TBD';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _errorState(String message) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 56, color: _primary),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(
            fontSize: 14, color: _textMid)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _controller.fetchAssignTrip(widget.tripId),
          style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
          child: const Text('Retry')),
      ]),
    ));
  }

  Widget _emptyState() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Iconsax.people, size: 56, color: _primary),
        const SizedBox(height: 16),
        Text('No bid found for this trip.', style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w600, color: _textMid)),
        const SizedBox(height: 8),
        Text('Bids may have been withdrawn.', style: GoogleFonts.poppins(
            fontSize: 12, color: _textGrey)),
      ]),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../controllers/Transport/assign_trip_controller.dart';
import '../../../models/assign_trip_model.dart';
import '../../../models/trip_confirmation_model.dart';
import '../../../services/razorpay_service.dart';
import '../../../services/trip_payment_service.dart';
import '../../../utils/session_manager.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_loader.dart';
import 'trip_accepted.dart';
import '../../../utils/app_logger.dart';
import '../../../controllers/Transport/user_profile_controller.dart';

class AssignTripScreen extends StatefulWidget {
  final String tripId;
  final String? bidId;

  const AssignTripScreen({super.key, required this.tripId, this.bidId});

  @override
  State<AssignTripScreen> createState() => _AssignTripScreenState();
}

class _AssignTripScreenState extends State<AssignTripScreen> {
  late final AssignTripController _controller;
  late final RazorpayService _razorpayService;
  late final TripPaymentService _tripPaymentService;
  AssignTripBid? _bidInPayment;
  TripPaymentVerificationPayload? _pendingVerificationPayload;
  bool _isPaymentProcessing = false;
  bool _showLoader = false;
  String _loaderMessage = "Confirming payment...";

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AssignTripController(), tag: widget.tripId);
    _razorpayService = RazorpayService(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    _tripPaymentService = TripPaymentService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchAssignTrip(widget.tripId);
    });
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    if (Get.isRegistered<AssignTripController>(tag: widget.tripId)) {
      Get.delete<AssignTripController>(tag: widget.tripId);
    }
    super.dispose();
  }

  AssignTripBid? _selectedBid() {
    final bidId = widget.bidId;
    if (bidId != null && bidId.isNotEmpty) {
      final bid = _controller.getBidById(bidId);
      if (bid != null) return bid;
    }
    if (_controller.assignBids.isNotEmpty) {
      return _controller.assignBids.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review Summary',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const CustomLoader(message: "Loading trip details...");
        }

        if (_controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(
            message: _controller.errorMessage.value,
            onRetry: () => _controller.fetchAssignTrip(widget.tripId),
          );
        }

        final bid = _selectedBid();
        if (bid == null) {
          return _buildEmptyState(
            onRefresh: () => _controller.fetchAssignTrip(widget.tripId),
          );
        }

        return Stack(
          children: [
            _buildContent(context, bid),
            if (_showLoader)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: CustomLoader(message: _loaderMessage),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildContent(BuildContext context, AssignTripBid bid) {
    final driverName = bid.driverName.isNotEmpty ? bid.driverName : 'Driver';
    final driverImage = bid.driverPhoto.isNotEmpty
        ? bid.driverPhoto
        : 'https://via.placeholder.com/150';
    final bidAmount = _formatCurrency(
      bid.bidAmount > 0 ? bid.bidAmount : bid.totalTripCost,
    );
    final pickupAddress = bid.pickupLocation.isNotEmpty
        ? bid.pickupLocation
        : 'Pickup location not available';
    final destinationAddress = bid.deliveryLocation.isNotEmpty
        ? bid.deliveryLocation
        : 'Destination not available';
    final dateTime = _formatPickupDateTime(bid.pickupDate, bid.pickupTime);
    final requirements = bid.specialInstructions.isNotEmpty
        ? bid.specialInstructions
        : 'No special instructions provided';

    final platformFeeAmount = _formatCurrency(_nonNegative(bid.platformFee));
    final amountToDriverAmount = _formatCurrency(
      _nonNegative(bid.amountToDriver),
    );
    final totalTripCostAmount = _formatCurrency(_resolveTotalCost(bid));

    final payoutAmount = _formatCurrency(_nonNegative(bid.amountToDriver));

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Bid Amount and Trip Details Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bid Amount Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bid Amount to Pay',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                bidAmount,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF00B894),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 12,
                              color: Color(0xFF2186EB),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2186EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Driver Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(driverImage),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          Text(
                            'Driver',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Trip Details
                  _buildTripDetail(
                    icon: Icons.location_on,
                    label: 'Pickup',
                    value: pickupAddress,
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildTripDetail(
                    icon: Icons.location_on,
                    label: 'Destination',
                    value: destinationAddress,
                    iconColor: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          requirements,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Review Your Booking Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startPayment(bid, isPartial: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B894),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Review Your Booking',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FAF4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '20% upfront, 80% on-',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Color(0xFF00B894),
                              ),
                            ),
                            Text(
                              'trip',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Color(0xFF00B894),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildPaymentRow(
                    label: 'Platform Booking Fee',
                    amount: platformFeeAmount,
                    hasInfo: true,
                    hasPayNow: true,
                    onPayNowTap: () => _startPayment(bid, isPartial: true),
                  ),
                  const Divider(height: 32),
                  _buildPaymentRow(
                    label: 'Amount Payable to Driver',
                    amount: amountToDriverAmount,
                    hasInfo: true,
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Trip Cost',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        totalTripCostAmount,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: Color(0xFF00B894),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment Method Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    '(for Platform Fee)',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FEFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00B894),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 27,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.credit_card, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Mastercard •••• 4679',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00B894),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 18,
                            color: Color(0xFF00B894),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Add New Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFBFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_card,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Add New Card',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Or pay using UPI',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'UPI ID:',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter UPI ID',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                            ),
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

          // Payment Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF2D3436),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2D3436),
                            ),
                            children: [
                              const TextSpan(text: 'Pay Remaining Amount ('),
                              TextSpan(
                                text: payoutAmount,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF00B894),
                                ),
                              ),
                              const TextSpan(
                                text: ') directly to\nthe driver via:',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.money,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Cash',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.help_outline,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.phone_android,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'UPI',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You\'ll receive payment instructions after\nbooking confirmation.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Pay Now Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPaymentProcessing
                    ? null
                    : () => _startPayment(bid, isPartial: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36969),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  _isPaymentProcessing ? 'Processing...' : 'Pay Full Amount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _startPayment(
    AssignTripBid bid, {
    bool isPartial = false,
  }) async {
    if (!mounted || _isPaymentProcessing) return;

    setState(() {
      _isPaymentProcessing = true;
      _showLoader = true;
      _loaderMessage = "Initializing payment...";
      _bidInPayment = bid;
    });

    // If partial, pay only platform fee. Otherwise, pay total/full.
    final payableAmount = isPartial
        ? _nonNegative(bid.platformFee)
        : _resolveTotalCost(bid);

    final receipt = _buildReceiptId(bid);

    try {
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString('userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('User information is missing. Please log in again.');
      }

      AppLogger.d(
        '[AssignTrip] Creating backend order for trip=${widget.tripId} bid=${bid.bidId} amount=$payableAmount',
      );
      final order = await _tripPaymentService.createOrder(
        totalAmount: payableAmount,
      );
      AppLogger.d(
        '[AssignTrip] Order created successfully orderId=${order.orderId}',
      );

      _pendingVerificationPayload = TripPaymentVerificationPayload(
        tripId: widget.tripId,
        bidId: bid.bidId,
        userId: userId,
        amount: _nonNegative(bid.amountToDriver),
        platformFee: _nonNegative(bid.platformFee),
        totalAmount: payableAmount,
        orderId: order.orderId,
      );

      String prefillEmail = 'hello@wheelboard.in';
      String prefillContact = '7420861942';

      try {
        if (Get.isRegistered<UserProfileController>()) {
          final profile = Get.find<UserProfileController>().userProfile.value;
          if (profile != null) {
            prefillEmail = profile.email ?? profile.mobileNo ?? prefillEmail;
            prefillContact = profile.mobileNo ?? prefillContact;
          }
        }
      } catch (e) {
        AppLogger.d(
          '[AssignTrip] Could not fetch user profile for prefill: $e',
        );
      }

      if (mounted) {
        setState(() {
          _showLoader = false;
        });
      }

      await _razorpayService.openCheckout(
        amountInPaise: order.amountInPaise,
        orderId: order.orderId,
        keyOverride: order.keyId.isNotEmpty ? order.keyId : null,
        receipt: receipt,
        description:
            'Trip payment for ${bid.driverName.isNotEmpty ? bid.driverName : 'WheelBoard driver'}',
        customerName: 'WheelBoard',
        prefillEmail: prefillEmail,
        prefillContact: prefillContact,
        notes: {
          'tripId': widget.tripId,
          'bidId': bid.bidId,
          'driverName': bid.driverName,
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPaymentProcessing = false;
          _showLoader = false;
        });
      }
      _bidInPayment = null;
      _pendingVerificationPayload = null;
      SnackBarHelper.error('Unable to start payment: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (mounted) {
      setState(() {
        _isPaymentProcessing = true;
        _showLoader = true;
        _loaderMessage = "Verifying payment...";
      });
    }
    AppLogger.d(
      '[AssignTrip] Razorpay success paymentId=${response.paymentId} orderId=${response.orderId}',
    );
    final bid = _bidInPayment;
    _bidInPayment = null;
    final verificationPayload = _pendingVerificationPayload;
    _pendingVerificationPayload = null;

    try {
      if (verificationPayload != null) {
        final enrichedPayload = verificationPayload.copyWith(
          orderId: response.orderId ?? verificationPayload.orderId,
          paymentId: response.paymentId ?? '',
          signature: response.signature ?? '',
        );

        // 1. Verify Payment with timeout
        AppLogger.d('[AssignTrip] Verifying payment on server...');
        await _tripPaymentService
            .verifyPayment(enrichedPayload)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw Exception(
                'Verification timed out after 15s. We will update your status shortly.',
              ),
            );

        // 2. Fetch Trip Confirmation (Optional/Low priority)
        TripConfirmationModel? confirmation;
        try {
          AppLogger.d('[AssignTrip] Fetching trip confirmation...');
          confirmation = await _tripPaymentService
              .getTripConfirmation(verificationPayload.tripId)
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          AppLogger.e(
            '[AssignTrip] Confirmation fetch failed (non-critical): $e',
          );
        }

        SnackBarHelper.success('Payment verified successfully!');

        if (bid != null) {
          _navigateToTripAccepted(bid, confirmation);
          if (mounted) {
            setState(() {
              _isPaymentProcessing = false;
              _showLoader = false;
            });
          }
          return;
        }
      } else {
        SnackBarHelper.success('Payment successful!');
        if (bid != null) {
          _navigateToTripAccepted(bid, null);
          if (mounted) {
            setState(() {
              _isPaymentProcessing = false;
              _showLoader = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      AppLogger.e('[AssignTrip] Payment handling failed: $e');
      if (mounted) {
        setState(() {
          _isPaymentProcessing = false;
          _showLoader = false;
        });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Payment Status'),
            content: Text(
              'Your payment was processed, but we had trouble confirming it: $e. Your trip status will be updated automatically.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (bid != null) _navigateToTripAccepted(bid, null);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (_isPaymentProcessing) _isPaymentProcessing = false;
          if (_showLoader) _showLoader = false;
        });
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() {
        _isPaymentProcessing = false;
        _showLoader = false;
      });
    }
    _bidInPayment = null;
    _pendingVerificationPayload = null;
    final reason = response.message ?? 'Something went wrong';
    SnackBarHelper.error('Payment failed: $reason');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    SnackBarHelper.info(
      'External wallet selected: ${response.walletName ?? 'Unknown'}',
    );
  }

  void _navigateToTripAccepted(
    AssignTripBid bid,
    TripConfirmationModel? confirmation,
  ) {
    // Use confirmation data if available, otherwise fallback to bid data
    final driverName = confirmation?.driver.isNotEmpty == true
        ? confirmation!.driver
        : (bid.driverName.isNotEmpty ? bid.driverName : 'Driver');
    final vehicleType = confirmation?.vehicle.isNotEmpty == true
        ? confirmation!.vehicle
        : 'Bus';
    final extractedDate = (confirmation?.pickupDate != null)
        ? _formatDateOnly(confirmation!.pickupDate)
        : _formatDateOnly(bid.pickupDate);
    final extractedTime = confirmation?.pickupTime.isNotEmpty == true
        ? confirmation!.pickupTime
        : (bid.pickupTime.isNotEmpty ? bid.pickupTime : 'Time TBD');
    final tripCode = confirmation?.tripCode.isNotEmpty == true
        ? confirmation!.tripCode
        : widget.tripId;

    Get.off(
      () => TripAccepted(
        tripId: tripCode,
        driverName: driverName,
        vehicleType: vehicleType,
        date: extractedDate,
        time: extractedTime,
      ),
    );
  }

  Widget _buildTripDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String amount,
    bool hasInfo = false,
    bool hasPayNow = false,
    VoidCallback? onPayNowTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasInfo) ...[
                const SizedBox(width: 4),
                const Icon(Icons.help_outline, size: 13, color: Colors.grey),
              ],
              if (hasPayNow) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onPayNowTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FAF4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Color(0xFF00B894),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required VoidCallback onRefresh}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment, color: Color(0xFF00B894), size: 48),
            const SizedBox(height: 12),
            const Text(
              'No bids available yet.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }

  double _resolveTotalCost(AssignTripBid bid) {
    if (bid.totalTripCost > 0) {
      return bid.totalTripCost;
    }
    final calculated = bid.bidAmount + bid.platformFee;
    if (calculated.isFinite && calculated > 0) {
      return calculated;
    }
    return bid.bidAmount;
  }

  double _nonNegative(double value) => value.isFinite && value > 0 ? value : 0;

  String _formatCurrency(double value) =>
      '₹${value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}';

  String _formatPickupDateTime(DateTime? date, String time) {
    final dateText = _formatDateOnly(date);
    final timeText = time.isNotEmpty ? time : 'Time TBD';
    return '$dateText, $timeText';
  }

  String _formatDateOnly(DateTime? date) {
    if (date == null) return 'Date TBD';
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  String _buildReceiptId(AssignTripBid bid) {
    final tripPart = _sanitizeIdPart(widget.tripId);
    final bidPart = _sanitizeIdPart(bid.bidId);
    final timestampPart = DateTime.now().millisecondsSinceEpoch.toRadixString(
      36,
    );
    var receipt = 'trip_${tripPart}_${bidPart}_$timestampPart';
    if (receipt.length > 40) {
      receipt = receipt.substring(0, 40);
    }
    return receipt;
  }

  String _sanitizeIdPart(String value, {int maxLength = 8}) {
    final sanitized = value
        .replaceAll(RegExp('[^a-zA-Z0-9]'), '')
        .toLowerCase();
    if (sanitized.isEmpty) {
      return 'id';
    }
    return sanitized.length <= maxLength
        ? sanitized
        : sanitized.substring(0, maxLength);
  }
}

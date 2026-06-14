import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../utils/app_logger.dart';
import '../widgets/custom_snackbar.dart';

class SubscriptionController extends GetxController {
  /// 'professional' | 'fleet_owner' | 'service_provider'
  final String category;

  SubscriptionController(this.category);

  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  final Rxn<UserSubscription> currentSubscription = Rxn<UserSubscription>();
  final Rxn<SubscriptionPlan> currentPlan = Rxn<SubscriptionPlan>();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<String> processingPlanId = Rxn<String>();
  /// Usage limits from GET /subscription/usage-limits
  final Rxn<Map<String, dynamic>> usageLimits = Rxn<Map<String, dynamic>>();
  final RxBool changingPlan = false.obs;

  late final Razorpay _razorpay;
  SubscriptionPlan? _pendingPaidPlan;
  /// Razorpay order id of the in-flight checkout, so a dismissed/failed modal
  /// can tell the backend to clear the pending intent.
  String? _pendingOrderId;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    fetchData();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // ── Data fetch ────────────────────────────────────────────────────────────

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        SubscriptionService.instance.getAvailablePlans(category),
        SubscriptionService.instance.getMySubscription(),
      ]);

      plans.value = results[0] as List<SubscriptionPlan>;
      final subResult = results[1]
          as ({UserSubscription? subscription, SubscriptionPlan? plan});
      currentSubscription.value = subResult.subscription;
      currentPlan.value = subResult.plan;

      AppLogger.d(
          '✅ Subscriptions loaded: ${plans.length} plans | active=${currentSubscription.value?.isActive}');
    } catch (e) {
      errorMessage.value = 'Failed to load subscription plans.';
      AppLogger.e('❌ Subscription fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Subscribe ─────────────────────────────────────────────────────────────

  bool isCurrentPlan(String planId) {
    final sub = currentSubscription.value;
    if (sub == null || !sub.isActive) return false;
    return sub.planId == planId;
  }

  Future<void> subscribe(SubscriptionPlan plan) async {
    if (processingPlanId.value != null) return;
    processingPlanId.value = plan.id;

    try {
      if (plan.pricing.amount == 0) {
        // ── Free plan: direct API call ──────────────────────────────────
        final sub = await SubscriptionService.instance.subscribeToPlan(plan.id);
        currentSubscription.value = sub;
        currentPlan.value = plan;
        SnackBarHelper.success('${plan.name} plan activated!');
        await fetchData();
        processingPlanId.value = null;
      } else {
        // ── Paid plan: Razorpay flow ────────────────────────────────────
        final paymentData =
            await SubscriptionService.instance.initiatePayment(plan.id);
        _pendingPaidPlan = plan;
        _openRazorpay(paymentData, plan);
        // processingPlanId cleared in Razorpay callbacks
      }
    } on DioException catch (e) {
      processingPlanId.value = null;
      _pendingPaidPlan = null;
      _handleDioError(e, plan);
    } catch (e) {
      processingPlanId.value = null;
      _pendingPaidPlan = null;
      AppLogger.e('❌ Subscribe error: $e');
      SnackBarHelper.error('Failed to subscribe. Please try again.');
    }
  }

  // ── Razorpay ──────────────────────────────────────────────────────────────

  void _openRazorpay(Map<String, dynamic> data, SubscriptionPlan plan) {
    // Backend returns amount in rupees. Razorpay SDK needs PAISE → multiply by 100.
    final amountRupees = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final amountPaise = (amountRupees * 100).toInt();

    final key = data['razorpayKeyId']?.toString() ?? '';
    final orderId = data['orderId']?.toString() ?? '';

    AppLogger.d('🔑 Razorpay key: $key, order: $orderId, amount: $amountPaise paise');

    if (key.isEmpty) {
      processingPlanId.value = null;
      _pendingPaidPlan = null;
      SnackBarHelper.error('Payment gateway not configured. Contact support.');
      return;
    }

    _pendingOrderId = orderId.isNotEmpty ? orderId : null;

    _razorpay.open({
      'key': key,
      'amount': amountPaise,
      'currency': data['currency']?.toString() ?? 'INR',
      'name': 'Wheelboard',
      'description': '${plan.name} Subscription',
      if (orderId.isNotEmpty) 'order_id': orderId,
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#F36969'},
    });
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final plan = _pendingPaidPlan;
    if (plan == null) {
      processingPlanId.value = null;
      return;
    }
    try {
      AppLogger.d('✅ Payment success: ${response.paymentId}, order: ${response.orderId}');
      final sub = await SubscriptionService.instance.verifyPayment(
        planId: plan.id,
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );
      currentSubscription.value = sub;
      currentPlan.value = plan;
      SnackBarHelper.success('${plan.name} activated successfully! 🎉');
      await fetchData();
    } catch (e) {
      AppLogger.e('❌ verify-payment error: $e');
      SnackBarHelper.error(
          'Payment was successful but activation failed. Contact support.');
    } finally {
      processingPlanId.value = null;
      _pendingPaidPlan = null;
      _pendingOrderId = null;
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    AppLogger.e('❌ Razorpay error code=${response.code}: ${response.message}');
    // User cancelled (code 2) is not really an error to display
    if (response.code != 2) {
      SnackBarHelper.error(response.message ?? 'Payment failed. Please try again.');
    }
    // Clear the pending intent server-side so a dismissed/failed checkout is not
    // later counted or displayed as a paid subscription.
    final orderId = _pendingOrderId;
    if (orderId != null && orderId.isNotEmpty) {
      SubscriptionService.instance.abandonPayment(orderId);
    }
    _pendingOrderId = null;
    processingPlanId.value = null;
    _pendingPaidPlan = null;
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    AppLogger.d('External wallet: ${response.walletName}');
    processingPlanId.value = null;
    _pendingPaidPlan = null;
    _pendingOrderId = null;
  }

  // ── Change plan (upgrade / downgrade) ──────────────────────────────────

  /// Switches the active subscription to [newPlan].
  /// If the new plan is free, calls `changePlan` directly.
  /// If paid, opens Razorpay for the new amount (backend initiates the order).
  Future<void> switchPlan(SubscriptionPlan newPlan) async {
    if (processingPlanId.value != null) return;
    if (isCurrentPlan(newPlan.id)) {
      SnackBarHelper.error('You are already on this plan.');
      return;
    }

    processingPlanId.value = newPlan.id;
    changingPlan.value = true;
    try {
      if (newPlan.pricing.amount == 0) {
        // Free target — switch immediately via change-plan (backend supersedes
        // the old plan atomically). Mirrors wheelboard-fe changePlan().
        final sub = await SubscriptionService.instance.changePlan(newPlan.id);
        currentSubscription.value = sub;
        currentPlan.value = newPlan;
        SnackBarHelper.success('Switched to ${newPlan.name} plan!');
        await fetchData();
        processingPlanId.value = null;
      } else {
        // Paid target — initiate Razorpay with the new plan.
        // processingPlanId is cleared in the Razorpay callbacks.
        _pendingPaidPlan = newPlan;
        final paymentData =
            await SubscriptionService.instance.initiatePayment(newPlan.id);
        _openRazorpay(paymentData, newPlan);
      }
    } on DioException catch (e) {
      processingPlanId.value = null;
      _pendingPaidPlan = null;
      _handleDioError(e, newPlan);
    } catch (e) {
      processingPlanId.value = null;
      _pendingPaidPlan = null;
      AppLogger.e('❌ switchPlan error: $e');
      SnackBarHelper.error('Failed to switch plan. Please try again.');
    } finally {
      changingPlan.value = false;
    }
  }

  // ── Plan tap routing + CTA labels (mirrors wheelboard-fe) ──────────────────

  /// Single entry point for a plan card tap. When the user already has an
  /// active subscription, switching (upgrade/downgrade/switch) is done in
  /// place via [switchPlan]; otherwise a fresh [subscribe]. Mirrors
  /// wheelboard-fe `handleSubscribe` which calls changePlan vs subscribeToPlan.
  Future<void> onPlanTap(SubscriptionPlan plan) async {
    if (isCurrentPlan(plan.id)) return;
    final sub = currentSubscription.value;
    if (sub != null && sub.isActive) {
      await switchPlan(plan);
    } else {
      await subscribe(plan);
    }
  }

  /// Amount of the user's active plan, for upgrade/downgrade labelling.
  int? get _currentPlanAmount {
    final sub = currentSubscription.value;
    if (sub == null || !sub.isActive) return null;
    for (final p in plans) {
      if (p.id == sub.planId) return p.pricing.amount.round();
    }
    return null;
  }

  /// CTA label for a plan card. Mirrors wheelboard-fe `getCtaLabel`:
  /// Current Plan / Get Started Free / Subscribe Now / Upgrade / Downgrade /
  /// Switch Plan.
  String ctaLabel(SubscriptionPlan plan) {
    if (isCurrentPlan(plan.id)) return 'Current Plan';
    final currentAmount = _currentPlanAmount;
    final planAmount = plan.pricing.amount.round();
    if (currentAmount == null) {
      return planAmount == 0 ? 'Get Started Free' : 'Subscribe Now';
    }
    if (planAmount > currentAmount) return 'Upgrade';
    if (planAmount < currentAmount) return 'Downgrade';
    return 'Switch Plan';
  }

  // ── Usage limits ─────────────────────────────────────────────────────────

  Future<void> fetchUsageLimits() async {
    try {
      final data = await SubscriptionService.instance.getUsageLimits();
      usageLimits.value = data;
    } catch (e) {
      AppLogger.d('ℹ️ fetchUsageLimits skipped: $e');
    }
  }

  // ── Cancel subscription ───────────────────────────────────────────────────

  Future<void> cancelSubscription(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Subscription',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to cancel your subscription? '
            'Your benefits will continue until the end of the billing period.',
            style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep It',
                style: TextStyle(
                    color: Color(0xFF6B7280), fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Plan',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await SubscriptionService.instance.cancelSubscription();
      SnackBarHelper.success('Subscription cancelled.');
      await fetchData();
    } catch (e) {
      SnackBarHelper.error('Failed to cancel subscription.');
    }
  }

  // ── Error handling ────────────────────────────────────────────────────────

  void _handleDioError(DioException e, SubscriptionPlan plan) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    // Extract the backend's human-readable message
    String message = 'Failed to subscribe. Please try again.';
    if (responseData is Map<String, dynamic>) {
      message = responseData['message']?.toString() ?? message;
    }

    AppLogger.e('❌ Subscribe HTTP $statusCode: $message');

    if (statusCode == 400) {
      if (message.toLowerCase().contains('already have an active subscription') ||
          message.toLowerCase().contains('already subscribed')) {
        // Show a specific dialog for "already subscribed" case
        _showAlreadySubscribedDialog(plan.category);
        return;
      }
      if (message.toLowerCase().contains('free plan') ||
          message.toLowerCase().contains('no payment required')) {
        // They tried to initiate payment on a free plan — subscribe directly
        _subscribeFreeDirectly(plan);
        return;
      }
    }

    SnackBarHelper.error(message);
  }

  void _showAlreadySubscribedDialog(String category) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Already Subscribed',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Text(
          'You already have an active subscription for $category. '
          'To switch plans, cancel your current subscription first.',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK',
                style: TextStyle(
                    color: Color(0xFFF36969), fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
    // Refresh to show the active subscription correctly
    fetchData();
  }

  Future<void> _subscribeFreeDirectly(SubscriptionPlan plan) async {
    try {
      processingPlanId.value = plan.id;
      final sub = await SubscriptionService.instance.subscribeToPlan(plan.id);
      currentSubscription.value = sub;
      currentPlan.value = plan;
      SnackBarHelper.success('${plan.name} plan activated!');
      await fetchData();
    } catch (e) {
      SnackBarHelper.error('Failed to activate free plan.');
    } finally {
      processingPlanId.value = null;
    }
  }
}

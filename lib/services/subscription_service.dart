// Mirrors wheelboard-fe/src/lib/subscriptionApi.ts methods exactly.
// All backend responses are wrapped: { success, data: {...} }
// This service unwraps them the same way the web's apiRequest does: data.data || data

import '../core/network/api_client.dart';
import '../models/subscription_model.dart';
import '../utils/app_logger.dart';

class SubscriptionService {
  const SubscriptionService._();
  static const instance = SubscriptionService._();

  // ── Unwrap helper (mirrors web's `data.data || data`) ────────────────────
  static dynamic _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['data'] ?? raw;
    }
    return raw;
  }

  // GET /subscription/available?category=...
  // Returns: { success, data: [...plans] }
  Future<List<SubscriptionPlan>> getAvailablePlans(String category) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        '/subscription/available',
        queryParameters: {'category': category},
      );
      final inner = _unwrap(raw);
      final list = inner is List ? inner : (inner is Map ? (inner['data'] ?? inner) : []);
      return (list as List)
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    } catch (e) {
      AppLogger.e('❌ getAvailablePlans error: $e');
      rethrow;
    }
  }

  // GET /subscription/my-subscription
  // Returns: { success, data: { subscription: {...}|null, plan: {...}|null } }
  Future<({UserSubscription? subscription, SubscriptionPlan? plan})>
      getMySubscription() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        '/subscription/my-subscription',
      );
      final inner = _unwrap(raw) as Map<String, dynamic>? ?? {};
      final subMap = inner['subscription'] as Map<String, dynamic>?;
      final planMap = inner['plan'] as Map<String, dynamic>?;
      return (
        subscription: subMap != null ? UserSubscription.fromJson(subMap) : null,
        plan: planMap != null ? SubscriptionPlan.fromJson(planMap) : null,
      );
    } catch (e) {
      AppLogger.d('ℹ️ No active subscription: $e');
      return (subscription: null, plan: null);
    }
  }

  // POST /subscription/subscribe  (FREE plans only)
  // Returns: { success, message, data: {UserSubscription} }
  Future<UserSubscription> subscribeToPlan(
    String planId, {
    String? paymentId,
    bool autoRenew = false,
  }) async {
    final raw = await ApiClient.instance.post<dynamic>(
      '/subscription/subscribe',
      data: {
        'planId': planId,
        if (paymentId != null) 'paymentId': paymentId,
        'autoRenew': autoRenew,
      },
    );
    final inner = _unwrap(raw);
    return UserSubscription.fromJson(inner as Map<String, dynamic>);
  }

  // POST /subscription/initiate-payment
  // Returns: { success, message, data: { orderId, amount(INR rupees), currency, razorpayKeyId, planName } }
  Future<Map<String, dynamic>> initiatePayment(String planId) async {
    final raw = await ApiClient.instance.post<dynamic>(
      '/subscription/initiate-payment',
      data: {'planId': planId},
    );
    // Unwrap so caller gets { orderId, amount, currency, razorpayKeyId, planName }
    final inner = _unwrap(raw);
    return inner as Map<String, dynamic>;
  }

  // POST /subscription/verify-payment
  // Returns: { success, message, data: {UserSubscription} }
  Future<UserSubscription> verifyPayment({
    required String planId,
    required String paymentId,
    required String orderId,
    required String signature,
    bool autoRenew = false,
  }) async {
    final raw = await ApiClient.instance.post<dynamic>(
      '/subscription/verify-payment',
      data: {
        'planId': planId,
        'paymentId': paymentId,
        'orderId': orderId,
        'signature': signature,
        'autoRenew': autoRenew,
      },
    );
    final inner = _unwrap(raw);
    return UserSubscription.fromJson(inner as Map<String, dynamic>);
  }

  // POST /subscription/cancel
  Future<void> cancelSubscription() async {
    await ApiClient.instance.post<dynamic>('/subscription/cancel');
  }

  // POST /subscription/change-plan  { newPlanId }
  // Upgrades or downgrades the current subscription.
  // Returns: { success, message, data: {UserSubscription} }
  Future<UserSubscription> changePlan(String newPlanId) async {
    final raw = await ApiClient.instance.post<dynamic>(
      '/subscription/change-plan',
      data: {'newPlanId': newPlanId},
    );
    final inner = _unwrap(raw);
    return UserSubscription.fromJson(inner as Map<String, dynamic>);
  }

  // GET /subscription/check-limit?feature=...
  // Returns: { success, data: { allowed: bool, current: int, limit: int | null } }
  Future<Map<String, dynamic>> checkLimit(String feature) async {
    final raw = await ApiClient.instance.get<dynamic>(
      '/subscription/check-limit',
      queryParameters: {'feature': feature},
    );
    final inner = _unwrap(raw);
    if (inner is Map<String, dynamic>) return inner;
    return {'allowed': true};
  }

  // GET /subscription/usage-limits
  // Returns: { success, data: { limits: [...], usage: {...} } }
  Future<Map<String, dynamic>> getUsageLimits() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        '/subscription/usage-limits',
      );
      final inner = _unwrap(raw);
      if (inner is Map<String, dynamic>) return inner;
      return {};
    } catch (e) {
      AppLogger.d('ℹ️ Usage limits unavailable: $e');
      return {};
    }
  }

  // ── Static error message extractor ───────────────────────────────────────
  /// Extracts the human-readable message from a DioException response body.
  static String extractErrorMessage(dynamic error) {
    try {
      // DioException with a JSON response body
      if (error is Exception) {
        final s = error.toString();
        // Try to find the backend message field
        if (s.contains('"message"')) {
          final start = s.indexOf('"message"') + 10;
          final end = s.indexOf('"', start + 1);
          if (end > start) return s.substring(start + 1, end);
        }
      }
    } catch (_) {}
    return error.toString();
  }
}

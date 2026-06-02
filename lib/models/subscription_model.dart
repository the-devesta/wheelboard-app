// Mirrors wheelboard-fe/src/lib/subscriptionApi.ts types exactly.

class SubscriptionPricing {
  final double amount;
  final String currency;
  final String duration; // monthly | yearly | lifetime | one_time | trial
  final int? trialDays;
  final double? discount;

  const SubscriptionPricing({
    required this.amount,
    required this.currency,
    required this.duration,
    this.trialDays,
    this.discount,
  });

  factory SubscriptionPricing.fromJson(Map<String, dynamic> j) =>
      SubscriptionPricing(
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        currency: j['currency']?.toString() ?? 'INR',
        duration: j['duration']?.toString() ?? 'monthly',
        trialDays: j['trialDays'] as int?,
        discount: (j['discount'] as num?)?.toDouble(),
      );

  String get formatted {
    if (amount == 0) return 'Free';
    final amt = '₹${amount.toStringAsFixed(0)}';
    switch (duration) {
      case 'monthly':
        return '$amt/month';
      case 'yearly':
        return '$amt/year';
      case 'lifetime':
        return '$amt (Lifetime)';
      case 'trial':
        return 'Free for ${trialDays ?? 30} days';
      default:
        return amt;
    }
  }
}

class SubscriptionLimits {
  final int? maxVehicles;
  final int? maxDrivers;
  final int? maxTrips;
  final int? maxJobPosts;
  final int? maxHirings;
  final int? maxServiceRequests;
  final int? maxListings;
  final int? maxPosts;
  final double? commissionRate;

  const SubscriptionLimits({
    this.maxVehicles,
    this.maxDrivers,
    this.maxTrips,
    this.maxJobPosts,
    this.maxHirings,
    this.maxServiceRequests,
    this.maxListings,
    this.maxPosts,
    this.commissionRate,
  });

  factory SubscriptionLimits.fromJson(Map<String, dynamic> j) =>
      SubscriptionLimits(
        maxVehicles: j['maxVehicles'] as int?,
        maxDrivers: j['maxDrivers'] as int?,
        maxTrips: j['maxTrips'] as int?,
        maxJobPosts: j['maxJobPosts'] as int?,
        maxHirings: j['maxHirings'] as int?,
        maxServiceRequests: j['maxServiceRequests'] as int?,
        maxListings: j['maxListings'] as int?,
        maxPosts: j['maxPosts'] as int?,
        commissionRate: (j['commissionRate'] as num?)?.toDouble(),
      );
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final String category; // service_provider | professional | fleet_owner
  final bool isRecommended;
  final SubscriptionPricing pricing;
  final SubscriptionLimits limits;
  final List<String> features;
  final String status;
  final int displayOrder;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.isRecommended,
    required this.pricing,
    required this.limits,
    required this.features,
    required this.status,
    required this.displayOrder,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> j) => SubscriptionPlan(
        id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        description: j['description']?.toString(),
        category: j['category']?.toString() ?? '',
        isRecommended: j['isRecommended'] as bool? ?? false,
        pricing: SubscriptionPricing.fromJson(
            j['pricing'] as Map<String, dynamic>? ?? {}),
        limits: SubscriptionLimits.fromJson(
            j['limits'] as Map<String, dynamic>? ?? {}),
        features: (j['features'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        status: j['status']?.toString() ?? 'active',
        displayOrder: j['displayOrder'] as int? ?? 0,
      );
}

class UserSubscription {
  final String id;
  final String userId;
  final String planId; // may be an ID string
  final String planName; // populated from planId object when available
  final String status; // active | expired | cancelled | pending_payment
  final DateTime startDate;
  final DateTime endDate;
  final double? amountPaid;
  final bool autoRenew;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.amountPaid,
    required this.autoRenew,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> j) {
    // planId can be a string or a populated object
    final rawPlanId = j['planId'];
    final String planId;
    final String planName;
    if (rawPlanId is Map<String, dynamic>) {
      planId = rawPlanId['_id']?.toString() ?? rawPlanId['id']?.toString() ?? '';
      planName = rawPlanId['name']?.toString() ?? '';
    } else {
      planId = rawPlanId?.toString() ?? '';
      planName = '';
    }

    return UserSubscription(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      userId: j['userId']?.toString() ?? '',
      planId: planId,
      planName: planName,
      status: j['status']?.toString() ?? 'active',
      startDate: _parseDate(j['startDate']),
      endDate: _parseDate(j['endDate']),
      amountPaid: (j['amountPaid'] as num?)?.toDouble(),
      autoRenew: j['autoRenew'] as bool? ?? false,
    );
  }

  int get daysRemaining {
    final diff = endDate.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inDays;
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());

  bool get expiringSoon => isActive && daysRemaining <= 7;

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}

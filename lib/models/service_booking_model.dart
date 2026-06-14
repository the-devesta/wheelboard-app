/// Service booking (provider side) — mirrors the backend `mapBooking()` shape
/// from `service-management/services.service.ts`.
///
/// IMPORTANT: the backend returns `id` / `serviceName` / `companyName` /
/// `companyPhone` / `pricing.amount`, NOT `assignmentId` / `serviceTitle` /
/// `customerName` / `customerMobile` / `amount`. The previous model read the
/// latter set, so every booking parsed with an EMPTY assignmentId (breaking
/// start/complete/cancel) and default title/customer/₹0. We read the real keys
/// here and keep the old keys as fallbacks for round-tripping via [toJson].
class ServiceBookingModel {
  final String assignmentId;
  final String serviceId;
  final String serviceTitle;
  final String customerName; // the company that booked (provider's customer)
  final String? customerMobile; // company phone
  final String? vehicleNumber;
  final String? description; // notes
  final String status;
  final String scheduledDate;
  final String scheduledTime;
  final dynamic pricingOption;
  final double amount; // pricing.amount
  final double? paymentAmount;
  final String? category;
  final String? assignedToUserId; // companyId

  // ── Workflow / payment fields (from mapBooking) ──────────────────────────
  final String paymentStatus; // Pending | Completed | Paid | ConfirmationPending | Failed | Cancelled | Refunded
  final String paymentMethod; // Online | Cash
  final bool businessCompletionConfirmed;
  final bool companyCompletionConfirmed;
  final bool fullyCompleted;
  final double? providerEarnings;
  final double platformFee;
  final double? amountPaid;
  final String? pricingType; // e.g. 'On Request'
  final String? bookingNo;
  final String? location;

  ServiceBookingModel({
    required this.assignmentId,
    required this.serviceId,
    required this.serviceTitle,
    required this.customerName,
    this.customerMobile,
    this.vehicleNumber,
    this.description,
    required this.status,
    required this.scheduledDate,
    required this.scheduledTime,
    this.pricingOption,
    required this.amount,
    this.paymentAmount,
    this.category,
    this.assignedToUserId,
    this.paymentStatus = 'Pending',
    this.paymentMethod = 'Online',
    this.businessCompletionConfirmed = false,
    this.companyCompletionConfirmed = false,
    this.fullyCompleted = false,
    this.providerEarnings,
    this.platformFee = 0,
    this.amountPaid,
    this.pricingType,
    this.bookingNo,
    this.location,
  });

  static double _toD(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);
  static double? _toDn(dynamic v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
  static bool _toB(dynamic v) =>
      v == true || v == 1 || v == 'true' || v == '1';

  factory ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] is Map
        ? Map<String, dynamic>.from(json['pricing'] as Map)
        : const <String, dynamic>{};

    return ServiceBookingModel(
      assignmentId: (json['id'] ?? json['assignmentId'] ?? '').toString(),
      serviceId: (json['serviceId'] ?? '').toString(),
      serviceTitle:
          (json['serviceName'] ?? json['serviceTitle'] ?? 'Service').toString(),
      customerName:
          (json['companyName'] ?? json['customerName'] ?? 'Customer').toString(),
      customerMobile: (json['companyPhone'] ??
              json['customerMobile'] ??
              json['contactNumber'] ??
              json['mobileNumber'])
          ?.toString(),
      vehicleNumber: json['vehicleNumber']?.toString(),
      description: (json['notes'] ?? json['description'])?.toString(),
      status: (json['status'] ?? 'Pending').toString(),
      scheduledDate: (json['scheduledDate'] ?? '').toString(),
      scheduledTime: (json['scheduledTime'] ?? '').toString(),
      pricingOption: json['pricingOption'] ?? pricing['type'],
      amount: _toD(pricing['amount'] ?? json['amount'] ?? json['paymentAmount']),
      paymentAmount: _toDn(json['paymentAmount'] ?? pricing['amount']),
      category: (json['serviceCategory'] ?? json['category'])?.toString(),
      assignedToUserId:
          (json['companyId'] ?? json['assignedToUserId'])?.toString(),
      paymentStatus: (json['paymentStatus'] ?? 'Pending').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'Online').toString(),
      businessCompletionConfirmed: _toB(json['businessCompletionConfirmed']),
      companyCompletionConfirmed: _toB(json['companyCompletionConfirmed']),
      fullyCompleted: _toB(json['fullyCompleted']),
      providerEarnings: _toDn(json['providerEarnings']),
      platformFee: _toD(json['platformFee']),
      amountPaid: _toDn(json['amountPaid']),
      pricingType: (pricing['type'] ?? json['pricingType'])?.toString(),
      bookingNo: json['bookingNo']?.toString(),
      location: json['location']?.toString(),
    );
  }

  /// Writes both the backend keys and the legacy keys so a value produced here
  /// round-trips cleanly back through [fromJson] (used for optimistic updates).
  Map<String, dynamic> toJson() {
    return {
      'id': assignmentId,
      'assignmentId': assignmentId,
      'serviceId': serviceId,
      'serviceName': serviceTitle,
      'serviceTitle': serviceTitle,
      'companyName': customerName,
      'companyPhone': customerMobile,
      'vehicleNumber': vehicleNumber,
      'notes': description,
      'description': description,
      'status': status,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'pricingOption': pricingOption,
      'amount': amount,
      'pricing': {'amount': amount, 'type': pricingType},
      'paymentAmount': paymentAmount,
      'serviceCategory': category,
      'companyId': assignedToUserId,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'businessCompletionConfirmed': businessCompletionConfirmed,
      'companyCompletionConfirmed': companyCompletionConfirmed,
      'fullyCompleted': fullyCompleted,
      'providerEarnings': providerEarnings,
      'platformFee': platformFee,
      'amountPaid': amountPaid,
      'pricingType': pricingType,
      'bookingNo': bookingNo,
      'location': location,
    };
  }

  /// Cash booking that the provider has marked complete but whose cash receipt
  /// still needs confirming.
  bool get needsCashConfirmation =>
      paymentMethod.toLowerCase() == 'cash' &&
      paymentStatus.toLowerCase() == 'confirmationpending';

  bool get isOnline => paymentMethod.toLowerCase() == 'online';

  bool get isPaid {
    final s = paymentStatus.toLowerCase();
    return s == 'completed' || s == 'paid';
  }
}

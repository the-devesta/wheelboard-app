// Unified fleet models matching wheelboard-fe API response shapes.
// Vehicle and Driver models remain in get_vehicle_model.dart / get_driver_model.dart

// ── Lease Listing ─────────────────────────────────────────────────────────────

class LeaseListing {
  final String id;
  final String vehicleId;
  final String title;
  final String? description;
  final String? terms;
  final int? odometerReading;
  final String pricingType; // 'flat' | 'on_request'
  final String? priceUnit; // 'daily' | 'weekly' | 'monthly'
  final double? priceAmount;
  final double? securityDeposit;
  final String? pickupLocation;
  final bool deliveryAvailable;
  final double? deliveryRadius;
  final double? deliveryFee;
  final String? availableFrom;
  final String? availableUntil;
  final int? minDurationDays;
  final int? maxDurationDays;
  final String status; // 'active' | 'paused' | 'draft' | 'removed'
  final int views;
  final int bookingsCount;
  // Populated vehicle info
  final String? vehicleName;
  final String? vehicleRegistration;
  final int? vehicleYear;
  final String? vehicleCategory;
  final String? vehicleImage;

  const LeaseListing({
    required this.id,
    required this.vehicleId,
    required this.title,
    this.description,
    this.terms,
    this.odometerReading,
    required this.pricingType,
    this.priceUnit,
    this.priceAmount,
    this.securityDeposit,
    this.pickupLocation,
    required this.deliveryAvailable,
    this.deliveryRadius,
    this.deliveryFee,
    this.availableFrom,
    this.availableUntil,
    this.minDurationDays,
    this.maxDurationDays,
    required this.status,
    required this.views,
    required this.bookingsCount,
    this.vehicleName,
    this.vehicleRegistration,
    this.vehicleYear,
    this.vehicleCategory,
    this.vehicleImage,
  });

  factory LeaseListing.fromJson(Map<String, dynamic> j) {
    // vehicleId can be a string or a populated object
    final rawVehicle = j['vehicleId'];
    String vehicleId = '';
    String? vehicleName, vehicleReg, vehicleCategory, vehicleImage;
    int? vehicleYear;
    if (rawVehicle is Map<String, dynamic>) {
      vehicleId = rawVehicle['_id']?.toString() ?? rawVehicle['id']?.toString() ?? '';
      vehicleName = rawVehicle['model']?.toString() ?? rawVehicle['name']?.toString();
      vehicleReg = rawVehicle['registrationNumber']?.toString();
      vehicleYear = (rawVehicle['year'] as num?)?.toInt();
      vehicleCategory = rawVehicle['category']?.toString();
      vehicleImage = rawVehicle['image']?.toString();
    } else {
      vehicleId = rawVehicle?.toString() ?? j['vehicle']?.toString() ?? '';
    }

    return LeaseListing(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      vehicleId: vehicleId,
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString(),
      terms: j['terms']?.toString(),
      odometerReading: (j['odometerReading'] as num?)?.toInt(),
      pricingType: j['pricingType']?.toString() ?? 'flat',
      priceUnit: j['priceUnit']?.toString(),
      priceAmount: (j['priceAmount'] as num?)?.toDouble(),
      securityDeposit: (j['securityDeposit'] as num?)?.toDouble(),
      pickupLocation: j['pickupLocation']?.toString(),
      deliveryAvailable: j['deliveryAvailable'] as bool? ?? false,
      deliveryRadius: (j['deliveryRadius'] as num?)?.toDouble(),
      deliveryFee: (j['deliveryFee'] as num?)?.toDouble(),
      availableFrom: j['availableFrom']?.toString(),
      availableUntil: j['availableUntil']?.toString(),
      minDurationDays: (j['minDurationDays'] as num?)?.toInt(),
      maxDurationDays: (j['maxDurationDays'] as num?)?.toInt(),
      status: j['status']?.toString() ?? 'draft',
      views: (j['views'] as num?)?.toInt() ?? 0,
      bookingsCount: (j['bookingsCount'] as num?)?.toInt() ?? 0,
      vehicleName: vehicleName,
      vehicleRegistration: vehicleReg,
      vehicleYear: vehicleYear,
      vehicleCategory: vehicleCategory,
      vehicleImage: vehicleImage,
    );
  }

  String get formattedPrice {
    if (pricingType == 'on_request') return 'On Request';
    if (priceAmount == null) return '—';
    return '₹${priceAmount!.toStringAsFixed(0)}/${priceUnit ?? 'day'}';
  }

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isDraft => status == 'draft';
}

// ── Lease Booking ─────────────────────────────────────────────────────────────

class LeaseBooking {
  final String id;
  final String listingId;
  final String? lesseeId;
  final String? lessorId;
  final String status; // pending_approval | approved | active | completed | cancelled | rejected
  final String? startDate;
  final String? endDate;
  final int? durationDays;
  final double? totalPrice;
  final double? basePrice;
  final double? deliveryFee;
  final double? securityDeposit;
  final String? requestMessage;
  final String? ownerNote;
  final String? rejectionReason;
  final String? cancellationReason;
  final String? pickupLocation;
  final String? returnLocation;
  final String createdAt;
  // Populated listing info
  final String? listingTitle;
  final String? vehicleImage;
  final String? vehicleName;
  // Populated lessee info
  final String? lesseeName;
  final String? lesseeCompany;

  const LeaseBooking({
    required this.id,
    required this.listingId,
    this.lesseeId,
    this.lessorId,
    required this.status,
    this.startDate,
    this.endDate,
    this.durationDays,
    this.totalPrice,
    this.basePrice,
    this.deliveryFee,
    this.securityDeposit,
    this.requestMessage,
    this.ownerNote,
    this.rejectionReason,
    this.cancellationReason,
    this.pickupLocation,
    this.returnLocation,
    required this.createdAt,
    this.listingTitle,
    this.vehicleImage,
    this.vehicleName,
    this.lesseeName,
    this.lesseeCompany,
  });

  factory LeaseBooking.fromJson(Map<String, dynamic> j) {
    // Extract listing info
    final rawListing = j['listingId'];
    String listingId = '';
    String? listingTitle, vehicleImage, vehicleName;
    if (rawListing is Map<String, dynamic>) {
      listingId = rawListing['_id']?.toString() ?? rawListing['id']?.toString() ?? '';
      listingTitle = rawListing['title']?.toString();
      final rawVehicle = rawListing['vehicleId'];
      if (rawVehicle is Map<String, dynamic>) {
        vehicleImage = rawVehicle['image']?.toString();
        vehicleName = rawVehicle['model']?.toString() ?? rawVehicle['name']?.toString();
      }
    } else {
      listingId = rawListing?.toString() ?? '';
    }

    // Extract lessee info
    final rawLessee = j['lesseeId'];
    String? lesseeId, lesseeName, lesseeCompany;
    if (rawLessee is Map<String, dynamic>) {
      lesseeId = rawLessee['_id']?.toString() ?? rawLessee['id']?.toString();
      final profile = rawLessee['profile'] as Map<String, dynamic>? ?? {};
      lesseeName = profile['fullName']?.toString() ?? profile['companyName']?.toString();
      lesseeCompany = profile['companyName']?.toString();
    } else {
      lesseeId = rawLessee?.toString();
    }

    return LeaseBooking(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      listingId: listingId,
      lesseeId: lesseeId,
      lessorId: j['lessorId']?.toString(),
      status: j['status']?.toString() ?? 'pending_approval',
      startDate: j['startDate']?.toString(),
      endDate: j['endDate']?.toString(),
      durationDays: (j['durationDays'] as num?)?.toInt(),
      totalPrice: (j['totalPrice'] as num?)?.toDouble(),
      basePrice: (j['basePrice'] as num?)?.toDouble(),
      deliveryFee: (j['deliveryFee'] as num?)?.toDouble(),
      securityDeposit: (j['securityDeposit'] as num?)?.toDouble(),
      requestMessage: j['requestMessage']?.toString(),
      ownerNote: j['ownerNote']?.toString(),
      rejectionReason: j['rejectionReason']?.toString(),
      cancellationReason: j['cancellationReason']?.toString(),
      pickupLocation: j['pickupLocation']?.toString(),
      returnLocation: j['returnLocation']?.toString(),
      createdAt: j['createdAt']?.toString() ?? '',
      listingTitle: listingTitle,
      vehicleImage: vehicleImage,
      vehicleName: vehicleName,
      lesseeName: lesseeName,
      lesseeCompany: lesseeCompany,
    );
  }

  bool get isPending => status == 'pending_approval';
  bool get isApproved => status == 'approved';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled =>
      status == 'cancelled' || status == 'rejected' || status == 'terminated';

  String get statusLabel {
    switch (status) {
      case 'pending_approval': return 'Pending';
      case 'approved': return 'Approved';
      case 'active': return 'Active';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'rejected': return 'Rejected';
      default: return status;
    }
  }

  String get formattedDates {
    if (startDate == null || endDate == null) return '—';
    return '${_fmt(startDate!)} → ${_fmt(endDate!)}';
  }

  static String _fmt(String raw) {
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }
}

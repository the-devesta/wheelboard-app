class UnassignedTrip {
  final String tripId;
  final String tripCode;
  final String pickupLocation;
  final String destination;
  final DateTime? pickupDate;
  final String pickupTime;
  final String payRange;
  final String tripStatus;
  final String tripType;

  // Rich fields the web shows on each card (read straight from the API shape).
  final double? distanceKm; // route.plannedDistance / estimatedDistance
  final int? durationSeconds; // route.plannedDuration
  final double? price; // price || financial.driverEarnings
  final int bidsCount; // bids.length
  final List<String> bidderIds; // bids[].bidderId — used to detect "already bid"

  UnassignedTrip({
    required this.tripId,
    required this.tripCode,
    required this.pickupLocation,
    required this.destination,
    required this.pickupDate,
    required this.pickupTime,
    required this.payRange,
    required this.tripStatus,
    required this.tripType,
    this.distanceKm,
    this.durationSeconds,
    this.price,
    this.bidsCount = 0,
    this.bidderIds = const [],
  });

  /// `true` when [userId] has already placed a bid on this trip (web parity:
  /// the card shows "Bid Placed" instead of "Place Bid").
  bool hasBidFrom(String userId) =>
      userId.isNotEmpty && bidderIds.contains(userId);

  factory UnassignedTrip.fromJson(Map<String, dynamic> json) {
    final route = json['route'] as Map<String, dynamic>? ?? {};
    final startLoc = route['startLocation'] as Map<String, dynamic>? ?? {};
    final endLoc = route['endLocation'] as Map<String, dynamic>? ?? {};
    final timeline = json['timeline'] as Map<String, dynamic>? ?? {};
    final bids = json['bids'] as List? ?? [];
    final financial = json['financial'] as Map<String, dynamic>? ?? {};

    final scheduledStart = timeline['scheduledStartTime'] ?? json['pickupDate'] ?? json['PickupDate'];

    return UnassignedTrip(
      tripId: json['tripId']?.toString() ?? '',
      tripCode: json['tripId']?.toString() ?? json['tripCode']?.toString() ?? '',
      // Backend: route.startLocation.address; legacy: pickupLocation
      pickupLocation: startLoc['address']?.toString() ?? json['pickupLocation']?.toString() ?? '',
      // Backend: route.endLocation.address; legacy: destination/deliveryLocation
      destination: endLoc['address']?.toString() ?? json['destination']?.toString() ?? json['deliveryLocation']?.toString() ?? '',
      pickupDate: _parseDate(scheduledStart),
      pickupTime: _formatTime(scheduledStart) ?? json['pickupTime']?.toString() ?? '',
      // Backend: expectedPay; legacy: payRange
      payRange: json['expectedPay']?.toString() ?? json['payRange']?.toString().trim() ?? json['PayRange']?.toString().trim() ?? '',
      // Backend: status; legacy: tripStatus
      tripStatus: json['status']?.toString() ?? json['tripStatus']?.toString() ?? '',
      tripType: json['tripType']?.toString() ?? json['tripType']?.toString() ?? 'created',
      distanceKm: (route['plannedDistance'] as num?)?.toDouble() ??
          (route['estimatedDistance'] as num?)?.toDouble(),
      durationSeconds: (route['plannedDuration'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble() ??
          (financial['driverEarnings'] as num?)?.toDouble(),
      bidsCount: bids.length,
      bidderIds: bids
          .whereType<Map>()
          .map((b) =>
              (b['bidderId'] ?? (b['bidder'] is Map ? b['bidder']['id'] : '') ?? '')
                  .toString())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value == '') return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _formatTime(dynamic value) {
    if (value == null || value == '') return null;
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return null;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class UnassignedTripDetails {
  final String tripId;
  final String tripCode;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime? pickupDate;
  final String pickupTime;
  final String specialInstructions;
  final String payRange;
  final String tripStatus;
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleModel;
  final int? manufacturingYear;
  final String ownershipType;
  final String vehicleTypeName;
  final String? driverId;
  final String driverName;
  final String driverContact;
  final String driverImagePath;
  final String companyName;
  final String companyMobileNo;

  UnassignedTripDetails({
    required this.tripId,
    required this.tripCode,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.specialInstructions,
    required this.payRange,
    required this.tripStatus,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleModel,
    this.manufacturingYear,
    required this.ownershipType,
    required this.vehicleTypeName,
    this.driverId,
    required this.driverName,
    required this.driverContact,
    required this.driverImagePath,
    required this.companyName,
    required this.companyMobileNo,
  });

  factory UnassignedTripDetails.fromJson(Map<String, dynamic> json) {
    final route = json['route'] as Map<String, dynamic>? ?? {};
    final startLoc = route['startLocation'] as Map<String, dynamic>? ?? {};
    final endLoc = route['endLocation'] as Map<String, dynamic>? ?? {};
    final timeline = json['timeline'] as Map<String, dynamic>? ?? {};

    final scheduledStart = timeline['scheduledStartTime'] ?? json['pickupDate'] ?? json['PickupDate'];

    return UnassignedTripDetails(
      tripId: json['tripId']?.toString() ?? '',
      tripCode: json['tripId']?.toString() ?? json['tripCode']?.toString() ?? '',
      pickupLocation: startLoc['address']?.toString() ?? json['pickupLocation']?.toString() ?? '',
      deliveryLocation: endLoc['address']?.toString() ?? json['deliveryLocation']?.toString() ?? '',
      pickupDate: _parseDate(scheduledStart),
      pickupTime: _formatTime(scheduledStart) ?? json['pickupTime']?.toString() ?? '',
      specialInstructions: json['specialInstructions']?.toString() ?? '',
      payRange: json['expectedPay']?.toString() ?? json['payRange']?.toString().trim() ?? json['PayRange']?.toString().trim() ?? '',
      tripStatus: json['status']?.toString() ?? json['tripStatus']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleNumber: json['vehicleNumber']?.toString() ?? '',
      vehicleModel: json['vehicleModel']?.toString() ?? '',
      manufacturingYear: (json['manufacturingYear'] as num?)?.toInt(),
      ownershipType: json['ownershipType']?.toString() ?? '',
      vehicleTypeName: json['vehicleTypeName']?.toString() ?? json['vehicleType']?.toString() ?? '',
      driverId: json['driverId']?.toString(),
      driverName: json['driver_name']?.toString() ?? json['driverName']?.toString() ?? '',
      driverContact: json['driver_phone']?.toString() ?? json['driverContact']?.toString() ?? '',
      driverImagePath: json['driverImagePath']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      companyMobileNo: json['companyMobileNo']?.toString() ?? '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value == '') return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _formatTime(dynamic value) {
    if (value == null || value == '') return null;
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return null;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

import 'dart:convert';

List<AssignedTrip> assignedTripFromJson(String str) => List<AssignedTrip>.from(
  json.decode(str).map((x) => AssignedTrip.fromJson(x)),
);

String assignedTripToJson(List<AssignedTrip> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AssignedTrip {
  final String tripId;
  final String userId;
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleModel;
  final String vehicleType;
  final String driverId;
  final String driverName;
  final String driverContact;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime pickupDate;
  final String pickupTime;
  final String specialInstructions;
  final String payRange;
  final String tripCode;
  final String tripStatus;
  final DateTime createdDate;
  final int totalBidCount;

  // Optional fields from old model for backward compatibility
  final String? bidId;
  final double? bidAmount;
  final String? bidDescription;
  final String? driverImagePath;
  final double? platformFee;
  final double? amountToDriver;
  final double? totalTripCost;
  /// Web-parity earnings fallback: backend `price` (used when there is no
  /// `financial.driverEarnings`). Web card shows `financial.driverEarnings || price`.
  final double? price;
  final String? distance;
  final double? latitude;
  final double? longitude;
  final String? companyName;
  final String? companyMobileNo;
  final String? companyLogoPath;
  final String? companyEmail;
  final String? companyAddress;

  // Fields for calculations (not in API)
  double? calculatedDistance;
  String? estimatedEta;

  AssignedTrip({
    required this.tripId,
    required this.userId,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.vehicleType,
    required this.driverId,
    required this.driverName,
    required this.driverContact,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.specialInstructions,
    required this.payRange,
    required this.tripCode,
    required this.tripStatus,
    required this.createdDate,
    required this.totalBidCount,
    this.bidId,
    this.bidAmount,
    this.bidDescription,
    this.driverImagePath,
    this.platformFee,
    this.amountToDriver,
    this.totalTripCost,
    this.price,
    this.distance,
    this.latitude,
    this.longitude,
    this.companyName,
    this.companyMobileNo,
    this.companyLogoPath,
    this.companyEmail,
    this.companyAddress,
  });

  factory AssignedTrip.fromJson(Map<String, dynamic> json) {
    final route = json['route'] as Map<String, dynamic>? ?? {};
    final startLoc = route['startLocation'] as Map<String, dynamic>? ?? {};
    final endLoc = route['endLocation'] as Map<String, dynamic>? ?? {};
    final timeline = json['timeline'] as Map<String, dynamic>? ?? {};
    final bids = json['bids'] as List? ?? [];
    // The `/trips` list response carries driver earnings inside the nested
    // `financial` object (same source the web card reads), NOT as a top-level
    // `amountToDriver`. Parse it here so per-card earnings render correctly.
    final financial = json['financial'] as Map<String, dynamic>? ?? {};

    final scheduledStart = timeline['scheduledStartTime'] ?? json['pickupDate'];
    final parsedDate = scheduledStart != null
        ? DateTime.tryParse(scheduledStart.toString()) ?? DateTime.now()
        : DateTime.now();

    final endCoords = endLoc['coordinates'] as List?;

    return AssignedTrip(
      tripId: json['tripId']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['fleetOwnerId']?.toString() ?? json['userId']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleNumber: json['vehicleNumber']?.toString() ?? '',
      vehicleModel: json['vehicleModel']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? '',
      driverId: json['driverId']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? json['driverName']?.toString() ?? '',
      driverContact: json['driver_phone']?.toString() ?? json['driverContact']?.toString() ?? '',
      pickupLocation: startLoc['address']?.toString() ?? json['pickupLocation']?.toString() ?? '',
      deliveryLocation: endLoc['address']?.toString() ?? json['deliveryLocation']?.toString() ?? '',
      pickupDate: parsedDate,
      pickupTime: _formatTime(scheduledStart) ?? json['pickupTime']?.toString() ?? '',
      specialInstructions: json['specialInstructions']?.toString() ?? '',
      payRange: json['expectedPay']?.toString() ?? json['payRange']?.toString() ?? '',
      tripCode: json['tripId']?.toString() ?? json['tripCode']?.toString() ?? '',
      tripStatus: json['status']?.toString() ?? json['tripStatus']?.toString() ?? '',
      createdDate: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      totalBidCount: bids.isNotEmpty ? bids.length : (json['totalBidCount'] as num?)?.toInt() ?? 0,
      bidId: json['bidId']?.toString(),
      bidAmount: (json['bidAmount'] as num?)?.toDouble(),
      bidDescription: json['bidDescription']?.toString() ?? json['notes']?.toString(),
      driverImagePath: json['driverImagePath']?.toString() ?? json['driverPhoto']?.toString(),
      platformFee: (json['platformFee'] as num?)?.toDouble(),
      amountToDriver: (json['amountToDriver'] as num?)?.toDouble() ??
          (financial['driverEarnings'] as num?)?.toDouble(),
      totalTripCost: (json['totalTripCost'] as num?)?.toDouble() ??
          (financial['tripCost'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      distance: route['plannedDistance']?.toString() ?? json['distance']?.toString(),
      // endLocation coordinates are [lng, lat] in GeoJSON
      latitude: endCoords != null && endCoords.length >= 2 ? (endCoords[1] as num).toDouble() : (json['latitude'] as num?)?.toDouble(),
      longitude: endCoords != null && endCoords.length >= 2 ? (endCoords[0] as num).toDouble() : (json['longitude'] as num?)?.toDouble(),
      companyName: json['companyName']?.toString() ?? json['company_name']?.toString(),
      companyMobileNo: json['companyMobileNo']?.toString() ?? json['companyContact']?.toString(),
      companyLogoPath: json['companyLogoPath']?.toString() ?? json['companyLogo']?.toString(),
      companyEmail: json['companyEmail']?.toString(),
      companyAddress: json['companyAddress']?.toString(),
    );
  }

  static String? _formatTime(dynamic value) {
    if (value == null) return null;
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return null;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    "tripId": tripId,
    "userId": userId,
    "vehicleId": vehicleId,
    "vehicleNumber": vehicleNumber,
    "vehicleModel": vehicleModel,
    "vehicleType": vehicleType,
    "driverId": driverId,
    "driverName": driverName,
    "driverContact": driverContact,
    "pickupLocation": pickupLocation,
    "deliveryLocation": deliveryLocation,
    "pickupDate": pickupDate.toIso8601String(),
    "pickupTime": pickupTime,
    "specialInstructions": specialInstructions,
    "payRange": payRange,
    "tripCode": tripCode,
    "tripStatus": tripStatus,
    "createdDate": createdDate.toIso8601String(),
    "totalBidCount": totalBidCount,
    // Optional fields
    if (bidId != null) "bidId": bidId,
    if (bidAmount != null) "bidAmount": bidAmount,
    if (bidDescription != null) "bidDescription": bidDescription,
    if (driverImagePath != null) "driverImagePath": driverImagePath,
    if (platformFee != null) "platformFee": platformFee,
    if (amountToDriver != null) "amountToDriver": amountToDriver,
    if (totalTripCost != null) "totalTripCost": totalTripCost,
    if (price != null) "price": price,
    if (distance != null) "distance": distance,
    if (latitude != null) "latitude": latitude,
    if (longitude != null) "longitude": longitude,
    if (companyName != null) "companyName": companyName,
    if (companyMobileNo != null) "companyMobileNo": companyMobileNo,
    if (companyLogoPath != null) "companyLogoPath": companyLogoPath,
    if (companyEmail != null) "companyEmail": companyEmail,
    if (companyAddress != null) "companyAddress": companyAddress,
  };

  AssignedTrip copyWith({
    String? tripId,
    String? userId,
    String? vehicleId,
    String? vehicleNumber,
    String? vehicleModel,
    String? vehicleType,
    String? driverId,
    String? driverName,
    String? driverContact,
    String? pickupLocation,
    String? deliveryLocation,
    DateTime? pickupDate,
    String? pickupTime,
    String? specialInstructions,
    String? payRange,
    String? tripCode,
    String? tripStatus,
    DateTime? createdDate,
    int? totalBidCount,
    String? bidId,
    double? bidAmount,
    String? bidDescription,
    String? driverPhoto,
    double? platformFee,
    double? amountToDriver,
    double? totalTripCost,
    double? price,
    String? distance,
    double? latitude,
    double? longitude,
    String? companyName,
    String? companyMobileNo,
    String? companyLogoPath,
    String? companyEmail,
    String? companyAddress,
  }) {
    return AssignedTrip(
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleType: vehicleType ?? this.vehicleType,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverContact: driverContact ?? this.driverContact,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      payRange: payRange ?? this.payRange,
      tripCode: tripCode ?? this.tripCode,
      tripStatus: tripStatus ?? this.tripStatus,
      createdDate: createdDate ?? this.createdDate,
      totalBidCount: totalBidCount ?? this.totalBidCount,
      bidId: bidId ?? this.bidId,
      bidAmount: bidAmount ?? this.bidAmount,
      bidDescription: bidDescription ?? this.bidDescription,
      driverImagePath: driverImagePath ?? driverImagePath,
      platformFee: platformFee ?? this.platformFee,
      amountToDriver: amountToDriver ?? this.amountToDriver,
      totalTripCost: totalTripCost ?? this.totalTripCost,
      price: price ?? this.price,
      distance: distance ?? this.distance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      companyName: companyName ?? this.companyName,
      companyMobileNo: companyMobileNo ?? this.companyMobileNo,
      companyLogoPath: companyLogoPath ?? this.companyLogoPath,
      companyEmail: companyEmail ?? this.companyEmail,
      companyAddress: companyAddress ?? this.companyAddress,
    );
  }
}

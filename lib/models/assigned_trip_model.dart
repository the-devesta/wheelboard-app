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
    this.distance,
    this.latitude,
    this.longitude,
    this.companyName,
    this.companyMobileNo,
    this.companyLogoPath,
    this.companyEmail,
    this.companyAddress,
  });

  factory AssignedTrip.fromJson(Map<String, dynamic> json) => AssignedTrip(
    tripId: json["tripId"] ?? "",
    userId: json["userId"] ?? "",
    vehicleId: json["vehicleId"] ?? "",
    vehicleNumber: json["vehicleNumber"] ?? "",
    vehicleModel: json["vehicleModel"] ?? "",
    vehicleType: json["vehicleType"] ?? "",
    driverId: json["driverId"] ?? "",
    driverName: json["driverName"] ?? "",
    driverContact: json["driverContact"] ?? "",
    pickupLocation: json["pickupLocation"] ?? "",
    deliveryLocation: json["deliveryLocation"] ?? "",
    pickupDate: json["pickupDate"] != null
        ? DateTime.parse(json["pickupDate"])
        : DateTime.now(),
    pickupTime: json["pickupTime"] ?? "",
    specialInstructions: json["specialInstructions"] ?? "",
    payRange: json["payRange"] ?? "",
    tripCode: json["tripCode"] ?? "",
    tripStatus: json["tripStatus"] ?? "",
    createdDate: json["createdDate"] != null
        ? DateTime.parse(json["createdDate"])
        : DateTime.now(),
    totalBidCount: json["totalBidCount"] ?? 0,
    // Optional fields
    bidId: json["bidId"],
    bidAmount: json["bidAmount"]?.toDouble(),
    bidDescription: json["bidDescription"],
    driverImagePath: json["driverImagePath"] ?? json["driverPhoto"],
    platformFee: json["platformFee"]?.toDouble(),
    amountToDriver: json["amountToDriver"]?.toDouble(),
    totalTripCost: json["totalTripCost"]?.toDouble(),
    distance: json["distance"]?.toString(),
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    companyName:
        json["companyName"] ?? json["CompanyName"] ?? json["company_name"],
    companyMobileNo:
        json["companyMobileNo"] ??
        json["CompanyMobileNo"] ??
        json["company_mobile_no"] ??
        json["companyContact"] ??
        json["company_contact"],
    companyLogoPath:
        json["companyLogoPath"] ??
        json["CompanyLogoPath"] ??
        json["company_logo_path"] ??
        json["companyLogo"] ??
        json["company_logo"],
    companyEmail:
        json["companyEmail"] ?? json["CompanyEmail"] ?? json["company_email"],
    companyAddress:
        json["companyAddress"] ??
        json["CompanyAddress"] ??
        json["company_address"],
  );

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

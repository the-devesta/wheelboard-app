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
  final String? driverPhoto;
  final double? platformFee;
  final double? amountToDriver;
  final double? totalTripCost;

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
    this.driverPhoto,
    this.platformFee,
    this.amountToDriver,
    this.totalTripCost,
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
    driverPhoto: json["driverPhoto"],
    platformFee: json["platformFee"]?.toDouble(),
    amountToDriver: json["amountToDriver"]?.toDouble(),
    totalTripCost: json["totalTripCost"]?.toDouble(),
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
    if (driverPhoto != null) "driverPhoto": driverPhoto,
    if (platformFee != null) "platformFee": platformFee,
    if (amountToDriver != null) "amountToDriver": amountToDriver,
    if (totalTripCost != null) "totalTripCost": totalTripCost,
  };
}

import 'dart:convert';

List<AssignedTrip> assignedTripFromJson(String str) =>
    List<AssignedTrip>.from(json.decode(str).map((x) => AssignedTrip.fromJson(x)));

String assignedTripToJson(List<AssignedTrip> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AssignedTrip {
  final String bidId;
  final double bidAmount;
  final String bidDescription;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime pickupDate;
  final String pickupTime;
  final String specialInstructions;
  final String driverName;
  final String driverPhoto;
  final double platformFee;
  final double amountToDriver;
  final double totalTripCost;

  AssignedTrip({
    required this.bidId,
    required this.bidAmount,
    required this.bidDescription,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.specialInstructions,
    required this.driverName,
    required this.driverPhoto,
    required this.platformFee,
    required this.amountToDriver,
    required this.totalTripCost,
  });

  factory AssignedTrip.fromJson(Map<String, dynamic> json) => AssignedTrip(
        bidId: json["bidId"],
        bidAmount: json["bidAmount"]?.toDouble(),
        bidDescription: json["bidDescription"],
        pickupLocation: json["pickupLocation"],
        deliveryLocation: json["deliveryLocation"],
        pickupDate: DateTime.parse(json["pickupDate"]),
        pickupTime: json["pickupTime"],
        specialInstructions: json["specialInstructions"],
        driverName: json["driverName"],
        driverPhoto: json["driverPhoto"],
        platformFee: json["platformFee"]?.toDouble(),
        amountToDriver: json["amountToDriver"]?.toDouble(),
        totalTripCost: json["totalTripCost"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "bidId": bidId,
        "bidAmount": bidAmount,
        "bidDescription": bidDescription,
        "pickupLocation": pickupLocation,
        "deliveryLocation": deliveryLocation,
        "pickupDate": pickupDate.toIso8601String(),
        "pickupTime": pickupTime,
        "specialInstructions": specialInstructions,
        "driverName": driverName,
        "driverPhoto": driverPhoto,
        "platformFee": platformFee,
        "amountToDriver": amountToDriver,
        "totalTripCost": totalTripCost,
      };
}

class Trip {
  final String tripId;
  final String userId;
  final String vehicleId;
  final String driverId;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime? pickupDate;
  final String pickupTime;
  final String specialInstructions;
  final String payRange;
  final String tripCode;
  final String tripStatus;

  Trip({
    required this.tripId,
    required this.userId,
    required this.vehicleId,
    required this.driverId,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.specialInstructions,
    required this.payRange,
    required this.tripCode,
    required this.tripStatus,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['TripId'] ?? '',
      userId: json['UserId'] ?? '',
      vehicleId: json['VehicleId'] ?? '',
      driverId: json['DriverId'] ?? '',
      pickupLocation: json['PickupLocation'] ?? '',
      deliveryLocation: json['DeliveryLocation'] ?? '',
      pickupDate: json['PickupDate'] != null && json['PickupDate'] != ""
          ? DateTime.tryParse(json['PickupDate'])
          : null,
      pickupTime: json['PickupTime'] ?? '',
      specialInstructions: json['SpecialInstructions'] ?? '',
      payRange: json['PayRange'] ?? '',
      tripCode: json['TripCode'] ?? '',
      tripStatus: json['TripStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "TripId": tripId,
      "UserId": userId,
      "VehicleId": vehicleId,
      "DriverId": driverId,
      "PickupLocation": pickupLocation,
      "DeliveryLocation": deliveryLocation,
      "PickupDate": pickupDate?.toIso8601String() ?? "",
      "PickupTime": pickupTime,
      "SpecialInstructions": specialInstructions,
      "PayRange": payRange,
      "TripCode": tripCode,
      "TripStatus": tripStatus,
    };
  }
}

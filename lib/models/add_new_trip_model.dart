class Trip {
  final String tripId;
  final String userId;
  final String vehicleId;
  final String? vehicleNumber;
  final String? vehicleModel;
  final String? vehicleType;
  final String driverId;
  final String? driverName;
  final String? driverContact;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime? pickupDate;
  final String pickupTime;
  final String specialInstructions;
  final String payRange;
  final String tripCode;
  final String tripStatus;
  final DateTime? createdDate;
  final int totalBidCount;
  final bool
  isScheduledTrip; // Flag to identify if this is a scheduled trip with driver
  final double? latitude;
  final double? longitude;
  final String? distance;

  Trip({
    required this.tripId,
    required this.userId,
    required this.vehicleId,
    this.vehicleNumber,
    this.vehicleModel,
    this.vehicleType,
    required this.driverId,
    this.driverName,
    this.driverContact,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.specialInstructions,
    required this.payRange,
    required this.tripCode,
    required this.tripStatus,
    this.createdDate,
    this.totalBidCount = 0,
    this.isScheduledTrip = false, // Default is false (post trip)
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['tripId'] ?? json['TripId'] ?? '',
      userId: json['userId'] ?? json['UserId'] ?? '',
      vehicleId: json['vehicleId'] ?? json['VehicleId'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? json['VehicleNumber'],
      vehicleModel: json['vehicleModel'] ?? json['VehicleModel'],
      vehicleType: json['vehicleType'] ?? json['VehicleType'],
      driverId: json['driverId'] ?? json['DriverId'] ?? '',
      driverName: json['driverName'] ?? json['DriverName'],
      driverContact: json['driverContact'] ?? json['DriverContact'],
      pickupLocation: json['pickupLocation'] ?? json['PickupLocation'] ?? '',
      deliveryLocation:
          json['deliveryLocation'] ?? json['DeliveryLocation'] ?? '',
      pickupDate:
          (json['pickupDate'] ?? json['PickupDate']) != null &&
              (json['pickupDate'] ?? json['PickupDate']) != ""
          ? DateTime.tryParse(json['pickupDate'] ?? json['PickupDate'])
          : null,
      pickupTime: json['pickupTime'] ?? json['PickupTime'] ?? '',
      specialInstructions:
          json['specialInstructions'] ?? json['SpecialInstructions'] ?? '',
      payRange: json['payRange'] ?? json['PayRange'] ?? '',
      tripCode: json['tripCode'] ?? json['TripCode'] ?? '',
      tripStatus: json['tripStatus'] ?? json['TripStatus'] ?? '',
      createdDate: (json['createdDate'] ?? json['CreatedDate']) != null
          ? DateTime.tryParse(json['createdDate'] ?? json['CreatedDate'])
          : null,
      totalBidCount:
          (json['totalBidCount'] ?? json['TotalBidCount'] ?? 0) is int
          ? (json['totalBidCount'] ?? json['TotalBidCount'] ?? 0) as int
          : int.tryParse(
                  (json['totalBidCount'] ?? json['TotalBidCount'] ?? 0)
                      .toString(),
                ) ??
                0,
      latitude: (json['latitude'] ?? json['Latitude'])?.toDouble(),
      longitude: (json['longitude'] ?? json['Longitude'])?.toDouble(),
      distance: json['distance'] ?? json['Distance'],
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
      "Latitude": latitude ?? 0,
      "Longitude": longitude ?? 0,
      "Distance": distance ?? "",
    };
  }
}

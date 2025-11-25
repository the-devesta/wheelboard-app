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
  });

  factory UnassignedTrip.fromJson(Map<String, dynamic> json) {
    return UnassignedTrip(
      tripId: json['tripId'] ?? '',
      tripCode: json['tripCode'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      destination: json['destination'] ?? '',
      pickupDate: json['pickupDate'] != null && json['pickupDate'] != ""
          ? DateTime.tryParse(json['pickupDate'])
          : null,
      pickupTime: json['pickupTime'] ?? '',
      payRange: json['payRange']?.toString().trim() ?? json['PayRange']?.toString().trim() ?? '',
      tripStatus: json['tripStatus'] ?? '',
      tripType: json['tripType'] ?? '',
    );
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
  });

  factory UnassignedTripDetails.fromJson(Map<String, dynamic> json) {
    return UnassignedTripDetails(
      tripId: json['tripId'] ?? '',
      tripCode: json['tripCode'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      deliveryLocation: json['deliveryLocation'] ?? '',
      pickupDate: json['pickupDate'] != null && json['pickupDate'] != ""
          ? DateTime.tryParse(json['pickupDate'])
          : null,
      pickupTime: json['pickupTime'] ?? '',
      specialInstructions: json['specialInstructions'] ?? '',
      payRange: json['payRange']?.toString().trim() ?? json['PayRange']?.toString().trim() ?? '',
      tripStatus: json['tripStatus'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      manufacturingYear: json['manufacturingYear'],
      ownershipType: json['ownershipType'] ?? '',
      vehicleTypeName: json['vehicleTypeName'] ?? '',
      driverId: json['driverId'],
      driverName: json['driverName'] ?? '',
      driverContact: json['driverContact'] ?? '',
      driverImagePath: json['driverImagePath'] ?? '',
    );
  }
}


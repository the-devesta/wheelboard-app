class Trip {
  /// MongoDB document id (`_id`). Backend lookups for share-navigation,
  /// trip detail, assign, etc. use this — NOT the human-readable [tripId].
  final String id;
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
  final String? driverImagePath;
  final String deliveryLocation;
  final DateTime? pickupDate;
  final String pickupTime;
  final String specialInstructions;
  final String payRange;
  final String tripCode;
  final String tripStatus;
  final DateTime? createdDate;
  final int totalBidCount;
  final bool isScheduledTrip;
  final double? pickupLat;
  final double? pickupLng;
  final double? latitude;
  final double? longitude;
  final String? distance;

  Trip({
    this.id = '',
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
    this.driverImagePath,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.specialInstructions,
    required this.payRange,
    required this.tripCode,
    required this.tripStatus,
    this.createdDate,
    this.totalBidCount = 0,
    this.isScheduledTrip = false,
    this.pickupLat,
    this.pickupLng,
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // Backend returns nested route and timeline objects
    final route = json['route'] as Map<String, dynamic>? ?? {};
    final startLoc = route['startLocation'] as Map<String, dynamic>? ?? {};
    final endLoc = route['endLocation'] as Map<String, dynamic>? ?? {};
    final timeline = json['timeline'] as Map<String, dynamic>? ?? {};
    final bids = json['bids'] as List? ?? [];

    // Pickup location: route.startLocation.address or legacy flat field
    final pickupLocation = startLoc['address']?.toString()
        ?? json['pickupLocation']?.toString()
        ?? json['PickupLocation']?.toString()
        ?? '';

    // Delivery location: route.endLocation.address or legacy flat field
    final deliveryLocation = endLoc['address']?.toString()
        ?? json['deliveryLocation']?.toString()
        ?? json['DeliveryLocation']?.toString()
        ?? '';

    // Scheduled time from timeline or legacy flat field
    final scheduledStart = timeline['scheduledStartTime']
        ?? json['pickupDate']
        ?? json['PickupDate'];

    final parsedDate = _parseDate(scheduledStart);

    // Pay range from expectedPay (new) or payRange (legacy)
    final payRange = json['expectedPay']?.toString()
        ?? json['payRange']?.toString()
        ?? json['PayRange']?.toString()
        ?? '';

    return Trip(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['TripId']?.toString() ?? '',
      // Backend returns 'fleetOwnerId'; legacy returned 'userId'
      userId: json['fleetOwnerId']?.toString() ?? json['userId']?.toString() ?? json['UserId']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? json['VehicleId']?.toString() ?? '',
      vehicleNumber: json['vehicleNumber']?.toString() ?? json['VehicleNumber']?.toString(),
      vehicleModel: json['vehicleModel']?.toString() ?? json['VehicleModel']?.toString(),
      vehicleType: json['vehicleType']?.toString() ?? json['VehicleType']?.toString(),
      driverId: json['driverId']?.toString() ?? json['DriverId']?.toString() ?? '',
      // Backend returns 'driver_name'; legacy returned 'driverName'
      driverName: json['driver_name']?.toString() ?? json['driverName']?.toString() ?? json['DriverName']?.toString(),
      // Backend returns 'driver_phone'; legacy returned 'driverContact'
      driverContact: json['driver_phone']?.toString() ?? json['driverContact']?.toString() ?? json['DriverContact']?.toString(),
      pickupLocation: pickupLocation,
      driverImagePath: json['driverImagePath']?.toString() ?? json['DriverImagePath']?.toString(),
      deliveryLocation: deliveryLocation,
      pickupDate: parsedDate,
      pickupTime: _formatTime(scheduledStart) ?? json['pickupTime']?.toString() ?? json['PickupTime']?.toString() ?? '',
      specialInstructions: json['specialInstructions']?.toString() ?? json['SpecialInstructions']?.toString() ?? '',
      payRange: payRange,
      // tripCode is same as tripId in new format
      tripCode: json['tripId']?.toString() ?? json['tripCode']?.toString() ?? json['TripCode']?.toString() ?? '',
      // Backend returns 'status'; legacy returned 'tripStatus'
      tripStatus: json['status']?.toString() ?? json['tripStatus']?.toString() ?? json['TripStatus']?.toString() ?? '',
      createdDate: _parseDate(json['createdAt'] ?? json['createdDate'] ?? json['CreatedDate']),
      // Count bids from the bids array
      totalBidCount: bids.isNotEmpty
          ? bids.length
          : ((json['totalBidCount'] ?? json['TotalBidCount'] ?? 0) is int
              ? json['totalBidCount'] ?? json['TotalBidCount'] ?? 0
              : int.tryParse((json['totalBidCount'] ?? json['TotalBidCount'] ?? 0).toString()) ?? 0),
      isScheduledTrip: json['tripType']?.toString() == 'scheduled' || json['isScheduledTrip'] == true,
      latitude: (json['latitude'] ?? json['Latitude'])?.toDouble(),
      longitude: (json['longitude'] ?? json['Longitude'])?.toDouble(),
      distance: route['plannedDistance']?.toString() ?? json['distance']?.toString() ?? json['Distance']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value == '') return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static String? _formatTime(dynamic value) {
    if (value == null || value == '') return null;
    final dt = value is DateTime ? value : DateTime.tryParse(value.toString());
    if (dt == null) return null;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

}

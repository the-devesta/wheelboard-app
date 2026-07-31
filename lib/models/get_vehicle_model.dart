class VehicleGpsLastKnown {
  final String providerCode;
  final String providerName;
  final String deviceId;
  final String providerDeviceId;
  final double? latitude;
  final double? longitude;
  final double? speedKph;
  final bool? ignition;
  final String? lastSeenAt;
  final String? syncedAt;
  final bool stale;

  const VehicleGpsLastKnown({
    required this.providerCode,
    required this.providerName,
    required this.deviceId,
    required this.providerDeviceId,
    this.latitude,
    this.longitude,
    this.speedKph,
    this.ignition,
    this.lastSeenAt,
    this.syncedAt,
    required this.stale,
  });

  factory VehicleGpsLastKnown.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');

    return VehicleGpsLastKnown(
      providerCode: json['providerCode']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      deviceId: json['deviceId']?.toString() ?? '',
      providerDeviceId: json['providerDeviceId']?.toString() ?? '',
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      speedKph: asDouble(json['speedKph']),
      ignition: json['ignition'] is bool ? json['ignition'] as bool : null,
      lastSeenAt: json['lastSeenAt']?.toString(),
      syncedAt: json['syncedAt']?.toString(),
      stale: json['stale'] == true,
    );
  }
}

class VehicleGpsPoint {
  final String telemetryId;
  final String vehicleId;
  final String connectionId;
  final String providerDeviceId;
  final double latitude;
  final double longitude;
  final double? speedKph;
  final double? heading;
  final bool? ignition;
  final double? fuelLevel;
  final double? odometer;
  final String recordedAt;
  final String? receivedAt;

  const VehicleGpsPoint({
    required this.telemetryId,
    required this.vehicleId,
    required this.connectionId,
    required this.providerDeviceId,
    required this.latitude,
    required this.longitude,
    this.speedKph,
    this.heading,
    this.ignition,
    this.fuelLevel,
    this.odometer,
    required this.recordedAt,
    this.receivedAt,
  });

  factory VehicleGpsPoint.fromJson(Map<String, dynamic> json) {
    double asRequiredDouble(dynamic value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    double? asDouble(dynamic value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');

    return VehicleGpsPoint(
      telemetryId: json['telemetryId']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      connectionId: json['connectionId']?.toString() ?? '',
      providerDeviceId: json['providerDeviceId']?.toString() ?? '',
      latitude: asRequiredDouble(json['latitude']),
      longitude: asRequiredDouble(json['longitude']),
      speedKph: asDouble(json['speedKph']),
      heading: asDouble(json['heading']),
      ignition: json['ignition'] is bool ? json['ignition'] as bool : null,
      fuelLevel: asDouble(json['fuelLevel']),
      odometer: asDouble(json['odometer']),
      recordedAt: json['recordedAt']?.toString() ?? '',
      receivedAt: json['receivedAt']?.toString(),
    );
  }

  String get stableKey => telemetryId.isNotEmpty
      ? telemetryId
      : '$providerDeviceId:$recordedAt:$latitude:$longitude';
}

class Vehicle {
  final String vehicleId;
  final String userId;
  final String vehicleName;
  final String vehicleModel;
  final String vehicleNumber;
  final int manufacturingYear;
  final String ownershipType;
  final String vehicleType;
  final String categoryDetail;
  final String fuelType;
  final String capacity;
  final String mileage;
  final String description;
  final bool isDeclarationAccepted;
  final String status;
  final List<String> imageUrls;
  final double avgRun;
  final double tripEfficiency;
  final double monthlyUsage;
  final VehicleGpsLastKnown? gpsLastKnown;

  Vehicle({
    required this.vehicleId,
    required this.userId,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.manufacturingYear,
    required this.ownershipType,
    required this.vehicleType,
    required this.description,
    required this.isDeclarationAccepted,
    required this.status,
    required this.imageUrls,
    this.vehicleName = '',
    this.categoryDetail = '',
    this.fuelType = 'Diesel',
    this.capacity = '',
    this.mileage = '',
    this.avgRun = 0,
    this.tripEfficiency = 0,
    this.monthlyUsage = 0,
    this.gpsLastKnown,
  });

  /// Read a numeric field that may arrive as a number OR a string.
  ///
  /// Several vehicle fields are stored inside a free-form JSON blob written by
  /// the client, so their runtime type is not guaranteed. A hard `as num?` cast
  /// throws on a mismatch, and because rows are mapped in one pass, a single
  /// odd row used to abort the whole list — turning a real fleet into "0
  /// vehicles". Returning null instead lets that one field fall back while the
  /// rest of the vehicle, and every other vehicle, still loads.
  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Backend returns a primary 'image' (single string) plus an 'images' array
    // (see mapVehicle in fleet.service.ts). Collect both, de-duplicated, with
    // the primary image first. ('imageUrls' kept as a legacy fallback key.)
    final images = <String>[];
    final singleImage = json['image']?.toString() ?? '';
    if (singleImage.isNotEmpty) images.add(singleImage);
    final rawImages = json['images'] ?? json['imageUrls'];
    if (rawImages is List) {
      for (final img in rawImages) {
        final s = img?.toString() ?? '';
        if (s.isNotEmpty && !images.contains(s)) images.add(s);
      }
    }

    final metrics = json['metrics'];
    final metricsMap = metrics is Map ? metrics : const {};
    final gpsRaw = json['gpsLastKnown'];
    final gps = gpsRaw is Map
        ? VehicleGpsLastKnown.fromJson(Map<String, dynamic>.from(gpsRaw))
        : null;

    return Vehicle(
      // Backend returns 'id'; legacy returned 'vehicleId'
      vehicleId: json['id']?.toString() ?? json['vehicleId']?.toString() ?? '',
      // Backend returns 'companyId'; legacy returned 'userId'
      userId: json['companyId']?.toString() ?? json['userId']?.toString() ?? '',
      // Backend returns separate 'name' and 'model' fields.
      vehicleName: json['name']?.toString() ?? '',
      // Backend returns 'model' or 'name'; legacy returned 'vehicleModel'
      vehicleModel: json['model']?.toString() ?? json['name']?.toString() ?? json['vehicleModel']?.toString() ?? '',
      // Backend returns 'registrationNumber'; legacy returned 'vehicleNumber'
      vehicleNumber: json['registrationNumber']?.toString() ?? json['vehicleNumber']?.toString() ?? '',
      // Backend returns 'year'; legacy returned 'manufacturingYear'
      // Parsed tolerantly, not cast. `year` is read from a free-form JSON blob
      // on the backend, so it can legitimately arrive as "2019" rather than
      // 2019 — and a hard `as num?` cast on one row used to throw, which
      // aborted the whole list mapping and emptied the entire fleet.
      manufacturingYear:
          _asInt(json['year']) ?? _asInt(json['manufacturingYear']) ?? 0,
      // Backend returns 'ownership'; legacy returned 'ownershipType'
      ownershipType: json['ownership']?.toString() ?? json['ownershipType']?.toString() ?? '',
      // Backend returns 'category'; legacy returned 'vehicleType'
      vehicleType: json['category']?.toString() ?? json['vehicleType']?.toString() ?? '',
      categoryDetail: json['categoryDetail']?.toString() ?? '',
      fuelType: json['fuelType']?.toString() ?? 'Diesel',
      capacity: json['capacity']?.toString() ?? '',
      mileage: json['mileage']?.toString() ?? '',
      // 'location' is the "Current Location / Description" field the
      // modal actually submits; 'description' is kept as a fallback for
      // any pre-existing records that only have the legacy field.
      description: json['location']?.toString() ?? json['description']?.toString() ?? '',
      isDeclarationAccepted: json['isDeclarationAccepted'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      imageUrls: images,
      avgRun: _asDouble(metricsMap['avgRun']) ?? 0,
      tripEfficiency: _asDouble(metricsMap['tripEfficiency']) ?? 0,
      monthlyUsage: _asDouble(metricsMap['monthlyUsage']) ?? 0,
      gpsLastKnown: gps,
    );
  }
}

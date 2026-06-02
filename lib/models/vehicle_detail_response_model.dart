// Backend GET /fleet/vehicles/:id returns a flat vehicle object via mapVehicle():
// { id, companyId, name, model, year, registrationNumber, status, fuelType,
//   capacity, mileage, lastService, location, image, statusBadge, ownership,
//   onTrip, assignedDriver, metrics:{avgRun,tripEfficiency,monthlyUsage},
//   recentTrips:[], totalTrips, manufacturer, isLeased, lease, category,
//   categoryDetail, leaseListingId, currentBookingId, leaseStatus, createdAt }

class VehicleDetailResponseModel {
  final String vehicleId;
  final String companyId;
  final String name;
  final String model;
  final int year;
  final String registrationNumber;
  final String status;
  final String statusBadge;
  final String ownership;
  final String? fuelType;
  final num? capacity;
  final num? mileage;
  final String? lastService;
  final String? location;
  final String image;
  final bool onTrip;
  final Map<String, dynamic>? assignedDriver;
  final VehicleMetrics metrics;
  final List<RecentTrip> recentTrips;
  final int totalTrips;
  final String? manufacturer;
  final bool isLeased;
  final String? category;
  final DateTime? createdAt;

  VehicleDetailResponseModel({
    required this.vehicleId,
    required this.companyId,
    required this.name,
    required this.model,
    required this.year,
    required this.registrationNumber,
    required this.status,
    required this.statusBadge,
    required this.ownership,
    this.fuelType,
    this.capacity,
    this.mileage,
    this.lastService,
    this.location,
    required this.image,
    required this.onTrip,
    this.assignedDriver,
    required this.metrics,
    required this.recentTrips,
    required this.totalTrips,
    this.manufacturer,
    required this.isLeased,
    this.category,
    this.createdAt,
  });

  factory VehicleDetailResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle both old wrapper format and new flat format
    final data = json.containsKey('data') ? (json['data'] as Map<String, dynamic>? ?? json) : json;

    final metricsRaw = data['metrics'] as Map<String, dynamic>? ?? {};
    final recentTripsRaw = data['recentTrips'] as List<dynamic>? ?? [];

    return VehicleDetailResponseModel(
      vehicleId: data['id']?.toString() ?? data['vehicleId']?.toString() ?? '',
      companyId: data['companyId']?.toString() ?? data['userId']?.toString() ?? '',
      name: data['name']?.toString() ?? data['model']?.toString() ?? '',
      model: data['model']?.toString() ?? data['name']?.toString() ?? data['vehicleModel']?.toString() ?? '',
      year: (data['year'] as num?)?.toInt() ?? (data['manufacturingYear'] as num?)?.toInt() ?? 0,
      registrationNumber: data['registrationNumber']?.toString() ?? data['vehicleNumber']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      statusBadge: data['statusBadge']?.toString() ?? data['status']?.toString() ?? '',
      ownership: data['ownership']?.toString() ?? data['ownershipType']?.toString() ?? '',
      fuelType: data['fuelType']?.toString(),
      capacity: data['capacity'] as num?,
      mileage: data['mileage'] as num?,
      lastService: data['lastService']?.toString(),
      location: data['location']?.toString(),
      image: data['image']?.toString() ?? '',
      onTrip: data['onTrip'] as bool? ?? false,
      assignedDriver: data['assignedDriver'] as Map<String, dynamic>?,
      metrics: VehicleMetrics.fromJson(metricsRaw),
      recentTrips: recentTripsRaw
          .map((e) => RecentTrip.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalTrips: (data['totalTrips'] as num?)?.toInt() ?? 0,
      manufacturer: data['manufacturer']?.toString(),
      isLeased: data['isLeased'] as bool? ?? false,
      category: data['category']?.toString() ?? data['vehicleType']?.toString(),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  // Compatibility accessor — used by old screens expecting VehicleInfo
  VehicleInfo get vehicleInfo => VehicleInfo(
        vehicleId: vehicleId,
        vehicleModel: model,
        vehicleNumber: registrationNumber,
        manufacturingYear: year,
        status: status,
        ownershipType: ownership,
      );

  // Compatibility .data accessor — used by vehicle_detail_screen.dart
  VehicleDetailCompat get data => VehicleDetailCompat(this);
}

class VehicleDetailCompat {
  final VehicleDetailResponseModel _m;
  const VehicleDetailCompat(this._m);

  VehicleInfo get vehicleInfo => _m.vehicleInfo;

  DriverInfo get driverInfo {
    final ad = _m.assignedDriver;
    if (ad == null) return DriverInfo(driverName: '', driverMobile: '');
    return DriverInfo(
      driverId: ad['id']?.toString() ?? ad['driverId']?.toString(),
      driverName: ad['name']?.toString() ?? ad['driverName']?.toString() ?? '',
      driverMobile: ad['phoneNumber']?.toString() ?? ad['driverMobile']?.toString() ?? '',
      driverImage: ad['image']?.toString() ?? ad['driverImage']?.toString(),
    );
  }

  List<RecentTrip> get recentTrips => _m.recentTrips;

  // monthlyUsageKM maps to metrics.monthlyUsage or metrics.avgRun
  num get monthlyUsageKM => _m.metrics.monthlyUsage > 0 ? _m.metrics.monthlyUsage : _m.metrics.avgRun;

  // costPerKM maps to metrics.tripEfficiency
  num get costPerKM => _m.metrics.tripEfficiency;
}

class VehicleMetrics {
  final num avgRun;
  final num tripEfficiency;
  final num monthlyUsage;

  VehicleMetrics({
    required this.avgRun,
    required this.tripEfficiency,
    required this.monthlyUsage,
  });

  factory VehicleMetrics.fromJson(Map<String, dynamic> json) {
    return VehicleMetrics(
      avgRun: json['avgRun'] as num? ?? 0,
      tripEfficiency: json['tripEfficiency'] as num? ?? 0,
      monthlyUsage: json['monthlyUsage'] as num? ?? 0,
    );
  }
}

// Legacy compatibility classes kept for screens that reference them
class VehicleDetailData {
  final VehicleInfo vehicleInfo;
  final DriverInfo driverInfo;
  final List<RecentTrip> recentTrips;
  final num monthlyUsageKM;
  final num costPerKM;

  VehicleDetailData({
    required this.vehicleInfo,
    required this.driverInfo,
    required this.recentTrips,
    required this.monthlyUsageKM,
    required this.costPerKM,
  });

  factory VehicleDetailData.fromJson(Map<String, dynamic> json) {
    return VehicleDetailData(
      vehicleInfo: VehicleInfo.fromJson(json['vehicleInfo'] as Map<String, dynamic>? ?? {}),
      driverInfo: DriverInfo.fromJson(json['driverInfo'] as Map<String, dynamic>? ?? {}),
      recentTrips: (json['recentTrips'] as List<dynamic>?)
              ?.map((e) => RecentTrip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monthlyUsageKM: json['monthlyUsageKM'] as num? ?? 0,
      costPerKM: json['costPerKM'] as num? ?? 0,
    );
  }
}

class VehicleInfo {
  final String vehicleId;
  final String vehicleModel;
  final String vehicleNumber;
  final int manufacturingYear;
  final String status;
  final String ownershipType;

  VehicleInfo({
    required this.vehicleId,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.manufacturingYear,
    required this.status,
    required this.ownershipType,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      vehicleId: json['id']?.toString() ?? json['vehicleId']?.toString() ?? '',
      vehicleModel: json['model']?.toString() ?? json['vehicleModel']?.toString() ?? '',
      vehicleNumber: json['registrationNumber']?.toString() ?? json['vehicleNumber']?.toString() ?? '',
      manufacturingYear: (json['year'] as num?)?.toInt() ?? (json['manufacturingYear'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      ownershipType: json['ownership']?.toString() ?? json['ownershipType']?.toString() ?? 'Owned',
    );
  }
}

class DriverInfo {
  final String? driverId;
  final String driverName;
  final String driverMobile;
  final String? driverImage;

  DriverInfo({
    this.driverId,
    required this.driverName,
    required this.driverMobile,
    this.driverImage,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      driverId: json['driverId']?.toString() ?? json['id']?.toString(),
      driverName: json['driverName']?.toString() ?? json['name']?.toString() ?? '',
      driverMobile: json['driverMobile']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      driverImage: json['driverImage']?.toString() ?? json['image']?.toString(),
    );
  }
}

class RecentTrip {
  final String tripId;
  final String tripCode;
  final String pickupLocation;
  final String deliveryLocation;
  final String tripStatus;
  final String createdDate;

  RecentTrip({
    required this.tripId,
    required this.tripCode,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.tripStatus,
    required this.createdDate,
  });

  factory RecentTrip.fromJson(Map<String, dynamic> json) {
    final route = json['route'] as Map<String, dynamic>? ?? {};
    final startLoc = route['startLocation'] as Map<String, dynamic>? ?? {};
    final endLoc = route['endLocation'] as Map<String, dynamic>? ?? {};

    return RecentTrip(
      tripId: json['tripId']?.toString() ?? json['id']?.toString() ?? '',
      tripCode: json['tripId']?.toString() ?? json['tripCode']?.toString() ?? '',
      pickupLocation: startLoc['address']?.toString() ?? json['pickupLocation']?.toString() ?? '',
      deliveryLocation: endLoc['address']?.toString() ?? json['deliveryLocation']?.toString() ?? '',
      tripStatus: json['status']?.toString() ?? json['tripStatus']?.toString() ?? '',
      createdDate: json['createdAt']?.toString() ?? json['createdDate']?.toString() ?? '',
    );
  }

  String getRoute() {
    final pickup = pickupLocation.split(',').first.trim();
    final delivery = deliveryLocation.split(',').first.trim();
    return '$pickup → $delivery';
  }
}

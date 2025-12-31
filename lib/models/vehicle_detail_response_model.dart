class VehicleDetailResponseModel {
  final bool status;
  final VehicleDetailData data;

  VehicleDetailResponseModel({required this.status, required this.data});

  factory VehicleDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return VehicleDetailResponseModel(
      status: json['status'] ?? false,
      data: VehicleDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

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
      vehicleInfo: VehicleInfo.fromJson(json['vehicleInfo'] ?? {}),
      driverInfo: DriverInfo.fromJson(json['driverInfo'] ?? {}),
      recentTrips:
          (json['recentTrips'] as List<dynamic>?)
              ?.map((e) => RecentTrip.fromJson(e))
              .toList() ??
          [],
      monthlyUsageKM: json['monthlyUsageKM'] ?? 0,
      costPerKM: json['costPerKM'] ?? 0,
    );
  }
}

class VehicleInfo {
  final String vehicleId;
  final String vehicleModel;
  final String vehicleNumber;
  final int manufacturingYear;
  final String status;

  VehicleInfo({
    required this.vehicleId,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.manufacturingYear,
    required this.status,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      vehicleId: json['vehicleId'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      manufacturingYear: json['manufacturingYear'] ?? 0,
      status: json['status'] ?? '',
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
      driverId: json['driverId'],
      driverName: json['driverName'] ?? '',
      driverMobile: json['driverMobile'] ?? '',
      driverImage: json['driverImage'],
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
    return RecentTrip(
      tripId: json['tripId'] ?? '',
      tripCode: json['tripCode'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      deliveryLocation: json['deliveryLocation'] ?? '',
      tripStatus: json['tripStatus'] ?? '',
      createdDate: json['createdDate'] ?? '',
    );
  }

  String getRoute() {
    // Extract city names from locations
    String pickup = pickupLocation.split(',').first.trim();
    String delivery = deliveryLocation.split(',').first.trim();
    return '$pickup-$delivery';
  }
}

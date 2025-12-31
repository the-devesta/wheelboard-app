class LeaseListItem {
  final String? leaseId;
  final String? vehicleTitle;
  final String? vehicleNumber;
  final int? odometerStartReading;
  final num? avgMonthlyRun;
  final num? flatPrice;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? imageUrl;
  final String? leaseStatus;

  LeaseListItem({
    this.leaseId,
    this.vehicleTitle,
    this.vehicleNumber,
    this.odometerStartReading,
    this.avgMonthlyRun,
    this.flatPrice,
    this.startDate,
    this.endDate,
    this.status,
    this.imageUrl,
    this.leaseStatus,
  });

  factory LeaseListItem.fromJson(Map<String, dynamic> json) {
    return LeaseListItem(
      leaseId: json['leaseId'],
      vehicleTitle: json['vehicleTitle'],
      vehicleNumber: json['vehicleNumber'],
      odometerStartReading: json['odometerStartReading'],
      avgMonthlyRun: json['avgMonthlyRun'],
      flatPrice: json['flatPrice'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      imageUrl: json['imageUrl'],
      leaseStatus: json['leaseStatus'],
    );
  }
}

class LeaseDetails {
  final String? leaseId;
  final String? vehicleTitle;
  final String? vehicleNumber;
  final int? odometerStartReading;
  final String? pricingType;
  final num? flatPrice;
  final num? avgMonthlyRun;
  final num? tripEfficiencyRate;
  final String? startDate;
  final String? endDate;
  final String? businessDays;
  final String? startTime;
  final String? endTime;
  final String? instructions;
  final String? userId;
  final String? vehicleId;
  final String? status;
  final int? modelYear;
  final String? vehicleType;
  final String? vehicleImage;
  final String? ownerName;
  final String? phoneNumber;
  final String? email;
  final String? profileImage;
  final String? serviceRegion;
  final String? leaseStatus;

  LeaseDetails({
    this.leaseId,
    this.vehicleTitle,
    this.vehicleNumber,
    this.odometerStartReading,
    this.pricingType,
    this.flatPrice,
    this.avgMonthlyRun,
    this.tripEfficiencyRate,
    this.startDate,
    this.endDate,
    this.businessDays,
    this.startTime,
    this.endTime,
    this.instructions,
    this.userId,
    this.vehicleId,
    this.status,
    this.modelYear,
    this.vehicleType,
    this.vehicleImage,
    this.ownerName,
    this.phoneNumber,
    this.email,
    this.profileImage,
    this.serviceRegion,
    this.leaseStatus,
  });

  factory LeaseDetails.fromJson(Map<String, dynamic> json) {
    return LeaseDetails(
      leaseId: json['leaseId'],
      vehicleTitle: json['vehicleTitle'],
      vehicleNumber: json['vehicleNumber'],
      odometerStartReading: json['odometerStartReading'],
      pricingType: json['pricingType'],
      flatPrice: json['flatPrice'],
      avgMonthlyRun: json['avgMonthlyRun'],
      tripEfficiencyRate: json['tripEfficiencyRate'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      businessDays: json['businessDays'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      instructions: json['instructions'],
      userId: json['userId'],
      vehicleId: json['vehicleId'],
      status: json['status'],
      modelYear: json['modelYear'],
      vehicleType: json['vehicleType'],
      vehicleImage: json['vehicleImage'],
      ownerName: json['ownerName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      profileImage: json['profileImage'],
      serviceRegion: json['serviceRegion'],
      leaseStatus: json['leaseStatus'],
    );
  }
}

class LeaseApplication {
  final String? applicationId;
  final String? vehicleTitle;
  final int? modelYear;
  final String? imageUrl;
  final String? fullName;
  final String? appliedDate;
  final num? distanceKm;
  final String? status;

  LeaseApplication({
    this.applicationId,
    this.vehicleTitle,
    this.modelYear,
    this.imageUrl,
    this.fullName,
    this.appliedDate,
    this.distanceKm,
    this.status,
  });

  factory LeaseApplication.fromJson(Map<String, dynamic> json) {
    return LeaseApplication(
      applicationId: json['applicationId'],
      vehicleTitle: json['vehicleTitle'],
      modelYear: json['modelYear'],
      imageUrl: json['imageUrl'],
      fullName: json['fullName'],
      appliedDate: json['appliedDate'],
      distanceKm: json['distanceKm'],
      status: json['status'],
    );
  }
}

class ApplyLeaseRequest {
  final String leaseId;
  final String userId;
  final String notes;

  ApplyLeaseRequest({
    required this.leaseId,
    required this.userId,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {'leaseId': leaseId, 'userId': userId, 'notes': notes};
  }
}

class UpdateLeaseApplicationStatusRequest {
  final String applicationId;
  final String status;

  UpdateLeaseApplicationStatusRequest({
    required this.applicationId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {'applicationId': applicationId, 'status': status};
  }
}

/// Vehicle Lease Model for Transport side
/// Used for adding/managing vehicle leases via API
library;

class VehicleLeaseModel {
  final String? userId;
  final String? vehicleId;
  final String? vehicleTitle;
  final String? vehicleNumber;
  final String? model; // Vehicle model - REQUIRED by API
  final int? odometerStartReading;
  final int? pricingType; // 0 = Flat, 1 = Per KM, 2 = Per Trip
  final int? flatPrice; // Changed to int as per API requirement
  final int? avgMonthlyRun; // Changed to int as per API requirement
  final int? tripEfficiencyRate; // Changed to int as per API requirement
  final DateTime? startDate;
  final DateTime? endDate;
  final String? businessDays;
  final String? startTime;
  final String? endTime;
  final String? instructions;

  VehicleLeaseModel({
    this.userId,
    this.vehicleId,
    this.vehicleTitle,
    this.vehicleNumber,
    this.model,
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
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "vehicleId": vehicleId,
      "vehicleTitle": vehicleTitle,
      "vehicleNumber": vehicleNumber,
      "model":
          model ?? vehicleTitle ?? "", // Use vehicleTitle as fallback for model
      "odometerStartReading": odometerStartReading ?? 0,
      "pricingType": pricingType ?? 0,
      "flatPrice": flatPrice ?? 0,
      "avgMonthlyRun": avgMonthlyRun ?? 0,
      "tripEfficiencyRate": tripEfficiencyRate ?? 0,
      "startDate": startDate?.toUtc().toIso8601String(),
      "endDate": endDate?.toUtc().toIso8601String(),
      "businessDays": businessDays ?? "",
      "startTime": startTime ?? "",
      "endTime": endTime ?? "",
      "instructions": instructions ?? "",
    };
  }

  /// Create from JSON response
  factory VehicleLeaseModel.fromJson(Map<String, dynamic> json) {
    return VehicleLeaseModel(
      userId: json['userId'],
      vehicleId: json['vehicleId'],
      vehicleTitle: json['vehicleTitle'],
      vehicleNumber: json['vehicleNumber'],
      model: json['model'],
      odometerStartReading: json['odometerStartReading'],
      pricingType: json['pricingType'],
      flatPrice: json['flatPrice'],
      avgMonthlyRun: json['avgMonthlyRun'],
      tripEfficiencyRate: json['tripEfficiencyRate'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      businessDays: json['businessDays'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      instructions: json['instructions'],
    );
  }

  /// Copy with method for updating specific fields
  VehicleLeaseModel copyWith({
    String? userId,
    String? vehicleId,
    String? vehicleTitle,
    String? vehicleNumber,
    String? model,
    int? odometerStartReading,
    int? pricingType,
    int? flatPrice,
    int? avgMonthlyRun,
    int? tripEfficiencyRate,
    DateTime? startDate,
    DateTime? endDate,
    String? businessDays,
    String? startTime,
    String? endTime,
    String? instructions,
  }) {
    return VehicleLeaseModel(
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleTitle: vehicleTitle ?? this.vehicleTitle,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      model: model ?? this.model,
      odometerStartReading: odometerStartReading ?? this.odometerStartReading,
      pricingType: pricingType ?? this.pricingType,
      flatPrice: flatPrice ?? this.flatPrice,
      avgMonthlyRun: avgMonthlyRun ?? this.avgMonthlyRun,
      tripEfficiencyRate: tripEfficiencyRate ?? this.tripEfficiencyRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      businessDays: businessDays ?? this.businessDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  String toString() {
    return 'VehicleLeaseModel(vehicleTitle: $vehicleTitle, vehicleNumber: $vehicleNumber, model: $model, startDate: $startDate, endDate: $endDate)';
  }
}

/// Pricing type enum for better readability
enum LeasePricingType {
  flat(0, 'Flat Price'),
  perKm(1, 'Per KM'),
  perTrip(2, 'Per Trip');

  final int value;
  final String label;
  const LeasePricingType(this.value, this.label);

  static LeasePricingType fromValue(int value) {
    return LeasePricingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LeasePricingType.flat,
    );
  }
}

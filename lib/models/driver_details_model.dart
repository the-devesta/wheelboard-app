class DriverDetailsModel {
  final String driverId;
  final String userId;
  final String fullName;
  final String contactNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String description;
  final bool isDeclarationAccepted;
  final bool isKYCCompleted;
  final bool isVerified;
  final String? driverImagePath;
  final String? dlNumber;
  final DateTime? dateOfBirth;

  DriverDetailsModel({
    required this.driverId,
    required this.userId,
    required this.fullName,
    required this.contactNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.description,
    required this.isDeclarationAccepted,
    this.isKYCCompleted = false,
    this.isVerified = false,
    this.driverImagePath,
    this.dlNumber,
    this.dateOfBirth,
  });

  factory DriverDetailsModel.fromJson(Map<String, dynamic> json) {
    return DriverDetailsModel(
      driverId: json['driverId'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      description: json['description'] ?? '',
      isDeclarationAccepted: json['isDeclarationAccepted'] ?? false,
      isKYCCompleted: json['isKYCCompleted'] ?? false,
      isVerified: json['isVerified'] ?? false,
      driverImagePath: json['driverImagePath'],
      dlNumber:
          json['dlNo'] ??
          json['dlNumber'] ??
          json['drivingLicenseNumber'] ??
          json['licenseNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'userId': userId,
      'fullName': fullName,
      'contactNumber': contactNumber,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'description': description,
      'isDeclarationAccepted': isDeclarationAccepted,
      'isKYCCompleted': isKYCCompleted,
      'isVerified': isVerified,
      'driverImagePath': driverImagePath,
      'dlNumber': dlNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}

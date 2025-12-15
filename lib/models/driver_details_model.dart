class DriverDetailsModel {
  final String driverId;
  final String userId;
  final String fullName;
  final String contactNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String description;
  final bool isDeclarationAccepted;
  final String? driverImagePath;
  final String? dlNumber;

  DriverDetailsModel({
    required this.driverId,
    required this.userId,
    required this.fullName,
    required this.contactNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.description,
    required this.isDeclarationAccepted,
    this.driverImagePath,
    this.dlNumber,
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
      driverImagePath: json['driverImagePath'],
      dlNumber:
          json['dlNumber'] ??
          json['drivingLicenseNumber'] ??
          json['licenseNumber'],
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
      'driverImagePath': driverImagePath,
      'dlNumber': dlNumber,
    };
  }
}

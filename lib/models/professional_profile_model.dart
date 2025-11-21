class ProfessionalProfile {
  final String driverId;
  final String fullName;
  final String contactNumber;
  final String vehicleNumber;
  final String description;
  final String driverType;
  final String? driverImagePath;

  const ProfessionalProfile({
    required this.driverId,
    required this.fullName,
    required this.contactNumber,
    required this.vehicleNumber,
    required this.description,
    required this.driverType,
    this.driverImagePath,
  });

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfile(
      driverId: json['driverId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Unknown',
      contactNumber: json['contactNumber']?.toString() ?? 'N/A',
      vehicleNumber: json['vehicleNumber']?.toString() ?? 'N/A',
      description: json['description']?.toString() ?? '',
      driverType: json['driverType']?.toString() ?? 'Unknown',
      driverImagePath: json['driverImagePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'fullName': fullName,
      'contactNumber': contactNumber,
      'vehicleNumber': vehicleNumber,
      'description': description,
      'driverType': driverType,
      'driverImagePath': driverImagePath,
    };
  }

  ProfessionalProfile copyWith({
    String? driverId,
    String? fullName,
    String? contactNumber,
    String? vehicleNumber,
    String? description,
    String? driverType,
    String? driverImagePath,
  }) {
    return ProfessionalProfile(
      driverId: driverId ?? this.driverId,
      fullName: fullName ?? this.fullName,
      contactNumber: contactNumber ?? this.contactNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      description: description ?? this.description,
      driverType: driverType ?? this.driverType,
      driverImagePath: driverImagePath ?? this.driverImagePath,
    );
  }
}


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
  final String? driverType;

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
    this.driverType,
  });

  /// Build from a `GET /users/:id/public-profile` response.
  ///
  /// Bidders are professional *users*, so their data lives under a nested
  /// `profile` object — not the flat fleet-driver shape.
  factory DriverDetailsModel.fromUserProfile(dynamic response) {
    final Map<String, dynamic> root =
        response is Map && response['data'] is Map
            ? Map<String, dynamic>.from(response['data'])
            : (response is Map
                ? Map<String, dynamic>.from(response)
                : <String, dynamic>{});

    final Map<String, dynamic> profile = root['profile'] is Map
        ? Map<String, dynamic>.from(root['profile'])
        : <String, dynamic>{};

    final id = (root['id'] ?? root['_id'] ?? '').toString();

    String name() {
      final first = (profile['firstName'] ?? '').toString().trim();
      final last = (profile['lastName'] ?? '').toString().trim();
      final combined = '$first $last'.trim();
      if (combined.isNotEmpty) return combined;
      final full = (profile['fullName'] ?? profile['name'] ?? '').toString().trim();
      if (full.isNotEmpty) return full;
      final email = (root['email'] ?? '').toString();
      if (email.contains('@')) return email.split('@').first;
      return 'Professional';
    }

    return DriverDetailsModel(
      driverId: id,
      userId: id,
      fullName: name(),
      contactNumber:
          (profile['phoneNumber'] ?? root['phoneNumber'] ?? '').toString(),
      vehicleType: (profile['vehicleType'] ?? '').toString(),
      vehicleNumber: (profile['vehicleNumber'] ?? '').toString(),
      description:
          (profile['description'] ?? profile['bio'] ?? '').toString(),
      isDeclarationAccepted: true,
      isKYCCompleted:
          (profile['isKYCCompleted'] ?? profile['kycCompleted'] ?? false) == true,
      isVerified: (profile['isVerified'] ?? false) == true,
      driverImagePath:
          (profile['profileImage'] ?? profile['avatar'])?.toString(),
      dlNumber:
          (profile['licenseNumber'] ?? profile['drivingLicenseNumber'])?.toString(),
      driverType:
          (profile['professionalType'] ?? profile['driverType'])?.toString(),
    );
  }

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
      driverType: json['driverType'],
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
      'driverType': driverType,
    };
  }
}

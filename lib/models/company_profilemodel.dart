import 'dart:io';

class CompleteProfileModel {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? fleetSize;
  final String? gstNumber;
  final File? companyLogo;

  CompleteProfileModel({
    required this.userId,
    this.firstName,
    this.lastName,
    this.address,
    this.fleetSize,
    this.gstNumber,
    this.companyLogo,
  });

  // Convert to normal string fields (without file)
  Map<String, String?> toJsonFields() {
    final map = <String, String?>{
      "UserId": userId,
      "FirstName": firstName ?? '',
      "LastName": lastName ?? '',
      "Address": address ?? '',
      "FleetSize": fleetSize ?? '',
    };
    // Only add GSTNumber if it's provided and not empty
    if (gstNumber != null && gstNumber!.isNotEmpty) {
      map["GSTNumber"] = gstNumber;
    }
    return map;
  }
}

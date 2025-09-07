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

  // class CompleteProfileModel {
  //   final String userId;
  //   final String? companyName;
  //   final String? firstName;
  //   final String? lastName;
  //   final String? address;
  //   final String? email;
  //   final String? phone;
  //   final String? fleetSize;
  //   final String? gstNumber;
  //   final File? companyLogo;

  //   CompleteProfileModel({
  //     required this.userId,
  //     this.companyName,
  //     this.firstName,
  //     this.lastName,
  //     this.address,
  //     this.fleetSize,
  //     this.email,
  //     this.phone,
  //     this.gstNumber,
  //     this.companyLogo,
  //   });

  // Convert to normal string fields (without file)
  Map<String, String?> toJsonFields() {
    final map = {
      "UserId": userId,
      "FirstName": firstName,
      "LastName": lastName,
      "Address": address,
      "FleetSize": fleetSize,
    };
    if (gstNumber != null && gstNumber!.isNotEmpty) {
      map["GSTNumber"] = gstNumber!;
    }
    return map;
  }
}

import 'dart:io';

class CompleteProfileModel {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? email; // ✅ Added Email field
  final String? address;
  final String? fleetSize;
  final String? gstNumber;
  final File? companyLogo;

  CompleteProfileModel({
    required this.userId,
    this.firstName,
    this.lastName,
    this.email, // ✅ Added Email parameter
    this.address,
    this.fleetSize,
    this.gstNumber,
    this.companyLogo,
  });

  // Convert to normal string fields (without file)
  Map<String, String?> toJsonFields() {
    final map = <String, String?>{"UserId": userId};

    // ✅ API expects FirstName and LastName separately (not FullName)
    // Send FirstName - use empty string if null (API might require it)
    map["FirstName"] = firstName?.trim() ?? '';

    // ✅ Send LastName - use empty string if null (API might require it)
    map["LastName"] = lastName?.trim() ?? '';

    // ✅ Add Email - REQUIRED by backend sp_CompleteTransportProfile
    map["Email"] = email?.trim() ?? '';

    // ✅ Add Address - use empty string if null
    map["Address"] = address?.trim() ?? '';

    // ✅ Add FleetSize - use '0' if empty (as per API example)
    map["FleetSize"] = (fleetSize != null && fleetSize!.trim().isNotEmpty)
        ? fleetSize!.trim()
        : '0';

    // ✅ Only add GSTNumber if it's provided and not empty
    if (gstNumber != null && gstNumber!.trim().isNotEmpty) {
      map["GSTNumber"] = gstNumber!.trim();
    }

    return map;
  }
}

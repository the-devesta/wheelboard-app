import 'dart:io';

class DriverModel {
  final String? userId;
  final String? driverId; // ✅ For update operations
  final String? fullName;
  final String? contactNumber;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? description;
  final bool? isDeclarationAccepted;
  final File? image; // ✅ single file instead of List<File>
  final int? partnerId; // ✅ integer instead of String
  final String? modifiedUserId; // ✅ For update operations

  DriverModel({
    this.userId,
    this.driverId,
    this.fullName,
    this.contactNumber,
    this.vehicleType,
    this.vehicleNumber,
    this.description,
    this.isDeclarationAccepted,
    this.image,
    this.partnerId,
    this.modifiedUserId,
  });

  // Convert to normal string fields (backend expects text)
  Map<String, String> toJsonFields() {
    return {
      "UserId": userId ?? "",
      "DriverId": driverId ?? "",
      "FullName": fullName ?? "",
      "ContactNumber": contactNumber ?? "",
      "VehicleType": vehicleType ?? "",
      "VehicleNumber": vehicleNumber ?? "",
      "Description": description ?? "",
      "IsDeclarationAccepted": isDeclarationAccepted?.toString() ?? "false",
      "PartnerId": partnerId?.toString() ?? "0",
      "ModifiedUserId": modifiedUserId ?? "",
    };
  }
}

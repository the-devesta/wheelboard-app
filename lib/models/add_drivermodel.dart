import 'dart:io';

class DriverModel {
  final String? userId;
  final String? fullName;
  final String? contactNumber;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? description;
  final bool? isDeclarationAccepted;
  final File? image; // ✅ single file instead of List<File>
  final int? partnerId; // ✅ integer instead of String

  DriverModel({
    this.userId,
    this.fullName,
    this.contactNumber,
    this.vehicleType,
    this.vehicleNumber,
    this.description,
    this.isDeclarationAccepted,
    this.image,
    this.partnerId,
  });

  // Convert to normal string fields (backend expects text)
  Map<String, String> toJsonFields() {
    return {
      "UserId": userId ?? "",
      "FullName": fullName ?? "",
      "ContactNumber": contactNumber ?? "",
      "VehicleType": vehicleType ?? "",
      "VehicleNumber": vehicleNumber ?? "",
      "Description": description ?? "",
      "IsDeclarationAccepted": isDeclarationAccepted?.toString() ?? "false",
      "PartnerId": partnerId?.toString() ?? "0",
    };
  }
}

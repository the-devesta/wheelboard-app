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
  final String? dlNo; // ✅ Driver License Number
  final DateTime? dateOfBirth; // ✅ Date of Birth

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
    this.dlNo,
    this.dateOfBirth,
  });

  // Convert to normal string fields (backend expects text)
  Map<String, String> toJsonFields() {
    return {
      "UserId": userId ?? "",
      "DriverId": driverId ?? "",
      "FullName": fullName ?? "",
      "ContactNumber": contactNumber ?? "",
      "VehicleType": vehicleType ?? "",
      // ✅ Backend requires VehicleNumber - send "Not Assigned" if null/empty
      "VehicleNumber":
          (vehicleNumber != null && vehicleNumber!.trim().isNotEmpty)
          ? vehicleNumber!.trim()
          : "Not Assigned",
      "Description": description ?? "",
      "IsDeclarationAccepted": isDeclarationAccepted?.toString() ?? "false",
      "PartnerId": partnerId?.toString() ?? "0",
      "ModifiedUserId": modifiedUserId ?? "",
      "DLNo": dlNo ?? "",
      "DateOfBirth": dateOfBirth?.toIso8601String() ?? "",
    };
  }
}

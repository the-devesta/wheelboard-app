import 'dart:io';

class DriverModel {
  final String? userId;
  final String? fullName;
  final String? contactNumber;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? description;
  final bool? isDeclarationAccepted;
  final List<File>? images;
  final String? partnerId;

  DriverModel({
    this.userId,
    this.fullName,
    this.contactNumber,
    this.vehicleType,
    this.vehicleNumber,
    this.description,
    this.isDeclarationAccepted,
    this.images,
    this.partnerId,
  });

  // Convert to normal string fields (without file)
  Map<String, String?> toJsonFields() {
    final map = {
      "UserId": userId,
      "FullName": fullName,
      "ContactNumber": contactNumber,
      "VehicleType": vehicleType,
      "VehicleNumber": vehicleNumber,
      "Description": description,
      "IsDeclarationAccepted": isDeclarationAccepted?.toString(),
      "PartnerId": partnerId,
    };

    return map;
  }

  // Get image files
  List<File>? getImageFiles() {
    return images;
  }
}

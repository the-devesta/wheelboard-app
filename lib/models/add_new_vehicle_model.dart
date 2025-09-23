// import 'dart:io';

// class VehicleModel {
//   final String? userId;
//   final String? vehicleModel;
//   final String? vehicleNumber;
//   final int? manufacturingYear;
//   final String? ownershipType;
//   final String? vehicleType;
//   final String? description;
//   final bool? isDeclarationAccepted;
//   final List<File>? images;

//   VehicleModel({
//     this.userId,
//     this.vehicleModel,
//     this.vehicleNumber,
//     this.manufacturingYear,
//     this.ownershipType,
//     this.vehicleType,
//     this.description,
//     this.isDeclarationAccepted,
//     this.images,
//   });

//   // Convert to JSON fields (without files)
//   Map<String, String?> toJsonFields() {
//     final map = {
//       "UserId": userId,
//       "VehicleModel": vehicleModel,
//       "VehicleNumber": vehicleNumber,
//       "ManufacturingYear": manufacturingYear?.toString(),
//       "OwnershipType": ownershipType,
//       "VehicleType": vehicleType,
//       "Description": description,
//       "IsDeclarationAccepted": isDeclarationAccepted?.toString(),
//     };

//     return map;
//   }

//   // Get image files
//   List<File>? getImageFiles() {
//     return images;
//   }
// }

import 'dart:io';

class VehicleModel {
  final String? userId;
  final String? vehicleModel;
  final String? vehicleNumber;
  final int? manufacturingYear; // keep as int
  final String? ownershipType;
  final String? vehicleType;
  final String? description;
  final bool? isDeclarationAccepted; // keep as bool
  final List<File>? images;

  VehicleModel({
    this.userId,
    this.vehicleModel,
    this.vehicleNumber,
    this.manufacturingYear,
    this.ownershipType,
    this.vehicleType,
    this.description,
    this.isDeclarationAccepted,
    this.images,
  });

  /// ✅ Convert to JSON/map fields (without files)
  /// Use dynamic so you can send int & bool correctly
  Map<String, dynamic> toJsonFields() {
    return {
      "UserId": userId,
      "VehicleModel": vehicleModel,
      "VehicleNumber": vehicleNumber,
      "ManufacturingYear": manufacturingYear, // int directly
      "OwnershipType": ownershipType,
      "VehicleType": vehicleType,
      "Description": description,
      "IsDeclarationAccepted": isDeclarationAccepted, // bool directly
    };
  }

  /// Get image files
  List<File>? getImageFiles() {
    return images;
  }
}

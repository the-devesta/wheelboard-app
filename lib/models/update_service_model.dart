import 'dart:io';

class UpdateServiceModel {
  final String serviceId;
  final String userId;
  final String serviceTitle;
  final String fullAddress;
  final String city;
  final String contactNumber;
  final String? whatsappNumber;
  final String description;
  final bool isFlatPrice;
  final double price;
  final bool isVisible;
  final String daysOpen;
  final String businessFrom;
  final String businessTo;
  final String modifiedBy;
  final String serviceCategory;
  final List<File>? newImages; // Optional - only new images to add

  UpdateServiceModel({
    required this.serviceId,
    required this.userId,
    required this.serviceTitle,
    required this.fullAddress,
    required this.city,
    required this.contactNumber,
    this.whatsappNumber,
    required this.description,
    required this.isFlatPrice,
    required this.price,
    required this.isVisible,
    required this.daysOpen,
    required this.businessFrom,
    required this.businessTo,
    required this.modifiedBy,
    required this.serviceCategory,
    this.newImages,
  });

  // Convert to JSON fields (excluding files)
  Map<String, String> toJsonFields() {
    return {
      'ServiceId': serviceId,
      'UserId': userId,
      'ServiceTitle': serviceTitle,
      'FullAddress': fullAddress,
      'City': city,
      'ContactNumber': contactNumber,
      if (whatsappNumber != null && whatsappNumber!.isNotEmpty)
        'WhatsappNumber': whatsappNumber!,
      'Description': description,
      'IsFlatPrice': isFlatPrice.toString(),
      'Price': price.toString(),
      'IsVisible': isVisible.toString(),
      'DaysOpen': daysOpen,
      'BusinessFrom': businessFrom,
      'BusinessTo': businessTo,
      'ModifiedBy': modifiedBy,
      'ServiceCategory': serviceCategory,
    };
  }

  // Get the files for upload
  List<File> getNewImages() {
    return newImages ?? [];
  }
}


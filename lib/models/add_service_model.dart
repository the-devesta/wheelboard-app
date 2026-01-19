import 'dart:io';

class AddServiceModel {
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
  final String createdBy;
  final String serviceCategory;
  final List<File> images;

  AddServiceModel({
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
    required this.createdBy,
    required this.serviceCategory,
    required this.images,
  });

  // Convert to JSON fields (excluding files)
  Map<String, String> toJsonFields() {
    return {
      'UserId': userId,
      'ServiceTitle': serviceTitle,
      'FullAddress': fullAddress,
      'City': city,
      'ContactNumber': contactNumber,
      // WhatsappNumber is required by API - use contactNumber as fallback
      'WhatsappNumber': (whatsappNumber != null && whatsappNumber!.isNotEmpty)
          ? whatsappNumber!
          : contactNumber,
      'Description': description,
      'IsFlatPrice': isFlatPrice.toString(),
      'Price': price.toString(),
      'IsVisible': isVisible.toString(),
      'DaysOpen': daysOpen,
      'BusinessFrom': businessFrom,
      'BusinessTo': businessTo,
      'CreatedBy': createdBy,
      'ServiceCategory': serviceCategory,
    };
  }

  // Get the files for upload
  List<File> getImages() {
    return images;
  }
}

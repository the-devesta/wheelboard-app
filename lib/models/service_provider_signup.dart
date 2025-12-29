import 'dart:io';

class ServiceProviderModel {
  final String userId;
  final String businessName;
  final String? gstNumber; // Optional field
  final String businessType;
  final List<String> servicesOffered;
  final String businessAddress;
  final String city;
  final String phoneNumber;
  final String email;
  final String? whatsappNumber; // Optional field
  final File? businessLogo; // Optional field for file upload
  final String description;

  ServiceProviderModel({
    required this.userId,
    required this.businessName,
    this.gstNumber, // Now optional
    required this.businessType,
    required this.servicesOffered,
    required this.businessAddress,
    required this.city,
    required this.phoneNumber,
    required this.email,
    this.whatsappNumber,
    this.businessLogo,
    required this.description,
  });

  // Convert to JSON fields (excluding file)
  Map<String, String> toJsonFields() {
    return {
      "UserId": userId,
      "BusinessName": businessName,
      if (gstNumber != null && gstNumber!.isNotEmpty) "GSTNumber": gstNumber!,
      "BusinessType": businessType,
      "ServicesOffered": servicesOffered.join(
        ", ",
      ), // Convert list to comma-separated string
      "BusinessAddress": businessAddress,
      "City": city,
      "PhoneNumber": phoneNumber,
      "Email": email,
      if (whatsappNumber != null && whatsappNumber!.isNotEmpty)
        "WhatsAppNumber": whatsappNumber!,
      "Description": description,
    };
  }

  // Get the file for upload
  File? getBusinessLogo() {
    return businessLogo;
  }
}

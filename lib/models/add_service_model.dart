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
  final String? listingPaymentOrderId;
  final String? listingPaymentId;
  final String? listingPaymentSignature;

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
    this.listingPaymentOrderId,
    this.listingPaymentId,
    this.listingPaymentSignature,
  });

  // Convert to JSON fields (excluding files)
  Map<String, String> toJsonFields() {
    final payload = <String, String>{
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

    if (listingPaymentOrderId != null && listingPaymentOrderId!.isNotEmpty) {
      payload['listingPaymentOrderId'] = listingPaymentOrderId!;
    }
    if (listingPaymentId != null && listingPaymentId!.isNotEmpty) {
      payload['listingPaymentId'] = listingPaymentId!;
    }
    if (listingPaymentSignature != null &&
        listingPaymentSignature!.isNotEmpty) {
      payload['listingPaymentSignature'] = listingPaymentSignature!;
    }

    return payload;
  }

  AddServiceModel withListingPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    return AddServiceModel(
      userId: userId,
      serviceTitle: serviceTitle,
      fullAddress: fullAddress,
      city: city,
      contactNumber: contactNumber,
      whatsappNumber: whatsappNumber,
      description: description,
      isFlatPrice: isFlatPrice,
      price: price,
      isVisible: isVisible,
      daysOpen: daysOpen,
      businessFrom: businessFrom,
      businessTo: businessTo,
      createdBy: createdBy,
      serviceCategory: serviceCategory,
      images: images,
      listingPaymentOrderId: orderId,
      listingPaymentId: paymentId,
      listingPaymentSignature: signature,
    );
  }

  // Get the files for upload
  List<File> getImages() {
    return images;
  }
}

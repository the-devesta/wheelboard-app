class ServiceModel {
  final String serviceId;
  final String serviceTitle;
  final String city;
  final String fullAddress;
  final bool isAvailable;
  final String businessName;
  final String businessType;
  final String? serviceCategory;

  // Detail specific fields
  final String? contactNumber;
  final String? whatsappNumber;
  final String? description;
  final String? pricingOption;
  final num? amount;
  final String? businessHoursFrom;
  final String? businessHoursTo;
  final String? daysOpen;

  ServiceModel({
    required this.serviceId,
    required this.serviceTitle,
    required this.city,
    required this.fullAddress,
    required this.isAvailable,
    required this.businessName,
    required this.businessType,
    this.serviceCategory,
    this.contactNumber,
    this.whatsappNumber,
    this.description,
    this.pricingOption,
    this.amount,
    this.businessHoursFrom,
    this.businessHoursTo,
    this.daysOpen,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['serviceId'] as String? ?? '',
      serviceTitle: json['serviceTitle'] as String? ?? '',
      city: json['city'] as String? ?? '',
      fullAddress: json['fullAddress'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      businessName: json['businessName'] as String? ?? '',
      businessType: json['businessType'] as String? ?? '',
      serviceCategory: json['serviceCategory'] as String?,
      contactNumber: json['contactNumber'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      description: json['description'] as String?,
      pricingOption: json['pricingOption'] as String?,
      amount: json['amount'] as num?,
      businessHoursFrom: json['businessHoursFrom'] as String?,
      businessHoursTo: json['businessHoursTo'] as String?,
      daysOpen: json['daysOpen'] as String?,
    );
  }

  ServiceModel copyWith(ServiceModel other) {
    return ServiceModel(
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      city: city,
      fullAddress: fullAddress,
      isAvailable: isAvailable,
      businessName: businessName,
      businessType: businessType,
      serviceCategory: other.serviceCategory ?? serviceCategory,
      contactNumber: other.contactNumber ?? contactNumber,
      whatsappNumber: other.whatsappNumber ?? whatsappNumber,
      description: other.description ?? description,
      pricingOption: other.pricingOption ?? pricingOption,
      amount: other.amount ?? amount,
      businessHoursFrom: other.businessHoursFrom ?? businessHoursFrom,
      businessHoursTo: other.businessHoursTo ?? businessHoursTo,
      daysOpen: other.daysOpen ?? daysOpen,
    );
  }
}


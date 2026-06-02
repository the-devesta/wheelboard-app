class ServiceModel {
  final String serviceId;
  final String serviceTitle;
  final String city;
  final String fullAddress;
  final bool isAvailable;
  final String businessName;
  final String businessType;
  final String? serviceCategory;
  final String? status;

  // Detail / contact
  final String? contactNumber;
  final String? whatsappNumber;
  final String? description;
  final String? pricingOption; // pricing.type
  final num? amount;           // pricing.amount
  final String? currency;
  final String? businessHoursFrom;
  final String? businessHoursTo;
  final String? daysOpen;

  // Extra fields from backend
  final List<String> images;
  final List<String> tags;
  final String? location;
  final String? businessId;
  final String? categoryColor;
  final double? rating;

  ServiceModel({
    required this.serviceId,
    required this.serviceTitle,
    required this.city,
    required this.fullAddress,
    required this.isAvailable,
    required this.businessName,
    required this.businessType,
    this.serviceCategory,
    this.status,
    this.contactNumber,
    this.whatsappNumber,
    this.description,
    this.pricingOption,
    this.amount,
    this.currency,
    this.businessHoursFrom,
    this.businessHoursTo,
    this.daysOpen,
    this.images = const [],
    this.tags = const [],
    this.location,
    this.businessId,
    this.categoryColor,
    this.rating,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Backend returns: id, title, category, pricing:{type,amount,currency},
    // contactInfo:{phone,email}, availability:{days,hours}, location, businessName,
    // businessId, status, images[], tags[]
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};
    final contactInfo = json['contactInfo'] as Map<String, dynamic>? ?? {};
    final availability = json['availability'] as Map<String, dynamic>? ?? {};

    // Derive availability hours
    final hours = availability['hours'] as String? ?? '';
    String? hoursFrom, hoursTo;
    if (hours.contains('-')) {
      final parts = hours.split('-');
      hoursFrom = parts[0].trim();
      hoursTo = parts.length > 1 ? parts[1].trim() : null;
    }

    final daysList = availability['days'] as List<dynamic>?;
    final daysOpen = daysList != null ? daysList.join(', ') : json['daysOpen']?.toString();

    // Location: backend returns 'location' as a string
    final locationStr = json['location']?.toString() ?? json['fullAddress']?.toString() ?? '';

    // City: try to extract from location or use 'city' field
    final cityStr = json['city']?.toString() ?? locationStr.split(',').first.trim();

    final imagesList = json['images'] as List<dynamic>? ?? [];
    final tagsList = json['tags'] as List<dynamic>? ?? [];

    // Status→isAvailable
    final statusStr = json['status']?.toString() ?? 'Draft';
    final isAvailable = statusStr.toLowerCase() == 'published';

    return ServiceModel(
      // Backend returns 'id'; legacy returned 'serviceId'
      serviceId: json['id']?.toString() ?? json['serviceId']?.toString() ?? '',
      // Backend returns 'title'; legacy returned 'serviceTitle'
      serviceTitle: json['title']?.toString() ?? json['serviceTitle']?.toString() ?? '',
      city: cityStr,
      fullAddress: locationStr,
      isAvailable: isAvailable,
      businessName: json['businessName']?.toString() ?? '',
      businessType: json['businessType']?.toString() ?? json['category']?.toString() ?? '',
      // Backend returns 'category'; legacy returned 'serviceCategory'
      serviceCategory: json['category']?.toString() ?? json['serviceCategory']?.toString(),
      status: statusStr,
      // contactInfo.phone or legacy contactNumber
      contactNumber: contactInfo['phone']?.toString() ?? json['contactNumber']?.toString(),
      whatsappNumber: contactInfo['whatsapp']?.toString() ?? json['whatsappNumber']?.toString(),
      description: json['description']?.toString() ?? json['detailedDescription']?.toString(),
      // pricing.type or legacy pricingOption
      pricingOption: pricing['type']?.toString() ?? json['pricingOption']?.toString(),
      // pricing.amount or legacy amount
      amount: (pricing['amount'] as num?) ?? (json['amount'] as num?),
      currency: pricing['currency']?.toString() ?? 'INR',
      businessHoursFrom: hoursFrom ?? json['businessHoursFrom']?.toString(),
      businessHoursTo: hoursTo ?? json['businessHoursTo']?.toString(),
      daysOpen: daysOpen,
      images: imagesList.map((e) => e.toString()).toList(),
      tags: tagsList.map((e) => e.toString()).toList(),
      location: locationStr,
      businessId: json['businessId']?.toString(),
      categoryColor: json['categoryColor']?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  ServiceModel copyWith(ServiceModel other) {
    return ServiceModel(
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      city: other.city.isNotEmpty ? other.city : city,
      fullAddress: other.fullAddress.isNotEmpty ? other.fullAddress : fullAddress,
      isAvailable: other.isAvailable,
      businessName: other.businessName.isNotEmpty ? other.businessName : businessName,
      businessType: other.businessType.isNotEmpty ? other.businessType : businessType,
      serviceCategory: other.serviceCategory ?? serviceCategory,
      status: other.status ?? status,
      contactNumber: other.contactNumber ?? contactNumber,
      whatsappNumber: other.whatsappNumber ?? whatsappNumber,
      description: other.description ?? description,
      pricingOption: other.pricingOption ?? pricingOption,
      amount: other.amount ?? amount,
      currency: other.currency ?? currency,
      businessHoursFrom: other.businessHoursFrom ?? businessHoursFrom,
      businessHoursTo: other.businessHoursTo ?? businessHoursTo,
      daysOpen: other.daysOpen ?? daysOpen,
      images: other.images.isNotEmpty ? other.images : images,
      tags: other.tags.isNotEmpty ? other.tags : tags,
      location: other.location ?? location,
      businessId: other.businessId ?? businessId,
      categoryColor: other.categoryColor ?? categoryColor,
      rating: other.rating ?? rating,
    );
  }
}

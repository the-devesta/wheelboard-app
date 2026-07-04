class Vehicle {
  final String vehicleId;
  final String userId;
  final String vehicleName;
  final String vehicleModel;
  final String vehicleNumber;
  final int manufacturingYear;
  final String ownershipType;
  final String vehicleType;
  final String categoryDetail;
  final String fuelType;
  final String capacity;
  final String mileage;
  final String description;
  final bool isDeclarationAccepted;
  final String status;
  final List<String> imageUrls;
  final double avgRun;
  final double tripEfficiency;
  final double monthlyUsage;

  Vehicle({
    required this.vehicleId,
    required this.userId,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.manufacturingYear,
    required this.ownershipType,
    required this.vehicleType,
    required this.description,
    required this.isDeclarationAccepted,
    required this.status,
    required this.imageUrls,
    this.vehicleName = '',
    this.categoryDetail = '',
    this.fuelType = 'Diesel',
    this.capacity = '',
    this.mileage = '',
    this.avgRun = 0,
    this.tripEfficiency = 0,
    this.monthlyUsage = 0,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Backend returns a primary 'image' (single string) plus an 'images' array
    // (see mapVehicle in fleet.service.ts). Collect both, de-duplicated, with
    // the primary image first. ('imageUrls' kept as a legacy fallback key.)
    final images = <String>[];
    final singleImage = json['image']?.toString() ?? '';
    if (singleImage.isNotEmpty) images.add(singleImage);
    final rawImages = json['images'] ?? json['imageUrls'];
    if (rawImages is List) {
      for (final img in rawImages) {
        final s = img?.toString() ?? '';
        if (s.isNotEmpty && !images.contains(s)) images.add(s);
      }
    }

    final metrics = json['metrics'];
    final metricsMap = metrics is Map ? metrics : const {};

    return Vehicle(
      // Backend returns 'id'; legacy returned 'vehicleId'
      vehicleId: json['id']?.toString() ?? json['vehicleId']?.toString() ?? '',
      // Backend returns 'companyId'; legacy returned 'userId'
      userId: json['companyId']?.toString() ?? json['userId']?.toString() ?? '',
      // Backend returns separate 'name' and 'model' fields.
      vehicleName: json['name']?.toString() ?? '',
      // Backend returns 'model' or 'name'; legacy returned 'vehicleModel'
      vehicleModel: json['model']?.toString() ?? json['name']?.toString() ?? json['vehicleModel']?.toString() ?? '',
      // Backend returns 'registrationNumber'; legacy returned 'vehicleNumber'
      vehicleNumber: json['registrationNumber']?.toString() ?? json['vehicleNumber']?.toString() ?? '',
      // Backend returns 'year'; legacy returned 'manufacturingYear'
      manufacturingYear: (json['year'] as num?)?.toInt() ?? (json['manufacturingYear'] as num?)?.toInt() ?? 0,
      // Backend returns 'ownership'; legacy returned 'ownershipType'
      ownershipType: json['ownership']?.toString() ?? json['ownershipType']?.toString() ?? '',
      // Backend returns 'category'; legacy returned 'vehicleType'
      vehicleType: json['category']?.toString() ?? json['vehicleType']?.toString() ?? '',
      categoryDetail: json['categoryDetail']?.toString() ?? '',
      fuelType: json['fuelType']?.toString() ?? 'Diesel',
      capacity: json['capacity']?.toString() ?? '',
      mileage: json['mileage']?.toString() ?? '',
      // 'location' is the "Current Location / Description" field the
      // modal actually submits; 'description' is kept as a fallback for
      // any pre-existing records that only have the legacy field.
      description: json['location']?.toString() ?? json['description']?.toString() ?? '',
      isDeclarationAccepted: json['isDeclarationAccepted'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      imageUrls: images,
      avgRun: (metricsMap['avgRun'] as num?)?.toDouble() ?? 0,
      tripEfficiency: (metricsMap['tripEfficiency'] as num?)?.toDouble() ?? 0,
      monthlyUsage: (metricsMap['monthlyUsage'] as num?)?.toDouble() ?? 0,
    );
  }
}

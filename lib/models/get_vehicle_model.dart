class Vehicle {
  final String vehicleId;
  final String userId;
  final String vehicleModel;
  final String vehicleNumber;
  final int manufacturingYear;
  final String ownershipType;
  final String vehicleType;
  final String description;
  final bool isDeclarationAccepted;
  final String status;
  final List<String> imageUrls;

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
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Backend returns 'image' (single string); collect into a list
    final images = <String>[];
    final singleImage = json['image']?.toString() ?? '';
    if (singleImage.isNotEmpty) images.add(singleImage);
    final rawImages = json['imageUrls'];
    if (rawImages is List) {
      for (final img in rawImages) {
        final s = img?.toString() ?? '';
        if (s.isNotEmpty && !images.contains(s)) images.add(s);
      }
    }

    return Vehicle(
      // Backend returns 'id'; legacy returned 'vehicleId'
      vehicleId: json['id']?.toString() ?? json['vehicleId']?.toString() ?? '',
      // Backend returns 'companyId'; legacy returned 'userId'
      userId: json['companyId']?.toString() ?? json['userId']?.toString() ?? '',
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
      description: json['description']?.toString() ?? '',
      isDeclarationAccepted: json['isDeclarationAccepted'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      imageUrls: images,
    );
  }
}

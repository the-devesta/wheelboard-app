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
    return Vehicle(
      vehicleId: json['vehicleId'],
      userId: json['userId'],
      vehicleModel: json['vehicleModel'],
      vehicleNumber: json['vehicleNumber'],
      manufacturingYear: json['manufacturingYear'],
      ownershipType: json['ownershipType'],
      vehicleType: json['vehicleType'],
      description: json['description'],
      isDeclarationAccepted: json['isDeclarationAccepted'],
      status: json['status'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
    );
  }
}

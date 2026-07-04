class Driver {
  final String driverId;
  final String userId;
  final String fullName;
  final String contactNumber;
  final String vehicleType;
  final String vehicleCategoryDetail;
  final String vehicleNumber;
  final String description;
  final bool isDeclarationAccepted;
  final String driverImagePath;
  final String dlNo;
  final String status;
  final String experience;
  final String location;
  final String address;
  DateTime? dateOfBirth;
  DateTime? licenseExpiryDate;

  Driver({
    required this.driverId,
    required this.userId,
    required this.fullName,
    required this.contactNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.description,
    required this.isDeclarationAccepted,
    required this.driverImagePath,
    required this.dlNo,
    required this.dateOfBirth,
    this.status = 'Available',
    this.experience = '',
    this.vehicleCategoryDetail = '',
    this.location = '',
    this.address = '',
    this.licenseExpiryDate,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      // Backend returns 'id'; legacy returned 'driverId'
      driverId: json['id']?.toString() ?? json['driverId']?.toString() ?? '',
      // Backend returns 'companyId'; legacy returned 'userId'
      userId: json['companyId']?.toString() ?? json['userId']?.toString() ?? '',
      // Backend returns 'name'; legacy returned 'fullName'
      fullName: json['name']?.toString() ?? json['fullName']?.toString() ?? '',
      // Backend returns 'phoneNumber'; legacy returned 'contactNumber'
      contactNumber: json['phoneNumber']?.toString() ?? json['contactNumber']?.toString() ?? '',
      // Backend returns 'vehicleCategoryExpertise'; legacy returned 'vehicleType'
      vehicleType: json['vehicleCategoryExpertise']?.toString() ?? json['vehicleType']?.toString() ?? '',
      vehicleCategoryDetail: json['vehicleCategoryExpertiseDetail']?.toString() ?? '',
      vehicleNumber: json['vehicleNumber']?.toString() ?? '',
      description: json['description']?.toString() ?? json['status']?.toString() ?? '',
      isDeclarationAccepted: json['isDeclarationAccepted'] as bool? ?? false,
      // Backend returns 'image'; legacy returned 'driverImagePath'
      driverImagePath: json['image']?.toString() ?? json['driverImagePath']?.toString() ?? '',
      // Backend returns 'licenseNumber'; legacy returned 'dlNo'
      dlNo: json['licenseNumber']?.toString() ?? json['dlNo']?.toString() ?? '',
      dateOfBirth: _parseDate(json['dateOfBirth']),
      licenseExpiryDate: _parseDate(json['licenseExpiryDate']),
      status: json['status']?.toString() ?? 'Available',
      experience: json['experience']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value == '') return null;
    return DateTime.tryParse(value.toString());
  }
}

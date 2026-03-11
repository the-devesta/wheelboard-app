class Driver {
  final String driverId;
  final String userId;
  final String fullName;
  final String contactNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String description;
  final bool isDeclarationAccepted;
  final String driverImagePath;
  final String dlNo;
  DateTime? dateOfBirth;
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
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'],
      userId: json['userId'],
      fullName: json['fullName'],
      contactNumber: json['contactNumber'],
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      description: json['description'],
      isDeclarationAccepted: json['isDeclarationAccepted'],
      driverImagePath: json['driverImagePath'],
      dlNo: json['dlNo'],
      dateOfBirth: json['dateOfBirth'] != null && json['dateOfBirth'] != ""
          ? DateTime.parse(json['dateOfBirth'])
          : null,
    );
  }
}

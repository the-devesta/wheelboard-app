class AssignedServiceModel {
  final String assignmentId;
  final String serviceTitle;
  final String description;
  final String status;
  final String vehicleNumber;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String category;
  final double amount;
  final String serviceId;
  final String assignedToUserId;

  AssignedServiceModel({
    required this.assignmentId,
    required this.serviceTitle,
    required this.description,
    required this.status,
    required this.vehicleNumber,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.category,
    required this.amount,
    required this.serviceId,
    required this.assignedToUserId,
  });

  factory AssignedServiceModel.fromJson(Map<String, dynamic> json) {
    return AssignedServiceModel(
      assignmentId: json['assignmentId'],
      serviceTitle: json['serviceTitle'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(), // Ensure double
      serviceId: json['serviceId'] ?? '',
      assignedToUserId: json['assignedToUserId'] ?? '',
    );
  }
}

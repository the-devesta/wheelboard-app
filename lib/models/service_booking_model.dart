class ServiceBookingModel {
  final String assignmentId;
  final String serviceId;
  final String serviceTitle;
  final String customerName;
  final String? customerMobile;
  final String? vehicleNumber;
  final String? description;
  final String status;
  final String scheduledDate;
  final String scheduledTime;
  final dynamic pricingOption;
  final double amount;
  final double? paymentAmount;
  final String? category;
  final String? assignedToUserId;

  ServiceBookingModel({
    required this.assignmentId,
    required this.serviceId,
    required this.serviceTitle,
    required this.customerName,
    this.customerMobile,
    this.vehicleNumber,
    this.description,
    required this.status,
    required this.scheduledDate,
    required this.scheduledTime,
    this.pricingOption,
    required this.amount,
    this.paymentAmount,
    this.category,
    this.assignedToUserId,
  });

  factory ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    return ServiceBookingModel(
      assignmentId: json['assignmentId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceTitle: json['serviceTitle'] ?? 'Service',
      customerName: json['customerName'] ?? 'Customer',
      customerMobile:
          json['customerMobile'] ??
          json['contactNumber'] ??
          json['mobileNumber'],
      vehicleNumber: json['vehicleNumber'],
      description: json['description'],
      status: json['status'] ?? 'Pending',
      scheduledDate: json['scheduledDate'] ?? '',
      scheduledTime: json['scheduledTime'] ?? '',
      pricingOption: json['pricingOption'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentAmount: json['paymentAmount'] != null
          ? (json['paymentAmount']).toDouble()
          : null,
      category: json['category'],
      assignedToUserId: json['assignedToUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'vehicleNumber': vehicleNumber,
      'description': description,
      'status': status,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'pricingOption': pricingOption,
      'amount': amount,
      'paymentAmount': paymentAmount,
      'category': category,
      'assignedToUserId': assignedToUserId,
    };
  }
}

class ReferralModel {
  final String referralId;
  final String fullName;
  final String role;
  final String referralStatus;
  final String createdDate;

  ReferralModel({
    required this.referralId,
    required this.fullName,
    required this.role,
    required this.referralStatus,
    required this.createdDate,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralId: json['referralId'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      referralStatus: json['referralStatus'] ?? '',
      createdDate: json['referralDate'] ?? '',
    );
  }
}

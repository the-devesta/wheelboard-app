class ReferralModel {
  final String referralId;
  final String fullName;
  final String role;
  final String referralStatus;
  final String createdDate; // optional if backend gives later

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
      createdDate: '', // backend se aaye to map kar lena
    );
  }

  bool get isAccepted => referralStatus == "ACCEPTED";
}

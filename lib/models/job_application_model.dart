class JobApplicationModel {
  final String applicationId;
  final String fullName;
  final String profileImage;
  final String location;
  final String? jobTitle;
  final int salaryExpectation;
  final String status;
  final String appliedDate;
  final String remarks;
  final String contactNumber;
  final String userId;

  JobApplicationModel({
    required this.applicationId,
    required this.fullName,
    required this.profileImage,
    required this.location,
    this.jobTitle,
    required this.salaryExpectation,
    required this.status,
    required this.appliedDate,
    required this.remarks,
    this.contactNumber = '',
    required this.userId,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      applicationId: json['applicationId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      location: json['location'] as String? ?? '',
      jobTitle: json['jobTitle'] as String?,
      salaryExpectation: (json['salaryExpectation'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Pending',
      appliedDate: json['appliedDate'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      contactNumber:
          json['contactNumber'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'fullName': fullName,
      'profileImage': profileImage,
      'location': location,
      'jobTitle': jobTitle,
      'salaryExpectation': salaryExpectation,
      'status': status,
      'appliedDate': appliedDate,
      'remarks': remarks,
      'contactNumber': contactNumber,
      'userId': userId,
    };
  }

  JobApplicationModel copyWith({
    String? applicationId,
    String? fullName,
    String? profileImage,
    String? location,
    String? jobTitle,
    int? salaryExpectation,
    String? status,
    String? appliedDate,
    String? remarks,
    String? contactNumber,
    String? userId,
  }) {
    return JobApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      jobTitle: jobTitle ?? this.jobTitle,
      salaryExpectation: salaryExpectation ?? this.salaryExpectation,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      remarks: remarks ?? this.remarks,
      contactNumber: contactNumber ?? this.contactNumber,
      userId: userId ?? this.userId,
    );
  }
}

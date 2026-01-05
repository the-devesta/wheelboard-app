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
  final String? jobId;
  final String? jobDuration;
  final int? salary;

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
    this.jobId,
    this.jobDuration,
    this.salary,
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
      jobId: json['jobId'] as String?,
      jobDuration: json['jobDuration'] as String?,
      salary: (json['salary'] as num?)?.toInt(),
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
      'jobId': jobId,
      'jobDuration': jobDuration,
      'salary': salary,
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
    String? jobId,
    String? jobDuration,
    int? salary,
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
      jobId: jobId ?? this.jobId,
      jobDuration: jobDuration ?? this.jobDuration,
      salary: salary ?? this.salary,
    );
  }
}

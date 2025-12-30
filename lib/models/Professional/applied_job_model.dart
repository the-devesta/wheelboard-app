class AppliedJob {
  final String applicationId;
  final String jobId;
  final int salary;
  final String jobRole;
  final String jobDuration;
  final String jobCity;
  final String jobType;
  final String jobDescription;
  final String userId;
  final String fullName;
  final String userLocation;
  final DateTime appliedDate;
  final String status;
  final int salaryExpectation;
  final String remarks;

  AppliedJob({
    required this.applicationId,
    required this.jobId,
    required this.salary,
    required this.jobRole,
    required this.jobDuration,
    required this.jobCity,
    required this.jobType,
    required this.jobDescription,
    required this.userId,
    required this.fullName,
    required this.userLocation,
    required this.appliedDate,
    required this.status,
    required this.salaryExpectation,
    required this.remarks,
  });

  factory AppliedJob.fromJson(Map<String, dynamic> json) {
    // Helper function to convert salary to int (handles both int and double)
    int parseSalary(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed?.toInt() ?? 0;
      }
      return 0;
    }

    return AppliedJob(
      applicationId: json['applicationId'] ?? '',
      jobId: json['jobId'] ?? '',
      salary: parseSalary(json['salary']),
      jobRole: json['jobRole'] ?? '',
      jobDuration: json['jobDuration'] ?? '',
      jobCity: json['jobCity'] ?? '',
      jobType: json['jobType'] ?? '',
      jobDescription: json['jobDescription'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      userLocation: json['userLocation'] ?? '',
      appliedDate: json['appliedDate'] != null
          ? DateTime.parse(json['appliedDate'])
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      salaryExpectation: parseSalary(json['salaryExpectation']),
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'salary': salary,
      'jobRole': jobRole,
      'jobDuration': jobDuration,
      'jobCity': jobCity,
      'jobType': jobType,
      'jobDescription': jobDescription,
      'userId': userId,
      'fullName': fullName,
      'userLocation': userLocation,
      'appliedDate': appliedDate.toIso8601String(),
      'status': status,
      'salaryExpectation': salaryExpectation,
      'remarks': remarks,
    };
  }

  // Helper method to format date
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[appliedDate.month - 1]} ${appliedDate.day}, ${appliedDate.year}';
  }

  // Helper method to check if status is accepted
  bool get isAccepted => status.toLowerCase() == 'accepted';

  // Helper method to check if status is rejected
  bool get isRejected => status.toLowerCase() == 'rejected';

  // Helper method to check if status is pending
  bool get isPending => status.toLowerCase() == 'pending';
}

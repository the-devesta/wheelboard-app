class JobModel {
  final String jobId;
  final String role;
  final String jobDuration;
  final int openings;
  final int salary;
  final String city;
  final String jobType;
  final String description;
  final List<String> imagePaths;

  JobModel({
    required this.jobId,
    required this.role,
    required this.jobDuration,
    required this.openings,
    required this.salary,
    required this.city,
    required this.jobType,
    required this.description,
    required this.imagePaths,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['jobId'] as String? ?? '',
      role: json['role'] as String? ?? '',
      jobDuration: json['jobDuration'] as String? ?? '',
      openings: (json['openings'] as num?)?.toInt() ?? 0,
      salary: (json['salary'] as num?)?.toInt() ?? 0,
      city: json['city'] as String? ?? '',
      jobType: json['jobType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePaths: (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'role': role,
      'jobDuration': jobDuration,
      'openings': openings,
      'salary': salary,
      'city': city,
      'jobType': jobType,
      'description': description,
      'imagePaths': imagePaths,
    };
  }
}


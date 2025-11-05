class OpenJob {
  final String jobId;
  final String role;
  final String jobDuration;
  final int openings;
  final double salary; // Changed to double to handle both int and double from API
  final String city;
  final String jobType;
  final String description;
  final List<String> imagePaths;

  OpenJob({
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

  factory OpenJob.fromJson(Map<String, dynamic> json) {
    // Handle salary as both int and double
    double salaryValue = 0.0;
    if (json['salary'] != null) {
      if (json['salary'] is int) {
        salaryValue = (json['salary'] as int).toDouble();
      } else if (json['salary'] is double) {
        salaryValue = json['salary'] as double;
      }
    }

    return OpenJob(
      jobId: json['jobId'] ?? '',
      role: json['role'] ?? '',
      jobDuration: json['jobDuration'] ?? '',
      openings: json['openings'] ?? 0,
      salary: salaryValue,
      city: json['city'] ?? '',
      jobType: json['jobType'] ?? '',
      description: json['description'] ?? '',
      imagePaths: json['imagePaths'] != null
          ? List<String>.from(json['imagePaths'])
          : [],
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


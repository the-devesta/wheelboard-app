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
  final int likeCount;
  final bool isLiked;
  final String? companyName;

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
    this.likeCount = 0,
    this.isLiked = false,
    this.companyName,
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
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] == null
          ? false
          : (json['isLiked'] is bool ? json['isLiked'] as bool : false),
      companyName: json['companyName'] as String?,
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
      'likeCount': likeCount,
      'isLiked': isLiked,
      'companyName': companyName,
    };
  }

  JobModel copyWith({
    String? jobId,
    String? role,
    String? jobDuration,
    int? openings,
    int? salary,
    String? city,
    String? jobType,
    String? description,
    List<String>? imagePaths,
    int? likeCount,
    bool? isLiked,
    String? companyName,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      role: role ?? this.role,
      jobDuration: jobDuration ?? this.jobDuration,
      openings: openings ?? this.openings,
      salary: salary ?? this.salary,
      city: city ?? this.city,
      jobType: jobType ?? this.jobType,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      companyName: companyName ?? this.companyName,
    );
  }
}

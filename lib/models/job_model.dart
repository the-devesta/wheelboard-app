import 'job_application_model.dart';

/// Job model — a 1:1 Dart mirror of the backend `buildJobResponse`
/// (`wheelboard-be/src/jobs/job.service.ts`) and the FE `Job` type
/// (`wheelboard-fe/src/lib/api.ts`).
///
/// Legacy getters (`jobId`, `role`, `jobType`, `jobDuration`, `imagePaths`,
/// `companyName`, `companyLogo`) are kept so existing screens keep compiling
/// while they migrate to the canonical field names.
class JobModel {
  final String id;
  final String employerId;
  final String employerType; // company | business
  final String employerName;
  final String? employerLogo;
  final String title;
  final String location;
  final String city;
  final String? state;
  final String type; // Driver | Technician | Helper
  final String salary; // display text e.g. "₹25,000 - ₹35,000/month"
  final int? salaryMin;
  final int? salaryMax;
  final String description;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> skills;
  final String? image;
  final int openings;
  final String duration; // Permanent | Task-based | Temporary | ...
  final String status; // Active | Paused | Closed
  final bool urgent;
  final int views;
  final List<JobApplication> applications;
  final List<String> savedBy;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// The current professional's own application on this job, present only on
  /// the `GET /jobs/my-applications` response (`myApplication`).
  final JobApplication? myApplication;

  /// Whether the current user has saved/bookmarked this job. Derived from
  /// [savedBy] or the `my-saved` list and toggled optimistically by the UI.
  final bool isSaved;

  /// Whether the current user has already applied. Derived by checking
  /// [applications] against the current user id (browse response has no flag).
  final bool isApplied;

  JobModel({
    required this.id,
    this.employerId = '',
    this.employerType = '',
    this.employerName = '',
    this.employerLogo,
    required this.title,
    this.location = '',
    required this.city,
    this.state,
    required this.type,
    this.salary = '',
    this.salaryMin,
    this.salaryMax,
    this.description = '',
    this.requirements = const [],
    this.benefits = const [],
    this.skills = const [],
    this.image,
    this.openings = 0,
    this.duration = '',
    this.status = 'Active',
    this.urgent = false,
    this.views = 0,
    this.applications = const [],
    this.savedBy = const [],
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.myApplication,
    this.isSaved = false,
    this.isApplied = false,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final appsList = json['applications'] as List<dynamic>? ?? const [];
    final myApp = json['myApplication'];

    return JobModel(
      id: json['id']?.toString() ?? json['jobId']?.toString() ?? '',
      employerId: json['employerId']?.toString() ?? '',
      employerType: json['employerType']?.toString() ?? '',
      employerName: json['employerName']?.toString() ??
          json['companyName']?.toString() ??
          json['businessName']?.toString() ??
          '',
      employerLogo:
          json['employerLogo']?.toString() ?? json['companyLogo']?.toString(),
      title: json['title']?.toString() ?? json['role']?.toString() ?? '',
      location: json['location']?.toString() ?? json['city']?.toString() ?? '',
      city: json['city']?.toString() ?? json['location']?.toString() ?? '',
      state: json['state']?.toString(),
      type: json['type']?.toString() ?? json['jobType']?.toString() ?? '',
      salary: _salaryText(json['salary']),
      salaryMin: (json['salaryMin'] as num?)?.toInt(),
      salaryMax: (json['salaryMax'] as num?)?.toInt(),
      description: json['description']?.toString() ?? '',
      requirements: _parseStringList(json['requirements']),
      benefits: _parseStringList(json['benefits']),
      skills: _parseStringList(json['skills']),
      image: (json['image']?.toString().isNotEmpty ?? false)
          ? json['image'].toString()
          : null,
      openings: (json['openings'] as num?)?.toInt() ?? 0,
      duration:
          json['duration']?.toString() ?? json['jobDuration']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      urgent: json['urgent'] as bool? ?? false,
      views: (json['views'] as num?)?.toInt() ?? 0,
      applications: appsList
          .whereType<Map<String, dynamic>>()
          .map(JobApplication.fromJson)
          .toList(),
      savedBy: _parseStringList(json['savedBy']),
      expiresAt: _parseDate(json['expiresAt']),
      createdAt: _parseDate(json['createdAt'] ?? json['dateEntered']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['dateModified']),
      myApplication: myApp is Map<String, dynamic>
          ? JobApplication.fromJson(myApp)
          : null,
    );
  }

  // ── Backward-compatibility getters (legacy field names) ───────────────────
  String get jobId => id;
  String get role => title;
  String get jobType => type;
  String get jobDuration => duration;
  String? get companyName => employerName.isNotEmpty ? employerName : null;
  String? get companyLogo => employerLogo;
  List<String> get imagePaths =>
      (image != null && image!.isNotEmpty) ? [image!] : const [];
  int get applicationCount => applications.length;

  /// Best-effort numeric salary (min, else first number found in the text).
  int get salaryAmount {
    if (salaryMin != null) return salaryMin!;
    final digits = salary.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits) ?? 0;
  }

  bool isSavedBy(String userId) =>
      isSaved || (userId.isNotEmpty && savedBy.contains(userId));

  bool isAppliedBy(String userId) =>
      isApplied ||
      (userId.isNotEmpty &&
          applications.any((a) => a.applicantId == userId));

  JobModel copyWith({
    String? id,
    String? employerId,
    String? employerType,
    String? employerName,
    String? employerLogo,
    String? title,
    String? location,
    String? city,
    String? state,
    String? type,
    String? salary,
    int? salaryMin,
    int? salaryMax,
    String? description,
    List<String>? requirements,
    List<String>? benefits,
    List<String>? skills,
    String? image,
    int? openings,
    String? duration,
    String? status,
    bool? urgent,
    int? views,
    List<JobApplication>? applications,
    List<String>? savedBy,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    JobApplication? myApplication,
    bool? isSaved,
    bool? isApplied,
  }) {
    return JobModel(
      id: id ?? this.id,
      employerId: employerId ?? this.employerId,
      employerType: employerType ?? this.employerType,
      employerName: employerName ?? this.employerName,
      employerLogo: employerLogo ?? this.employerLogo,
      title: title ?? this.title,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      type: type ?? this.type,
      salary: salary ?? this.salary,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      skills: skills ?? this.skills,
      image: image ?? this.image,
      openings: openings ?? this.openings,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      urgent: urgent ?? this.urgent,
      views: views ?? this.views,
      applications: applications ?? this.applications,
      savedBy: savedBy ?? this.savedBy,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      myApplication: myApplication ?? this.myApplication,
      isSaved: isSaved ?? this.isSaved,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  static String _salaryText(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

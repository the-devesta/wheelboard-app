/// Job application model — a 1:1 Dart mirror of the backend `buildApplications`
/// output (`wheelboard-be/src/jobs/job.service.ts`) and the FE `JobApplication`
/// type (`wheelboard-fe/src/lib/api.ts`).
///
/// Status is the backend's normalized lowercase enum:
/// `pending | reviewed | shortlisted | rejected | hired`.
class JobApplication {
  final String id;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String? applicantAvatar;
  final String? coverLetter;
  final String experience;
  final String? expectedSalary;
  final String? resume;
  final String? availability;
  final String status;
  final DateTime? appliedAt;
  final DateTime? reviewedAt;
  final String? notes;

  JobApplication({
    required this.id,
    required this.applicantId,
    this.applicantName = '',
    this.applicantEmail = '',
    this.applicantPhone = '',
    this.applicantAvatar,
    this.coverLetter,
    this.experience = '',
    this.expectedSalary,
    this.resume,
    this.availability,
    this.status = 'pending',
    this.appliedAt,
    this.reviewedAt,
    this.notes,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id']?.toString() ?? json['applicationId']?.toString() ?? '',
      applicantId:
          json['applicantId']?.toString() ?? json['userId']?.toString() ?? '',
      applicantName: json['applicantName']?.toString() ??
          json['fullName']?.toString() ??
          '',
      applicantEmail: json['applicantEmail']?.toString() ?? '',
      applicantPhone: json['applicantPhone']?.toString() ??
          json['contactNumber']?.toString() ??
          json['phoneNumber']?.toString() ??
          '',
      applicantAvatar: json['applicantAvatar']?.toString() ??
          json['profileImage']?.toString(),
      coverLetter: json['coverLetter']?.toString(),
      experience: json['experience']?.toString() ?? '',
      expectedSalary: json['expectedSalary']?.toString(),
      resume: json['resume']?.toString(),
      availability: json['availability']?.toString(),
      status: _normalizeStatus(json['status']?.toString()),
      appliedAt: _parseDate(json['appliedAt'] ?? json['appliedDate']),
      reviewedAt: _parseDate(json['reviewedAt']),
      notes: json['notes']?.toString() ?? json['remarks']?.toString(),
    );
  }

  /// The five canonical statuses, in pipeline order.
  static const List<String> statuses = [
    'pending',
    'reviewed',
    'shortlisted',
    'rejected',
    'hired',
  ];

  static String _normalizeStatus(String? raw) {
    final s = (raw ?? '').toLowerCase();
    return statuses.contains(s) ? s : 'pending';
  }

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isShortlisted => status == 'shortlisted';
  bool get isRejected => status == 'rejected';
  bool get isHired => status == 'hired';

  /// Capitalized label for display, e.g. `shortlisted` → `Shortlisted`.
  String get statusLabel =>
      status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1);

  String get appliedDateFormatted {
    final d = appliedAt;
    if (d == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Backward-compatibility getters (legacy field names) ───────────────────
  String get applicationId => id;
  String get userId => applicantId;
  String get fullName => applicantName;
  String get profileImage => applicantAvatar ?? '';
  String get contactNumber => applicantPhone;
  String get remarks => notes ?? coverLetter ?? '';
  String get appliedDate => appliedAt?.toIso8601String() ?? '';

  JobApplication copyWith({
    String? id,
    String? applicantId,
    String? applicantName,
    String? applicantEmail,
    String? applicantPhone,
    String? applicantAvatar,
    String? coverLetter,
    String? experience,
    String? expectedSalary,
    String? resume,
    String? availability,
    String? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? notes,
  }) {
    return JobApplication(
      id: id ?? this.id,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantAvatar: applicantAvatar ?? this.applicantAvatar,
      coverLetter: coverLetter ?? this.coverLetter,
      experience: experience ?? this.experience,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      resume: resume ?? this.resume,
      availability: availability ?? this.availability,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      notes: notes ?? this.notes,
    );
  }
}

/// Legacy alias for code still referencing `JobApplicationModel`.
typedef JobApplicationModel = JobApplication;

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

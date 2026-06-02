// Hired professional models — mirror the backend `getHiredProfessionals`
// output (`wheelboard-be/src/jobs/job.service.ts`) and the FE
// `HiredProfessional` / `HiredProfessionalsStats` types.

class HiredJobInfo {
  final String jobId;
  final String jobTitle;
  final DateTime? hiredAt;
  final String status; // onboarding | active | completed
  final DateTime? completedAt;

  const HiredJobInfo({
    required this.jobId,
    required this.jobTitle,
    this.hiredAt,
    this.status = 'onboarding',
    this.completedAt,
  });

  factory HiredJobInfo.fromJson(Map<String, dynamic> json) {
    return HiredJobInfo(
      jobId: json['jobId']?.toString() ?? '',
      jobTitle: json['jobTitle']?.toString() ?? '',
      hiredAt: _parseDate(json['hiredAt']),
      status: json['status']?.toString() ?? 'onboarding',
      completedAt: _parseDate(json['completedAt']),
    );
  }
}

class HiredProfessionalProfile {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? city;
  final String? state;
  final String? licenseNumber;
  final String? vehicleType;
  final int? experience;
  final double? rating;
  final String? avatar;
  final List<String> skills;

  const HiredProfessionalProfile({
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.city,
    this.state,
    this.licenseNumber,
    this.vehicleType,
    this.experience,
    this.rating,
    this.avatar,
    this.skills = const [],
  });

  factory HiredProfessionalProfile.fromJson(Map<String, dynamic> json) {
    return HiredProfessionalProfile(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      licenseNumber: json['licenseNumber']?.toString(),
      vehicleType: json['vehicleType']?.toString(),
      experience: (json['experience'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      avatar: json['avatar']?.toString(),
      skills: (json['skills'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class HiredProfessional {
  final String id;
  final String email;
  final HiredProfessionalProfile profile;
  final HiredJobInfo? hiredJobInfo;

  const HiredProfessional({
    required this.id,
    this.email = '',
    this.profile = const HiredProfessionalProfile(),
    this.hiredJobInfo,
  });

  factory HiredProfessional.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    final hiredJson = json['hiredJobInfo'];
    return HiredProfessional(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profile: profileJson is Map<String, dynamic>
          ? HiredProfessionalProfile.fromJson(profileJson)
          : const HiredProfessionalProfile(),
      hiredJobInfo: hiredJson is Map<String, dynamic>
          ? HiredJobInfo.fromJson(hiredJson)
          : null,
    );
  }
}

/// Hired professionals statistics (`GET /jobs/hired-professionals/stats`).
class HiredProfessionalsStats {
  final int total;
  final int onboarding;
  final int active;
  final int completed;

  const HiredProfessionalsStats({
    this.total = 0,
    this.onboarding = 0,
    this.active = 0,
    this.completed = 0,
  });

  factory HiredProfessionalsStats.fromJson(Map<String, dynamic> json) {
    return HiredProfessionalsStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      onboarding: (json['onboarding'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

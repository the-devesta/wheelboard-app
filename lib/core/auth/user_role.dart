/// User roles matching the NestJS backend `UserRole` enum
/// from `wheelboard-be/src/database/enums/user.enums.ts`
/// and `wheelboard-fe/src/lib/api.ts`.
enum UserRole {
  admin('admin'),
  superAdmin('super_admin'),
  professional('professional'),
  business('business'),
  company('company');

  final String value;
  const UserRole(this.value);

  /// Parse a role string from the backend into a [UserRole].
  /// Falls back to [UserRole.professional] (same as wheelboard-fe).
  static UserRole fromString(String? raw) {
    if (raw == null || raw.isEmpty) return UserRole.professional;
    final normalized = raw.toLowerCase().trim();
    for (final role in UserRole.values) {
      if (role.value == normalized) return role;
    }
    // Legacy mapping: the old app stored "Transport" / "Service Provider"
    if (normalized == 'transport') return UserRole.company;
    if (normalized == 'service provider') return UserRole.business;
    return UserRole.professional;
  }
}

/// User status matching backend `UserStatus` enum.
enum UserStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  pending('pending');

  final String value;
  const UserStatus(this.value);

  static UserStatus fromString(String? raw) {
    if (raw == null || raw.isEmpty) return UserStatus.pending;
    final normalized = raw.toLowerCase().trim();
    for (final s in UserStatus.values) {
      if (s.value == normalized) return s;
    }
    return UserStatus.pending;
  }
}

/// Professional type matching backend `ProfessionalType` enum.
enum ProfessionalType {
  driver('driver'),
  transportProvider('transport_provider'),
  serviceProvider('service_provider'),
  mechanic('mechanic');

  final String value;
  const ProfessionalType(this.value);

  static ProfessionalType? fromString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.toLowerCase().trim();
    for (final t in ProfessionalType.values) {
      if (t.value == normalized) return t;
    }
    return null;
  }
}

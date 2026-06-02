import 'dart:convert';

import 'user_role.dart';

/// Tokens returned by the backend on login / register / refresh.
/// Matches `AuthTokens` interface in `wheelboard-fe/src/lib/api.ts`.
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}

/// Unified user model matching the backend `SqlUserResponse` shape
/// and the frontend `User` interface in `wheelboard-fe/src/lib/api.ts`.
class AppUser {
  final String id;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final UserStatus status;
  final String? customId;
  final Map<String, dynamic> profile;
  final bool twoFactorEnabled;
  final String? createdAt;
  final String? updatedAt;

  const AppUser({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.status,
    this.customId,
    this.profile = const {},
    this.twoFactorEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> profile = {};
    final rawProfile = json['profile'];
    if (rawProfile is Map<String, dynamic>) {
      profile = rawProfile;
    } else if (rawProfile is String && rawProfile.isNotEmpty) {
      try {
        profile = Map<String, dynamic>.from(jsonDecode(rawProfile) as Map);
      } catch (_) {}
    }

    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      role: UserRole.fromString(json['role']?.toString()),
      status: UserStatus.fromString(json['status']?.toString()),
      customId: json['customId']?.toString(),
      profile: profile,
      twoFactorEnabled: json['twoFactorEnabled'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role.value,
        'status': status.value,
        'customId': customId,
        'profile': profile,
        'twoFactorEnabled': twoFactorEnabled,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  /// Convenience getters for profile fields used across the app.
  String get fullName {
    final first = profile['firstName']?.toString() ?? '';
    final last = profile['lastName']?.toString() ?? '';
    final full = profile['fullName']?.toString() ?? '';
    if (full.isNotEmpty) return full;
    return '$first $last'.trim();
  }

  String get companyName =>
      profile['companyName']?.toString() ??
      profile['businessName']?.toString() ??
      '';

  String get displayName {
    if (role == UserRole.company || role == UserRole.business) {
      return companyName.isNotEmpty ? companyName : fullName;
    }
    return fullName;
  }

  bool get isKYCCompleted {
    // Mirror wheelboard-fe's isKycVerified logic:
    // isKycVerified(kycStatus) || isKycVerified(kycOverallStatus) || isVerified
    final kycStatus = profile['kycStatus']?.toString().toLowerCase();
    final kycOverallStatus =
        profile['kycOverallStatus']?.toString().toLowerCase();
    return kycStatus == 'verified' ||
        kycOverallStatus == 'verified' ||
        profile['isVerified'] == true ||
        profile['kycCompleted'] == true ||
        profile['isKYCCompleted'] == true;
  }

  /// Mirrors wheelboard-fe's profile completion check.
  ///
  /// company (home/page.tsx): address && city && state
  ///   → backend stores only `address` for companies (no separate city/state entity)
  ///   → so we check address is present (only collected in complete-profile form)
  ///
  /// business (home/page.tsx): businessType && address && city && state
  ///   → we check businessType && address (city is in allied_business entity
  ///     but may not always be populated from legacy sync)
  bool get isProfileComplete {
    final addr = profile['address']?.toString().trim() ?? '';
    switch (role) {
      case UserRole.company:
        // Transport companies: address is only set after the complete-profile form
        return addr.isNotEmpty;
      case UserRole.business:
        final bType = profile['businessType']?.toString().trim() ??
            profile['businessCategory']?.toString().trim() ?? '';
        return bType.isNotEmpty && addr.isNotEmpty;
      default:
        // Professionals and others have no profile-completion gate
        return true;
    }
  }

  bool get isHired {
    final hiredJobs = profile['hiredJobs'];
    if (hiredJobs is List && hiredJobs.isNotEmpty) return true;
    return profile['isHired'] == true;
  }
}

/// Full auth response from `POST /api/auth/login` and `POST /api/auth/register`.
/// Matches `{ user, tokens: { accessToken, refreshToken }, sessionId? }`.
class AuthResponse {
  final AppUser user;
  final AuthTokens tokens;
  final String? sessionId;

  const AuthResponse({
    required this.user,
    required this.tokens,
    this.sessionId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      tokens: AuthTokens.fromJson(
        json['tokens'] as Map<String, dynamic>? ?? {},
      ),
      sessionId: json['sessionId']?.toString(),
    );
  }
}

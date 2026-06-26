import '../core/auth/auth_models.dart';
import '../core/auth/user_role.dart';

/// Common User Profile Model
/// Handles Company/Transport, Professional, and Service Provider profile types
class UserProfileModel {
  final String userId;
  final String userType; // 'Company', 'Professional', 'ServiceProvider'

  // Common fields
  final String? mobileNo;

  // Company/Transport fields
  final String? companyName;
  final String? gstNumber;
  final String? businessCategory;
  final String? companyLogoPath;
  final String? fullName;
  final String? address;
  final String? fleetSize;

  // Professional fields
  final String? name;
  final String? fatherName;
  final String? email;
  final String? dateOfBirth;
  final String? state;
  final String? city;
  final String? professionalType;
  final String? profileImagePath;

  // Service Provider fields
  final String? businessName;
  final String? businessType;
  final String? businessLogoPath;
  final String? servicesOffered;

  // KYC related fields
  final bool? isKYCCompleted;

  UserProfileModel({
    required this.userId,
    required this.userType,
    this.mobileNo,
    // Company fields
    this.companyName,
    this.gstNumber,
    this.businessCategory,
    this.companyLogoPath,
    this.fullName,
    this.address,
    this.fleetSize,
    // Professional fields
    this.name,
    this.fatherName,
    this.email,
    this.dateOfBirth,
    this.state,
    this.city,
    this.professionalType,
    this.profileImagePath,
    // Service Provider fields
    this.businessName,
    this.businessType,
    this.businessLogoPath,
    this.servicesOffered,
    // KYC fields
    this.isKYCCompleted,
  });

  /// Build from the authenticated [AppUser] returned by GET /auth/profile.
  factory UserProfileModel.fromAppUser(AppUser user) {
    final p = user.profile;
    return UserProfileModel(
      userId: user.id,
      userType: user.role.value,
      mobileNo: user.phoneNumber,
      companyName: p['companyName']?.toString(),
      gstNumber: p['gstNumber']?.toString(),
      businessCategory: p['businessCategory']?.toString(),
      companyLogoPath: p['logo']?.toString() ?? p['companyLogoPath']?.toString(),
      fullName: _deriveName(p),
      address: p['address']?.toString(),
      fleetSize: p['fleetSize']?.toString(),
      name: _deriveName(p),
      fatherName: p['fatherName']?.toString(),
      email: user.email,
      dateOfBirth: p['dateOfBirth']?.toString(),
      state: p['state']?.toString(),
      city: p['city']?.toString(),
      professionalType: p['professionalType']?.toString(),
      profileImagePath: p['avatar']?.toString() ?? p['profileImage']?.toString(),
      businessName: p['businessName']?.toString(),
      businessType: p['businessType']?.toString(),
      businessLogoPath: p['logo']?.toString() ?? p['businessLogoPath']?.toString(),
      servicesOffered: _joinList(p['servicesOffered']),
      isKYCCompleted: user.isKYCCompleted,
    );
  }

  static String? _joinList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.join(', ');
    return value.toString();
  }

  /// Resolve a display name from a raw profile map. Prefers `fullName`, then
  /// falls back to `firstName` + `lastName` (professionals are often stored with
  /// first/last only), so the profile view never shows a blank/placeholder name.
  static String? _deriveName(Map<String, dynamic> p) {
    final full = p['fullName']?.toString().trim() ?? '';
    if (full.isNotEmpty) return full;
    final first = p['firstName']?.toString().trim() ?? '';
    final last = p['lastName']?.toString().trim() ?? '';
    final combined = [first, last].where((s) => s.isNotEmpty).join(' ').trim();
    return combined.isNotEmpty ? combined : null;
  }

  /// Build from GET /users/:id/public-profile response.
  /// Response shape: { id, email, role, profile: { ... } }
  factory UserProfileModel.fromPublicProfile(Map<String, dynamic> json) {
    final p = json['profile'] as Map<String, dynamic>? ?? {};
    return UserProfileModel(
      userId: json['id']?.toString() ?? '',
      userType: json['role']?.toString() ?? '',
      email: json['email']?.toString(),
      mobileNo: p['mobileNo']?.toString() ?? p['phoneNumber']?.toString(),
      companyName: p['companyName']?.toString(),
      gstNumber: p['gstNumber']?.toString(),
      businessCategory: p['businessCategory']?.toString(),
      companyLogoPath: p['logo']?.toString() ?? p['companyLogoPath']?.toString(),
      fullName: _deriveName(p),
      address: p['address']?.toString(),
      fleetSize: p['fleetSize']?.toString(),
      name: _deriveName(p),
      fatherName: p['fatherName']?.toString(),
      dateOfBirth: p['dateOfBirth']?.toString(),
      state: p['state']?.toString(),
      city: p['city']?.toString(),
      professionalType: p['professionalType']?.toString(),
      profileImagePath: p['avatar']?.toString() ?? p['profileImage']?.toString(),
      businessName: p['businessName']?.toString(),
      businessType: p['businessType']?.toString(),
      businessLogoPath: p['logo']?.toString() ?? p['businessLogoPath']?.toString(),
      servicesOffered: _joinList(p['servicesOffered']),
      isKYCCompleted: p['isKYCCompleted'] as bool?,
    );
  }

  /// Factory constructor to create from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final userType = json['userType'] as String? ?? '';

    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      userType: userType,
      mobileNo: json['mobileNo'] as String?,

      // Company/Transport fields
      companyName: json['companyName'] as String?,
      gstNumber: json['gstNumber'] as String?,
      businessCategory: json['businessCategory'] as String?,
      companyLogoPath: json['companyLogoPath'] as String?,
      fullName: json['fullName'] as String?,
      address: json['address'] as String?,
      fleetSize: json['fleetSize'] as String?,

      // Professional fields
      name: json['name'] as String?,
      fatherName: json['fatherName'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      professionalType: json['professionalType'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      // Service Provider fields
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      businessLogoPath: json['businessLogoPath'] as String?,
      servicesOffered: json['servicesOffered'] as String?,
      // KYC fields
      isKYCCompleted: json['isKYCCompleted'] as bool?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'mobileNo': mobileNo,
      // Company fields
      if (companyName != null) 'companyName': companyName,
      if (gstNumber != null) 'gstNumber': gstNumber,
      if (businessCategory != null) 'businessCategory': businessCategory,
      if (companyLogoPath != null) 'companyLogoPath': companyLogoPath,
      if (fullName != null) 'fullName': fullName,
      if (address != null) 'address': address,
      if (fleetSize != null) 'fleetSize': fleetSize,
      // Professional fields
      if (name != null) 'name': name,
      if (fatherName != null) 'fatherName': fatherName,
      if (email != null) 'email': email,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
      if (professionalType != null) 'professionalType': professionalType,
      if (profileImagePath != null) 'profileImagePath': profileImagePath,
      // Service Provider fields
      if (businessName != null) 'businessName': businessName,
      if (businessType != null) 'businessType': businessType,
      if (businessLogoPath != null) 'businessLogoPath': businessLogoPath,
      if (servicesOffered != null) 'servicesOffered': servicesOffered,
      // KYC fields
      if (isKYCCompleted != null) 'isKYCCompleted': isKYCCompleted,
    };
  }

  /// Parsed role enum from the raw [userType] string.
  UserRole get _role => UserRole.fromString(userType);

  /// Check if user is Company/Transport
  bool get isCompany => _role == UserRole.company;

  /// Check if user is Professional
  bool get isProfessional => _role == UserRole.professional;

  /// Check if user is Service Provider
  bool get isServiceProvider => _role == UserRole.business;

  /// Get display name based on user type
  String get displayName {
    if (isCompany) {
      return companyName ?? 'N/A';
    } else if (isProfessional) {
      return name ?? 'N/A';
    } else if (isServiceProvider) {
      return businessName ?? 'N/A';
    }
    return 'N/A';
  }

  /// Get profile image path based on user type
  String? get profileImage {
    if (isCompany) {
      return companyLogoPath;
    } else if (isProfessional) {
      return profileImagePath;
    } else if (isServiceProvider) {
      return businessLogoPath;
    }
    return null;
  }
}

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
    // KYC fields
    this.isKYCCompleted,
  });

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
      // KYC fields
      if (isKYCCompleted != null) 'isKYCCompleted': isKYCCompleted,
    };
  }

  /// Check if user is Company/Transport
  bool get isCompany =>
      userType.toLowerCase() == 'company' ||
      userType.toLowerCase() == 'transport';

  /// Check if user is Professional
  bool get isProfessional => userType.toLowerCase() == 'professional';

  /// Check if user is Service Provider
  bool get isServiceProvider =>
      userType.toLowerCase() == 'serviceprovider' ||
      userType.toLowerCase() == 'service provider';

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

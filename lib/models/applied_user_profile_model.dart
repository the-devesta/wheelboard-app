class AppliedUserProfile {
  final String userId;
  final String profileName;
  final String email;
  final String phone;
  final String address;
  final String profileImage;
  final String profileType;

  AppliedUserProfile({
    required this.userId,
    required this.profileName,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.profileType,
  });

  factory AppliedUserProfile.fromJson(Map<String, dynamic> json) {
    // Backend `getApplicantProfile` returns
    // `{ id, email, role, status, profile: {...} }` with the personal fields
    // nested under `profile`. Fall back to flat keys for legacy payloads.
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : json;

    final firstName = profile['firstName']?.toString() ?? '';
    final lastName = profile['lastName']?.toString() ?? '';
    final composedName = '$firstName $lastName'.trim();
    final addressParts = [
      profile['address']?.toString(),
      profile['city']?.toString(),
      profile['state']?.toString(),
    ].where((p) => p != null && p.isNotEmpty).cast<String>().toList();

    return AppliedUserProfile(
      userId: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      profileName: composedName.isNotEmpty
          ? composedName
          : (profile['businessName']?.toString() ??
                profile['companyName']?.toString() ??
                json['profileName']?.toString() ??
                ''),
      email: json['email']?.toString() ?? profile['email']?.toString() ?? '',
      phone: profile['phoneNumber']?.toString() ??
          profile['phone']?.toString() ??
          json['phone']?.toString() ??
          '',
      address: addressParts.isNotEmpty
          ? addressParts.join(', ')
          : (json['address']?.toString() ?? ''),
      profileImage: profile['avatar']?.toString() ??
          profile['profileImage']?.toString() ??
          json['profileImage']?.toString() ??
          '',
      profileType: profile['professionalType']?.toString() ??
          json['role']?.toString() ??
          json['profileType']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileName': profileName,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'profileType': profileType,
    };
  }
}

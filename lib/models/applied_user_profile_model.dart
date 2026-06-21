/// Applicant profile — a 1:1 mirror of the backend `getApplicantProfile`
/// (`wheelboard-be/src/jobs/job.service.ts`) which returns
/// `{ id, email, role, status, profile: {...raw professional profile...} }`,
/// and the FE `CandidateProfileModal` (`wheelboard-fe/src/components/shared`).
///
/// Exposes every field the web "View Complete Profile" modal shows so the app's
/// profile sheet renders the same details.
class AppliedUserProfile {
  final String userId;
  final String profileName;
  final String email;
  final String phone;
  final String address;
  final String profileImage;
  final String profileType;

  // ── Extended (web CandidateProfileModal) ──────────────────────────────────
  final String status;
  final String dateOfBirth;
  final String experience;
  final String vehicleType;
  final String licenseNumber;
  final String licenseExpiry;
  final String rating;
  final String totalTrips;
  final List<String> skills;
  final String description;
  final String licenseDoc;
  final String insuranceDoc;
  final String backgroundCheckDoc;

  AppliedUserProfile({
    required this.userId,
    required this.profileName,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.profileType,
    this.status = '',
    this.dateOfBirth = '',
    this.experience = '',
    this.vehicleType = '',
    this.licenseNumber = '',
    this.licenseExpiry = '',
    this.rating = '',
    this.totalTrips = '',
    this.skills = const [],
    this.description = '',
    this.licenseDoc = '',
    this.insuranceDoc = '',
    this.backgroundCheckDoc = '',
  });

  factory AppliedUserProfile.fromJson(Map<String, dynamic> json) {
    // Backend `getApplicantProfile` returns
    // `{ id, email, role, status, profile: {...} }` with the personal fields
    // nested under `profile`. Fall back to flat keys for legacy payloads.
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : json;

    String s(dynamic v) => v?.toString() ?? '';

    final firstName = s(profile['firstName']);
    final lastName = s(profile['lastName']);
    final composedName = '$firstName $lastName'.trim();

    // Address: address, city, state - zipCode (web parity).
    final addr = s(profile['address']);
    final city = s(profile['city']);
    final state = s(profile['state']);
    final zip = s(profile['zipCode']);
    final addressParts = [addr, city, state].where((p) => p.isNotEmpty).toList();
    var address = addressParts.join(', ');
    if (zip.isNotEmpty) address = address.isEmpty ? zip : '$address - $zip';

    final docs = profile['documents'] is Map
        ? Map<String, dynamic>.from(profile['documents'] as Map)
        : const <String, dynamic>{};

    final rawSkills = profile['skills'];
    final skills = rawSkills is List
        ? rawSkills.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return AppliedUserProfile(
      userId: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      profileName: composedName.isNotEmpty
          ? composedName
          : (s(profile['businessName']).isNotEmpty
              ? s(profile['businessName'])
              : s(profile['companyName']).isNotEmpty
                  ? s(profile['companyName'])
                  : s(json['profileName'])),
      email: s(json['email']).isNotEmpty ? s(json['email']) : s(profile['email']),
      phone: s(profile['phoneNumber']).isNotEmpty
          ? s(profile['phoneNumber'])
          : (s(profile['phone']).isNotEmpty
              ? s(profile['phone'])
              : s(json['phoneNumber']).isNotEmpty
                  ? s(json['phoneNumber'])
                  : s(json['phone'])),
      address: address.isNotEmpty ? address : s(json['address']),
      profileImage: s(profile['avatar']).isNotEmpty
          ? s(profile['avatar'])
          : (s(profile['profileImage']).isNotEmpty
              ? s(profile['profileImage'])
              : s(json['profileImage'])),
      profileType: s(profile['professionalType']).isNotEmpty
          ? s(profile['professionalType'])
          : (s(profile['vehicleType']).isNotEmpty
              ? s(profile['vehicleType'])
              : s(json['role']).isNotEmpty
                  ? s(json['role'])
                  : s(json['profileType'])),
      status: s(json['status']),
      dateOfBirth: s(profile['dateOfBirth']),
      experience: s(profile['experience']),
      vehicleType: s(profile['vehicleType']),
      licenseNumber: s(profile['licenseNumber']),
      licenseExpiry: s(profile['licenseExpiry']),
      rating: s(profile['rating']),
      totalTrips: s(profile['totalTrips']),
      skills: skills,
      description: s(profile['description']),
      licenseDoc: s(docs['license']),
      insuranceDoc: s(docs['insurance']),
      backgroundCheckDoc: s(docs['backgroundCheck']),
    );
  }

  bool get hasProfessionalInfo =>
      experience.isNotEmpty ||
      vehicleType.isNotEmpty ||
      licenseNumber.isNotEmpty ||
      licenseExpiry.isNotEmpty ||
      rating.isNotEmpty ||
      totalTrips.isNotEmpty;

  bool get hasDocuments =>
      licenseDoc.isNotEmpty ||
      insuranceDoc.isNotEmpty ||
      backgroundCheckDoc.isNotEmpty;

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

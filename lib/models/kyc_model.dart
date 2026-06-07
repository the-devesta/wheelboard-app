/// KYC models — mirror wheelboard-be `src/kyc/kyc.service.ts` (`toKycResponse`)
/// and the required-documents / completeness responses.
///
/// `professionalType` is resolved by the backend from the caller's role
/// (BUSINESS→service_provider, COMPANY→transport_provider, PROFESSIONAL→driver),
/// so the same model serves all three app roles.
library;

/// KYC document type identifiers (backend `DocumentType`).
class KycDocType {
  static const pan = 'pan';
  static const drivingLicense = 'driving_license';
  static const aadhar = 'aadhar';
  static const bankAccount = 'bank_account';
  static const profilePhoto = 'profile_photo';
  static const registrationCertificate = 'registration_certificate';
  static const taxCertificate = 'tax_certificate';
  static const insurance = 'insurance';

  static String label(String type) {
    switch (type) {
      case pan:
        return 'PAN Card';
      case drivingLicense:
        return 'Driving License';
      case aadhar:
        return 'Aadhaar Card';
      case bankAccount:
        return 'Bank Account';
      case profilePhoto:
        return 'Profile Photo';
      case registrationCertificate:
        return 'Registration Certificate';
      case taxCertificate:
        return 'Tax Certificate';
      case insurance:
        return 'Insurance';
      default:
        return type
            .split('_')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }
}

/// KYC status values (backend `KYCStatus`).
class KycStatus {
  static const pending = 'pending';
  static const verified = 'verified';
  static const rejected = 'rejected';
  static const incomplete = 'incomplete';
}

class KycDocument {
  final String type;
  final String number;
  final String? name;
  final String? fileUrl;
  final String status;

  const KycDocument({
    required this.type,
    required this.number,
    this.name,
    this.fileUrl,
    required this.status,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) => KycDocument(
        type: (json['type'] ?? '').toString(),
        number: (json['number'] ?? '').toString(),
        name: json['name']?.toString(),
        fileUrl: json['fileUrl']?.toString(),
        status: (json['status'] ?? KycStatus.pending).toString(),
      );
}

class Kyc {
  final String professionalType; // driver | transport_provider | service_provider | mechanic
  final String overallStatus; // pending | verified | rejected | incomplete
  final List<KycDocument> documents;

  final String? panNumber;
  final String? panStatus;
  final String? panName; // from panVerificationData when available

  final String? dlNumber;
  final String? dlStatus;
  final String? dlName;
  final String? dlValidUpto;

  final String? dateOfBirth;
  final String? aadharNumber;
  final String? aadharStatus;
  final String? bankStatus;
  final String? profilePhotoUrl;
  final String? profilePhotoStatus;

  const Kyc({
    required this.professionalType,
    required this.overallStatus,
    required this.documents,
    this.panNumber,
    this.panStatus,
    this.panName,
    this.dlNumber,
    this.dlStatus,
    this.dlName,
    this.dlValidUpto,
    this.dateOfBirth,
    this.aadharNumber,
    this.aadharStatus,
    this.bankStatus,
    this.profilePhotoUrl,
    this.profilePhotoStatus,
  });

  bool get isVerified => overallStatus == KycStatus.verified;
  bool get isPanVerified => panStatus == KycStatus.verified;
  bool get isDlVerified => dlStatus == KycStatus.verified;
  bool get isDriver => professionalType == 'driver';

  /// Status for a given document type, resolved from the dedicated status
  /// fields first, then the embedded documents list.
  String? statusForType(String type) {
    switch (type) {
      case KycDocType.pan:
        return panStatus ?? _docStatus(type);
      case KycDocType.drivingLicense:
        return dlStatus ?? _docStatus(type);
      case KycDocType.aadhar:
        return aadharStatus ?? _docStatus(type);
      case KycDocType.bankAccount:
        return bankStatus ?? _docStatus(type);
      case KycDocType.profilePhoto:
        return profilePhotoStatus ?? _docStatus(type);
      default:
        return _docStatus(type);
    }
  }

  String? _docStatus(String type) {
    for (final d in documents) {
      if (d.type == type) return d.status;
    }
    return null;
  }

  factory Kyc.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final docsRaw = root['documents'];
    final panData = root['panVerificationData'] is Map
        ? Map<String, dynamic>.from(root['panVerificationData'])
        : const {};
    final dlData = root['dlVerificationData'] is Map
        ? Map<String, dynamic>.from(root['dlVerificationData'])
        : const {};

    return Kyc(
      professionalType: (root['professionalType'] ?? 'driver').toString(),
      overallStatus: (root['overallStatus'] ?? KycStatus.incomplete).toString(),
      documents: docsRaw is List
          ? docsRaw
              .whereType<Map>()
              .map((e) => KycDocument.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      panNumber: root['panNumber']?.toString(),
      panStatus: root['panStatus']?.toString(),
      panName: panData['fullName']?.toString() ?? panData['name']?.toString(),
      dlNumber: root['dlNumber']?.toString(),
      dlStatus: root['dlStatus']?.toString(),
      dlName: dlData['name']?.toString(),
      dlValidUpto: dlData['validUpto']?.toString() ?? dlData['validTill']?.toString(),
      dateOfBirth: root['dateOfBirth']?.toString(),
      aadharNumber: root['aadharNumber']?.toString(),
      aadharStatus: root['aadharStatus']?.toString(),
      bankStatus: root['bankStatus']?.toString(),
      profilePhotoUrl: root['profilePhotoUrl']?.toString(),
      profilePhotoStatus: root['profilePhotoStatus']?.toString(),
    );
  }
}

/// Required documents for a professional type (backend `getRequiredDocuments`).
class RequiredDocuments {
  final List<String> mandatory;
  final List<String> optional;

  const RequiredDocuments({required this.mandatory, required this.optional});

  factory RequiredDocuments.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    List<String> list(dynamic v) =>
        v is List ? v.map((e) => e.toString()).toList() : const [];
    return RequiredDocuments(
      mandatory: list(root['mandatory']),
      optional: list(root['optional']),
    );
  }
}

/// KYC completeness result (backend `checkKYCCompleteness`).
class KycCompleteness {
  final bool complete;
  final List<String> missing;
  final String status;

  const KycCompleteness({
    required this.complete,
    required this.missing,
    required this.status,
  });

  factory KycCompleteness.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return KycCompleteness(
      complete: root['complete'] == true,
      missing: root['missing'] is List
          ? (root['missing'] as List).map((e) => e.toString()).toList()
          : const [],
      status: (root['status'] ?? KycStatus.incomplete).toString(),
    );
  }
}

/// Result of a PAN/DL verification call.
class KycVerifyResult {
  final bool verified;
  final Kyc? kyc;
  final String? name;

  const KycVerifyResult({required this.verified, this.kyc, this.name});

  factory KycVerifyResult.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic> && json['verified'] == null
        ? json['data'] as Map<String, dynamic>
        : json;
    final data = root['data'] is Map ? Map<String, dynamic>.from(root['data']) : const {};
    return KycVerifyResult(
      verified: root['verified'] == true,
      kyc: root['kyc'] is Map
          ? Kyc.fromJson(Map<String, dynamic>.from(root['kyc']))
          : null,
      name: data['name']?.toString() ?? data['fullName']?.toString(),
    );
  }
}

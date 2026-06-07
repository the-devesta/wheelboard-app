/// Lorry Receipt (LR) models — mirror the backend `GenerateLRDto` (request) and
/// `LrService.getLR()` response shape from wheelboard-be
/// (`src/modules/trips/lr/lr.service.ts`).
///
/// Backend nested contract:
///   GenerateLRDto { consignor, consignee, cargo, charges }
///   getLR()       { lrNumber, lrDocumentUrl, generatedAt, consignor,
///                   consignee, cargo, charges, driverConfirmation }
library;

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

double? _toDoubleN(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

/// Consignor / consignee party — backend `ConsignorDto`.
class LrParty {
  final String name;
  final String address;
  final String? gstin;
  final String contactPerson;
  final String contactPhone;
  final String? email;

  const LrParty({
    required this.name,
    required this.address,
    this.gstin,
    required this.contactPerson,
    required this.contactPhone,
    this.email,
  });

  factory LrParty.fromJson(Map<String, dynamic> json) => LrParty(
        name: (json['name'] ?? '').toString(),
        address: (json['address'] ?? '').toString(),
        gstin: json['gstin']?.toString(),
        contactPerson: (json['contactPerson'] ?? '').toString(),
        contactPhone: (json['contactPhone'] ?? '').toString(),
        email: json['email']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        if (gstin != null && gstin!.isNotEmpty) 'gstin': gstin,
        'contactPerson': contactPerson,
        'contactPhone': contactPhone,
        if (email != null && email!.isNotEmpty) 'email': email,
      };
}

/// Cargo details — backend `CargoDto`.
class LrCargo {
  final String description;
  final double totalWeight;
  final double? totalQuantity;
  final double? declaredValue;
  final String? packagingType;
  final String? specialInstructions;

  const LrCargo({
    required this.description,
    required this.totalWeight,
    this.totalQuantity,
    this.declaredValue,
    this.packagingType,
    this.specialInstructions,
  });

  factory LrCargo.fromJson(Map<String, dynamic> json) => LrCargo(
        description: (json['description'] ?? '').toString(),
        totalWeight: _toDouble(json['totalWeight']),
        totalQuantity: _toDoubleN(json['totalQuantity']),
        declaredValue: _toDoubleN(json['declaredValue']),
        packagingType: json['packagingType']?.toString(),
        specialInstructions: json['specialInstructions']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'totalWeight': totalWeight,
        if (totalQuantity != null) 'totalQuantity': totalQuantity,
        if (declaredValue != null) 'declaredValue': declaredValue,
        if (packagingType != null && packagingType!.isNotEmpty)
          'packagingType': packagingType,
        if (specialInstructions != null && specialInstructions!.isNotEmpty)
          'specialInstructions': specialInstructions,
        'itemsList': const [],
      };
}

/// Freight charges — backend `LRChargesDto`.
/// `paymentMode` is one of: to-pay | paid | to-be-billed.
class LrCharges {
  final double freightAmount;
  final double gst;
  final double? otherCharges;
  final double totalAmount;
  final String paymentMode;

  const LrCharges({
    required this.freightAmount,
    required this.gst,
    this.otherCharges,
    required this.totalAmount,
    required this.paymentMode,
  });

  factory LrCharges.fromJson(Map<String, dynamic> json) => LrCharges(
        freightAmount: _toDouble(json['freightAmount']),
        gst: _toDouble(json['gst']),
        otherCharges: _toDoubleN(json['otherCharges']),
        totalAmount: _toDouble(json['totalAmount']),
        paymentMode: (json['paymentMode'] ?? 'to-pay').toString(),
      );

  Map<String, dynamic> toJson() => {
        'freightAmount': freightAmount,
        'gst': gst,
        if (otherCharges != null) 'otherCharges': otherCharges,
        'totalAmount': totalAmount,
        'paymentMode': paymentMode,
      };
}

/// Driver confirmation status embedded in the LR.
class LrDriverConfirmation {
  final String status; // pending | verified | rejected
  final String? verificationMethod; // checkbox | otp
  final DateTime? confirmedAt;
  final String? rejectionReason;
  final String? rejectionNotes;

  const LrDriverConfirmation({
    required this.status,
    this.verificationMethod,
    this.confirmedAt,
    this.rejectionReason,
    this.rejectionNotes,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';

  factory LrDriverConfirmation.fromJson(Map<String, dynamic> json) {
    final data = json['confirmationData'] as Map<String, dynamic>? ?? const {};
    return LrDriverConfirmation(
      status: (json['status'] ?? 'pending').toString(),
      verificationMethod: json['verificationMethod']?.toString(),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
      rejectionReason: data['rejectionReason']?.toString(),
      rejectionNotes: data['rejectionNotes']?.toString(),
    );
  }
}

/// Full LR detail returned by `GET /trips/:id/lr`.
class LrDetails {
  final String lrNumber;
  final String? lrDocumentUrl;
  final DateTime? generatedAt;
  final LrParty? consignor;
  final LrParty? consignee;
  final LrCargo? cargo;
  final LrCharges? charges;
  final LrDriverConfirmation? driverConfirmation;

  const LrDetails({
    required this.lrNumber,
    this.lrDocumentUrl,
    this.generatedAt,
    this.consignor,
    this.consignee,
    this.cargo,
    this.charges,
    this.driverConfirmation,
  });

  factory LrDetails.fromJson(Map<String, dynamic> json) {
    // Unwrap `{ data: {...} }` envelopes if present.
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    Map<String, dynamic>? sub(String key) =>
        root[key] is Map ? Map<String, dynamic>.from(root[key]) : null;

    return LrDetails(
      lrNumber: (root['lrNumber'] ?? '').toString(),
      lrDocumentUrl: root['lrDocumentUrl']?.toString(),
      generatedAt: root['generatedAt'] != null
          ? DateTime.tryParse(root['generatedAt'].toString())
          : null,
      consignor: sub('consignor') != null ? LrParty.fromJson(sub('consignor')!) : null,
      consignee: sub('consignee') != null ? LrParty.fromJson(sub('consignee')!) : null,
      cargo: sub('cargo') != null ? LrCargo.fromJson(sub('cargo')!) : null,
      charges: sub('charges') != null ? LrCharges.fromJson(sub('charges')!) : null,
      driverConfirmation: sub('driverConfirmation') != null
          ? LrDriverConfirmation.fromJson(sub('driverConfirmation')!)
          : null,
    );
  }
}

/// Request payload for `POST /trips/:id/lr/generate` and `PATCH /trips/:id/lr`.
class GenerateLrPayload {
  final LrParty consignor;
  final LrParty consignee;
  final LrCargo cargo;
  final LrCharges charges;

  const GenerateLrPayload({
    required this.consignor,
    required this.consignee,
    required this.cargo,
    required this.charges,
  });

  Map<String, dynamic> toJson() => {
        'consignor': consignor.toJson(),
        'consignee': consignee.toJson(),
        'cargo': cargo.toJson(),
        'charges': charges.toJson(),
      };
}

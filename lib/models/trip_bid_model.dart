/// A bid placed on a trip.
///
/// Mirrors the web `Bid`/`Bidder` shape produced by
/// `wheelboard-fe/src/lib/tripsTransform.ts → transformBackendTrip()`.
///
/// The backend embeds bids inside the trip document (`GET /trips/:tripId`):
/// ```json
/// {
///   "_id": "<bidId>",
///   "bidderId": {            // populated object OR a plain id string
///     "_id": "...", "email": "...",
///     "profile": { "firstName", "lastName", "phoneNumber",
///                  "experience", "avatar"/"profileImage",
///                  "rating", "totalTrips", "isVerified" }
///   },
///   "amount": 5000,
///   "notes": "…",
///   "status": "pending" | "accepted" | "rejected",
///   "timestamp": "2025-…"
/// }
/// ```
class TripBid {
  final String bidId;
  final String tripId;
  final String bidderId;
  final double bidAmount;
  final String message;
  final DateTime? createdAt;
  final String status;

  // ── Bidder profile ──
  final String name;
  final String avatar;
  final double rating;
  final int totalTrips;
  final bool isVerified;
  final String experience;
  final String phoneNumber;

  TripBid({
    required this.bidId,
    required this.tripId,
    required this.bidderId,
    required this.bidAmount,
    required this.message,
    required this.createdAt,
    required this.status,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.totalTrips,
    required this.isVerified,
    required this.experience,
    required this.phoneNumber,
  });

  // ── Backward-compatible getters (old flat field names) ──
  String get driverId => bidderId;
  String get driverImagePath => avatar;
  String get bidDescription => message;
  String get contactNumber => phoneNumber;
  DateTime? get dateEntered => createdAt;

  /// True when the bidder profile wasn't populated in the trip document and
  /// must be fetched separately (mirrors web `useTripById` enrichment).
  bool get needsEnrichment {
    final n = name.trim().toLowerCase();
    return bidderId.isNotEmpty &&
        bidderId != 'unknown-bidder' &&
        (n.isEmpty || n == 'unknown bidder' || n == 'unknown' ||
            phoneNumber.isEmpty || phoneNumber == 'Not available' ||
            avatar.isEmpty);
  }

  TripBid copyWith({
    String? name,
    String? avatar,
    double? rating,
    int? totalTrips,
    bool? isVerified,
    String? experience,
    String? phoneNumber,
  }) {
    return TripBid(
      bidId: bidId,
      tripId: tripId,
      bidderId: bidderId,
      bidAmount: bidAmount,
      message: message,
      createdAt: createdAt,
      status: status,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      isVerified: isVerified ?? this.isVerified,
      experience: experience ?? this.experience,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  /// Merge a `/users/:id/public-profile` response into this bid.
  /// Mirrors the enrichment block in `wheelboard-fe useTripById()`.
  TripBid mergeProfile(dynamic profileResponse) {
    if (profileResponse is! Map) return this;
    final root = profileResponse['data'] is Map
        ? Map<String, dynamic>.from(profileResponse['data'])
        : Map<String, dynamic>.from(profileResponse);
    final profile = root['profile'] is Map
        ? Map<String, dynamic>.from(root['profile'])
        : <String, dynamic>{};
    if (profile.isEmpty) return this;

    final email = root['email'] ?? profile['email'];
    final resolved = _resolveDisplayName(
      profile: profile,
      data: root,
      email: email,
      fallback: name,
    );

    return copyWith(
      name: (resolved.isNotEmpty && resolved != 'Unknown Bidder')
          ? resolved
          : name,
      avatar: (profile['profileImage'] ??
              profile['avatar'] ??
              (avatar.isEmpty ? null : avatar) ??
              '')
          .toString(),
      rating: _toDouble(profile['rating'], fallback: rating),
      totalTrips: _toInt(profile['totalTrips'], fallback: totalTrips),
      isVerified: _toBool(profile['isVerified'], fallback: isVerified),
      experience: profile['experience'] != null
          ? '${profile['experience']} years'
          : experience,
      phoneNumber:
          (profile['phoneNumber'] ?? root['phoneNumber'] ?? phoneNumber)
              .toString(),
    );
  }

  /// Parse a single embedded backend bid object.
  ///
  /// [tripId] is the parent trip id; [index] is used only as a fallback when
  /// the bid has no `_id`.
  factory TripBid.fromBackendBid(
    Map<String, dynamic> bid, {
    required String tripId,
    int index = 0,
  }) {
    final rawBidder = bid['bidderId'] ?? bid['bidder'];
    final bool isObject = rawBidder is Map;
    final Map<String, dynamic> bidderData =
        isObject ? Map<String, dynamic>.from(rawBidder) : <String, dynamic>{};
    final Map<String, dynamic> profile =
        bidderData['profile'] is Map
            ? Map<String, dynamic>.from(bidderData['profile'])
            : <String, dynamic>{};

    final String bidderId = isObject
        ? (bidderData['_id'] ?? bidderData['id'] ?? bidderData['userId'] ?? '')
            .toString()
        : (rawBidder is String ? rawBidder : (bid['bidderId'] ?? '').toString());

    final String name = _resolveDisplayName(
      profile: profile,
      data: bidderData,
      email: profile['email'] ?? bidderData['email'],
      fallback: bid['bidderName'],
    );

    final String avatar = (profile['profileImage'] ??
            profile['avatar'] ??
            bidderData['profileImage'] ??
            bidderData['avatar'] ??
            '')
        .toString();

    return TripBid(
      bidId: (bid['_id'] ?? bid['bidId'] ?? 'bid-$index').toString(),
      tripId: tripId,
      bidderId: bidderId,
      bidAmount: _toDouble(bid['amount'] ?? bid['bidAmount']),
      message: (bid['notes'] ?? bid['bidDescription'] ?? '').toString(),
      createdAt: _toDate(bid['timestamp'] ?? bid['createdAt'] ?? bid['dateEntered']),
      status: (bid['status'] ?? 'pending').toString(),
      name: name,
      avatar: avatar,
      rating: _toDouble(profile['rating'] ?? bidderData['rating'], fallback: 4.5),
      totalTrips: _toInt(profile['totalTrips'] ?? bidderData['totalTrips']),
      isVerified: _toBool(profile['isVerified'] ?? bidderData['isVerified'],
          fallback: true),
      experience: profile['experience'] != null
          ? '${profile['experience']} years'
          : '0 years',
      phoneNumber: (profile['phoneNumber'] ?? bidderData['phoneNumber'] ?? '')
          .toString(),
    );
  }

  /// Legacy flat-shape parser kept for any callers that still pass a flat map.
  factory TripBid.fromJson(Map<String, dynamic> json) {
    // If it looks like a backend embedded bid (has amount/bidderId), delegate.
    if (json.containsKey('amount') ||
        json['bidderId'] is Map ||
        json.containsKey('_id')) {
      return TripBid.fromBackendBid(json,
          tripId: (json['tripId'] ?? '').toString());
    }
    return TripBid(
      bidId: (json['bidId'] ?? '').toString(),
      tripId: (json['tripId'] ?? '').toString(),
      bidderId: (json['driverId'] ?? '').toString(),
      bidAmount: _toDouble(json['bidAmount']),
      message: (json['bidDescription'] ?? '').toString(),
      createdAt: _toDate(json['dateEntered']),
      status: (json['status'] ?? 'pending').toString(),
      name: (json['name'] ?? '').toString(),
      avatar: (json['imagePath'] ?? json['driverImagePath'] ?? '').toString(),
      rating: _toDouble(json['rating'], fallback: 4.5),
      totalTrips: _toInt(json['totalTrips']),
      isVerified: _toBool(json['isVerified'], fallback: true),
      experience: (json['experience'] ?? '0 years').toString(),
      phoneNumber: (json['contactNumber'] ?? '').toString(),
    );
  }

  // ── helpers ──
  static double _toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null || v.toString().isEmpty) return null;
    return DateTime.tryParse(v.toString());
  }

  /// Port of `resolveDisplayName` from tripsTransform.ts (simplified).
  static String _resolveDisplayName({
    Map<String, dynamic>? profile,
    Map<String, dynamic>? data,
    dynamic email,
    dynamic fallback,
  }) {
    final p = profile ?? {};
    final d = data ?? {};

    String? norm(dynamic v) {
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    final fromParts = [
      norm(p['firstName'] ?? d['firstName']),
      norm(p['lastName'] ?? d['lastName']),
    ].whereType<String>().join(' ').trim();

    final candidates = <String?>[
      fromParts.isEmpty ? null : fromParts,
      norm(p['fullName']),
      norm(p['name']),
      norm(p['userName']),
      norm(p['companyName']),
      norm(p['driverName']),
      norm(p['professionalName']),
      norm(d['fullName']),
      norm(d['name']),
      norm(d['driverName']),
    ];

    for (final c in candidates) {
      if (c != null && c.isNotEmpty) return c;
    }

    final emailStr = norm(email);
    if (emailStr != null && emailStr.contains('@')) {
      final part = emailStr.split('@').first;
      if (part.isNotEmpty) return part;
    }

    return norm(fallback) ?? 'Unknown Bidder';
  }
}

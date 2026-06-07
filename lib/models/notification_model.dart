class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final String createdDate;
  // Backend sends 'info' | 'success' | 'warning' | 'error'
  final String type;

  /// Rich payload the backend attaches to a notification. For trip-assignment
  /// notifications this carries the LR OTP, route, earnings, distance, payment
  /// info and tripId — mirroring the web `notification.data` object.
  final Map<String, dynamic> data;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdDate,
    this.type = 'info',
    this.data = const {},
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Backend (NestJS) uses _id and createdAt — map both naming conventions
    final id = (json['_id'] ?? json['id'] ?? json['notificationId'] ?? '') as String;
    final created = (json['createdAt'] ?? json['createdDate'] ?? '') as String;
    return NotificationModel(
      notificationId: id,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] == true || json['isRead'] == 'true',
      createdDate: created,
      type: json['type'] as String? ?? 'info',
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdDate': createdDate,
      'type': type,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? message,
    bool? isRead,
    String? createdDate,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdDate: createdDate ?? this.createdDate,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  // ── trip-assignment payload accessors (mirror web notification.data.*) ─────
  String? get dataType => data['type']?.toString();

  /// The LR start code — `lrOtp` preferred, falling back to `otp`.
  String? get lrOtp {
    final v = data['lrOtp'] ?? data['otp'];
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  String? get lrNumber {
    final s = data['lrNumber']?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  String? get tripId {
    final s = (data['tripId'] ?? data['id'])?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  String? get fromLocation => data['from']?.toString();
  String? get toLocation => data['to']?.toString();
  String? get distance => data['distance']?.toString();
  String? get otpExpiry => data['otpExpiry']?.toString();
  String? get paymentTiming => data['paymentTiming']?.toString();
  String? get paymentMode => data['paymentMode']?.toString();
  bool get otpVerified => data['otpVerified'] == true || data['otpVerified'] == 'true';
  String? get lrStatus => data['lrStatus']?.toString();

  num? get estimatedEarnings => _num(data['estimatedEarnings']);
  num? get platformFee => _num(data['platformFee']);

  static num? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString().replaceAll(',', ''));
  }

  /// A "rich" trip-assignment notification — mirrors the web check:
  /// `data.type startsWith 'trip_assignment' || data.lrOtp || data.otp`.
  bool get isTripAssignment =>
      (dataType?.startsWith('trip_assignment') ?? false) || lrOtp != null;

  String get formattedDate {
    try {
      final date = DateTime.parse(createdDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
        }
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return createdDate;
    }
  }
}

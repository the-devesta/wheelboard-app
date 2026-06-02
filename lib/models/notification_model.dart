class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final String createdDate;
  // Backend sends 'info' | 'success' | 'warning' | 'error'
  final String type;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdDate,
    this.type = 'info',
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
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdDate: createdDate ?? this.createdDate,
      type: type ?? this.type,
    );
  }

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

class CalendarEvent {
  final String eventId;
  final String createdBy;
  final int partnerId;
  final String userId;
  final String eventName;
  final String note;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final bool isActive;

  CalendarEvent({
    required this.eventId,
    required this.createdBy,
    required this.partnerId,
    required this.userId,
    required this.eventName,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.isActive,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['eventId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      partnerId: json['partnerId'] ?? 0,
      userId: json['userId'] ?? '',
      eventName: json['eventName'] ?? '',
      note: json['note'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      category: json['category'] ?? 'Trip',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'createdBy': createdBy,
      'partnerId': partnerId,
      'userId': userId,
      'eventName': eventName,
      'note': note,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category,
      'isActive': isActive,
    };
  }
}


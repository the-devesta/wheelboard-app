/// Calendar event — a 1:1 mirror of the backend `mapEvent` output
/// (`wheelboard-be/src/modules/calendar/calendar.service.ts`) and the FE
/// `CalendarEvent` type (`wheelboard-fe/src/lib/calendarApi.ts`).
///
/// Shape: `{ id, title, description, startDate, endDate, type, status, metadata }`.
/// The old `{ eventId, eventName, note, startTime, endTime, category, isActive }`
/// shape was wrong (the app sent/parsed fields the backend never used, which is
/// why the calendar never loaded) — those names are kept only as compatibility
/// getters so any remaining caller keeps compiling.
class CalendarEvent {
  final String id;
  final String title;
  final String description;

  /// Raw ISO strings exactly as returned by the backend. Kept as strings so the
  /// day-grid match mirrors the web (`startDate.startsWith('YYYY-MM-DD')`) and is
  /// immune to timezone parsing drift.
  final String startDate;
  final String endDate;

  final String type; // availability | trip | job | reminder
  final String status; // active | cancelled | completed
  final Map<String, dynamic> metadata;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDate,
    required this.endDate,
    this.type = 'availability',
    this.status = 'active',
    this.metadata = const {},
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id']?.toString() ?? json['eventId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['eventName']?.toString() ?? '',
      description:
          json['description']?.toString() ?? json['note']?.toString() ?? '',
      startDate:
          json['startDate']?.toString() ?? json['startTime']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? json['endTime']?.toString() ?? '',
      type: (json['type'] ?? json['category'] ?? 'availability').toString(),
      status: (json['status'] ??
              ((json['isActive'] == false) ? 'cancelled' : 'active'))
          .toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }

  // ── Parsed helpers ──────────────────────────────────────────────────────────

  /// Local-time parse of [startDate] (for display only).
  DateTime? get start => DateTime.tryParse(startDate)?.toLocal();
  DateTime? get end => DateTime.tryParse(endDate)?.toLocal();

  /// `YYYY-MM-DD` date key from the raw start string — used to match a day cell.
  String get dateKey =>
      startDate.contains('T') ? startDate.split('T').first : startDate;

  bool get isAvailability => type.toLowerCase() == 'availability';
  bool get isTrip => type.toLowerCase() == 'trip';
  bool get isJob => type.toLowerCase() == 'job';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// `HH:mm` of the start time, or empty when the raw string has no time part.
  String get startClock => _clock(startDate);
  String get endClock => _clock(endDate);

  static String _clock(String iso) {
    if (!iso.contains('T')) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── Backward-compat getters (legacy field names) ──────────────────────────
  String get eventName => title;
  String get note => description;
  DateTime get startTime => start ?? DateTime.now();
  DateTime get endTime => end ?? DateTime.now();
  String get category => type;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'type': type,
        'status': status,
        'metadata': metadata,
      };
}

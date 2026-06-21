import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../models/Professional/calendar_event_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Calendar controller — a 1:1 mirror of the FE `calendarApi`
/// (`wheelboard-fe/src/lib/calendarApi.ts`):
///   GET  /calendar/events?month=&year=   → list
///   GET  /calendar/stats?month=&year=    → { totalEventsScheduled, totalActiveDays, thisMonthAvailability }
///   POST /calendar/events                → create
///   PATCH/DELETE /calendar/events/:id    → update / delete
///
/// Drives the "My Calendar" availability board: the professional marks days as
/// Available/Unavailable (and optional trip/job events); the data is exposed to
/// company-transport & business users who view the professional's calendar.
class CalendarController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var events = <CalendarEvent>[].obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Stats (mirrors web CalendarStats).
  var totalEventsScheduled = 0.obs;
  var totalActiveDays = 0.obs;
  var thisMonthAvailability = 0.obs;

  // Currently-viewed month (first day) + the selected day key ('YYYY-MM-DD').
  late final Rx<DateTime> currentMonth;
  var selectedDateKey = ''.obs;

  CalendarController() {
    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1).obs;
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  int get _month => currentMonth.value.month;
  int get _year => currentMonth.value.year;

  /// Fetch events + stats for the current month in parallel (web `fetchData`).
  Future<void> fetchData() async {
    if (AuthService.to.currentUserId.isEmpty) {
      events.value = [];
      return;
    }
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final results = await Future.wait([
        _fetchEvents(),
        _fetchStats(),
      ]);
      events.value = results.first as List<CalendarEvent>;
    } on DioException catch (e) {
      hasError.value = true;
      errorMessage.value = _msg(e, 'Unable to load calendar');
      AppLogger.d('⚠️ Calendar load failed: $e');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unable to load calendar';
      AppLogger.d('⚠️ Calendar load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CalendarEvent>> _fetchEvents() async {
    final raw = await ApiClient.instance.get<dynamic>(
      ApiEndpoints.calendar.events,
      queryParameters: {'month': _month, 'year': _year},
    );
    final list = raw is List
        ? raw
        : (raw is Map ? (raw['data'] ?? raw['events'] ?? const []) : const []);
    return (list as List)
        .whereType<Map<String, dynamic>>()
        .map(CalendarEvent.fromJson)
        .toList();
  }

  Future<void> _fetchStats() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.calendar.stats,
        queryParameters: {'month': _month, 'year': _year},
      );
      final data = raw is Map
          ? (raw['data'] is Map ? raw['data'] as Map : raw)
          : const {};
      totalEventsScheduled.value =
          (data['totalEventsScheduled'] as num?)?.toInt() ?? 0;
      totalActiveDays.value = (data['totalActiveDays'] as num?)?.toInt() ?? 0;
      thisMonthAvailability.value =
          (data['thisMonthAvailability'] as num?)?.toInt() ?? 0;
    } catch (e) {
      AppLogger.d('ℹ️ Calendar stats skipped: $e');
    }
  }

  // ── Month navigation ────────────────────────────────────────────────────────
  void goToPrevMonth() {
    currentMonth.value =
        DateTime(currentMonth.value.year, currentMonth.value.month - 1, 1);
    selectedDateKey.value = '';
    fetchData();
  }

  void goToNextMonth() {
    currentMonth.value =
        DateTime(currentMonth.value.year, currentMonth.value.month + 1, 1);
    selectedDateKey.value = '';
    fetchData();
  }

  void selectDate(String dateKey) => selectedDateKey.value = dateKey;

  /// Events whose start date falls on [dateKey] ('YYYY-MM-DD').
  List<CalendarEvent> eventsForKey(String dateKey) =>
      events.where((e) => e.dateKey == dateKey).toList();

  /// `active` when the day has an active availability event (web grid green).
  bool isActiveDay(String dateKey) => eventsForKey(dateKey)
      .any((e) => e.isAvailability && e.isActive);

  /// `inactive` when the day has a cancelled availability event (web grid grey).
  bool isInactiveDay(String dateKey) => eventsForKey(dateKey)
      .any((e) => e.isAvailability && e.isCancelled);

  // ── Mutations ───────────────────────────────────────────────────────────────

  /// POST /calendar/events — create from an already-built web-parity payload
  /// (`{ title, description?, startDate, endDate, type, status?, metadata? }`).
  Future<bool> createEvent(Map<String, dynamic> payload) async {
    return _mutate(() => ApiClient.instance
        .post<dynamic>(ApiEndpoints.calendar.createEvent, data: payload));
  }

  /// PATCH /calendar/events/:id.
  Future<bool> updateEvent(String id, Map<String, dynamic> payload) async {
    return _mutate(() => ApiClient.instance
        .patch<dynamic>(ApiEndpoints.calendar.updateEvent(id), data: payload));
  }

  /// Mark a day available/unavailable — the core availability feature.
  Future<bool> markAvailability(DateTime date, bool isActive) async {
    final iso = DateTime.utc(date.year, date.month, date.day).toIso8601String();
    return createEvent({
      'title': isActive ? 'Available' : 'Unavailable',
      'startDate': iso,
      'endDate': iso,
      'type': 'availability',
      'status': isActive ? 'active' : 'cancelled',
    });
  }

  /// DELETE /calendar/events/:id.
  Future<bool> deleteEvent(String id) async {
    try {
      await ApiClient.instance
          .delete<dynamic>(ApiEndpoints.calendar.deleteEvent(id));
      SnackBarHelper.success('Event deleted');
      await fetchData();
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, 'Failed to delete event'));
      return false;
    } catch (e) {
      SnackBarHelper.error('Failed to delete event');
      return false;
    }
  }

  Future<bool> _mutate(Future<dynamic> Function() request) async {
    try {
      isSaving.value = true;
      if (AuthService.to.currentUserId.isEmpty) {
        SnackBarHelper.error('Please login to update your calendar');
        return false;
      }
      await request();
      await fetchData();
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, 'Failed to save event'));
      return false;
    } catch (e) {
      SnackBarHelper.error('Failed to save event: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> refreshEvents() => fetchData();

  // ── Legacy compatibility (orphaned CalendarInactive screen) ────────────────
  /// Old typed-event signature, re-expressed as a web-parity create.
  Future<bool> saveEvent({
    required String eventName,
    required DateTime startTime,
    required DateTime endTime,
    required String note,
    required String category,
    required bool isActive,
  }) async {
    final type = category.toLowerCase();
    return createEvent({
      'title': eventName,
      'description': note,
      'startDate': startTime.toIso8601String(),
      'endDate': endTime.toIso8601String(),
      'type': type == 'job' ? 'job' : 'trip',
      'status': isActive ? 'active' : 'cancelled',
    });
  }

  String _msg(DioException e, String fallback) =>
      e.error is ApiException ? (e.error as ApiException).message : fallback;
}

import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../models/Professional/calendar_event_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class CalendarController extends GetxController {
  var isLoading = false.obs;
  var events = <CalendarEvent>[].obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  /// Fetch calendar events for current user
  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final authService = AuthService.to;
      final userId = authService.currentUserId;

      if (userId.isEmpty) {
        AppLogger.d("⚠️ User not logged in, cannot fetch events");
        // Silently handle - just show empty calendar
        events.value = [];
        return;
      }

      AppLogger.d("📅 Fetching calendar events for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getEventsByUserId}$userId',
        headers: {'UserId': userId, 'Accept': '*/*'},
      );

      AppLogger.d("📅 Events response status: ${response.statusCode}");
      AppLogger.d("📅 Events response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final List data = json.decode(response.body);
          events.value = data.map((e) => CalendarEvent.fromJson(e)).toList();
          AppLogger.d("✅ Fetched ${events.length} calendar events");
          hasError.value = false;
        } catch (e) {
          // If response is not valid JSON, treat as empty
          AppLogger.d("⚠️ Invalid JSON response, treating as empty: $e");
          events.value = [];
          hasError.value = false;
        }
      } else {
        // Silently handle error - just show empty calendar
        AppLogger.d(
          "⚠️ Failed to fetch events: ${response.statusCode} - Handling silently",
        );
        events.value = [];
        hasError.value = true;
        errorMessage.value = 'Unable to load events';
        // Don't show error message to user - just show empty calendar
      }
    } catch (e) {
      // Silently handle error - just show empty calendar
      AppLogger.d("⚠️ Error fetching calendar events (handled silently): $e");
      events.value = [];
      hasError.value = true;
      errorMessage.value = 'Unable to load events';
      // Don't show error message to user - just show empty calendar
    } finally {
      isLoading.value = false;
    }
  }

  /// Save calendar event
  Future<bool> saveEvent({
    required String eventName,
    required DateTime startTime,
    required DateTime endTime,
    required String note,
    required String category,
    required bool isActive,
  }) async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;

      if (userId.isEmpty) {
        SnackBarHelper.error("Please login to save events");
        return false;
      }

      // Generate eventId (proper UUID v4 format)
      final eventId = _generateEventId();

      // Build the event data exactly as the API expects (matching curl example)
      final requestData = {
        'eventId': eventId,
        'createdBy': userId,
        'partnerId': 0,
        'userId': userId,
        'eventName': eventName,
        'note': note,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'category': category,
        'isActive': isActive,
      };

      AppLogger.d("📅 Saving calendar event:");
      AppLogger.d("📅 Event ID (GUID): $eventId");
      AppLogger.d("📅 Request Data: ${json.encode(requestData)}");

      final response = await HttpHelper.postData(
        endpoint: API.saveCalendarEvent,
        data: requestData,
        headers: {
          'UserId': userId,
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      AppLogger.d("📅 Save event response status: ${response.statusCode}");
      AppLogger.d("📅 Save event response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['message'] != null ||
              responseData['success'] == true) {
            SnackBarHelper.success("Event saved successfully!");
            await fetchEvents(); // Refresh events
            return true;
          }
        } catch (e) {
          // If response is not JSON but status is 200, consider it success
          SnackBarHelper.success("Event saved successfully!");
          await fetchEvents(); // Refresh events
          return true;
        }
      } else {
        String errorMessage = "Failed to save event";
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? response.body;
        } catch (e) {
          errorMessage = response.body.isNotEmpty
              ? response.body
              : "Failed: ${response.statusCode}";
        }
        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error saving calendar event: $e");
      SnackBarHelper.error("Failed to save event: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }

    return false;
  }

  /// Generate proper UUID v4 format (GUID) - Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  String _generateEventId() {
    final random = Random();
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    // Generate UUID v4 format: 8-4-4-4-12 (hexadecimal)
    // Part 1: 8 hex digits
    final part1 = _generateHexSegment(8, random, timestamp);

    // Part 2: 4 hex digits
    final part2 = _generateHexSegment(4, random, timestamp);

    // Part 3: 4 hex digits starting with '4' (version 4)
    final part3 = '4${_generateHexSegment(3, random, timestamp)}';

    // Part 4: 4 hex digits with variant bits (8, 9, a, or b)
    final variant = ['8', '9', 'a', 'b'][random.nextInt(4)];
    final part4 = '$variant${_generateHexSegment(3, random, timestamp)}';

    // Part 5: 12 hex digits
    final part5 = _generateHexSegment(12, random, timestamp);

    return '$part1-$part2-$part3-$part4-$part5';
  }

  String _generateHexSegment(int length, Random random, int seed) {
    const hex = '0123456789abcdef';
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(hex[random.nextInt(16)]);
    }
    return buffer.toString();
  }

  /// Get events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Get event dates for calendar highlighting
  List<DateTime> getEventDates() {
    return events.map((event) {
      return DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
    }).toList();
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await fetchEvents();
  }
}

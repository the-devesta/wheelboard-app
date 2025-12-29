import 'dart:convert';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../models/notification_model.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_logger.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Fetch notifications for current user
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty) {
        AppLogger.d("⚠️ User not logged in, cannot fetch notifications");
        return;
      }

      AppLogger.d("🔔 Fetching notifications for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getNotifications}?userId=$userId',
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("🔔 Notifications response status: ${response.statusCode}");
      AppLogger.d("🔔 Notifications response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        notifications.value = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();
        AppLogger.d("✅ Fetched ${notifications.length} notifications");
      } else {
        AppLogger.d("❌ Failed to fetch notifications: ${response.statusCode}");
        SnackBarHelper.error("Failed to load notifications");
        notifications.value = [];
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching notifications: $e");
      SnackBarHelper.error("Failed to load notifications: ${e.toString()}");
      notifications.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final authService = AuthService.to;
      final token = authService.currentToken;

      AppLogger.d("🔔 Marking notification as read: $notificationId");

      final response = await HttpHelper.postData(
        endpoint: '${API.markNotificationRead}?notificationId=$notificationId',
        data: {},
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("🔔 Mark read response status: ${response.statusCode}");
      AppLogger.d("🔔 Mark read response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local state
        final index = notifications.indexWhere(
          (notif) => notif.notificationId == notificationId,
        );
        if (index != -1) {
          final updatedNotif = notifications[index].copyWith(isRead: true);
          final updatedList = List<NotificationModel>.from(notifications);
          updatedList[index] = updatedNotif;
          notifications.value = updatedList;
        }
        return true;
      } else {
        AppLogger.d(
          "❌ Failed to mark notification as read: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error marking notification as read: $e");
      return false;
    }
  }

  /// Get unread count
  int get unreadCount {
    return notifications.where((notif) => !notif.isRead).length;
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
}

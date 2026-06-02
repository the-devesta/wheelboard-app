import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/notification_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchNotifications());
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      AppLogger.d('🔔 Fetching notifications');

      // JWT on the request already identifies the user — no userId param needed
      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.notifications.list,
      );

      notifications.value =
          data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      AppLogger.d('✅ Fetched ${notifications.length} notifications');
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Failed to load notifications';
      AppLogger.e('❌ Error fetching notifications: $e');
      SnackBarHelper.error(msg);
      notifications.value = [];
    } catch (e) {
      AppLogger.e('❌ Error fetching notifications: $e');
      notifications.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    if (notificationId.isEmpty) return false;
    try {
      await ApiClient.instance.patch(
        ApiEndpoints.notifications.markRead(notificationId),
      );
      _updateLocal(notificationId, isRead: true);
      return true;
    } catch (e) {
      AppLogger.e('❌ Failed to mark notification as read: $e');
      return false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiClient.instance.post(ApiEndpoints.notifications.readAll);
      notifications.value = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    } catch (e) {
      AppLogger.e('❌ Failed to mark all as read: $e');
      SnackBarHelper.error('Failed to mark all as read');
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    if (notificationId.isEmpty) return false;
    try {
      await ApiClient.instance.delete(
        ApiEndpoints.notifications.delete(notificationId),
      );
      notifications.removeWhere((n) => n.notificationId == notificationId);
      return true;
    } catch (e) {
      AppLogger.e('❌ Failed to delete notification: $e');
      SnackBarHelper.error('Failed to delete notification');
      return false;
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> refreshNotifications() => fetchNotifications();

  void _updateLocal(String id, {required bool isRead}) {
    final idx = notifications.indexWhere((n) => n.notificationId == id);
    if (idx == -1) return;
    final updated = List<NotificationModel>.from(notifications);
    updated[idx] = updated[idx].copyWith(isRead: isRead);
    notifications.value = updated;
  }
}

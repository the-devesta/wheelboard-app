import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../widgets/custom_loader.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFFCD2D2),
            width: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: const CustomLoader(
              message: "Loading notifications...",
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    size: 40,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No notifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're all caught up!",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Read Count Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: controller.unreadCount > 0
                              ? const Color(0xFFFF6B6B).withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${controller.unreadCount} Unread',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: controller.unreadCount > 0
                                ? const Color(0xFFFF6B6B)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      controller.refreshNotifications();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFFFF6B6B),
                      size: 22,
                    ),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                color: const Color(0xFFFF6B6B),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return _buildNotificationCard(
                      notification: notification,
                      controller: controller,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel notification,
    required NotificationController controller,
  }) {
    final isUnread = !notification.isRead;
    
    return GestureDetector(
      onTap: () async {
        if (isUnread) {
          await controller.markAsRead(notification.notificationId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread 
                ? const Color(0xFFFF6B6B).withOpacity(0.3)
                : const Color(0xFFF3F4F6),
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? const Color(0xFFFF6B6B).withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isUnread
                      ? const Color(0xFFFF6B6B).withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getNotificationIcon(notification.title),
                  color: isUnread
                      ? const Color(0xFFFF6B6B)
                      : Colors.grey.shade600,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF1E1E1E),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('like') || lowerTitle.contains('liked')) {
      return Icons.favorite;
    } else if (lowerTitle.contains('application') || lowerTitle.contains('apply')) {
      return Icons.work;
    } else if (lowerTitle.contains('job')) {
      return Icons.business_center;
    } else if (lowerTitle.contains('message') || lowerTitle.contains('comment')) {
      return Icons.message;
    } else if (lowerTitle.contains('trip') || lowerTitle.contains('bid')) {
      return Icons.directions_car;
    } else {
      return Icons.notifications;
    }
  }
}


import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../controllers/Transport/notification_controller.dart';
import '../core/auth/auth_service.dart';
import '../core/auth/user_role.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../screens/CompanyServiceProvider/sp_notification_screen.dart';
import '../screens/CompanyTransport/notification_screen.dart';
import '../screens/Professional/Notification1/Notification1Screen.dart';
import '../utils/app_logger.dart';

/// Background isolate message handler — must be a top-level (or static)
/// function and annotated for AOT. The OS renders the tray entry from the
/// message's `notification` payload automatically; we only ensure Firebase is
/// initialised in this isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

/// Firebase Cloud Messaging wiring.
///
/// Server side: every in-app notification created by the backend
/// (`NotificationsService.createNotification`) already calls `pushToDevice`,
/// which sends an FCM message to the user's stored `deviceId`. This service
/// supplies that `deviceId` (the FCM token) and renders/route incoming pushes.
///
/// It is **defensive**: if the native Firebase config is not present yet
/// (`google-services.json` / `GoogleService-Info.plist` — see FCM_SETUP.md),
/// [init] simply logs and disables push so the rest of the app is unaffected.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _enabled = false;
  bool _initialised = false;
  String? _lastToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'wheelboard_default',
    'General Notifications',
    description: 'Trip, job, service and account notifications',
    importance: Importance.high,
  );

  /// Call once at startup (after `WidgetsFlutterBinding.ensureInitialized`).
  /// Never throws.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      AppLogger.w(
          '[Push] Firebase not configured — push disabled. Add native config '
          '(see FCM_SETUP.md). Reason: $e');
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Local notifications — used to show a tray entry while in the foreground
      // (FCM does not auto-display foreground messages on Android).
      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (resp) {
          final payload = resp.payload;
          if (payload != null && payload.isNotEmpty) {
            _routeFromData(_decode(payload));
          }
        },
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Permissions (iOS + Android 13+).
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _routeFromData(m.data));
      FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);

      // Tap that cold-launched the app from terminated state.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _routeFromData(initial.data),
        );
      }

      _enabled = true;
      AppLogger.d('[Push] FCM initialised');
    } catch (e) {
      AppLogger.w('[Push] init error: $e');
    }
  }

  /// Fetch the current FCM token and register it with the backend so pushes
  /// reach this device. Call after login and at startup when already logged in.
  Future<void> registerForCurrentUser() async {
    if (!_enabled) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) await _registerToken(token);
    } catch (e) {
      AppLogger.w('[Push] getToken failed: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    if (token == _lastToken) return;
    if (!AuthService.to.isLoggedIn) return;
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.notifications.registerDevice,
        data: {'deviceId': token},
      );
      _lastToken = token;
      AppLogger.d('[Push] device token registered');
    } catch (e) {
      AppLogger.w('[Push] token registration failed: $e');
    }
  }

  /// Clear the token server-side and locally (call on logout).
  Future<void> unregister() async {
    try {
      if (AuthService.to.isLoggedIn) {
        await ApiClient.instance.delete<dynamic>(
          ApiEndpoints.notifications.unregisterDevice,
        );
      }
      if (_enabled) await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // best-effort
    }
    _lastToken = null;
  }

  void _onForegroundMessage(RemoteMessage m) {
    // Keep the in-app list fresh.
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotifications();
    }

    final n = m.notification;
    final title =
        n?.title ?? m.data['title']?.toString() ?? 'Wheelboard';
    final body = n?.body ?? m.data['message']?.toString() ?? '';

    _local.show(
      m.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _encode(m.data),
    );
  }

  /// Open the role-appropriate notifications screen when a push is tapped.
  void _routeFromData(Map<String, dynamic> data) {
    if (!AuthService.to.isLoggedIn) return;
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotifications();
    }
    switch (AuthService.to.userRole) {
      case UserRole.business:
        Get.to(() => const SpNotificationScreen());
        break;
      case UserRole.professional:
        Get.to(() => const Notification1Screen());
        break;
      case UserRole.company:
      case UserRole.admin:
      case UserRole.superAdmin:
        Get.to(() => const NotificationScreen());
        break;
    }
  }

  Map<String, dynamic> _decode(String s) {
    try {
      final m = jsonDecode(s);
      return m is Map<String, dynamic> ? m : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _encode(Map<String, dynamic> data) {
    try {
      return jsonEncode(
        data.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      );
    } catch (_) {
      return '{}';
    }
  }
}

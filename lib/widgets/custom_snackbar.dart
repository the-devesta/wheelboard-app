// custom_snackbar.dart - Simplified SnackBar Utility
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

// ==================== SIMPLE SNACKBAR HELPER ====================
class SnackBarHelper {
  /// Safely show a GetX snackbar.
  ///
  /// Deferred to the next frame and guarded by an Overlay-context check so it
  /// can never throw "No Overlay widget found" when called during a route
  /// transition or before the first frame is mounted.
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration? duration,
  }) {
    void present() {
      // IMPORTANT: use ScaffoldMessenger ONLY — never `Get.snackbar`.
      //
      // GetX's `Get.snackbar` registers a snackbar in GetX's own queue. Once one
      // is open, the very next `Get.back()` (e.g. dismissing a confirm dialog)
      // calls `closeCurrentSnackbar()`, which crashes with
      // `LateInitializationError: Field '_controller' has not been initialized`
      // when the snackbar is still mid-init. That made Mark-Paid / Delete / any
      // confirm dialog throw. ScaffoldMessenger snackbars are independent of
      // GetX navigation, so `Get.back()` can never trip over them.
      final context = Get.context ?? Get.key.currentContext;
      if (context == null) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger
        ..clearSnackBars() // don't stack toasts
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: duration ?? const Duration(seconds: 3),
          ),
        );
    }

    // If we're mid-build/transition, wait for the frame to settle.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => present());
    } else {
      present();
    }
  }

  static void success(String message, {Duration? duration}) => _show(
        title: 'Success',
        message: message,
        backgroundColor: const Color(0xFF4CAF50),
        icon: Icons.check_circle,
        duration: duration,
      );

  static void error(String message, {Duration? duration}) => _show(
        title: 'Error',
        message: message,
        backgroundColor: const Color(0xFFE53935),
        icon: Icons.error,
        duration: duration ?? const Duration(seconds: 4),
      );

  static void info(String message, {Duration? duration}) => _show(
        title: 'Info',
        message: message,
        backgroundColor: const Color(0xFF1E88E5),
        icon: Icons.info,
        duration: duration,
      );

  static void warning(String message, {Duration? duration}) => _show(
        title: 'Warning',
        message: message,
        backgroundColor: const Color(0xFFFF8F00),
        icon: Icons.warning,
        duration: duration ?? const Duration(seconds: 4),
      );

  static void custom({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration? duration,
  }) =>
      _show(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
      );
}

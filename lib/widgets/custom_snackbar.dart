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
      // Overlay must exist before GetX can mount the snackbar.
      if (Get.overlayContext == null) return;
      // Avoid stacking duplicate snackbars during rapid failures.
      // closeAllSnackbars can crash if a queued snackbar's animation controller
      // is not yet initialized, so guard against that.
      if (Get.isSnackbarOpen) {
        try {
          Get.closeAllSnackbars();
        } catch (_) {}
      }
      Get.snackbar(
        title,
        message,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        icon: Icon(icon, color: Colors.white),
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        isDismissible: true,
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

// custom_snackbar.dart - Simplified SnackBar Utility
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==================== SIMPLE SNACKBAR HELPER ====================
class SnackBarHelper {
  // ✅ Success SnackBar
  static void success(String message, {Duration? duration}) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
    );
  }

  // ✅ Error SnackBar
  static void error(String message, {Duration? duration}) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xFFE53935),
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: duration ?? const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
    );
  }

  // ✅ Info SnackBar
  static void info(String message, {Duration? duration}) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: const Color(0xFF1E88E5),
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
    );
  }

  // ✅ Warning SnackBar
  static void warning(String message, {Duration? duration}) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: const Color(0xFFFF8F00),
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: duration ?? const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
    );
  }

  // ✅ Loading SnackBar
  static void loading(String message) {
    Get.snackbar(
      'Loading',
      message,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      icon: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: false,
    );
  }

  // ✅ Custom SnackBar
  static void custom({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration? duration,
  }) {
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
}
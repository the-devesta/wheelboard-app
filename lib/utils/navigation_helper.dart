import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../controllers/main_wrapper_controller.dart';
import '../screens/Professional/main_wrapper.dart';
import '../screens/CompanyTransport/main_wrapper.dart';
import '../screens/CompanyServiceProvider/main_wrapper.dart';
import '../utils/app_logger.dart';

/// Helper class to navigate to appropriate wrapper based on user type
class NavigationHelper {
  /// Navigate to the correct main wrapper based on user type
  static void navigateToMainWrapper() {
    final authService = AuthService.to;
    final userType = authService.currentUserType;

    AppLogger.d("🧭 Navigation Helper - User Type: $userType");

    // Navigate based on user type
    if (userType == "Professional" || userType == "professional") {
      Get.offAll(() => const ProfessionalMainWrapper());
    } else if (userType == "Transport" || userType == "transport") {
      Get.offAll(() => const CompanyTransportMainWrapper());
    } else if (userType == "Service Provider" ||
        userType == "service provider") {
      Get.offAll(() => const CompanyServiceProviderMainWrapper());
    } else {
      // Default fallback - you can change this to your preferred default

      Get.offAll(() => const ProfessionalMainWrapper());
    }
  }

  /// Get the appropriate wrapper widget based on user type
  static Widget getMainWrapper() {
    final authService = AuthService.to;
    final userType = authService.currentUserType;

    if (userType == "Professional" || userType == "professional") {
      return const ProfessionalMainWrapper();
    } else if (userType == "Transport" || userType == "transport") {
      return const CompanyTransportMainWrapper();
    } else if (userType == "Service Provider" ||
        userType == "service provider") {
      return const CompanyServiceProviderMainWrapper();
    } else {
      // Default fallback
      return const ProfessionalMainWrapper();
    }
  }

  /// Navigate to Trips tab in bottom navigation (index 2)
  static void navigateToTripsTab() {
    final authService = AuthService.to;
    final userType = authService.currentUserType;

    if (userType == "Transport" || userType == "transport") {
      // Use GetX controller to switch tabs without navigation
      try {
        final wrapperController = Get.find<MainWrapperController>();
        wrapperController.switchToTripsTab();
      } catch (e) {
        // If controller not found, navigate to main wrapper with trips tab
        Get.offAll(() => const CompanyTransportMainWrapper(initialIndex: 2));
      }
    }
  }
}

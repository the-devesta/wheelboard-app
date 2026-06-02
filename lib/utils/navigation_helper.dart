import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/auth/auth_service.dart' as core;
import '../core/auth/user_role.dart';
import '../core/navigation/app_routes.dart';
import '../controllers/Transport/main_wrapper_controller.dart';
import '../screens/Professional/main_wrapper.dart';
import '../screens/CompanyTransport/main_wrapper.dart';
import '../screens/CompanyServiceProvider/main_wrapper.dart';
import '../utils/app_logger.dart';

/// Helper class to navigate to appropriate wrapper based on user role.
///
/// Now uses [UserRole] enum and [AppRoutes] named routes,
/// matching the `normalizeRole()` pattern from wheelboard-fe.
class NavigationHelper {
  /// Navigate to the correct main wrapper based on the user's role.
  /// Prefers named routes when available, falls back to direct navigation.
  static void navigateToMainWrapper() {
    final auth = core.AuthService.to;
    final role = auth.userRole;

    AppLogger.d('🧭 Navigation Helper - User Role: ${role.value}');

    switch (role) {
      case UserRole.professional:
        Get.offAllNamed(AppRoutes.professionalHome);
        break;
      case UserRole.company:
        Get.offAllNamed(AppRoutes.companyHome);
        break;
      case UserRole.business:
        Get.offAllNamed(AppRoutes.serviceProviderHome);
        break;
      case UserRole.admin:
      case UserRole.superAdmin:
        Get.offAllNamed(AppRoutes.companyHome);
        break;
    }
  }

  /// Get the appropriate wrapper widget based on user role.
  static Widget getMainWrapper() {
    final auth = core.AuthService.to;
    final role = auth.userRole;

    switch (role) {
      case UserRole.professional:
        return const ProfessionalMainWrapper();
      case UserRole.company:
        return const CompanyTransportMainWrapper();
      case UserRole.business:
        return const CompanyServiceProviderMainWrapper();
      case UserRole.admin:
      case UserRole.superAdmin:
        return const CompanyTransportMainWrapper();
    }
  }

  /// Get the named route for the user's home screen.
  static String homeRouteForCurrentUser() {
    final auth = core.AuthService.to;
    switch (auth.userRole) {
      case UserRole.professional:
        return AppRoutes.professionalHome;
      case UserRole.company:
        return AppRoutes.companyHome;
      case UserRole.business:
        return AppRoutes.serviceProviderHome;
      case UserRole.admin:
      case UserRole.superAdmin:
        return AppRoutes.companyHome;
    }
  }

  /// Navigate to Trips tab in bottom navigation (index 2).
  static void navigateToTripsTab() {
    final auth = core.AuthService.to;
    final role = auth.userRole;

    if (role == UserRole.company) {
      try {
        final wrapperController = Get.find<MainWrapperController>();
        wrapperController.switchToTripsTab();
      } catch (e) {
        Get.offAll(() => const CompanyTransportMainWrapper(initialIndex: 2));
      }
    }
  }

  /// Navigate to login, clearing all routes.
  static void navigateToLogin() {
    Get.offAllNamed(AppRoutes.onboarding);
  }
}

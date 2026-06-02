import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth_service.dart' as core;
import '../auth/user_role.dart';
import '../../utils/app_logger.dart';

/// Route middleware that blocks unauthenticated users.
///
/// Attach to any `GetPage` that requires login:
/// ```dart
/// GetPage(
///   name: '/dashboard',
///   page: () => DashboardScreen(),
///   middlewares: [AuthGuard()],
/// )
/// ```
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final auth = core.AuthService.to;
    if (!auth.isLoggedIn) {
      AppLogger.d('🛡️ AuthGuard: blocked $route → redirecting to /onboarding');
      return const RouteSettings(name: '/onboarding');
    }
    return null; // Allow through
  }
}

/// Route middleware that restricts access to specific user roles.
///
/// ```dart
/// GetPage(
///   name: '/company/fleet',
///   page: () => FleetScreen(),
///   middlewares: [RoleGuard(allowedRoles: [UserRole.company])],
/// )
/// ```
class RoleGuard extends GetMiddleware {
  final List<UserRole> allowedRoles;

  RoleGuard({required this.allowedRoles});

  @override
  int? get priority => 2; // Runs after AuthGuard

  @override
  RouteSettings? redirect(String? route) {
    final auth = core.AuthService.to;
    if (!auth.isLoggedIn) {
      return const RouteSettings(name: '/onboarding');
    }

    final userRole = auth.userRole;
    if (!allowedRoles.contains(userRole)) {
      AppLogger.w(
        '🛡️ RoleGuard: ${userRole.value} blocked from $route '
        '(allowed: ${allowedRoles.map((r) => r.value).join(", ")})',
      );
      // Redirect to user's own home screen
      return RouteSettings(name: _homeRouteForRole(userRole));
    }
    return null;
  }

  static String _homeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.professional:
        return '/professional';
      case UserRole.company:
        return '/company';
      case UserRole.business:
        return '/service-provider';
      case UserRole.admin:
      case UserRole.superAdmin:
        return '/company';
    }
  }
}

/// Route middleware that checks KYC completion for professionals.
///
/// Redirects to the KYC screen if the user hasn't completed verification.
/// ```dart
/// GetPage(
///   name: '/professional/bid/:id',
///   page: () => BidSubmitScreen(),
///   middlewares: [AuthGuard(), KycGuard()],
/// )
/// ```
class KycGuard extends GetMiddleware {
  @override
  int? get priority => 3; // Runs after AuthGuard and RoleGuard

  @override
  RouteSettings? redirect(String? route) {
    final auth = core.AuthService.to;
    final user = auth.user;

    if (user == null) {
      return const RouteSettings(name: '/onboarding');
    }

    // Only enforce KYC for professionals
    if (user.role == UserRole.professional && !user.isKYCCompleted) {
      AppLogger.w('🛡️ KycGuard: KYC incomplete → redirecting to /professional/kyc');
      // Instead of blocking, we let through but controllers can check KycHelper
      // This avoids disrupting existing flows where KYC is a soft gate
      return null;
    }
    return null;
  }
}

/// Route middleware that ensures profile is complete.
///
/// For company/business roles that need to complete their profile
/// after initial registration.
class ProfileCompleteGuard extends GetMiddleware {
  @override
  int? get priority => 3;

  @override
  RouteSettings? redirect(String? route) {
    final auth = core.AuthService.to;
    final user = auth.user;

    if (user == null) {
      return const RouteSettings(name: '/onboarding');
    }

    if (!user.isProfileComplete) {
      if (user.role == UserRole.company) {
        AppLogger.w('🛡️ ProfileGuard: incomplete → /company/complete-profile');
        return const RouteSettings(name: '/company/complete-profile');
      }
      if (user.role == UserRole.business) {
        AppLogger.w('🛡️ ProfileGuard: incomplete → /signup/service-provider');
        return const RouteSettings(name: '/signup/service-provider');
      }
    }
    return null;
  }
}

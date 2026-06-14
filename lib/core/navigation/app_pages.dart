import 'package:get/get.dart';

import '../../main.dart';
import '../../screens/auth/onboarding_screen.dart';
import '../../screens/auth/login.dart';
import '../../screens/auth/company_signup.dart';
import '../../screens/auth/professional_signup.dart';
import '../../screens/auth/service_provider_register_screen.dart';
import '../../screens/auth/forgot_password.dart';
import '../../screens/Professional/main_wrapper.dart';
import '../../screens/CompanyTransport/main_wrapper.dart';
import '../../screens/CompanyServiceProvider/main_wrapper.dart';
import '../../screens/CompanyServiceProvider/complete_profile_screen.dart';
import '../../screens/CompanyTransport/complete_company_profile.dart';
import '../auth/user_role.dart';
import 'app_routes.dart';
import 'route_guards.dart';

/// Central route configuration for `GetMaterialApp`.
///
/// Usage in `main.dart`:
/// ```dart
/// GetMaterialApp(
///   initialRoute: AppRoutes.splash,
///   getPages: AppPages.pages,
/// )
/// ```
class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    // ── Auth (public, no guards) ──────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const RegisterScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.companySignup,
      page: () => const Signup(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.professionalSignup,
      page: () => const ProfessionalRegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.serviceProviderSignup,
      page: () => const ServiceProviderRegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),

    // ── Main Wrappers (auth required, role-gated) ─────────────────────
    GetPage(
      name: AppRoutes.professionalHome,
      page: () => const ProfessionalMainWrapper(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: [UserRole.professional]),
        ProfileCompleteGuard(),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.companyHome,
      page: () => const CompanyTransportMainWrapper(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: [UserRole.company, UserRole.admin, UserRole.superAdmin]),
        ProfileCompleteGuard(),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.serviceProviderHome,
      page: () => const CompanyServiceProviderMainWrapper(),
      middlewares: [
        AuthGuard(),
        RoleGuard(allowedRoles: [UserRole.business]),
        ProfileCompleteGuard(),
      ],
      transition: Transition.fadeIn,
    ),

    // ── Profile Completion (auth required, no role guard) ─────────────
    GetPage(
      name: AppRoutes.companyCompleteProfile,
      page: () => CompanyCompleteProfile(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.serviceProviderCompleteProfile,
      page: () => const ServiceProviderCompleteProfileScreen(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
  ];
}

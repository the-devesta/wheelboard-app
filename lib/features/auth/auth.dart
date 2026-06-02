/// Feature barrel: Authentication
///
/// All auth-related exports consolidated in one place.
/// New code should import this barrel instead of individual files.
///
/// ```dart
/// import 'package:wheelboard/features/auth/auth.dart';
/// ```
library;

// Core auth (Phase 1)
export '../../core/auth/auth_models.dart';
export '../../core/auth/auth_service.dart';
export '../../core/auth/user_role.dart';

// Auth controllers
export '../../controllers/Transport/login_controller.dart';
export '../../controllers/Transport/signup_controller.dart';
export '../../controllers/Transport/professional_signup_controller.dart';

// Auth screens
export '../../screens/auth/login.dart';
export '../../screens/auth/onboarding_screen.dart';
export '../../screens/auth/company_signup.dart';
export '../../screens/auth/professional_signup.dart';
export '../../screens/auth/service_provider_login.dart';
export '../../screens/auth/otp_screen.dart';
export '../../screens/auth/verify_email.dart';
export '../../screens/auth/forgot_password.dart';
export '../../screens/auth/forget_password_screen.dart'
    hide ForgotPasswordScreen;

// Auth models
export '../../models/company_signupmodel.dart';
export '../../models/professional_signupmodel.dart';
export '../../models/service_provider_signup.dart';

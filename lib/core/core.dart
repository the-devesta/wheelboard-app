/// Core module barrel export.
///
/// Import this single file to access all core services:
/// ```dart
/// import 'package:wheelboard/core/core.dart';
/// ```
library;

export 'auth/auth_models.dart';
export 'auth/auth_service.dart';
export 'auth/user_role.dart';
export 'config/app_environment.dart';
export 'navigation/app_pages.dart';
export 'navigation/app_routes.dart';
export 'navigation/route_guards.dart';
export 'network/api_client.dart';
export 'network/api_endpoints.dart';
export 'network/api_exception.dart';
export 'storage/secure_session_manager.dart';

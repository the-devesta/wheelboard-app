import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../auth/auth_models.dart';
import '../auth/user_role.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../storage/secure_session_manager.dart';
import '../../services/push_notification_service.dart';
import '../../utils/app_logger.dart';

/// Centralized authentication service.
///
/// Mirrors `authAPI` + `tokenStorage` from `wheelboard-fe/src/lib/api.ts`
/// and `wheelboard-fe/src/contexts/AuthContext.tsx`.
///
/// All endpoints match the NestJS `AuthController` at `/api/auth/*`.
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final SecureSessionManager _storage;
  late final ApiClient _api;

  // ── Observable state (used by UI via Obx) ──────────────────────────────
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isLoading = false.obs;

  String _accessToken = '';

  bool get isLoggedIn => currentUser.value != null;
  bool get isAuthenticated => currentUser.value != null;
  AppUser? get user => currentUser.value;
  UserRole get userRole => currentUser.value?.role ?? UserRole.professional;
  String get userId => currentUser.value?.id ?? '';

  // ── Legacy-compatible convenience aliases ────────────────────────────────
  /// Alias for [userId] — preferred in existing code that used the legacy shim.
  String get currentUserId => userId;

  /// Current access token for use in headers.
  String get currentToken => _accessToken;

  /// Whether the current professional user is hired.
  bool get isUserHired => currentUser.value?.isHired ?? false;

  /// Role as a display string matching legacy userType values.
  String get currentUserType {
    switch (userRole) {
      case UserRole.professional:
        return 'Professional';
      case UserRole.company:
        return 'Transport';
      case UserRole.business:
        return 'Service Provider';
      case UserRole.admin:
      case UserRole.superAdmin:
        return 'Admin';
    }
  }

  bool get isUserLoggedIn => isLoggedIn;
  bool get isUserKYCCompleted => currentUser.value?.isKYCCompleted ?? false;

  // ── Role helpers ─────────────────────────────────────────────────────────
  bool get isProfessional => userRole == UserRole.professional;
  bool get isCompany => userRole == UserRole.company;
  bool get isServiceProvider => userRole == UserRole.business;
  bool get isAdmin =>
      userRole == UserRole.admin || userRole == UserRole.superAdmin;

  AuthService({SecureSessionManager? storage})
      : _storage = storage ?? SecureSessionManager();

  @override
  void onInit() {
    super.onInit();
    _api = ApiClient.instance;
    // Wire up 401 → clear session + navigate to login
    ApiClient.onUnauthenticated = () {
      _clearSession();
      Get.offAllNamed('/login');
    };
  }

  // ── Initialization (called from SplashScreen) ──────────────────────────

  /// Check if a valid session exists and restore user state.
  /// Called once at app startup (equivalent to AuthContext's initializeAuth).
  Future<void> initialize() async {
    try {
      // Migrate legacy SharedPreferences data (one-time)
      await _storage.migrateFromLegacy();

      // Try to restore session from secure storage
      final tokens = await _storage.getTokens();
      if (tokens == null || tokens.accessToken.isEmpty) {
        AppLogger.d('🔐 No stored session found');
        return;
      }

      // We have a token — try to fetch the profile to validate it
      _accessToken = tokens.accessToken;
      final storedUser = await _storage.getUser();
      if (storedUser != null) {
        currentUser.value = storedUser;
        AppLogger.d('🔐 Session restored for user: ${storedUser.id}');
      }

      // Optionally validate token against backend (non-blocking)
      _refreshProfile();
    } catch (e) {
      AppLogger.e('🔐 Session initialization failed', error: e);
      await _storage.clearAll();
    }
  }

  /// Background profile refresh to keep data in sync.
  Future<void> _refreshProfile() async {
    try {
      final data = await _api.get<Map<String, dynamic>>('/auth/profile');
      final user = AppUser.fromJson(data);
      currentUser.value = user;
      await _storage.setUser(user);
    } catch (e) {
      // If 401, onUnauthorized will handle it
      AppLogger.d('🔐 Background profile refresh failed: $e');
    }
  }

  // ── Login with password ────────────────────────────────────────────────
  // Matches: POST /api/auth/login { identifier, password }
  // Same as wheelboard-fe authAPI.login()

  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final data = await _api.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'identifier': identifier, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(data);
      await _persistSession(authResponse);

      AppLogger.d('✅ Login successful: ${authResponse.user.id}');
      return authResponse;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Request OTP ────────────────────────────────────────────────────────
  // Matches: POST /api/auth/request-otp { mobileNo }
  // Same as wheelboard-fe authAPI (via apiAdapter requestOtp)

  Future<String> requestOtp({required String mobileNo}) async {
    isLoading.value = true;
    try {
      final data = await _api.post<Map<String, dynamic>>(
        '/auth/request-otp',
        data: {'mobileNo': mobileNo},
      );
      return data['message']?.toString() ?? 'OTP sent successfully';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login with OTP ─────────────────────────────────────────────────────
  // Matches: POST /api/auth/login/otp { mobileNo, otp }
  // Same as wheelboard-fe apiAdapter.loginWithOtp()

  Future<AuthResponse> loginWithOtp({
    required String mobileNo,
    required String otp,
  }) async {
    isLoading.value = true;
    try {
      final data = await _api.post<Map<String, dynamic>>(
        '/auth/login/otp',
        data: {'mobileNo': mobileNo, 'otp': otp},
      );

      final authResponse = AuthResponse.fromJson(data);
      await _persistSession(authResponse);

      AppLogger.d('✅ OTP Login successful: ${authResponse.user.id}');
      return authResponse;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Register ───────────────────────────────────────────────────────────
  // Matches: POST /api/auth/register (RegisterDto)
  // Same as wheelboard-fe authAPI.register()

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    Map<String, dynamic>? profile,
    String? identityType,
    String? identityNumber,
    String? professionalType,
  }) async {
    isLoading.value = true;
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'role': role,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (profile != null) 'profile': profile,
        if (identityType != null) 'identityType': identityType,
        if (identityNumber != null) 'identityNumber': identityNumber,
        if (professionalType != null) 'professionalType': professionalType,
      };

      final data = await _api.post<Map<String, dynamic>>(
        '/auth/register',
        data: body,
      );

      final authResponse = AuthResponse.fromJson(data);
      await _persistSession(authResponse);

      AppLogger.d('✅ Registration successful: ${authResponse.user.id}');
      return authResponse;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────
  // Matches: POST /api/auth/logout (requires Bearer token)
  // Same as wheelboard-fe authAPI.logout()

  Future<void> logout() async {
    try {
      // Clear this device's push token while still authenticated.
      await PushNotificationService.instance.unregister();
      // Call server-side logout to invalidate session
      await _api.post<dynamic>('/auth/logout');
    } catch (e) {
      // Non-fatal: always clear local state even if server call fails
      AppLogger.d('⚠️ Server logout failed (non-fatal): $e');
    } finally {
      await _clearSession();
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────
  // Matches: POST /api/auth/forgot-password/request-otp
  // Same as wheelboard-fe authAPI.forgotPasswordRequestOtp()

  Future<String> forgotPasswordRequestOtp({required String mobileNo}) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/forgot-password/request-otp',
      data: {'mobileNo': mobileNo},
    );
    return data['message']?.toString() ?? 'OTP sent';
  }

  // Matches: POST /api/auth/forgot-password/verify-otp
  Future<String> forgotPasswordVerifyOtp({
    required String mobileNo,
    required String otp,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/forgot-password/verify-otp',
      data: {'mobileNo': mobileNo, 'otp': otp},
    );
    return data['resetToken']?.toString() ?? '';
  }

  // Matches: POST /api/auth/reset-password
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
    return data['message']?.toString() ?? 'Password reset successfully';
  }

  // ── Delete Account ────────────────────────────────────────────────────
  // Matches: DELETE /api/auth/delete-account { password, reason? }
  // Same as wheelboard-fe authAPI.deleteAccount()

  Future<String> deleteAccount({
    required String password,
    String? reason,
  }) async {
    final data = await _api.delete<Map<String, dynamic>>(
      '/auth/delete-account',
      data: {'password': password, if (reason != null) 'reason': reason},
    );
    await _clearSession();
    return data['message']?.toString() ?? 'Account deleted';
  }

  // ── Change Password ───────────────────────────────────────────────────
  // Matches: PUT /api/settings/account/password { currentPassword, newPassword }
  // Same as wheelboard-fe api.changePassword()
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final data = await _api.put<Map<String, dynamic>>(
      '/settings/account/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return data['message']?.toString() ?? 'Password updated successfully';
  }

  // ── KYC Verification ──────────────────────────────────────────────────
  // Matches: POST /api/auth/verify-pan, POST /api/auth/verify-dl

  Future<Map<String, dynamic>> verifyPan({required String panNumber}) async {
    return _api.post<Map<String, dynamic>>(
      '/auth/verify-pan',
      data: {'panNumber': panNumber},
    );
  }

  Future<Map<String, dynamic>> verifyDriverLicense({
    required String licenseNumber,
    required String dateOfBirth,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/auth/verify-dl',
      data: {'licenseNumber': licenseNumber, 'dateOfBirth': dateOfBirth},
    );
  }

  /// Update KYC status locally (called after KYC verification success).
  Future<void> updateKYCStatus(bool isKYCCompleted) async {
    if (currentUser.value == null) return;
    final updatedProfile = Map<String, dynamic>.from(currentUser.value!.profile);
    updatedProfile['isKYCCompleted'] = isKYCCompleted;
    updatedProfile['kycCompleted'] = isKYCCompleted;
    if (isKYCCompleted) updatedProfile['kycStatus'] = 'verified';
    final u = currentUser.value!;
    final updatedUser = AppUser(
      id: u.id,
      email: u.email,
      phoneNumber: u.phoneNumber,
      role: u.role,
      status: u.status,
      customId: u.customId,
      profile: updatedProfile,
      twoFactorEnabled: u.twoFactorEnabled,
      createdAt: u.createdAt,
      updatedAt: u.updatedAt,
    );
    currentUser.value = updatedUser;
    await _storage.setUser(updatedUser);
  }

  /// Re-fetch profile to sync latest state (e.g. after login flow checks).
  Future<void> refreshLoginStatus() async {
    await _refreshProfile();
  }

  // ── Get Profile ────────────────────────────────────────────────────────
  // Matches: GET /api/auth/profile
  // Same as wheelboard-fe authAPI.getProfile()

  Future<AppUser> getProfile() async {
    final data = await _api.get<Map<String, dynamic>>('/auth/profile');
    final user = AppUser.fromJson(data);
    currentUser.value = user;
    await _storage.setUser(user);
    return user;
  }

  // ── Helpers (extract error message from DioException) ──────────────────

  /// Extract a user-friendly error message from a caught exception.
  static String extractError(dynamic error) {
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).message;
    }
    if (error is ApiException) return error.message;
    if (error is DioException) {
      return ApiException.toFriendlyMessage(
        error.response?.data,
        error.response?.statusCode ?? 0,
      );
    }
    return 'Something went wrong. Please try again.';
  }

  // ── Private Helpers ────────────────────────────────────────────────────

  /// Persist tokens + user to secure storage and update reactive state.
  Future<void> _persistSession(AuthResponse response) async {
    await _storage.setTokens(response.tokens);
    await _storage.setUser(response.user);
    _accessToken = response.tokens.accessToken;
    currentUser.value = response.user;
    // Register this device for push now that we have a session (fire-and-forget).
    PushNotificationService.instance.registerForCurrentUser();
  }

  /// Clear all session data and reset reactive state.
  Future<void> _clearSession() async {
    await _storage.clearAll();
    _accessToken = '';
    currentUser.value = null;
    AppLogger.d('🔐 Session cleared');
  }

}

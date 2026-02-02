import 'dart:convert';

import 'package:get/get.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/screens/auth/onboarding_screen.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/utils/error_handler.dart';
import '../utils/session_manager.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_logger.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final SessionManager _sessionManager = SessionManager();

  // Observable variables
  final RxBool isLoggedIn = false.obs;
  final RxString authToken = ''.obs;
  final RxString userId = ''.obs;
  final RxString userType = ''.obs; // 'Professional' or 'Company'
  final RxBool isKYCCompleted = false.obs; // KYC completion status
  final RxBool isHired = false.obs; // Professional hired status

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      AppLogger.d("🔐 AuthService: Checking login status...");
      final token = await _sessionManager.getString("authToken");
      final user = await _sessionManager.getString("userId");
      final type = await _sessionManager.getString("userType");
      final kycStatus = await _sessionManager.getBool("isKYCCompleted");
      final hiredStatus = await _sessionManager.getBool("isHired");

      AppLogger.d("🔐 Token exists: ${token != null && token.isNotEmpty}");
      AppLogger.d("🔐 User exists: ${user != null && user.isNotEmpty}");
      AppLogger.d("🔐 KYC Status from session: ${kycStatus ?? false}");

      if (token != null &&
          token.isNotEmpty &&
          user != null &&
          user.isNotEmpty) {
        authToken.value = token;
        userId.value = user;
        userType.value = type ?? '';
        isKYCCompleted.value = kycStatus ?? false;
        isHired.value = hiredStatus ?? false;
        isLoggedIn.value = true;

        AppLogger.d("✅ User is already logged in: $user");
        AppLogger.d("✅ User Type: ${type ?? 'N/A'}");
        AppLogger.d("✅ KYC Completed: ${kycStatus ?? false}");
        AppLogger.d("✅ Is Hired: ${hiredStatus ?? false}");
        AppLogger.d("✅ AuthService state: isLoggedIn = ${isLoggedIn.value}");
      } else {
        authToken.value = '';
        userId.value = '';
        userType.value = '';
        isKYCCompleted.value = false;
        isHired.value = false;
        isLoggedIn.value = false;
        AppLogger.d("❌ User is not logged in");
      }
    } catch (e) {
      AppLogger.d("❌ Error checking login status: $e");
      isLoggedIn.value = false;
    }
  }

  /// Login user
  Future<bool> login({
    required String token,
    required String userId,
    required String userType,
    bool? isKYCCompleted,
    bool? isHired,
  }) async {
    try {
      AppLogger.d("==================================");
      AppLogger.d("🔐 AUTH SERVICE: LOGIN PROCESS");
      AppLogger.d("==================================");
      AppLogger.d(
        "🔐 Token: ${token.isNotEmpty ? 'Present (${token.substring(0, 20)}...)' : 'Empty'}",
      );
      AppLogger.d("🔐 UserId: $userId");
      AppLogger.d("🔐 UserType: $userType");
      AppLogger.d("==================================");

      // Store in session
      await _sessionManager.saveString("authToken", token);
      await _sessionManager.saveString("userId", userId);
      await _sessionManager.saveString("userType", userType);
      await _sessionManager.saveBool("isKYCCompleted", isKYCCompleted ?? false);
      await _sessionManager.saveBool("isHired", isHired ?? false);

      // Update observable variables
      authToken.value = token;
      this.userId.value = userId;
      this.userType.value = userType;
      this.isKYCCompleted.value = isKYCCompleted ?? false;
      this.isHired.value = isHired ?? false;
      isLoggedIn.value = true;

      AppLogger.d("✅ LOGIN SUCCESSFUL!");
      AppLogger.d("✅ User Type Saved: $userType");
      AppLogger.d("✅ User ID Saved: $userId");
      AppLogger.d("✅ KYC Completed: ${isKYCCompleted ?? false}");
      AppLogger.d("✅ Is Hired: ${isHired ?? false}");
      AppLogger.d("✅ Token Saved: ${token.substring(0, 20)}...");
      AppLogger.d("==================================");

      SnackBarHelper.success("Login successful! Welcome back.");
      return true;
    } catch (e) {
      AppLogger.d("❌ LOGIN ERROR: $e");
      SnackBarHelper.error("Login failed. Please try again.");
      return false;
    }
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      // Clear session data
      await _sessionManager.remove("authToken");
      await _sessionManager.remove("userId");
      await _sessionManager.remove("userType");
      await _sessionManager.remove("isKYCCompleted");
      await _sessionManager.remove("isHired");

      // Reset observable variables
      authToken.value = '';
      userId.value = '';
      userType.value = '';
      isKYCCompleted.value = false;
      isHired.value = false;
      isLoggedIn.value = false;

      AppLogger.d("✅ User logged out successfully");
      SnackBarHelper.info("You have been logged out successfully.");
      return true;
    } catch (e) {
      AppLogger.d("❌ Error during logout: $e");
      SnackBarHelper.error("Logout failed. Please try again.");
      return false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await HttpHelper.postWithQuery(
        endpoint: API.deleteAccount,
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
        queryParams: {"userId": Get.find<AuthService>().userId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        SnackBarHelper.success(data['message']);

        final success = await AuthService.to.logout();
        if (success) {
          Get.offAll(() => const RegisterScreen());
        }
      } else {
        final errorMessage = ErrorHandler.parseError(
          response.body,
          statusCode: response.statusCode,
        );
        SnackBarHelper.error(errorMessage);
      }
    } catch (e) {
      AppLogger.d("❌ Error during delete account: $e");
      SnackBarHelper.error("Delete failed. Please try again.");
    }
  }

  /// Get current auth token
  String get currentToken => authToken.value;

  /// Get current user ID
  String get currentUserId => userId.value;

  /// Get current user type
  String get currentUserType => userType.value;

  /// Check if user is logged in
  bool get isUserLoggedIn => isLoggedIn.value;

  /// Get KYC completion status
  bool get isUserKYCCompleted => isKYCCompleted.value;

  /// Get hired status (for professionals)
  bool get isUserHired => isHired.value;

  /// Force refresh login status
  Future<void> refreshLoginStatus() async {
    await _checkLoginStatus();
  }

  /// Update KYC status
  Future<void> updateKYCStatus(bool status) async {
    AppLogger.d("🔐 [AuthService] updateKYCStatus called");
    AppLogger.d("🔐 [AuthService] Current KYC status: ${isKYCCompleted.value}");
    AppLogger.d("🔐 [AuthService] New KYC status: $status");

    await _sessionManager.saveBool("isKYCCompleted", status);
    isKYCCompleted.value = status;

    AppLogger.d("✅ [AuthService] KYC Status Updated and Saved: $status");
    AppLogger.d(
      "🔐 [AuthService] isKYCCompleted.value is now: ${isKYCCompleted.value}",
    );

    // Verify it was saved correctly
    final savedStatus = await _sessionManager.getBool("isKYCCompleted");
    AppLogger.d(
      "🔐 [AuthService] Verified saved status in session: ${savedStatus ?? false}",
    );
  }
}

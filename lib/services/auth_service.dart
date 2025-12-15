import 'package:get/get.dart';
import '../utils/session_manager.dart';
import '../widgets/custom_snackbar.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final SessionManager _sessionManager = SessionManager();

  // Observable variables
  final RxBool isLoggedIn = false.obs;
  final RxString authToken = ''.obs;
  final RxString userId = ''.obs;
  final RxString userType = ''.obs; // 'Professional' or 'Company'
  final RxBool isKYCCompleted = false.obs; // KYC completion status

  @override
  void onInit() {
    super.onInit();
    // ✅ Don't auto-check on init, let splash screen control when to check
    // _checkLoginStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      print("🔐 AuthService: Checking login status...");
      final token = await _sessionManager.getString("authToken");
      final user = await _sessionManager.getString("userId");
      final type = await _sessionManager.getString("userType");
      final kycStatus = await _sessionManager.getBool("isKYCCompleted");

      print("🔐 Token exists: ${token != null && token.isNotEmpty}");
      print("🔐 User exists: ${user != null && user.isNotEmpty}");
      print("🔐 KYC Status from session: ${kycStatus ?? false}");

      if (token != null &&
          token.isNotEmpty &&
          user != null &&
          user.isNotEmpty) {
        authToken.value = token;
        userId.value = user;
        userType.value = type ?? '';
        isKYCCompleted.value = kycStatus ?? false;
        isLoggedIn.value = true;

        print("✅ User is already logged in: $user");
        print("✅ User Type: ${type ?? 'N/A'}");
        print("✅ KYC Completed: ${kycStatus ?? false}");
        print("✅ AuthService state: isLoggedIn = ${isLoggedIn.value}");
      } else {
        authToken.value = '';
        userId.value = '';
        userType.value = '';
        isKYCCompleted.value = false;
        isLoggedIn.value = false;
        print("❌ User is not logged in");
      }
    } catch (e) {
      print("❌ Error checking login status: $e");
      isLoggedIn.value = false;
    }
  }

  /// Login user
  Future<bool> login({
    required String token,
    required String userId,
    required String userType,
    bool? isKYCCompleted,
  }) async {
    try {
      print("==================================");
      print("🔐 AUTH SERVICE: LOGIN PROCESS");
      print("==================================");
      print(
        "🔐 Token: ${token.isNotEmpty ? 'Present (${token.substring(0, 20)}...)' : 'Empty'}",
      );
      print("🔐 UserId: $userId");
      print("🔐 UserType: $userType");
      print("==================================");

      // Store in session
      await _sessionManager.saveString("authToken", token);
      await _sessionManager.saveString("userId", userId);
      await _sessionManager.saveString("userType", userType);
      await _sessionManager.saveBool("isKYCCompleted", isKYCCompleted ?? false);

      // Update observable variables
      authToken.value = token;
      this.userId.value = userId;
      this.userType.value = userType;
      this.isKYCCompleted.value = isKYCCompleted ?? false;
      isLoggedIn.value = true;

      print("✅ LOGIN SUCCESSFUL!");
      print("✅ User Type Saved: $userType");
      print("✅ User ID Saved: $userId");
      print("✅ KYC Completed: ${isKYCCompleted ?? false}");
      print("✅ Token Saved: ${token.substring(0, 20)}...");
      print("==================================");

      SnackBarHelper.success("Login successful! Welcome back.");
      return true;
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
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

      // Reset observable variables
      authToken.value = '';
      userId.value = '';
      userType.value = '';
      isKYCCompleted.value = false;
      isLoggedIn.value = false;

      print("✅ User logged out successfully");
      SnackBarHelper.info("You have been logged out successfully.");
      return true;
    } catch (e) {
      print("❌ Error during logout: $e");
      SnackBarHelper.error("Logout failed. Please try again.");
      return false;
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

  /// Force refresh login status
  Future<void> refreshLoginStatus() async {
    await _checkLoginStatus();
  }

  /// Update KYC status
  Future<void> updateKYCStatus(bool status) async {
    await _sessionManager.saveBool("isKYCCompleted", status);
    isKYCCompleted.value = status;
    print("✅ KYC Status Updated: $status");
  }
}

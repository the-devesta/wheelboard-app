import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../models/user_profile_model.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class UserProfileController extends GetxController {
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Preference Toggles (Local State)
  var smsNotifications = true.obs;
  var emailNotifications = false.obs;
  var whatsappNotifications = true.obs;

  void toggleSmsNotifications(bool value) => smsNotifications.value = value;
  void toggleEmailNotifications(bool value) => emailNotifications.value = value;
  void toggleWhatsappNotifications(bool value) =>
      whatsappNotifications.value = value;

  /// Fetch user profile by userId
  Future<bool> fetchUserProfile(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      AppLogger.d("==================================");
      AppLogger.d("📡 Fetching User Profile");
      AppLogger.d("👉 UserId: $userId");
      AppLogger.d("==================================");

      // Get auth token
      final authService = AuthService.to;
      final token = authService.currentToken;

      // Build endpoint URL
      final endpoint = API.userProfile.replaceAll('{userId}', userId);

      // Make API call
      final response = await HttpHelper.getData(
        endpoint: endpoint,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("📥 Response Status: ${response.statusCode}");
      AppLogger.d("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        userProfile.value = UserProfileModel.fromJson(data);

        AppLogger.d("✅ Profile loaded successfully");
        AppLogger.d("👉 User Type: ${userProfile.value?.userType}");
        AppLogger.d("👉 Display Name: ${userProfile.value?.displayName}");
        AppLogger.d(
          "👉 KYC Status from API: ${userProfile.value?.isKYCCompleted}",
        );

        // Update AuthService KYC status
        if (userProfile.value?.isKYCCompleted != null) {
          AppLogger.d(
            "🔐 Updating AuthService KYC status to: ${userProfile.value!.isKYCCompleted!}",
          );
          await AuthService.to.updateKYCStatus(
            userProfile.value!.isKYCCompleted!,
          );
          AppLogger.d(
            "🔐 AuthService KYC status after update: ${AuthService.to.isUserKYCCompleted}",
          );
        } else {
          AppLogger.d(
            "⚠️ WARNING: Profile API did not return isKYCCompleted field!",
          );
        }

        AppLogger.d("==================================");

        return true;
      } else {
        final errorMsg = "Failed to load profile: ${response.statusCode}";
        errorMessage.value = errorMsg;
        AppLogger.d("❌ $errorMsg");
        SnackBarHelper.error("Failed to load profile");
        return false;
      }
    } catch (e) {
      final errorMsg = "Error loading profile: ${e.toString()}";
      errorMessage.value = errorMsg;
      AppLogger.d("❌ $errorMsg");
      SnackBarHelper.error("Error loading profile");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch current logged-in user's profile
  Future<bool> fetchCurrentUserProfile() async {
    final authService = AuthService.to;
    final userId = authService.currentUserId;

    if (userId.isEmpty) {
      errorMessage.value = "User not logged in";
      SnackBarHelper.error("Please login to view profile");
      return false;
    }

    return await fetchUserProfile(userId);
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    if (userProfile.value != null) {
      await fetchUserProfile(userProfile.value!.userId);
    }
  }

  /// Clear profile data
  void clearProfile() {
    userProfile.value = null;
    errorMessage.value = '';
  }
}
